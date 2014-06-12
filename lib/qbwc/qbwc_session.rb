module QBWC
  class QbwcSession < ActiveRecord::Base
    before_create :setup

    belongs_to :previous_job, class_name: QBWC::QbwcJob, foreign_key: :prev_qbwc_job_id
    belongs_to :next_job,     class_name: QBWC::QbwcJob, foreign_key: :next_qbwc_job_id

    def current_request
      request = nil
      mark_prev_as_processed
      if job = self.next_job
        obj = job.klass.send(:find, job.klass_id)
        request = obj.qb_payload
        request.delete('xml_attributes')
        request.values.first['xml_attributes'] = {'iterator' => 'Continue', 'iteratorID' => obj.id}
        request = QBWC::Request.new(request)
        advance
      end
      request
    end

    def next_job_in_queue
      QBWC::QbwcJob.where(processed: false).where('id != ?', self.next_job.id).order('id asc').limit(1).first
    end

    def advance
      self.prev_qbwc_job_id = next_job.id
      self.next_qbwc_job_id = next_job_in_queue.try(:id) || nil
      self.save
    end

    def mark_prev_as_processed
      return if self.previous_job.blank?
      self.previous_job.processed = true
      self.previous_job.save!
    end

    def progress
      n_processed = QBWC::QbwcJob.where(processed: true).count.to_f
      total_jobs = QBWC::QbwcJob.count.to_f
      return 100 if n_processed == total_jobs
      (n_processed / total_jobs)*100
    end

    def complete_session
      QBWC::QbwcJob.where(processed: true).destroy_all
      self.destroy
    end

    private
    def setup
      self.token = Digest::SHA1.hexdigest("#{Rails.application.config.secret_token}#{Time.now.to_i}")
    end
  end
end