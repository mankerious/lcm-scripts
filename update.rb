require 'bundler/setup'
require 'gooddata'
require 'active_support/all'
require_relative 'credentials'
require 'colorize'
require 'peach'
require 'json-compare'
require 'yajl'

VALID_PROJECTS = [MASTERPROJECT1]
@segment_id = SEGMENTID
@client_name = CLIENTNAMES
@parameter_value = PARAMETERVALUES
@project = Array.new
@index = Array.new
@index = CLIENTSINDEX

  GoodData.logging_http_on
  
  client = GoodData.connect(LOGIN, PASSWORD)
  @projects = VALID_PROJECTS.pmap { |pid| client.projects(pid) }
  domain = client.domain(DOMAIN)
  @master_project = client.projects(@projects[0].pid)

  blueprint = @master_project.blueprint
  puts blueprint
  blueprint.store_to_file('updated.json')

 # parser = Yajl::Parser.new
  json1 = File.new('original.json', 'r')
  json2 = File.new('updated.json', 'r')
  old1, new1 = Yajl::Parser.parse(json1), Yajl::Parser.parse(json2)
  result = JsonCompare.get_diff(old1, new1)
  puts result

  #Clone the client project with the ETL including graph, schedule and parameter

  # @index.each do |i|
  #   puts @client_name[i].green
  #   @project[i] = GoodData::Project.clone_with_etl(@master_project,:title => @client_name[i], auth_token: TOKEN)  
  #   @schedule = @project[i].processes.first.schedules.first
  #   @schedule.update_params({PARAMETER => @parameter_value[i]})
  #   @schedule.save
  #   @schedule.execute
  # end

  # puts "All client workspaces have been created successfully.. would you like to delete them now?(y/n)".blue
  # answer=gets.chomp
  # if answer == "y"
  #   #Delete the client workspaces
  #     @project.each do |p| 
  #         GoodData.with_project(p.pid) do |project|
  #             project.delete
  #         end
  #     end


  # end



