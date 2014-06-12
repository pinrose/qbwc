module QBWC
  class QbwcSession < ActiveRecord::Base
    before_create :setup

    def current_request
      request = nil
      mark_prev_as_processed
      if next_id = self.next_qbwc_job_id
        job = QBWC::QbwcJob.find_by_id(next_id)
        obj = job.klass.send(:find_by_id, job.klass_id)
        request = obj.qb_payload
        request.delete('xml_attributes')
        request.values.first['xml_attributes'] = {'iterator' => 'Continue', 'iteratorID' => obj.id}
        request = QBWC::Request.new(request)
        advance(job)
      end
      request
    end

    def advance(current_job)
      next_job = QBWC::QbwcJob.where(processed: false).where('id != ?', current_job.id).order('id asc').limit(1).first
      self.prev_qbwc_job_id = current_job.id
      self.next_qbwc_job_id = next_job.try(:id) || nil
      self.save
    end

    def mark_prev_as_processed
      return if self.prev_qbwc_job_id.blank?
      prev = QBWC::QbwcJob.find_by_id(self.prev_qbwc_job_id)
      prev.processed = true
      prev.save
    end

    def progress
      n_processed = QBWC::QbwcJob.where(processed: true).count.to_f
      return 100 if n_processed < 1
      (n_processed / self.total_requests)*100
    end

    def complete_session
      QBWC::QbwcJob.where(processed: true).destroy_all
      self.destroy
    end

    private
    def setup
      self.token = Digest::SHA1.hexdigest("#{Rails.application.config.secret_token}#{Time.now.to_i}")
      self.total_requests = QBWC::QbwcJob.where(processed: false).count
    end
  end
end