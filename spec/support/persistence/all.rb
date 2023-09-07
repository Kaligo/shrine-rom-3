Dir[Pathname.new(__dir__).join('relations/*.rb')].sort.each { |f| require f }

require 'pathname'

require_relative 'shrine_attachments'
require_relative 'model'
require_relative 'entities'
require_relative 'repositories'
