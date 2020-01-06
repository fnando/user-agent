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

  def report_json
    formatter = Rouge::Formatters::HTML.new
    lexer = Rouge::Lexers::JSON.new
    formatter.format(lexer.lex(report.to_json))
  end

  def report
    Report.new(user_agent, accept_language)
  end
end

get "/" do
  redirect to("/?ua=#{CGI.escape(user_agent)}") unless params[:ua]

  erb :report
end

get "/json" do
  content_type :json

  Report.new(
    request.env["HTTP_USER_AGENT"],
    request.env["HTTP_ACCEPT_LANGUAGE"]
  ).to_json
end
