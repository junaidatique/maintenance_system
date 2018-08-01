class CaptAcceptanceCertificate
  include Mongoid::Document
  include SimpleEnum::Mongoid
  include Mongoid::Timestamps

  as_enum :mission, 
    "GENERAL HANDLING": 'GH', 
    "INSTRUMENT FLYING": 'IF',
    "FORMATION":  'FORM',
    "NIGHT":  'NIGHT',
    "FLY PAST": 'FLY PAST',
    "FUNCTIONAL CHECK FLIGHT": 'FCF',
    "CHECK FLIGHT": 'CHECK FLIGHT',
    "NAVIGATION": 'NAV',
    "CIRCUIT AND LANDING": 'CCT & LDG',
    "TAXI": 'TAXI',
    "TAXI TEST": 'TAXI TEST',
    "STAFF CONTINUATION TRAINING": 'SCT',
    "TRANSITION": 'TR',
    "FAMILIARIZATION": 'FAM',
    "INSTRUMENT RATING TEST": 'IRT',
    "INSTRUCTIONAL TECHNIQUE": 'IT',
    "INSTRUCTIONAL QUALIFICATION": 'IQ',
    "INSTRUCTIONAL QUALIFICATION TEST": 'IQT',
    "TRANSITION NIGHT": 'TRN',
    "SCREENING": 'SC',
    "SCREENING -1": 'SC-1',
    "SCREENING -2": 'SC-2',
    "SCREENING -3": 'SC-3',
    "SCREENING -4": 'SC-4',
    "SCREENING -5": 'SC-5',
    "SCREENING -6": 'SC-6',
    "SCREENING -7": 'SC-7',
    "SCREENING -8": 'SC-8',
    "SCREENING -9": 'SC-9',
    "SCREENING -10": 'SC-10',
    "STREAMING": "ST",
    "STREAMING - 1": "ST-1",
    "STREAMING - 2": "ST-2",
    "STREAMING - 3": "ST-3",
    "STREAMING - 4": "ST-4",
    "STREAMING - 5": "ST-5",
    "STREAMING - 6": "ST-6",
    "STREAMING - 7": "ST-7",
    "STREAMING - 8": "ST-8",
    "STREAMING - 9": "ST-9",
    "STREAMING - 10": "ST-10",
    "STREAMING - 11": "ST-11",
    "STREAMING - 12": "ST-12",
    "STREAMING - 13": "ST-13",
    "STREAMING - 14": "ST-14",
    "STREAMING - 15": "ST-15",
    "STREAMING - 16": "ST-16",
    "STREAMING - 17": "ST-17",
    "STREAMING - 18": "ST-18",
    "STREAMING - 19": "ST-19",
    "STREAMING - 20": "ST-20",
    "STREAMING - 21": "ST-21",
    "STREAMING - 22": "ST-22",
    "STREAMING - 23": "ST-23",
    "STREAMING - 24": "ST-24",
    "STREAMING - 25": "ST-25"

    

  field :flight_time, type: String
  field :view_history, type: Mongoid::Boolean
  field :view_deffered_log, type: Mongoid::Boolean
  field :third_seat_name, type: String
  
  validates :view_history, presence: true
  validates :view_deffered_log, presence: true

  belongs_to :user
  belongs_to :flying_log
  belongs_to :second_pilot, class_name: 'User', optional: true
  
end
