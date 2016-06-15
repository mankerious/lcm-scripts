require 'bundler/setup'
require 'gooddata'
require 'active_support/all'
require_relative 'credentials'
require 'colorize'

VALID_PROJECTS = [MASTERPROJECT1]
@segment_id = SEGMENTID
@client_name1 = CLIENTNAME1
@client_name2 = CLIENTNAME2
@client_name3 = CLIENTNAME3

app_state = {
  segments: []
}

GoodData.logging_http_on
  
  client = GoodData.connect(LOGIN, PASSWORD)
  @projects = VALID_PROJECTS.pmap { |pid| client.projects(pid) }
  #display the pid of the valid project from the credentials file
  domain = client.domain(DOMAIN)
  begin
    #get the first valid project to use as a master, then create the segment and associate it to the master project
    @master_project = client.projects(@projects[0].pid)
    @segment = domain.create_segment(segment_id: @segment_id, master_project: @master_project)
  end

  puts @master_project.pid.green
  puts @client_name1.green
  puts TOKEN.green

  #Clone the client project with the ETL including graph, schedule and parameter
  @project = GoodData::Project.clone_with_etl(@master_project,:title => @client_name1, auth_token: TOKEN)  

#  domain.segments(@segment_id).create_client(id: @client_name1, project: client.projects(@project))

  @schedule = @project.processes.first.schedules.first
  @schedule.update_params({PARAMETER => PARAMETERVALUE1})
  @schedule.save
  @schedule.execute

#  @project = domain.segments(@segment_id).master_project.clone(:title => @client_name1, auth_token: TOKEN).pid

#************2nd Client
  puts @client_name2.green
  @project = GoodData::Project.clone_with_etl(@master_project,:title => @client_name2, auth_token: TOKEN)  
  @schedule = @project.processes.first.schedules.first
  @schedule.update_params({PARAMETER => PARAMETERVALUE2})
  @schedule.save
  @schedule.execute

  #************3rd Client
  puts @client_name3.green
  @project = GoodData::Project.clone_with_etl(@master_project,:title => @client_name3, auth_token: TOKEN)  
  @schedule = @project.processes.first.schedules.first
  @schedule.update_params({PARAMETER => PARAMETERVALUE3})
  @schedule.save
  @schedule.execute

