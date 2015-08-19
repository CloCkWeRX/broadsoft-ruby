require 'rubygems'
require 'rubygems/package_task'

spec = Gem::Specification.new do |s|
    s.platform  =   Gem::Platform::RUBY
    s.name      =   "broadsoft"
    s.version   =   "0.1.0"
    s.author    =   "Thomas McCarthy-Howe"
    s.email     =   "howethomas @nospam@ aol.com"
    s.summary   =   "A package for controllign a Broadworks switch."
    s.files     =   FileList['lib/*.rb', 'test/*'].to_a
    s.require_path  =   "lib"
    s.homepage = "http://broadsoft.rubyforge.org" 
    s.rubyforge_project = 'broadsoft'
    s.has_rdoc  =   true
    s.extra_rdoc_files  =   ["README"]
end

Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = true
end

task :default => "pkg/#{spec.name}-#{spec.version}.gem" do
    puts "generated latest version"
end 