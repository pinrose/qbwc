class QBWC::ActiveRecord::Session < QBWC::Session
  class QbwcSession < ActiveRecord::Base
    attr_accessible :company, :ticket, :user unless Rails::VERSION::MAJOR >= 4
  end

  def debug(obj, close=false)
    (@f ||= File.open('/tmp/qbwc_debug.log','a')).puts(obj.inspect)
    if close
      @f.close
      @f = nil
    end
  end

	def self.get(ticket)
		session = QbwcSession.find_by_ticket(ticket)
    debug "get(ticket) called and resulting session was #{session.inspect}"
    self.new(session) if session
	end

  def initialize(session_or_user = nil, company = nil, ticket = nil)
    debug "initializing Session: session_or_user = #{session_or_user}, company = >#{company}<, ticket = #{ticket}"
    if session_or_user.is_a? QbwcSession
      @session = session_or_user
      # Restore current job from saved one on QbwcSession
      @current_job = QBWC.jobs[@session.current_job.to_sym] if @session.current_job
      # Restore pending jobs from saved list on QbwcSession
      @pending_jobs = @session.pending_jobs.split(',').map { |job| QBWC.jobs[job.to_sym] }
      debug 'We went into condition: session_or_user.is_a? QbwcSession'
      super(@session.user, @session.company, @session.ticket)
    else
      super
      @session = QbwcSession.new(:user => self.user, :company => self.company, :ticket => self.ticket)
      self.save
      debug 'We went into ELSE condition: means that session_or_user.is_a? QbwcSession returned false'
      @session
    end
    debug "company = #{@session.company}, ticket = #{@session.ticket}, user = #{@session.user}"
    debug "at the end of initialize Session, session = #{@session.inspect}, current_job = #{@current_job.inspect}, pending_jobs = #{@pending_jobs.inspect}"
    debug 'initialize done.', true
  end

  def save
    @session.pending_jobs = pending_jobs.map(&:name).join(',')
    @session.current_job = current_job.try(:name)
    @session.save
    super
  end

  def destroy
    @session.destroy
    super
  end

  [:error, :progress, :iterator_id].each do |method|
    define_method method do
      @session.send(method)
    end
    define_method "#{method}=" do |value|
      @session.send("#{method}=", value)
    end
  end
  protected :progress=, :iterator_id=, :iterator_id

end
