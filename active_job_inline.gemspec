Gem::Specification.new do |s|
  s.name        = "active_job_inline"
  s.summary     = "ActiveJobInline"
  s.version     = "0.0.2"
  s.authors     = ["Aliaksandr Yakubenka"]
  s.email       = "alexandr.yakubenko@startdatelabs.com"
  s.files       = ["lib/active_job_inline.rb"]
  s.license       = "MIT"
  s.add_dependency "redis-mutex"
end
