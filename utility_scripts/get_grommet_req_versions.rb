regs = []

distribute_reads do
  Registrant.where(home_state: pa).where("state_ovr_data IS NOT NULL and status='complete' and created_at > ?", Date.parse("2020-01-01")).includes("home_state" ).find_each do |r|
      regs.push({
        id: r.id,
        uid: r.uid,
        pid: r.partner_id,
        created_at: r.created_at,
        grommet_id: r.state_ovr_data["grommet_request_id"]
      })
  
  end
end

grommet_req_versions = {}
grommet_ids = regs.collect {|r| r[:grommet_id] }
distribute_reads do
  GrommetRequest.where(id: grommet_ids).find_each do |g|
    h = JSON.parse(g.request_headers.gsub('=>', ':'))
  
    grommet_req_versions[g.id] = {
      version:h["HTTP_GROMMET_VERSION"],
      path: h["PATH_INFO"],
    }
  end
end

csvstr = CSV.generate do |csv|
  csv << ["ID", "UID", "Partner ID", "Created At", "Grommet Version", "API Path"]
  regs.each do |r|
    if r[:grommet_id]
      g = r[:grommet_id] ? grommet_req_versions[r[:grommet_id]] : nil
      csv << [r[:id], r[:uid], r[:pid], r[:created_at], g ? g[:version] : r[:grommet_id], g ? g[:path] : '']
    end
  end
end
