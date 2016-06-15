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
  @master_project = client.projects(@projects[0].pid)

  #Clone the client project with the ETL including graph, schedule and parameter

  @index.each do |i|
    puts @client_name[i].green
    @project[i] = GoodData::Project.clone_with_etl(@master_project,:title => @client_name[i], auth_token: TOKEN)  
    @schedule = @project[i].processes.first.schedules.first
    @schedule.update_params({PARAMETER => @parameter_value[i]})
    @schedule.save
    @schedule.execute
  end

  puts "All client workspaces have been created successfully.. would you like to delete them now?(y/n)".blue
  answer=gets.chomp
  if answer == "y"
    #Delete the client workspaces
      @project.each do |p| 
          GoodData.with_project(p.pid) do |project|
              project.delete
          end
      end


  end



