require 'arxiv_import'

class PapersController < ApplicationController
  include PapersHelper

  def show
    @paper = Paper.where(uid: Arxiv.strip_version(params[:paper_uid]))
      .select('id', 'uid', 'title', 'abstract', 'scites_count', 'abs_url', 'pdf_url', 'update_date', 'submit_date', 'pubdate', 'author_comments', 'msc_class', 'report_no', 'journal_ref', 'doi', 'proxy', 'updated_at', 'author_str', 'versions_count', 'locked')
      .first!

    @feeds = @paper.feeds
      .select('fullname', 'uid')

    @authors = @paper.authors
      .select('fullname', 'searchterm')

    @sciters = @paper.sciters
      .select('fullname', 'username')

    @scited_by_uid = if current_user && @sciters.find { |s| s.username == current_user.username }
      { @paper.uid => true }
    else
      {}
    end

    @comments = find_comments_sorted_by_rating

    render 'papers/show'
  end

  def __quote(val)
    val.include?(' ') ? "(#{val})" : val
  end

  def search
    if not signed_in?
      redirect_to login_path, notice: "Please sign in."
    else
      basic = params[:q]
      advanced = params[:advanced]
      page = params[:page] ? params[:page].to_i : 1

      @search = Search::Paper::Query.new(basic, advanced)

      per_page = 70

      if !@search.query.empty?
        res = @search.run(from: (page-1)*per_page, size: per_page)

        papers_by_uid = map_models :uid, Paper.where(uid: res.documents.map(&:_id))

        @papers = res.documents.map do |doc|
          paper = papers_by_uid[doc[:_id]]

          paper.authors_fullname = doc.authors_fullname
          paper.authors_searchterm = doc.authors_searchterm
          paper.feed_uids = doc.feed_uids

          paper
        end

        @pagination = WillPaginate::Collection.new(page, per_page, @search.results.raw.hits.total)

        # Determine which folder we should have selected
        @folder_uid = @search.feed && (@search.feed.parent_uid || @search.feed.uid)

        @scited_by_uid = current_user.scited_by_uid(@papers) if current_user
      end

      render :search
    end
  end

  # Show the users who scited this paper
  def scites
    @paper = Paper.find_by_uid!(params[:paper_uid])
  end

  def next
    date = parse_date params
    feed = parse_feed params

    if feed.nil? && signed_in? && current_user.has_subscriptions?
       date ||= current_user.feed_last_paper_date

      papers = current_user.feed
    else
      feed ||= Feed.default
      date ||= feed.last_paper_date

      papers = feed.cross_listed_papers
    end

    ndate = next_date(papers, date)

    if ndate.nil?
      flash[:error] = "No future papers found!"
      ndate = date
    end

    redirect_to papers_path(params.merge(date: ndate, action: nil))
  end

  def prev
    date = parse_date params
    feed = parse_feed params

    if feed.nil? && signed_in? && current_user.has_subscriptions?
      date ||= current_user.feed_last_paper_date
      papers = current_user.feed
    else
      feed ||= Feed.default
      date ||= feed.last_paper_date

      papers = feed.cross_listed_papers
    end

    pdate = prev_date(papers, date)

    if pdate.nil?
      flash[:error] = "No past papers found!"
      pdate = date
    end

    redirect_to papers_path(params.merge(date: pdate, action: nil))
  end

  private

  def paper_id
    if has_versioning_suffix?(params[:id])
      params[:id].split(/v\d/)[0]
    else
      params[:id]
    end
  end

  def has_versioning_suffix?(id)
    id =~ /v\d/
  end

  # Less naive statistical comment sorting as per
  # http://www.evanmiller.org/how-not-to-sort-by-average-rating.html
  # Rating sorting is currently disabled
  def find_top_level_comments
    #total_votes = %Q{ NULLIF(cached_votes_up + cached_votes_down, 0) }
    #Comment.select(%Q{
    #    comments.*, COALESCE(
    #      ((cached_votes_up + 1.9208) / #{total_votes} - 1.96 * SQRT((cached_votes_up * cached_votes_down) / #{total_votes} + 0.9604) / #{total_votes} ) / (1 + 3.8416 / #{total_votes})
    #    , 0) AS ci_lower_bound
    #})
    Comment.where("paper_uid = ? AND ancestor_id IS NULL",
            @paper.uid)
    .order("created_at ASC")
    .includes(:last_change)
  end

  # We don't use voting information to order reply chains
  def find_comments_with_ancestors(ancestors)
    Comment.where(
      %Q{
        paper_uid = ? AND ancestor_id IN (?)
      }, @paper.uid, ancestors.map(&:id))
    .order("created_at ASC")
    .includes(:last_change)
  end

  def find_comments_sorted_by_rating
    toplevel_comments = find_top_level_comments
    comment_tree = find_comments_with_ancestors(toplevel_comments).group_by(&:ancestor_id)

    comments = []
    @has_children = {}
    toplevel_comments.each do |ancestor|
      comments << ancestor
      children = comment_tree[ancestor.id] || []

      p children

      if !children.empty? && children.any? { |c| !c.deleted && !c.hidden }
        @has_children[ancestor.id] = true
        comments += children
      end
    end

    comments
  end
end
