# You will paginate!
module WillPaginate
end

if defined?(Rails::Railtie)
  require 'will_paginate/railtie'
end

if defined?(Sinatra) and Sinatra.respond_to? :register
  require 'will_paginate/view_helpers/sinatra'
end
