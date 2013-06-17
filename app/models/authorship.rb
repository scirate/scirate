class Authorship < ActiveRecord::Base
  attr_accessible :author_id, :paper_id

  belongs_to :author
  belongs_to :paper
end
