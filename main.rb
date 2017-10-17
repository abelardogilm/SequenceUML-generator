# Load the bundled environment
require "rubygems"
require "bundler/setup"
require 'json'

def load_json
  JSON.parse(File.read(@file))
end

def generate_uml_file
  body = ["@startuml"]
  body << plantuml_call
  body << connections
  body << "@enduml"
  body.join("\n")
end

def plantuml_call
  "!definelong AUTHEN(x,y,text)
  x -> y : text
  !enddefinelong"
end

def file_basename
  File.basename @file, '.json'
end

def file_name
  "#{file_basename}-#{Time.now.strftime('%Y-%m-%d_%H-%M-%S')}.plantuml"
end

def save_plant_uml body
  File.open(File.join("output", file_name), 'w') {|f| f.write body}
end

def host_to_valid_name host
  return 'N/A' unless host
  host.gsub(/(http[s]?|ftp):\/\//, '').match(/^([a-zA-Z]*)(.*)/)[1]
end

def request_method request
  request.dig request.first.first, "http.request.method"
end

def connections
  @json.map{|x| x["_source"]}.map{|x| x["layers"]['http']}.map{|x|
    ["AUTHEN(#{host_to_valid_name x['http.host']},",
    " #{host_to_valid_name x['http.request.full_uri']},",
    " #{request_method x} - #{x['http.response_in']})"].join
  }.join("\n")
end

@file = ARGV[0]
@json = load_json

save_plant_uml generate_uml_file
