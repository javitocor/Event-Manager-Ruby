require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def day(date) 
  parseDate = DateTime.strptime(date, '%m/%d/%y %H:%M')
  parseDate.strftime("%A")
end

def hour(date)
  return date[-5..-4]
end

def correctNumber(string)
  number = string.delete('^0-9')
  if number.length < 10 || number.length > 11 
    return 'wrong number'
  elsif number.length === 11 
    if number[0] === 1 
      return number[1..10]
    else
      return 'wrong number'
    end
  else 
    return number
  end
end

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end

puts "EventManager initialized."

contents = CSV.open 'small_sample.csv', headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter
peakHour = []
weekDay = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phoneNumber = correctNumber(row[:homephone])  
  legislators = legislators_by_zipcode(zipcode)  
  peakHour.push(hour(row[:regdate])) 
  weekDay << day(row[:regdate])
  form_letter = erb_template.result(binding)

  save_thank_you_letter(id,form_letter)
end

def weekDays(weekDay) 
  peak = weekDay.group_by(&:itself).map { |k,v| [k, v.count] }.to_h  
  peak_sorted = peak.sort_by {|k, v| -v}
  CSV.open("peakDays.csv", "wb") {|csv| peak_sorted.to_a.each {|elem| csv << elem} }
end

weekDays(weekDay)

def peakHours(peakHour)
  peak = peakHour.group_by(&:itself).map { |k,v| [k, v.count] }.to_h  
  peak_sorted = peak.sort_by {|k, v| -v}
  CSV.open("peakHours.csv", "wb") {|csv| peak_sorted.to_a.each {|elem| csv << elem} }
end

peakHours(peakHour)
=begin
require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

puts "EventManager initialized."

contents = CSV.open 'sample_small.csv', headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  Dir.mkdir("output") unless Dir.exists? "output"

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end

end

require 'csv'
require 'google/apis/civicinfo_v2'


template_letter = File.read "form_letter.html"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    legislators = civic_info.representative_info_by_address(
                                  address: zip,
                                  levels: 'country',
                                  roles: ['legislatorUpperBody', 'legislatorLowerBody'])
    legislators = legislators.officials
    legislator_names = legislators.map(&:name)
    legislator_names.join(", ")
  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

puts "EventManager initialized."

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol

contents.each do |row|
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)

  personal_letter = template_letter.gsub('FIRST_NAME',name)
  personal_letter.gsub!('LEGISLATORS',legislators)

  puts personal_letter
end

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    legislators = civic_info.representative_info_by_address(
                                  address: zip,
                                  levels: 'country',
                                  roles: ['legislatorUpperBody', 'legislatorLowerBody'])
    legislators = legislators.officials
    legislator_names = legislators.map(&:name)
    legislator_names.join(", ")
  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

puts "EventManager initialized."

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol

contents.each do |row|
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)

  puts "#{name} #{zipcode} #{legislators}"
end


civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

puts "EventManager initialized."

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol

contents.each do |row|
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  begin
    legislators = civic_info.representative_info_by_address(
                              address: zipcode,
                              levels: 'country',
                              roles: ['legislatorUpperBody', 'legislatorLowerBody'])
    legislators = legislators.officials
  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end

  legislator_names = legislators.map(&:name)

  legislators_string = legislator_names.join(", ")

  puts "#{name} #{zipcode} #{legislators_string}"
end

contents = CSV.open "small_sample.csv", headers: true
contents.each do |row|
  name = row[2]
  puts name
end

contents = CSV.open "small_sample.csv", headers: true, header_converters: :symbol
contents.each do |row|
  name = row[:first_name]
  puts name
end

contents = CSV.open "small_sample.csv", headers: true, header_converters: :symbol
contents.each do |row|
  name = row[:first_name]
  zipcode = row[:zipcode]
  puts "#{name} #{zipcode}"
end

contents = CSV.open 'small_sample.csv', headers: true, header_converters: :symbol

contents.each do |row|
  name = row[:first_name]
  zipcode = row[:zipcode]

  if zipcode.length < 5
    zipcode = zipcode.rjust 5, "0"
  elsif zipcode.length > 5
    zipcode = zipcode[0..4]
  end

  puts "#{name} #{zipcode}"
end

contents = CSV.open 'small_sample.csv', headers: true, header_converters: :symbol

contents.each do |row|
  name = row[:first_name]
  zipcode = row[:zipcode]

  if zipcode.nil?
    zipcode = "00000"
  elsif zipcode.length < 5
    zipcode = zipcode.rjust 5, "0"
  elsif zipcode.length > 5
    zipcode = zipcode[0..4]
  end

  puts "#{name} #{zipcode}"
end

def clean_zipcode(zipcode)
  if zipcode.nil?
    "00000"
  elsif zipcode.length < 5
    zipcode.rjust(5,"0")
  elsif zipcode.length > 5
    zipcode[0..4]
  else
    zipcode
  end
end

contents = CSV.open 'small_sample.csv', headers: true, header_converters: :symbol

contents.each do |row|
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  puts "#{name} #{zipcode}"
end

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end


puts "EventManager Initialized!"

puts File.exist? "small_sample.csv"

contents = File.read "small_sample.csv"
puts contents

lines = File.readlines "small_sample.csv"
lines.each do |line|
  puts line
end

lines = File.readlines "small_sample.csv"
lines.each do |line|
  columns = line.split(",")
  p columns
end

lines = File.readlines "small_sample.csv"
lines.each do |line|
  columns = line.split(",")
  name = columns[2]
  puts name
end

lines = File.readlines "small_sample.csv"
lines.each do |line|
  next if line == " ,RegDate,first_Name,last_Name,Email_Address,HomePhone,Street,City,State,Zipcode\n"
  columns = line.split(",")
  name = columns[2]
  puts name
end

lines = File.readlines "small_sample.csv"
lines.drop(1).each do |line|
  columns = line.split(",")
  name = columns[2]
  puts name
end
=end

