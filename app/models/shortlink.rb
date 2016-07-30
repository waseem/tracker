require 'active_record'

class Shortlink < ActiveRecord::Base
  belongs_to :campaign
end
