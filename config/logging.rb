require 'logger'

configure do
  LOGGER = Logger.new(STDOUT)
end

configure :development do
  require 'pry'
end