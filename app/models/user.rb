class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include SimpleEnum::Mongoid

  as_enum :role, 
                admin: 0,
                chief_maintenance_officer: 1,
                squadron_engineering_officer: 2,
                flightline_supervisor: 3,
                crew_cheif: 4,
                pilot: 5,
                logistics: 6,
                engg: 7,
                inst_fitt: 8,
                eng_fitt: 9,
                afr_fitt: 10,
                ro_fitt: 11,
                log_asst: 12,
                elect_fitt: 13,
                gen_fitt: 14,                
                master_control: 15                
                

                
  
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable


  ## Database authenticatable
  field :email,              type: String, default: ""
  field :username,           type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  field :name,          type: String
  field :rank,          type: String
  field :personal_code, type: String
  field :trade,         type: String
  field :status,        type: Mongoid::Boolean
    
  embeds_one :profile_picture, as: :attachable, class_name: Picture.name, cascade_callbacks: true, autobuild: true
  embeds_one :signature, as: :attachable, class_name: Picture.name, cascade_callbacks: true, autobuild: true
  
  accepts_nested_attributes_for :profile_picture
  accepts_nested_attributes_for :signature
  
  has_and_belongs_to_many :autherization_codes
  has_many :requested_tools
  validates :username, presence: true, uniqueness: true  
  scope :online, -> { gt(updated_at: 10.minutes.ago) }


  def email_required?
    false
  end

  def active_for_authentication?
    super && self.status # i.e. super && self.is_active
  end

  def inactive_message
    "Sorry, this account has been deactivated."
  end
  def online?
    if updated_at.present?
      updated_at > 10.minutes.ago
    else 
      false
    end
  end
end
