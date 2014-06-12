require 'qbwc/railtie'
require 'qbxml'

module QBWC
  autoload :ActiveRecord, 'qbwc/active_record'
  autoload :Controller, 'qbwc/controller'
  autoload :Version, 'qbwc/version'
  autoload :Job, 'qbwc/job'
  autoload :Session, 'qbwc/session'
  autoload :Request, 'qbwc/request'

  # Web connector login credentials
  mattr_accessor :username
  @@username = 'foo'
  mattr_accessor :password
  @@password = 'bar'
  
  # Full path to pompany file 
  mattr_accessor :company_file_path 
  @@company_file_path = ""
  
  # Minimum quickbooks version required for use in qbxml requests
  mattr_accessor :min_version
  @@min_version = 3.0
  
  # Quickbooks app url provided in qwc file, defaults to root_url + ''
  mattr_accessor :app_url
  @@app_url = nil
  
  # Quickbooks support url provided in qwc file, defaults to root_url
  mattr_accessor :support_site_url
  @@support_site_url = nil
  
  # Quickbooks owner id provided in qwc file
  mattr_accessor :owner_id
  @@owner_id = '{57F3B9B1-86F1-4fcc-B1EE-566DE1813D20}'

  # Quickbooks owner id provided in qwc file
  mattr_accessor :file_id
  @@file_id = '{57F3B9B1-86F1-4fcc-B1EE-566DE1813D20}'

  # How often to run web service (in minutes)
  mattr_accessor :minutes_to_run
  @@minutes_to_run = 5
  
  # Job definitions
  mattr_reader :jobs
  @@jobs = {}
  
  mattr_reader :on_error
  @@on_error = 'stopOnError'

  # Quickbooks Type (either :qb or :qbpos)
  mattr_reader :api, :parser
  @@api = :qb

  # Storage module
  mattr_accessor :storage
  @@storage = :active_record
  
  class << self

    def pending_jobs
      QBWC::QbwcJob.where(processed: false)
    end

  end
  
end
