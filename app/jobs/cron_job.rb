# Default configuration in `app/jobs/application_job.rb`, or subclass
# ActiveJob::Base .
class CronJob


  class_attribute :cron_expression

  class << self

    def schedule
      Delayed::Job.enqueue(self.new, cron: cron_expression) unless scheduled?
    end

    def remove
      delayed_job.destroy if scheduled?
    end

    def scheduled?
      delayed_job.present?
    end

    def delayed_job
      Delayed::Job
        .where('handler LIKE ?', "%#{name}%")
        .first
    end

  end
end