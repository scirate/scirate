module PapersHelper
  def last_date(papers)
    last = papers.find(:first, order: "submit_date DESC")
    last.nil? ? Time.now.utc.to_date : last.submit_date
  end

  def next_date(papers, date)
    next_paper = papers.find(:last,
                            order: "submit_date DESC",
                            conditions: ["submit_date > ?", date])
    next_paper.nil? ? nil : next_paper.submit_date
  end

  def prev_date(papers, date)
    prev_paper = papers.find(:first,
                            order: "submit_date DESC",
                            conditions: ["submit_date < ?", date])
    prev_paper.nil? ? nil : prev_paper.submit_date
  end

  # Formats a Paper model into a standardized JSON structure.
  def format_paper_json(paper)
    {
      # Core Metadata
      uid: paper.uid,
      title: paper.title,
      authors: paper.authors_fullname,
      abstract: paper.respond_to?(:abstract) ? paper.abstract : nil,
      
      # Scirate Stats
      scites_count: paper.scites_count,
      comments_count: paper.comments_count,
      is_scited: @scited_by_uid&.key?(paper.uid) || false,
      
      # Dates
      pubdate: paper.pubdate,
      submit_date: paper.submit_date,
    }
  end
end
