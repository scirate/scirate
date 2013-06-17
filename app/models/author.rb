class Author < ActiveRecord::Base
  attr_accessible :affiliation, :forenames, :identifier, :keyname, :suffix

  has_many :authorships
  has_many :papers, through: :authorships
end
