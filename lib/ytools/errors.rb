
module YTools
  Error = Class.new(RuntimeError)

  ConfigurationError = Class.new(YTools::Error)
  PathError          = Class.new(YTools::Error)
end
