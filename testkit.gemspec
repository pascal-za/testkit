Gem::Specification.new do |s|
  s.name = "testkit"
  s.version = "0.0.1"
  s.authors = ["Pascal Houliston"]
  s.email = "101pascal@gmail.com"
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {spec,features}/*`.split("\n")
  s.homepage = "http://github.com/pascalh1011/testkit"
  s.require_path = "lib"
  s.rubygems_version = "1.3.5"
  s.summary = "Portmanteau of test::unit and webkit, a combination for great integration testing!"
  s.add_runtime_dependency "rails", "~> 3.0.0"
  s.add_runtime_dependency "turn"
  s.add_runtime_dependency "thin"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "thoughtbot-shoulda"
  s.add_development_dependency "sqlite3"
end

