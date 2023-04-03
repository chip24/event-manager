require "csv"
require "google/apis/civicinfo_v2"
require "erb"
require "time"
require "date"


def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone(home_phone)
    phone_number = home_phone.tr('^0-9','')
    if phone_number.to_s.length == 10
        puts phone_number
    elsif phone_number.to_s.length < 10
        puts "Phone number too short."
    elsif phone_number.to_s.length == 11 && phone_number[0] == 1
        phone number = phone_number[1..10]
        puts phone_number
    elsif phone_number.to_s.length == 11 && phone_number[0] != 1
        puts "Phone number does not begin with 1."
    else
        puts "Phone number too long."
    end
end

    
def legislators_by_zipcode(zip)
    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw' 

    begin
        legislators = civic_info.representative_info_by_address(address: zip, levels: 'country', roles: ['legislatorUpperBody', 'legislatorLowerBody']).officials

    rescue
        "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials."
    end
end

def get_time(time)
    a = Time.strptime(time, "%m/%d/%Y %k:%M")
    donate_time = a.strftime("%k:%M")
    puts donate_time
end

def get_day(time)
    b = Time.strptime(time, "%m/%d/%Y %k:%M")
    day_of_week = b.wday
    day_name = Date::DAYNAMES[day_of_week]
    puts day_of_week
    puts day_name
end


def save_thank_you_letter(id, form_letter)
    Dir.mkdir('output') unless Dir.exist?('output')

    filename = "output/thanks_#{id}.html"

    File.open(filename,'w') do |file|
        file.puts form_letter
    end

end


puts "Event Manager Initialized!"

#File.exists? "event_attendees.csv"

=begin
contents = File.read('event_attendees.csv')
puts contents

lines = File.readlines("event_attendees.csv")
lines.each_with_index do |line,index|
    next if index == 0
    columns = line.split(",")
    #p columns
    name = columns[2]
    puts name
end
=end

contents = CSV.open("event_attendees.csv", headers:true, header_converters: :symbol)

template_letter = File.read('/home/chip/repos/event-manager/form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
    id = row[0]
    name = row[:first_name]

    

    zipcode = clean_zipcode(row[:zipcode])

    legislators = legislators_by_zipcode(zipcode)

    form_letter = erb_template.result(binding)

    save_thank_you_letter(id, form_letter)

    #puts "#{name} #{zipcode} #{legislators}"
    phone_number = clean_phone(row[:homephone])
    #puts "#{phone_number}"

    time = get_time(row[:regdate])
    #time = row[:regdate]
    #puts time

    day = get_day(row[:regdate])

    


end





