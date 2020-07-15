class BlocksServiceBulkSubmission < ActiveRecord::Base
  QUEUE_NAME = "blocks_bulk_shifts".freeze
  
  serialize :partners_submitted, Hash
  validates_presence_of(:shift_start)
  validates_presence_of(:shift_end)

  def self.bootstrap!(previous_shift_end = nil)
    previous_shift_end ||= BlocksServiceBulkSubmission.last&.shift_end || Time.now.beginning_of_day
    BlocksServiceBulkSubmission.delay(run_at: next_run_time(previous_shift_end), queue: QUEUE_NAME).create_virtual_pa_partner_shifts(previous_shift_end)
  end

  def self.shift_length
    RockyConf.blocks_configuration.shift_length.hours
  end
  
  # Given a current running time, assume end time is now - minutes_beforeabandoned, beginning of an hour
  # e.g. given a 2hr shift and a 20 min abandon time, running at 11:25 gives a shift end of 11pm
  def self.shift_end(previous_shift_end = nil)
    previous_shift_end ? (previous_shift_end + shift_length) : (Time.now - RockyConf.minutes_before_abandoned).beginning_of_hour
  end
  
  #Given the current start time, schedule the next run shift length + abandoned + buffer after
  # e.g. give a 2hr shift and a 15 min abandoned length, if this shift is 7am- is 9am, the next start time should be 11:20am
  def self.next_run_time(previous_shift_end = Time.now)
                        #hours                                     #minutes
    previous_shift_end + self.shift_length + (RockyConf.minutes_before_abandoned + 5).minutes
  end
  
  def self.create_virtual_pa_partner_shifts(previous_shift_end)
    end_time = self.shift_end(previous_shift_end)
    shift_start = end_time - self.shift_length
    
    submission = BlocksServiceBulkSubmission.create(shift_start: shift_start, shift_end: end_time)
    submission.run    
  end
  
  
  def run
    self.partners_submitted ||= {}
    RockyConf.blocks_configuration.partners.keys.each do |pid|
      partner = Partner.find_by_id(pid.to_s)
      registrants = []
      if partner
        self.partners_submitted[pid] = {}
        started_registrants = partner.registrants.includes(:canvassing_shift_registrant=>:canvassing_shift).where(home_state: GeoState["PA"]).where("created_at >= ? AND created_at < ?", shift_start, shift_end)
        started_registrants.each do |r|
          # only include complete or submitted registrants that aren't part of another canvassing shift or, if they are part
          # of a shift, include if that shift is submitted and this registrant was created after that shift submission
          registrants << r if (r.status == 'complete' || r.submitted_via_state_api?) && (r.canvassing_shift.nil? || (r.canvassing_shift.submitted_to_blocks && r.created_at > r.canvassing_shift.updated_at))
        end
        if registrants.any?
          self.partners_submitted[pid] = "Submitting #{registrants.count} Registrants"
          self.save
          service = BlocksService.new
          service.upload_complete_shift_for_partner(partner, registrants, shift_start, shift_end)
        else
          self.partners_submitted[pid] = "No Registrants Submitted"
          self.save
        end
      end      
    end
    self.save
    # Schedule the next job if successful. If error through DJ will requeue current job.
    BlocksServiceBulkSubmission.delay(run_at: next_run_time, queue: QUEUE_NAME).create_virtual_pa_partner_shifts(shift_end)
  end
  
  def next_run_time
    self.class.next_run_time(shift_end)
  end

  
  
end
