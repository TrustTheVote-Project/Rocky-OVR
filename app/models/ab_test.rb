class AbTest < ActiveRecord::Base
  belongs_to :registrant
  
  MOBILE_UI="NewMobileUI".freeze
  MOBILE_UI_OLD="OLD".freeze
  MOBILE_UI_NEW="NEW".freeze

  OLD = "OLD".freeze
  NEW = "NEW".freeze
  
  NEW_UI_2020="newui2020".freeze

  def self.tests
    # Temporarily turn off B variant
    return []
    [
      [NEW_UI_2020, :assign_2020_ui_text]
    ]
  end

  def self.assign_2020_ui_text(registrant, controller)
    return nil if registrant.nil?
    return nil if registrant.javascript_disabled?
    return nil unless registrant.use_short_form?
    partner = registrant.partner
    # If whitelabeled partner has custom css but not partner3_css
    return nil if partner.whitelabeled && partner.any_css_present? && !partner.partner3_css_present?
    t = self.assign(NEW_UI_2020, [NEW, OLD])
    t.save!
    return t
  end

  def self.is_mobile_request(controller)
    agent = controller.request.user_agent.to_s.downcase
    RockyConf.mobile_browsers.each do |b|
      if agent =~ /#{b}/
        return true
      end
    end
    return false
  end

  def self.assign_mobile_ui_test(registrant, controller)
    return nil if registrant.nil?
    return nil if registrant.javascript_disabled?
    #return nil if registrant.home_state_allows_ovr_ignoring_license?
    #return nil if registrant.locale != 'en'
    #return nil if registrant.partner != Partner.primary_partner
    is_mobile = false
    agent = controller.request.user_agent.to_s.downcase
    RockyConf.mobile_browsers.each do |b|
      if agent =~ /#{b}/
        is_mobile = true
      end
    end
    return nil if !is_mobile
    t = self.assign(MOBILE_UI, [MOBILE_UI_NEW, MOBILE_UI_NEW], registrant)
    t.save!
    return t
  end
  
  def self.assign(name, options, registrant=nil) 
    assignment = nil
    assignment_value = (rand * 100).round # 0 <= r < 100
    opt_list = []
    if options.is_a?(Hash) 
      opt_list = options.to_a.sort {|a1,a2| a1[1]<=>a2[1]}
      # should be {assignment: weight / 100} where all weights add up to 100
    else
      weight = 100 / options.count
      options.each do |a|
        opt_list << [a, weight]
      end
    end
    
    
    
    total = 0
    opt_list.each do |a,v|
      total = total + v
      if assignment_value < total
        assignment = a
        break
      end
    end
    if !assignment
      return self.assign(name, options, registrant)
    end

    t = AbTest.new
    t.name = name
    t.assignment = assignment
    t.registrant_id = registrant ? registrant.id : nil
    return t
  end
  
end
