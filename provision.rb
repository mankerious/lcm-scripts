#require 'bundler/setup'
require 'gooddata'
require 'active_support/all'
require_relative 'configuration'
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
  segment = domain.segments(SEGMENTID)
  @master_project = client.projects(@projects[0].pid)
  clients = []

  #Clone the client project with the ETL including graph, schedule and parameter

  @index.peach do |i|
    puts @client_name[i].green
    @project[i] = GoodData::Project.clone_with_etl(@master_project,:title => " #{@client_name[i]}", auth_token: TOKEN)  
    schedule = @project[i].processes.first.schedules.first
    schedule.update_params({PARAMETER => @parameter_value[i]})
    schedule.save
    schedule.execute
    segment_client = segment.create_client(id: "client_#{@parameter_value[i]}")
    segment_client.project = @project[i]
    segment_client.save
    clients << segment_client
  end

  puts "All client workspaces have been created successfully.. would you like to delete them now?(y/n)".blue
  answer=gets.chomp
  if answer == "y"
      #Delete the client workspaces
      @project.each { |p| p.delete }
      clients.each { |sc| sc.delete }
  end



