require 'net/ftp'
class PdfDelivery < ActiveRecord::Base
  
  belongs_to :registrant
  
  def generate_pdf!
    generate_pdf(true)
  end
  
  def generate_pdf(force = false)
    if registrant.pdf_writer.valid?
      if registrant.pdf_writer.generate_pdf(force, true)
        return true
      else
        return false
      end
    else
      return false
    end
  end
  
  def finalize_pdf
    self.pdf_ready = true
    save(validate: false)
  end
  
  # URL is ftp.garnerprint.com
  # User name:whenwevote
  # Password: redfq86#
  def self.transfer(local_path)
    #file_name = 
    
    port = 21
    ftp = Net::FTP.new  # don't pass hostname or it will try open on default port
    ftp.connect('ftp.garnerprint.com', port)  # here you can pass a non-standard port number
    ftp.passive = true
    ftp.login('whenwevote', 'redfq86#')
    files = ftp.list('*')
    puts files
    ftp.close
    
    # Net::FTP.open('ftp.garnerprint.com') do |ftp|
    #   ftp.login('whenwevote', 'redfq86#')
    #   files = ftp.list('*')
    #   puts files
    #   #ftp.getbinaryfile('nif.rb-0.91.gz', 'nif.gz', 1024)
    # end
    
    
  end
  
end
