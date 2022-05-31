require 'data_helpers'

module Arxiv
  # Remove trailing version from an arXiv paper uid
  def self.strip_version(uid)
    if m = uid.match(/(.+)v\d+/)
      m[1]
    else
      uid
    end
  end
end

module Arxiv::Import
  def self.papers(models, opts={})
    new_uids = []
    updated_uids = []
    ActiveRecord::Base.transaction do
      new_uids, updated_uids = self._import_papers(models, opts)
    end

    # Ensure Elasticsearch knows about these new/updated papers
    paper_uids = new_uids+updated_uids
    Search::Paper.index_by_uids(paper_uids) unless paper_uids.empty?

    [new_uids, updated_uids]
  end

  def self._import_papers(models, opts)
    syncdate = opts.delete(:syncdate) # For dating papers

    ### First pass: Add new Feeds.
    feed_uids = models.map { |m| m.categories }.flatten.uniq
    Feed.arxiv_import(feed_uids, opts)
    feeds_by_uid = Rails.cache.fetch(:feeds_by_uid) { map_models :uid, Feed.all }

    ### Second pass: Add new papers and handle updates.

    # Need to find and update existing papers, then bulk import new ones
    uids = models.map(&:id)
    existing_by_uid = map_models :uid, Paper.where(uid: uids).select('uid', 'update_date', 'pubdate')

    paper_columns = [:uid, :submitter, :title, :author_str, :abstract, :author_comments, :msc_class, :report_no, :journal_ref, :doi, :proxy, :license, :submit_date, :update_date, :versions_count, :pubdate, :abs_url, :pdf_url]
    paper_values = []

    version_columns = [:paper_uid, :position, :date, :size]
    version_values = []

    author_columns = [:paper_uid, :position, :fullname, :searchterm]
    author_values = []

    category_columns = [:paper_uid, :position, :feed_uid, :crosslist_date]
    category_values = []

    new_uids = []
    updated_uids = []

    models.each do |model|
      existing = existing_by_uid[model.id]

      if existing
        if existing.update_date >= model.versions[-1].date
          next # Already up to date
        else
          updated_uids << model.id
        end
      else
        new_uids << model.id
      end

      # Since the arXiv doesn't give us date of publication, only
      # date of submission, we may have to estimate it ourselves
      pubdate = if syncdate && !existing
        syncdate
      elsif existing
        existing.pubdate
      else
        Paper.estimate_pubdate(model.versions[0].date.utc)
      end

      paper_values << [
        model.id,
        model.submitter,
        model.title,
        model.author_str,
        model.abstract,
        model.comments,
        model.msc_class,
        model.report_no,
        model.journal_ref,
        model.doi,
        model.proxy,
        model.license,

        model.versions[0].date,
        model.versions[-1].date,
        model.versions.length,
        pubdate,
        "https://arxiv.org/abs/#{model.id}",
        "https://arxiv.org/pdf/#{model.id}.pdf",
      ]

      model.versions.each_with_index do |version, j|
        version_values << [
          model.id,
          j,
          version.date,
          version.size
        ]
      end

      model.authors.each_with_index do |author, j|
        author_values << [
          model.id,
          j,
          author,
          Author.make_searchterm(author)
        ]
      end

      model.categories.each_with_index do |feed_uid, j|
        category_values << [
          model.id,
          j,
          feed_uid,
          pubdate
        ]

        feeds_by_uid[feed_uid].new_paper_date!(pubdate)
      end
    end

    unless updated_uids.empty?
      Version.where(paper_uid: updated_uids).delete_all
      Author.where(paper_uid: updated_uids).delete_all
      Category.where(paper_uid: updated_uids).delete_all
      Paper.where(uid: updated_uids).delete_all
    end

    puts "Read #{models.length} items: #{new_uids.length} new, #{updated_uids.length} updated [#{models[0].id} to #{models[-1].id}]"
    result = Paper.import(paper_columns, paper_values, opts)
    unless result.failed_instances.empty?
      SciRate::Application.notify_error("Error importing papers: #{result.failed_instances.inspect}")
    end

    puts "Importing #{version_values.length} versions" unless version_values.empty?
    result = Version.import(version_columns, version_values, opts)
    unless result.failed_instances.empty?
      SciRate::Application.notify_error("Error importing versions #{result.failed_instances.inspect}")
    end

    puts "Importing #{author_values.length} authors" unless author_values.empty?
    result = Author.import(author_columns, author_values, opts)
    unless result.failed_instances.empty?
      SciRate::Application.notify_error("Error importing authors: #{result.failed_instances.inspect}")
    end

    puts "Importing #{category_values.length} categories" unless category_values.empty?
    result = Category.import(category_columns, category_values, opts)
    unless result.failed_instances.empty?
      SciRate::Application.notify_error("Error importing categories: #{result.failed_instances.inspect}")
    end

    # Ensure counter caches are recreated for updated papers
    Paper.where(uid: updated_uids).each do |paper|
      paper.refresh_comments_count!
      paper.refresh_scites_count!
    end

    # Return uids of the papers we imported/updated
    [new_uids, updated_uids]
  end
end
