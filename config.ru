require File.expand_path("../page", __FILE__)
run -> env { Page.new(env).to_rack }
