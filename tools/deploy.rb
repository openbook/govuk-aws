#!/usr/bin/env ruby

require 'net/http'
require 'net/https'
require 'json'
require 'uri'

# Fields from the command line
command = ARGV[0]
environment = ARGV[1]
stack = ARGV[2]
project = ARGV[3]

# Valid values for each field
valid_commands = %w(plan apply destroy).freeze
valid_environments = %w(integration staging production test tools).freeze
valid_stacks = %w(blue green govuk).freeze

usage = 'Usage: GITHUB_USERNAME=... GITHUB_TOKEN=... ruby deploy.rb <command> <environment> <stack> <project>'

abort("GITHUB_USERNAME environment variable must be set\n#{usage}") unless ENV.has_key?('GITHUB_USERNAME')
abort("GITHUB_TOKEN environment variable must be set\n#{usage}") unless ENV.has_key?('GITHUB_TOKEN')
abort("command must be one of #{valid_commands.join(', ')}\n#{usage}") unless valid_commands.include?(command)
abort("environment must be one of #{valid_environments.join(', ')}\n#{usage}") unless valid_environments.include?(environment)
abort("stack must be one of #{valid_stacks.join(', ')}\n#{usage}") unless valid_stacks.include?(stack)

# Make sure the user is happy to go ahead
puts "You're about to #{command} the #{stack}/#{project} project in #{environment}"
puts 'Do you want to go ahead? [y/N]'
continue = STDIN.gets.chomp
abort('Build aborted') unless continue.downcase == 'y'

# Jenkins details
jenkins_url = 'https://ci-deploy.integration.publishing.service.gov.uk'.freeze
jenkins_crumb_issuer_path = '/crumbIssuer/api/json'.freeze
jenkins_job_path = '/job/Deploy_Terraform_GOVUK_AWS/buildWithParameters'.freeze
jenkins_crumb_issuer_uri = URI.parse("#{jenkins_url}#{jenkins_crumb_issuer_path}")
jenkins_job_uri = URI.parse("#{jenkins_url}#{jenkins_job_path}")

# Get temporary AWS credentials
puts 'Requesting temporary AWS credentials...'

aws_credentials_string = `govuk aws --profile govuk-#{environment} --export-json`
abort('Could not get temporary AWS credentials') unless $?.exitstatus.zero?

aws_credentials = JSON.parse(aws_credentials_string)

# Get a Jenkins "crumb" to authenticate the next request
puts 'Requesting Jenkins crumb...'
jenkins_crumb_http = Net::HTTP.new(jenkins_crumb_issuer_uri.host, jenkins_crumb_issuer_uri.port)
jenkins_crumb_http.use_ssl = true
jenkins_crumb_request = Net::HTTP::Get.new(jenkins_crumb_issuer_uri.path)
jenkins_crumb_request.basic_auth(ENV['GITHUB_USERNAME'], ENV['GITHUB_TOKEN'])
jenkins_crumb_response = jenkins_crumb_http.request(jenkins_crumb_request)
abort('Could not get crumb from Jenkins') unless jenkins_crumb_response.code == '200'
jenkins_crumb = JSON.parse(jenkins_crumb_response.body)

# Make a request to the Jenkins API to queue the build
puts 'Queuing Jenkins job...'
jenkins_job_http = Net::HTTP.new(jenkins_job_uri.host, jenkins_job_uri.port)
jenkins_job_http.use_ssl = true
jenkins_job_request = Net::HTTP::Post.new(jenkins_job_uri.path)
jenkins_job_request.basic_auth(ENV['GITHUB_USERNAME'], ENV['GITHUB_TOKEN'])
jenkins_job_request.set_form_data({
  'AWS_ACCESS_KEY_ID' => aws_credentials['access_key_id'],
  'AWS_SECRET_ACCESS_KEY' => aws_credentials['secret_access_key'],
  'AWS_SESSION_TOKEN' => aws_credentials['session_token'],
  'COMMAND' => command,
  'ENVIRONMENT' => environment,
  'STACKNAME' => stack,
  'PROJECT' => project
})
jenkins_job_request[jenkins_crumb['crumbRequestField']] = jenkins_crumb['crumb']
jenkins_job_response = jenkins_job_http.request(jenkins_job_request)

abort('Could not queue Jenkins job') unless jenkins_job_response.code == '201'

puts 'Jenkins job queued'
