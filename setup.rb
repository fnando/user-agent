# frozen_string_literal: true

require "bundler/setup"
require "browser"
require "rack"
require "erb"
require "json"
require "rouge"
require "sinatra"

require_relative "report"

helpers do
  def accept_language
    request.env["HTTP_ACCEPT_LANGUAGE"]
  end

  def user_agent
    request.env["HTTP_USER_AGENT"]
  end

  def user_agent_param
    Hash[
      URI.decode_www_form(URI.parse(request.env["REQUEST_URI"]).query.to_s)
    ].fetch("ua")
  end

  def accept_language_param
    params.fetch(:al)
  end

  def report_json
    formatter = Rouge::Formatters::HTML.new
    lexer = Rouge::Lexers::JSON.new
    formatter.format(lexer.lex(report.to_json))
  end

  def report
    Report.new(user_agent_param, accept_language_param)
  end

  def gem_version
    Browser::VERSION
  end
end

get "/" do
  unless params[:ua]
    escaped_ua = CGI.escape(user_agent)
    escaped_language = CGI.escape(accept_language)
    redirect to("/?ua=#{escaped_ua}&al=#{escaped_language}")
    return
  end

  erb :report
end

get "/json" do
  content_type :json

  Report.new(user_agent_param, accept_language_param).to_json
end
