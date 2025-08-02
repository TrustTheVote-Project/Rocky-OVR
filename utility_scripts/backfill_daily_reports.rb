     ENV['GENERATING_REPORTS'] = "true"
     start_time = DateTime.parse("2022-04-25 00:44:29")
     end_time = DateTime.parse("2022-04-26 18:45:58")
     distribute_reads(failover: false) do
       registrants = Registrant.where("created_at > ? and created_at <= ?", start_time, end_time).includes(:home_state)
       abrs = Abr.where("created_at > ? and created_at <= ?", start_time, end_time).includes(:home_state)
       lookups = CatalistLookup.where("created_at > ? and created_at <= ?", start_time, end_time).includes(:state, :abr)
       bscs = BallotStatusCheck.where("created_at > ? and created_at <= ?", start_time, end_time)
       alerts = AlertRequest.where("created_at > ? and created_at <= ?", start_time, end_time).includes(:state)

       # Also preload all PA and VA state registrants?
       pa_registrants = {}
       va_registrants = {}
       mi_registrants = {}
       mn_registrants = {}
       #wa_registrants = {}
       StateRegistrants::PARegistrant.where("created_at > ? and created_at <= ?", start_time, end_time).find_each {|sr| pa_registrants[sr.registrant_id] = sr}
       StateRegistrants::VARegistrant.where("created_at > ? and created_at <= ?", start_time, end_time).find_each {|sr| va_registrants[sr.registrant_id] = sr}
       StateRegistrants::MIRegistrant.where("created_at > ? and created_at <= ?", start_time, end_time).find_each {|sr| mi_registrants[sr.registrant_id] = sr}
       StateRegistrants::MNRegistrant.where("created_at > ? and created_at <= ?", start_time, end_time).find_each {|sr| mn_registrants[sr.registrant_id] = sr}
       #StateRegistrants::WARegistrant.where("created_at > ? and created_at <= ?", start_time, end_time).find_each {|sr| wa_registrants[sr.registrant_id] = sr}

       headers = ReportGenerator.registrant_fields.dup
       headers += [
         "abr_uid",
         "lookup_uid",
         "ballot_status_check_uid",
         "alert_request_uid",
         "current_step",
         "max_step",
         "pdf_ready",
         "gender",
         "tool"
       ]
       csv_str_regs = CsvFormatter.wrap do |csv|
         csv << headers
         CsvFormatter.rename_array_item(headers, 'home_state_abbrev', 'abbreviation')
         CsvFormatter.rename_array_item(headers, 'first_registration?', 'first_registration')

         registrants.find_each do |r|
           # Set the @existing_state_registrant value
           if r.use_state_flow?
             sr  = nil
             case r.home_state_abbrev
             when "PA"
               sr = pa_registrants[r.uid] || nil
             when "VA"
               sr = va_registrants[r.uid] || nil
             when "MI"
               sr = mi_registrants[r.uid] || nil
             when "MN"
               sr = mn_registrants[r.uid] || nil
             # when "WA"
             #   sr = wa_registrants[r.uid] || nil
             end
             r.instance_variable_set(:@existing_state_registrant, sr)
             r.instance_variable_set(:@existing_state_registrant_fetched, true)
           end
           reg_attributes = ReportGenerator.registrant_fields.collect {|fname| r.send(fname) || ""}
           csv << reg_attributes + ["", "", "", "", "", "", "", "", "vr"]          
         end
       end
       csv_str_abrs = CsvFormatter.wrap do |csv|
         csv << headers
         CsvFormatter.rename_array_item(headers, 'home_state_abbrev', 'abbreviation')
         CsvFormatter.rename_array_item(headers, 'first_registration?', 'first_registration')
         abrs.find_each do |abr|
           abr_attributes = headers.collect {|fname| ReportGenerator.abr_field_mapping(fname, abr) || ""}
           csv << abr_attributes
         end
       end

       csv_str_lookups = CsvFormatter.wrap do |csv|
         csv << headers
         CsvFormatter.rename_array_item(headers, 'home_state_abbrev', 'abbreviation')
         CsvFormatter.rename_array_item(headers, 'first_registration?', 'first_registration')
         lookups.find_each do |lookup|
           lookup_attributes = headers.collect {|fname| ReportGenerator.lookup_field_mapping(fname, lookup) || ""}
           csv << lookup_attributes
         end
       end
      
       csv_str_bscs = CsvFormatter.wrap do |csv|
         csv << headers
         CsvFormatter.rename_array_item(headers, 'home_state_abbrev', 'abbreviation')
         CsvFormatter.rename_array_item(headers, 'first_registration?', 'first_registration')
         bscs.find_each do |bsc|
           bsc_attributes = headers.collect {|fname| ReportGenerator.bsc_field_mapping(fname, bsc) || ""}
           csv << bsc_attributes
         end
       end
      
       csv_str_alerts  = CsvFormatter.wrap do |csv|
         csv << headers
         alerts.find_each do |alert|
           alert_attributes = headers.collect {|fname| ReportGenerator.alert_field_mapping(fname, alert) || ""}
           csv << alert_attributes
         end
       end

       file_name = "rocky-custom-2022-04-25-registrants.csv"
       ReportGenerator.save_csv_to_s3(csv_str_regs, file_name)

       file_name = "rocky-custom-2022-04-25-abrs.csv"
       ReportGenerator.save_csv_to_s3(csv_str_abrs, file_name)

       file_name = "rocky-custom-2022-04-25-lookups.csv"
       ReportGenerator.save_csv_to_s3(csv_str_lookups, file_name)

       file_name = "rocky-custom-2022-04-25-ballot-status-checks.csv"
       ReportGenerator.save_csv_to_s3(csv_str_bscs, file_name)

       file_name = "rocky-custom-2022-04-25-election-alerts.csv"       
       ReportGenerator.save_csv_to_s3(csv_str_alerts, file_name)
     end
     ENV['GENERATING_REPORTS'] = nil