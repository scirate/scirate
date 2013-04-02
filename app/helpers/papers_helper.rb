module PapersHelper
  def last_date(papers)
    last = papers.find(:first, order: "pubdate DESC")
    last.nil? ? Time.now.utc.to_date : last.pubdate
  end

  def next_date(papers, date)
    next_paper = papers.find(:last,
                            order: "pubdate DESC",
                            conditions: ["pubdate > ?", date])
    next_paper.nil? ? nil : next_paper.pubdate
  end

  def prev_date(papers, date)
    prev_paper = papers.find(:first,
                            order: "pubdate DESC",
                            conditions: ["pubdate < ?", date])
    prev_paper.nil? ? nil : prev_paper.pubdate
  end
end
