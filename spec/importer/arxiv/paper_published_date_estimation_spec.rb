require 'spec_helper'

describe Arxiv::PaperPublishedDateEstimation do
  let(:zone) { zone = ActiveSupport::TimeZone["EST"] }

  describe '#estimate_pubdate' do
    context 'when submit date is on weekend' do
      context 'when submit date is Saturday' do
        it 'returns next Monday UTC time' do
          submit_date = zone.parse("Sat Mar 8 15:59 EST 2014")
          expected_date = zone.parse("Mon Mar 10 20:00 EST 2014")
          pubdate = described_class.new(submit_date).estimate_pubdate
          expect(pubdate).to eq expected_date
        end
      end

      context 'when submit date is Sunday' do
        it 'returns next Monday UTC time' do
          submit_date = zone.parse("Sun Mar 9 15:59 EST 2014")
          expected_date = zone.parse("Mon Mar 10 20:00 EST 2014")
          pubdate = described_class.new(submit_date).estimate_pubdate
          expect(pubdate).to eq expected_date
        end
      end
    end

    context 'when submit date is on weekday' do
      context 'when submit date is not Friday' do
        context 'when not overdue' do
          it 'returns submit date adjusted to 20:00 in UTC time' do
            submit_date = zone.parse("Wed Mar 5 15:59 EST 2014")
            expected_date = zone.parse("Wed Mar 5 20:00 EST 2014")
            pubdate = described_class.new(submit_date).estimate_pubdate
            expect(pubdate).to eq expected_date
          end
        end

        context 'when overdue' do
          it 'returns next day in UTC' do
            submit_date = zone.parse("Wed Mar 5 16:01 EST 2014")
            expected_date = zone.parse("Thu Mar 6 20:00 EST 2014")
            pubdate = described_class.new(submit_date).estimate_pubdate
            expect(pubdate).to eq expected_date
          end
        end
      end

      context 'when submit date is Friday' do
        context 'when not overdue' do
          it 'returns next Saturday adjusted in UTC' do
            submit_date = zone.parse("Fri Mar 7 15:59 EST 2014")
            expected_date = zone.parse("Sun Mar 9 20:00 EST 2014")
            pubdate = described_class.new(submit_date).estimate_pubdate
            expect(pubdate).to eq expected_date
          end
        end

        context 'when overdue' do
          it 'returns next Sunday in UTC' do
            submit_date = zone.parse("Fri Mar 7 16:01 EST 2014")
            expected_date = zone.parse("Mon Mar 10 20:00 EST 2014")
            pubdate = described_class.new(submit_date).estimate_pubdate
            expect(pubdate).to eq expected_date
          end
        end
      end
    end
  end
end
