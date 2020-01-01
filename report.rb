# frozen_string_literal: true

class Report
  attr_reader :browser

  def initialize(user_agent, accept_language)
    @browser = Browser.new(user_agent, accept_language: accept_language)
  end

  def as_json(*)
    map_attributes(browser)
  end

  def map_attributes(target, except = [])
    method_list(target, except).each_with_object({}) do |method_name, buffer|
      value = target.public_send(method_name)

      buffer[method_name] = case method_name
                            when :device, :bot, :platform
                              map_attributes(value)
                            when :accept_language
                              value.map do |accept_language|
                                {
                                  code: accept_language.code,
                                  region: accept_language.region,
                                  name: accept_language.name,
                                  quality: accept_language.quality,
                                  full: accept_language.full
                                }
                              end
                            when /\?$/
                              !!value
                            else
                              value
                            end
    end
  end

  def to_json(*)
    JSON.pretty_generate(as_json)
  end

  def method_list(target, except = [])
    (target.public_methods - Object.instance_methods)
      .sort
      .reject {|name| except.include?(name) }
  end
end
