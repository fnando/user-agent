require 'bundler/setup'
require 'browser'
require 'rack'
require 'erb'

class Page
  attr_reader :env, :request, :browser, :template

  def initialize(env)
    @env = env
    @request = Rack::Request.new(env)
    @browser = Browser.new(
      ua: request.params['ua'],
      accept_language: request.params['accept_language']
    )
    @template = template = File.read(File.expand_path('../index.erb', __FILE__))
  end

  def default_value(value, default_value)
    if value.kind_of?(String) && value.empty?
      default_value
    else
      value.inspect
    end
  end

  def list_item(label, value, default = '[not detected]')
    value = default_value(value, default)

    <<-HTML
      <li>
        <strong>#{label}</strong>:
        #{value}
      </li>
    HTML
  end

  def to_html
    ERB.new(template).result(binding)
  end

  def to_rack
    if request.params.key?('ua')
      [200, {'Content-Type' => 'text/html'}, [to_html]]
    else
      location = "/?" << URI.encode_www_form(ua: env['HTTP_USER_AGENT'], accept_language: env['HTTP_ACCEPT_LANGUAGE'])
      [
        301,
        {'Content-Type' => 'text/html', 'Location' => location},
        [%[You were redirected to <a href="#{location}">#{location}</a>]]
      ]
    end
  end
end
