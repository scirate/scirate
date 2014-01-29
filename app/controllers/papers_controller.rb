class PapersController < ApplicationController
  include PapersHelper

  def show
    @paper = Paper.find_by_uid!(params[:id])

    @scited = current_user && current_user.scited_papers.where(id: @paper.id).exists?

    # Less naive statistical comment sorting as per
    # http://www.evanmiller.org/how-not-to-sort-by-average-rating.html
    @toplevel_comments = Comment.find_by_sql([
      "SELECT *, COALESCE(((cached_votes_up + 1.9208) / NULLIF(cached_votes_up + cached_votes_down, 0) - 1.96 * SQRT((cached_votes_up * cached_votes_down) / NULLIF(cached_votes_up + cached_votes_down, 0) + 0.9604) / NULLIF(cached_votes_up + cached_votes_down, 0)) / (1 + 3.8416 / NULLIF(cached_votes_up + cached_votes_down, 0)), 0) AS ci_lower_bound FROM comments WHERE paper_uid = ? AND ancestor_id IS NULL AND (hidden = FALSE OR user_id = ?) ORDER BY ci_lower_bound DESC;",
      @paper.uid,
      current_user ? current_user.id : nil
    ])

    @comment_tree = {}
    @paper.comments.where("ancestor_id IS NOT NULL").order("created_at ASC").each do |c|
      @comment_tree[c.ancestor_id] ||= []
      @comment_tree[c.ancestor_id] << c
    end

    @comments = []
    @toplevel_comments.each do |c|
      @comments << c
      @comments += @comment_tree[c.id]||[]
    end
  end

  def __quote(val)
    val.include?(' ') ? "(#{val})" : val
  end

  def search
    @query = params[:q] || ''

    params.each do |key, val|
      next if val.empty?

      case key
      when 'authors'
        authors = val.split(/,\s*/)
        @query += ' ' + authors.map { |au| "au:#{__quote(au)}" }.join(' ')
      when 'title'
        @query += " ti:#{__quote(val)}"
      when 'abstract'
        @query += " abs:#{__quote(val)}"
      when 'feed'
        @query += " feed:#{__quote(val)}"
      when 'general'
        @query += " #{val}"
      when 'order'
        @query += " order:#{val}" unless val == 'scites'
      end
    end

    @query = @query.strip

    @search = Paper::Search.new(@query)

    if !@query.empty?
      paper_ids = @search.run(page: params[:page], per_page: 20)

      @papers = Paper.where(id: paper_ids).includes(:authors, :feeds).order(@search.order_sql)

      # Pass the Sphinx pagination values through to will_paginate
      # A little hacky
      @papers = @papers.paginate(page: 1)
      @papers.total_entries = paper_ids.total_entries
      @papers.per_page = paper_ids.per_page
      @papers.current_page = paper_ids.current_page

      # Determine which folder we should have selected
      @folder_uid = @search.feed && (@search.feed.parent_uid || @search.feed.uid)

      @scited_ids = current_user.scited_papers.pluck(:id) if current_user
    end

    render :search
  end

  # Show the users who scited this paper
  def scites
    @paper = Paper.find_by_uid!(params[:id])
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
end
