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
end
