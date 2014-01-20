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

# An Author represents an element in an ordered
# list of paper authors.
#
# NOTE (Mispy):
#
# I've decided not to normalize authors into a paper-independent
# table after all. We currently cannot do so with any kind of
# accuracy: no author property or combination of author properties
# is guaranteed to correspond to a unique individual.
#
# Instead, we should choose the assumptions we want to make for
# unifying different authors at the point of retrieval. This also
# makes queries and sphinx indexing faster, as we only have to go
# through a single association to get most of the data.
#
class Author < ActiveRecord::Base
  belongs_to :paper, foreign_key: :paper_uid, primary_key: :uid

  validates :paper_uid, presence: true
  validates :position, presence: true
  validates :fullname, presence: true
  validates :searchterm, presence: true

  # Makes a searchterm of the form e.g.
  # "Biagini_M" from "Maria Enrica Biagini"
  def self.make_searchterm(name)
    spl = name.split(/\s+/)
    if spl.length == 0
      term = spl[0]
    else
      term = "#{spl[-1]}_#{spl[0][0]}"
    end

    term.mb_chars.normalize(:kd).gsub(/[^\x00-\x7f]/n, '').to_s
  end
end
