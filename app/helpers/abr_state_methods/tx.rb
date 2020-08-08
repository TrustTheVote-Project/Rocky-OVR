module AbrStateMethods::TX
  
  def self.included(klass)
    klass.extend(AbrStateMethods::ClassMethods)
    klass.add_pdf_fields({
      "Full name": {
        method: "full_name"
      },
      "fill_2": {},
      "Phone": {
        method: "phone"
      },
      "and Street": {
        method: "address"
      },
      "City": {
        method: "city"
      },
      "Zip Code": {
        method: "zip"
      },
      "date": {
        method: "date_of_birth_mm_dd_yyyy"
      },
      "Security Number": {},
      "Email Address": {
        pdf_name: "address",
        method: "email"
      },
      # mailing address if different that residence address
      "fill_10": {        
      },
      # "Expected Election Day Location"
      "fill_11": {},
      # "Expected Election Day Phone Number"
      "Day phone": {},
      "Primary": { 
        options: ["Off", "On"],
        value: "Off" 
      },
      # Presidential Primary
      "toggle_12": { 
        options: ["Off", "On"],
        value: "Off" 
      },
      "General": { 
        options: ["Off", "On"],
        value: "On" 
      },
      "Special": { 
        options: ["Off", "On"],
        value: "Off" 
      },
      # All elections
      "toggle_15": { 
        options: ["Off", "On"],
        value: "Off" 
      },
      "1 I am in public service of the US or the State of": {
        options: ["Off", "On"]        
      },
      # 2) Due to  the nature of my business or occupa&#415;on
      "toggle_2": {
        options: ["Off", "On"]        
      },    
      "3 I am sick or temporarily or permanently": {
        options: ["Off", "On"]        
      },
      #4) I am absent from the district while on vaca&#415;on
      "toggle_4": {
        options: ["Off", "On"]        
      },
      "5 Due to the tenets or teachings of my religion": {
        options: ["Off", "On"]        
      },
      "6 I am temporarily residing outside of the U S": {
        options: ["Off", "On"]        
      },    
      # Send ballot by mail
      "mail": {
        options: ["Off", "On"]        
      },    
      # Send ballot by fax
      "fax or": {
        options: ["Off", "On"]        
      },    
      # Send ballot by email
      "delivery email": {
        pdf_name: "email",
        options: ["Off", "On"]        
      },   
      "FAX": {},
      "Make me a permanent absentee voter": {
        options: ["Off", "On"],
        default: "Off"
      }
    })
  end
  
  def form_field_items
    [
      {"fill_2": {}}, # Political Party
      {"Security Number": {required: true}},
      {"fill_10": {}},
      {"fill_11": {required: true}},  # Expected Election Day Location
      {"Day phone": {requiretd: true}}, # On election day
      {"absentee_reason": { type: :radio, options: [1,2,3,4,5,6], required: true}},
      {"absentee_delivery": { visible: "absentee_reason_3", type: :radio, options: ["mail", "fax", "email"]}},
      {"FAX": {visible: "absentee_delivery_fax"}},
      {"Make me a permanent absentee voter": {type: :checkbox}}      
    ]
  end
  
  def custom_form_field_validations
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery
  end

  
end