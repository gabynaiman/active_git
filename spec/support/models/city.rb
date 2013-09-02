class City < ActiveRecord::Base
  git_included_in :country
  belongs_to :country
end