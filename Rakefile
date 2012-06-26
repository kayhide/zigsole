require 'net/ftp'
require 'pathname'

@host = ENV['HOST']
@username = ENV['USERNAME']
@password = ENV['PASSWORD']
@dir = ENV['DIR']
@uploding_files = ['**/*.js', '**/*.html', '**/*.css', 'asset/**/*', 'libs/**/*']

@jstestdriver_dir = 'c:/usr/jsTestDriver'

$>.sync = true

def coffee arg
  sh "coffee #{arg}"
end

def java arg
  sh "java #{arg.gsub '/', '\\'}"
end

desc 'watches coffee files.'
task :watch do
  coffee '-wco js/src js/coffee'
end

desc 'starts test server.'
task :start_test_server do
  java "-jar #{@jstestdriver_dir}/JsTestDriver-1.3.4.b.jar --port 4224"
end

desc 'runs tests.'
task :test do
  puts 'testing...'
  cd File.expand_path('../js', __FILE__)
  
  coffee '-co test/js test'
  java "-jar #{@jstestdriver_dir}/JsTestDriver-1.3.4.b.jar --tests all"
end

desc 'uploads by ftp.'
task :upload do
  ftp = Net::FTP.new(@host, @username, @password)
  puts "login: #{@username}:#{@host}"
  
  root = File.expand_path("..", __FILE__)
  files = @uploding_files.map do |ptn|
    Dir[File.join(root, ptn)]
  end.inject(&:+)
  files.select do |file|
    File.file? file
  end.each do |file|
    dir = File.join(@dir, file.pathmap("%{#{root},}d"))
    ftp.move_to dir
    ftp.update_file file, File.basename(file)
  end
  puts 'done.'
end



class Net::FTP
  def move_to path
    @pwd ||= Pathname.new(self.pwd)
    path = Pathname.new(path) unless Pathname === path
    
    if path != @pwd
      path = path.relative_path_from(@pwd)
      path.each_filename do |basename|
        unless self.nlst.include? basename
          self.mkdir basename
          puts "mkdir: #{basename}"
        end
        self.chdir basename
        @pwd = Pathname.new(self.pwd)
        puts "chdir: #{@pwd}"
      end
    end
  end
  
  def update_file src, dst
    @timestamps ||= {}
    @pwd ||= Pathname.new(self.pwd)
    @timestamps[@pwd] ||= Hash[self.get_timestamps]
    
    unless @timestamps[@pwd][dst] && @timestamps[@pwd][dst] > File.mtime(src)
      self.put src, dst
      puts "put: #{File.basename(src)}"
    end
  end
  
  def get_timestamps
    self.list.map do |line|
      data = line.split
      filename = data.last
      year, month, day = data[7], data[5], data[6]
      if year =~ /\d+:\d+/
        hour, min = year.split(':')
        year = Time.now.year
        [filename, Time.new(year, month, day, hour, min)]
      else
        [filename, Time.new(year, month, day)]
      end
    end
  end
end
