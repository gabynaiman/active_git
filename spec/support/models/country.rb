class Country < ActiveRecord::Base
  git_versioned include: [:language, :cities]
  belongs_to :language
  has_many :cities
end