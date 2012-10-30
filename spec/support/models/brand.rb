class Brand < ActiveRecord::Base
  git_versioned

  attr_accessible :name
end