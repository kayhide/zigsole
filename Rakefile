@jstestdriver_dir = 'c:/usr/jsTestDriver'

def coffee arg
  sh "coffee #{arg}"
end

def java arg
  sh "java #{arg.gsub '/', '\\'}"
end

desc 'watches coffee files.'
task 'watch' do
  coffee '-wco js/bin js/src'
end

desc 'launches tests server.'
task 'run-test-server' do
  java "-jar #{@jstestdriver_dir}/JsTestDriver-1.3.4.b.jar --port 4224"
end

desc 'runs tests.'
task 'test' do
  puts 'testing...'
  cd File.expand_path('../js', __FILE__)
  
  coffee '-co test/js test'
  java "-jar #{@jstestdriver_dir}/JsTestDriver-1.3.4.b.jar --tests all"
end


