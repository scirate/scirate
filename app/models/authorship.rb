class Authorship < ActiveRecord::Base
  belongs_to :author
  belongs_to :paper
  acts_as_list :scope => :paper
end
