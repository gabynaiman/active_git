class Language < ActiveRecord::Base
  git_versioned include: {countries: {include: :cities}}
  has_many :countries
end