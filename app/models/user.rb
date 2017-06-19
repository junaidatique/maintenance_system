class User
  include Mongoid::Document
  include SimpleEnum::Mongoid

  as_enum :role, admin: 0, engineer: 1, data_entry: 2, crew_cheif: 3
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
        # :registerable,
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
  field :status,        type: Mongoid::Boolean
    
  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time

  embeds_one :profile_picture, as: :attachable, class_name: Picture.name, cascade_callbacks: true, autobuild: true

  accepts_nested_attributes_for :profile_picture

  has_and_belongs_to_many :work_unit_codes

  validates :username, presence: true
  
  def email_required?
    false
  end

  def active_for_authentication?
    super && self.status # i.e. super && self.is_active
  end

  def inactive_message
    "Sorry, this account has been deactivated."
  end
end
