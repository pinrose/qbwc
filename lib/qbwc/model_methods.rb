module QBWC
  module ModelMethods
    def qb_payload
      raise 'You must add a method to your class called qb_payload.'
    end

    def qb_response_handler(response)
      raise 'You must add a method to your class called qb_response_handler. It takes a hash argument.'
    end

    def qb_queue
      QBWC::QbwcJob.create(klass: self.class.to_s, klass_id: self.id)
    end
  end
end