module AlertRequestReportHelper
  def alert_request_report_csv_header
    AlertRequest::CSV_HEADER
  end
  
  def alert_request_report_conditions    
    conditions = [[]]
    if start_date
      conditions[0] << " alert_requests.created_at >= ? "
      conditions << start_date
    end
    if end_date
      conditions[0] << " alert_requests.created_at < ? "
      conditions << end_date + 1.day
    end
    conditions[0] = conditions[0].join(" AND ")
    return conditions
  end
  
  def alert_request_report_selector
    @alert_request_report_selector ||= partner.alert_requests.where(alert_request_report_conditions)
  end
    
  def generate_alert_request_report(start=0, csv_method=:to_csv_array)
    distribute_reads(failover: false) do
      return CSV.generate do |csv|
        selector.order(:id).offset(start).limit(Report::THRESHOLD).each do |alert|
          csv << alert.send(csv_method)
        end
      end
    end
  end
end
