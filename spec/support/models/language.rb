class Language < ActiveRecord::Base
  has_git

  attr_accessible :name
end