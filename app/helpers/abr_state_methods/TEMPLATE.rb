module AbrStateMethods::OH
  
  def self.included(klass)
    klass.extend(AbrStateMethods::ClassMethods)
    klass.add_pdf_fields({
      
    })
  end
  
  def form_field_items
    [
      {"Security Number": {required: true}},
    ]
  end
  
  def custom_form_field_validations
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery
  end
  
 
end