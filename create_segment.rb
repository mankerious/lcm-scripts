require 'bundler/setup'
require 'gooddata'
require 'active_support/all'
require_relative 'credentials'
require 'colorize'
require 'peach'

VALID_PROJECTS = [MASTERPROJECT1]
@segment_id = SEGMENTID
@client_name = CLIENTNAMES
@parameter_value = PARAMETERVALUES
@project = Array.new
@index = Array.new
@index = CLIENTSINDEX

app_state = {
  segments: []
}

GoodData.logging_http_on
  
  client = GoodData.connect(LOGIN, PASSWORD)
  @projects = VALID_PROJECTS.pmap { |pid| client.projects(pid) }
  domain = client.domain(DOMAIN)
  begin
    #get the first valid project to use as a master, then create the segment and associate it to the master project
    @master_project = client.projects(@projects[0].pid)
    @segment = domain.create_segment(segment_id: @segment_id, master_project: @master_project)
    puts "Segment #{@segment_id} created successfully".green
  end

  puts "Segment's master project pid is #{@master_project.pid}"

