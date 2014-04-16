# == Schema Information
#
# Table name: authors
#
#  id         :integer          not null, primary key
#  position   :integer          not null
#  fullname   :text             not null
#  searchterm :text             not null
#  paper_uid  :text
#

require 'spec_helper'

describe Author do
  it { should validate_presence_of(:paper_uid) }
  it { should validate_presence_of(:position) }
  it { should validate_presence_of(:fullname) }
  it { should validate_presence_of(:searchterm) }

  describe '#make_searchterm' do
    it 'generates searchterms correctly' do
      term = Author.make_searchterm('Ben Toner (CWI)')
      expect(term).to eq 'Toner_B'

      term = Author.make_searchterm('Ben Toner [CWI]')
      expect(term).to eq 'Toner_B'

      term = Author.make_searchterm('BABAR Collaboration')
      expect(term).to eq 'Collaboration_BABAR'
    end
  end
end
