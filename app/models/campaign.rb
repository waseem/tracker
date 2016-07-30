require 'active_record'

class Campaign < ActiveRecord::Base
  has_many :shortlinks
end
