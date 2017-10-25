require 'date'

Gem::Specification.new do |s|
  s.name        = 'mongo_missing_indexes'
  s.version     = '0.2.0'
  s.date        = Date.today.to_s
  s.summary     = "Detect missing indexes in mongo queries"
  s.description = "Detect missing indexes in mongo queries"
  s.authors     = [
    "Scott Taylor",
  ]
  s.email       = 'scott@railsnewbie.com'
  s.files       = Dir.glob("lib/**/**.rb")
  s.homepage    =
    'http://github.com/GoLearnUp/mongo_missing_indexes'
  s.license       = 'MIT'
end
