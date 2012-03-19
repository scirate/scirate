class Scite < ActiveRecord::Base
  attr_accessible :paper_id

  belongs_to :sciter, class_name: "User"
  belongs_to :paper

  validates :sciter, presence: true
  validates :paper,  presence: true
end
