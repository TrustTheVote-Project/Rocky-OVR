class BlocksFormDispositionJob < CronJob
  # set the (default) cron expression
  self.cron_expression = '*/5 * * * *'

  def perform
    BlocksFormDisposition.submit_updates!
  end
end