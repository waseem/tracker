class Campaign < ActiveRecord::Base
  has_many :shortlinks
  validates :offer_url, presence: true

  def active?
    status == 'active'
  end
end
