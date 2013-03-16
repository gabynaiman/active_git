module Crm
  class Customer < ActiveRecord::Base
    self.table_name_prefix = 'crm_'
    git_versioned
  end
end