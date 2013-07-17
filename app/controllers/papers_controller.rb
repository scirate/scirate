class PapersController < ApplicationController
  include PapersHelper

  def show
    @paper = Paper.find_by_identifier!(params[:id])

    @scited_papers = Set.new(current_user.scited_papers) if signed_in?

    # Less naive statistical comment sorting as per
    # http://www.evanmiller.org/how-not-to-sort-by-average-rating.html
    @comments = Comment.find_by_sql([
      "SELECT *, COALESCE(((cached_votes_up + 1.9208) / NULLIF(cached_votes_up + cached_votes_down, 0) - 1.96 * SQRT((cached_votes_up * cached_votes_down) / NULLIF(cached_votes_up + cached_votes_down, 0) + 0.9604) / NULLIF(cached_votes_up + cached_votes_down, 0)) / (1 + 3.8416 / NULLIF(cached_votes_up + cached_votes_down, 0)), 0) AS ci_lower_bound FROM comments WHERE paper_id = ? AND (hidden = FALSE OR user_id = ?) ORDER BY ci_lower_bound DESC;",
      @paper.id,
      current_user ? current_user.id : nil
    ])

    @categories = @paper.cross_listed_feeds.order("name").select("name").where("name != ?", @paper.feed.name)
  end

  def __search(query)
    @scited_papers = Set.new( current_user.scited_papers ) if signed_in?
    

    # TODO (Mispy): Proper parsing with precedence parentheses and such
    
    terms = { :or => {}, :and => {} }

    operator = :and
    query.split.each do |term|
      if term.upcase == "OR"
        operator = :or
      else
        operator = :and
      end

      if term.start_with?('au:')
        terms[operator][:author] = term.split('au:')[1]
      elsif term.start_with?('ti:')
        terms[operator][:title] = term.split('ti:')[1]
      elsif term.start_with?('abs:')
        terms[operator][:abstract] = term.split('ti:')[1]
      else
        Paper.instance_eval { searchable_columns }.each do |f|
          terms[:or][f] = term
        end
      end
    end

    p terms
    @papers = Paper
    @papers = @papers.basic_search(terms[:or], false) unless terms[:or].empty?
    @papers = @papers.basic_search(terms[:and]) unless terms[:and].empty?
    @papers = @papers.paginate(page: params[:page])

#    if query.start_with?('au:')
#      author_query = query.split('au:', 2)[1]
#      if author_query.match(/^[^_]+_[^_]$/) # arXiv style author query
#        authors = Author.where(searchterm: query.split('au:')[1])
#      else
#        authors = Author.advanced_search(fullname: author_query)
#      end
#
#      @papers = Paper.joins(:authorships)
#                     .where(:authorships => { :author_id => authors.map(&:id) })
#                     .includes(:authors, :cross_lists, :scites, :feed)
#                     .paginate(page: params[:page])
#
#    else
#      @authors = Author.advanced_search(fullname: query).limit(50).all.uniq(&:fullname)
#      @papers = Paper.includes(:authors, :cross_lists, :scites, :feed)
#                     .basic_search(query).except(:order)
#                     .paginate(page: params[:page])
#    end

    render :search
  end

  def search
    @query = params[:q] || ''

    params.each do |key, val|
      next if val.empty?

      case key
      when 'authors'
        authors = val.split(/,\s+/)
        @query += authors.map { |au| "au:#{au}" }.join(' AND ')
      when 'title'
        @query += " AND ti:#{val}"
      when 'abstract'
        @query += " AND abs:#{val}"
      when 'feed'
        @query += " AND feed:#{val}"
      end
    end

    @query = @query.gsub(/^ AND /, '')
    __search(@query)
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
