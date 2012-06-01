require 'pathname'
require 'fileutils'

$>.sync = true

@src_dir = File.expand_path('../js/src', __FILE__)
@src_ext = '.coffee'
@dst_dir = File.expand_path('../js/bin', __FILE__)
@dst_ext = '.js'

@cmd = 'coffee -co :dst_dir :src'

@interval = 1 # sec

@files = {}
def check methods
  files = Dir[File.join(@src_dir, "**/*#{@src_ext}")]
  files.each do |f|
    t = @files[f]
    if t.nil?
      methods[:added].call f
      @files[f] = File.mtime(f)
    elsif File.mtime(f) != t
      methods[:updated].call f
      @files[f] = File.mtime(f)
    end
  end
  (@files.keys - files).each do |f|
    methods[:deleted].call f
    @files.delete f
  end
end

def dst_of src
  dir, basename = File.split(src)
  dir = Pathname.new(@dst_dir) + Pathname.new(dir).relative_path_from(Pathname.new(@src_dir)).to_s
  basename = File.basename(basename, @src_ext) + @dst_ext
  (dir + basename).to_s
end

def compile f, force = false
  dst = dst_of(f)
  if force || !File.exist?(dst) || File.mtime(dst) < File.mtime(f)
    dst_dir = File.dirname(dst)
    FileUtils.mkdir_p dst_dir
    cmd = @cmd.gsub(/:src/, f).gsub(/:dst_dir/, dst_dir)
    `#{cmd}`
    print "\a"
  end
end

def delete f
  dst = dst_of(f)
  if File.exist? dst
    File.delete dst
  end
end

@methods = {
  added: lambda do |f|
    puts "#{Time.now.strftime('%T')} - added #{f}"
    compile f
  end,
  updated: lambda do |f|
    puts "#{Time.now.strftime('%T')} - updated #{f}"
    compile f
  end,
  deleted: lambda do |f|
    puts "#{Time.now.strftime('%T')} - deleted #{f}"
    delete f
  end,
}


def run
  loop do
    check @methods
    sleep @interval
  end
end

run


