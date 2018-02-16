# Update common email typos
count = 0
1.times do
  Registrant.where("created_at > ?", 15.days.ago).find_each(:batch_size=>100) do |reg|
    if reg.email_address =~ /\.con$/
      e = reg.email_address.gsub(/\.con$/, ".com")
      count += 1
      puts "#{reg.email_address} => #{e}"
      reg.email_address = e
      reg.save!
    elsif reg.email_address =~ /\.comm$/
      e = reg.email_address.gsub(/\.comm$/, ".com")
      count += 1
      puts "#{reg.email_address} => #{e}"
      reg.email_address = e
      reg.save!
    end
  end
end
puts count