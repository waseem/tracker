class Shortlink < ActiveRecord::Base
  belongs_to :campaign

  def has_active_campaign?
    self.campaign.present? && self.campaign.active?
  end

  def self.cacheable_object(id_or_slug)
    shortlink = self.where("id = ? OR slug = ?", id_or_slug, id_or_slug).take
    return nil unless shortlink
    return nil unless shortlink.has_active_campaign?
    {
      shortlink_id: shortlink.id,
      slug:         shortlink.slug,
      offer_url:    shortlink.campaign.offer_url
    }
  end
end
