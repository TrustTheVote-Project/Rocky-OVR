module AdminStatisticsHelper

  # returns:
  # [[partner_id, partner_name, percentage], ...]
  def self.pdf_percentage_per_partner
    conditions = "finish_with_state = ? AND (status = 'complete' OR status = 'step_5') AND pdf_downloaded = ?"

    names = Hash[Partner.all.map { |p| [p.id, p.name] }]

    downloads_count = Registrant.where(conditions, false, true).group("partner_id").count
    not_down_count = Registrant.where(conditions, false, false).group("partner_id").count
    ids = (downloads_count.keys + not_down_count.keys).uniq.sort
    # if we decide to load all partners regardless empty registrants list
    # ids = names.keys.sort

    ids.map do |id|
      c1 = downloads_count[id] || 0
      c2 = not_down_count[id] || 0
      total = c1 + c2
      percent = total != 0 ? "#{(100*c1.to_f/total).round(2)}%" : "N/A"
      [id, names[id], percent]
    end
  end

end