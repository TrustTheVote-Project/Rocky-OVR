class User < ApplicationRecord
  has_many :partner_users, dependent: :destroy
  has_many :partners, through: :partner_users

  acts_as_google_authenticated method: :email_with_label

  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::SCrypt
  end
  
  validates_format_of :email, :with => Registrant::EMAIL_REGEX, :allow_blank => true
  validates :email, presence: true

  validates :password,
    confirmation: { if: :require_password? },
    format: {
      with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[$@$!%*?&])[A-Za-z\d$@$!%*?&]{10,}/, 
      allow_blank: true
    },
    length: {
      minimum: 10,
      if: :require_password?
    }
  validates :password_confirmation,
    length: {
      minimum: 10,
      if: :require_password?
    }


  def self.create_default_partner_user(partner)
    u = User.new
    u.password = u.password_confirmation = 'aBc123!@' + SecureRandom.hex(10) + 'a'
    u.email = partner.email
    u.name = partner.name
    u.phone = partner.phone
    u.partners << partner
    u.save
  rescue
  end

  def self.deactivate_stale_users!
    date = 90.days.ago
    users = User.where("(current_login_at < ? OR current_login_at IS NULL) AND created_at < ?", date, date)
    users.each do |u|
      u.active = false
      u.save(validate: false)
    end
    
    if users.any?
      AdminMailer.deactivate_users(users).deliver_now
    end
    
  end


  def self.permitted_attributes
    attrs = self.column_names - self.protected_attributes
    return [attrs, :password, :password_confirmation, :state_abbrev].flatten
  end

  def self.protected_attributes
    Partner::PROTECTED_ATTRIBUTES
  end

  def self.add_to_partner!(email, partner)
    user = User.find_by_email(email)
    if !user
      user = User.create({email: email})
      user.password = user.password_confirmation = 'aBc123!@' + SecureRandom.hex(10) + 'a'
      #user.deliver_password_reset_instructions!
    end
    
    unless user.partners.include?(partner)
      user.partners << partner
    end
    user.save
    begin
      user.send_invite(partner)
    rescue 
    end
    return user
  end

  def send_invite(partner)
    AdminMailer.invite_user(self, partner).deliver_now    
  end

  def email_with_label
    "RTV Partner Platform #{env_label}(#{email})"
  end

  def env_label
    Rails.env.production? ? '' : "- #{Rails.env} "
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.password_reset_instructions(self).deliver_now
  end


  PROTECTED_ATTRIBUTES = [
    :crypted_password, :password_salt, :persistence_token, :perishable_token, :created_at, :updated_at, :failed_login_count, :login_count, :last_request_at, :current_login_at, :current_login_ip, :last_login_ip
  ]
end
