class Shortlink < ActiveRecord::Base
  belongs_to :campaign

  def has_active_campaign?
    self.campaign.present? && self.campaign.active?
  end
end
