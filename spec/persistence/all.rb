Dir[Pathname.new(__dir__).join('relations')].sort.each { |f| require f }
