class AbTest < ActiveRecord::Base
  belongs_to :registrant
  
  MOBILE_UI="NewMobileUI".freeze
  MOBILE_UI_OLD="OLD".freeze
  MOBILE_UI_NEW="NEW".freeze
  def self.assign_mobile_ui_test(registrant, controller)
    return nil if registrant.nil?
    return nil if registrant.javascript_disabled?
    return nil if registrant.home_state_allows_ovr_ignoring_license?
    return nil if registrant.locale != 'en'
    return nil if registrant.partner != Partner.primary_partner
    is_mobile = false
    agent = controller.request.user_agent.to_s.downcase
    RockyConf.mobile_browsers.each do |b|
      if agent =~ /#{b}/
        is_mobile = true
      end
    end
    return nil if !is_mobile
    t = self.assign(MOBILE_UI, [MOBILE_UI_OLD, MOBILE_UI_NEW], registrant)
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
