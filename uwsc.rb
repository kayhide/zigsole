str = 'cd /c/htdocs/coffee/zigsole'
str = 'sh watch.sh'

lines = str.each_char.map do |ch|
  ch = case ch
  when ' '
    'SPACE'
  when '.'
    'OEM_PERIOD'
  when '-'
    'OEM_MINUS'
  when '/'
    'OEM_2'
  else
    ch.upcase
  end
    
  "KBD(VK_#{ch},CLICK,40)"
end

puts lines
