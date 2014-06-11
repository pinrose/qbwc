class QBWC::ActiveRecord::Job < QBWC::Job
  class QbwcJob < ActiveRecord::Base
    validates :name, :uniqueness => true, :presence => true
  end

  def debug(obj, close=false)
    (@f ||= File.open('/tmp/qbwc_debug.log','a')).puts(obj.inspect)
    if close
      @f.close
      @f = nil
    end
  end

  def self.debug(obj, close=false)
    (@f ||= File.open('/tmp/qbwc_debug.log','a')).puts(obj.inspect)
    if close
      @f.close
      @f = nil
    end
  end

  def initialize(name, company, *requests, &block)
    super
    @job = find_job.first_or_create do |job|
      job.company = @company
      job.enabled = @enabled
      job.next_request = @next_request
    end
    debug "in initialize of Job: company = #{@company.inspect}, enabled = #{@enabled.inspect}, next_request = #{@next_request}"
  end

  def find_job
    debug "find_job was called and name passed through args was >#{name}<"
    QbwcJob.where(:name => name)
  end

  def enabled=(value)
    debug "enabled= method called with the value #{value.inspect}"
    find_job.update_all(:enabled => value)
  end

  def enabled?
    enbled = find_job.where(:enabled => true).exists?
    debug "enabled? method called. Result was #{enbled.inspect}"
    enbled
  end

  def next_request
    next_req = find_job.pluck(:next_request).first
    debug "Next request is #{next_req.inspect}"
    next_req
  end

  def reset
    resetted = find_job.update_all(:next_request => 0)
    debug "Reset was called and update_all returned #{resetted}"
    super
  end

  def advance_next_request
    debug "Advancing to next request: job.id = #{@job.id}"
    QbwcJob.increment_counter :next_request, @job.id
  end
end
