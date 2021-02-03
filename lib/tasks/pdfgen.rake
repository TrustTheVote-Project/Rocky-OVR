namespace :pdf do
  
  desc "Generate PDFs from the queue"
  task :generate => :environment do
    loop do
      PriorityPdfGeneration.find_and_generate
      PdfGeneration.find_and_generate
    end
  end

  desc "Pre-Generate ABR PDF templates with cover pages"
  task :generate_abr_cover_pages => :environment do
    AbrPdfCoverPageMerger.run
  end


  # Removed these PdfGeneration methods, not tested
  # desc "Empty the queue"
  # task :dequeue => :environment do
  #   loop do
  #     PdfGeneration.find_and_remove
  #   end
  # end
  #
  # desc "Built the HTMLs from the queue"
  # task :htmlify => :environment do
  #   loop do
  #     PdfGeneration.find_and_htmlify
  #   end
  # end
  
end