module DateExtensions
  refine ActiveSupport::TimeWithZone do
    def weekend?
      self.saturday? || self.sunday?
    end

    def saturday?
      self.wday == 6
    end

    def sunday?
      self.wday == 0
    end

    def friday?
      self.wday == 5
    end
  end
end


module Arxiv
  # Given when a paper was submitted, estimate the
  # time at which the arXiv was likely to have published it
  class PaperPublishedDateEstimation
    using DateExtensions

    def initialize(submit_date)
      @submit_date = find_arxiv_submit_date(submit_date)
    end

    def estimate_pubdate
      @pubdate = @submit_date.dup.change(hour: 20)

      if submitted_on_weekend?
        set_pubdate_to_monday
      else
        if submitted_on_friday?
          set_pubdate_to_sunday
        end

        if passed_submission_deadline?
          @pubdate += 1.day
        end
      end

      @pubdate
    end

    private

      # arXiv runs on EST localtime
      # arxiv.org/localtime
      def find_arxiv_submit_date(date)
        date.in_time_zone('EST')
      end

      def submitted_on_weekend?
        @submit_date.weekend?
      end

      def submitted_on_friday?
        @submit_date.friday?
      end

      def passed_submission_deadline?
        @submit_date.hour >= 16
      end

      def set_pubdate_to_monday
        @pubdate += 1.days if @submit_date.sunday?
        @pubdate += 2.days if @submit_date.saturday?
      end

      def set_pubdate_to_sunday
        @pubdate += 2.days
      end
  end
end