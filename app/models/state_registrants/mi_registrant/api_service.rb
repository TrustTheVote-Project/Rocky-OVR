module StateRegistrants::MIRegistrant::ApiService
  
  #response codes
  # 0.0: Error message attached
  # 4.0: Failure: Address update failed ?
  # 5.0: Underage Voter
  # 9.0: Adressed matched ?
  # 12.0: Ineligible

  # 6.0: Expired License, send to paper with note

  # 1.0: Success: New Registration
  # 2.0: Success: Already REgistrered at this address
  # 3.0: Success: Address updated
  
  # 10.0: RECORD NOT PROCESSED, busy queue for retry
  # 11.0: Error while processing, busy queue for retry
  
  # 7.0: License not found - try again
  # 8.0: Address not found - try again
  def submitted?
    self.mi_submission_complete?
    #self.registrant.skip_state_flow?
  end
  
  def submit_to_online_reg_url
    
    # Do the actual submission
    # if failed, call self.registrant.skip_state_flow!
    if self.full_name.downcase.strip== "error error"
      self.registrant.skip_state_flow!
    else
      self.mi_transaction_id = "ABC123SAMPLEID"
    end
  ensure
    self.mi_submission_complete = true
    self.save(validate: false)  
  end
  
  
  def to_nist_format
  end
  
end