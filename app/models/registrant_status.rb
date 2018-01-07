class RegistrantStatus < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :registrant
  belongs_to :admin
  belongs_to :geo_state
  
  serialize :state_data, Hash
  
  def self.get_columns(state)
    case state
    when GeoState["PA"]
      return {id_column: "Application_ID", date_column: "Application_Date", status_column: "Status", status_details_column: "Status_Reason"}
    end
  end
  
  def self.state_ovr_id_finder(state, state_id)
    case state
    when GeoState["PA"]
      "%pa_transaction_id: '#{state_id}'%"
    end
  end
  
  def self.import_ovr_status!(csv, state, admin_user)
    # First, read the registrants into a list
    reg_statuses = {}
    max_date = Date.parse("2000-01-01")
    min_date = Date.parse(1.day.from_now.to_s)
    cols = self.get_columns(state)

    imports = CSV.read(csv, {:headers=>true}) #,  :encoding => 'windows-1251:utf-8'
    imports.each do |row|
      next if row.to_s.strip.blank?
      state_transaction_id = row[cols[:id_column]]
      state_application_date = row[cols[:date_column]]

      state_application_date = Date.strptime(state_application_date, "%m/%d/%y")
      state_status = row[cols[:status_column]]
      state_status_details = row[cols[:status_details_column]]
      reg_statuses[state_transaction_id] = {
        state_transaction_id: state_transaction_id,
        state_application_date: state_application_date,
        state_status: state_status,
        state_status_details: state_status_details,
        geo_state_id: state.id,
        state_data: row.to_hash,
        admin_id: admin_user.id
      }

      if state_application_date < min_date
        min_date = state_application_date
      end
      if state_application_date > max_date
        max_date = state_application_date
      end
      
    end
    
    reg_statuses_results = {}
    
    potential_registrants = Registrant.where(home_state_id: state.id).where("created_at >= ? and created_at <= ?", min_date - 14.days, max_date + 1.days).where("state_ovr_data IS NOT NULL and state_ovr_data != '--- {}\\n'")
    
    reg_statuses.each do |state_id, reg_data|
      # Find row in table?
      existing = self.where(state_transaction_id: state_id, geo_state_id: reg_data[:geo_state_id]).first
      if (existing)
        existing.update_attributes(reg_data)
        reg_statuses_results[state_id] = "Updated status record"
      else
        # Find registrant
        regs = potential_registrants.where("state_ovr_data LIKE ?", state_ovr_id_finder(state, state_id))
        if (regs.count > 1)
          reg_statuses_results[state_id] = "More than one registrant matched #{reg_data}"
        elsif regs.count == 0
          reg_statuses_results[state_id] = "No registrants matched #{reg_data}"
        else
          reg = regs.first
          data = reg_data.merge({registrant_id: reg.id})
          self.create!(data)
          reg_statuses_results[state_id] = "Created status record"          
        end
      end
    end
    return reg_statuses_results
  end
  
end
