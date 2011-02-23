#!/Users/tyler/.rvm/rubies/ruby-1.8.7-p330/bin/ruby -w
=begin
Filename: imsxmlwriter.rb
Author: Tyler Clair
About: This ruby script generates an IMS compatiable XML file from a CSV file
that contains the CRN (Course Record Number) and the section name of a course.
This file can be imported into the Blackboard Vista Learning Management System
via the Imports form on the Administration tab in Vista.
=end
require 'rubygems'
require 'builder'
require 'Fastercsv'

#arguments
csv_file = ARGV[0]
xml_file = ARGV[1]
data_source = ARGV[2]
term_code = ARGV[3]
append_text = ARGV[4]

#check if all arguments are there, prompt if there is an error.
unless ARGV.length == 5
  puts "Incorrect number of arguments supplied."
  puts "Usage: ruby hashtest.rb input_file.csv \"Data Source\" output_file.xml term_code semester_text"
  exit
end

t = Time.now
file = File.new(xml_file, "w")
x = Builder::XmlMarkup.new(:target=>file, :indent => 2)
x.instruct!
x.enterprise {
  x.properties {
    x.datasource data_source
    x.datetime t.strftime("%Y-%m-%dT%H:%M:%S")
  }
  #loop through csv file and create a hash of each row and output xml
  FasterCSV.foreach(csv_file, :headers => true) do |row|
    sections = row.to_hash
    x.group("recstatus" => "2") {
      x.sourcedid {
        x.source data_source
        #CRN for each row is inserted here
        x.id sections['crn'] + "." + term_code
      }
      x.grouptype {
        x.scheme "LEARNING_CONTEXT_V1"
        x.typevalue("level" => "90")
      }
      x.description {
        #section name for each row is inserted here
        x.short sections['sectionname'] + append_text 
      }
      x.relationship("relation" => "1") {
        x.sourcedid {
          x.source data_source
          x.id term_code
        }
        x.label "Term"
      } 
    }
  end #end group loop
}