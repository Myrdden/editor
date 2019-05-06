require 'io/console'

$beat = 20
def read_char
  STDIN.echo = false
  STDIN.raw!

  input = STDIN.getc
  value = ""
  t = 0
  while t < $beat do
    started = Time.now
    if input != nil then
      # if input.chr == "\e" then
      #   input << STDIN.read_nonblock(3) rescue nil
      #   input << STDIN.read_nonblock(2) rescue nil
      # end
      value << input.chr
      t = 0
    else
      ended = Time.now
      t += (ended - started)*1000
    end
    input = STDIN.read_nonblock(1) rescue nil
  end
ensure
  STDIN.echo = true
  STDIN.cooked!
  return value
end

# oringal case statement from:
# http://www.alecjacobson.com/weblog/?p=75
def show_single_key
  c = read_char

  case c
  when " "
    puts "SPACE"
  when "\t"
    puts "TAB"
  when "\r"
    puts "RETURN"
  when "\n"
    puts "LINE FEED"
  when "\e"
    puts "ESCAPE"
  when "\e[A"
    puts "UP ARROW"
  when "\e[B"
    puts "DOWN ARROW"
  when "\e[C"
    puts "RIGHT ARROW"
  when "\e[D"
    puts "LEFT ARROW"
  when "\177"
    puts "BACKSPACE"
  when "\004"
    puts "DELETE"
  when "\e[3~"
    puts "ALTERNATE DELETE"
  when "\u0003"
    puts "CONTROL-C"
    exit 0
  when /^.$/
    puts "SINGLE CHAR HIT: #{c.inspect}"
  else
    puts "SOMETHING ELSE: #{c.inspect}"
  end
end



def do_the_thing
  command = read_char

  if command == "\u0003"
    exit 0
  end
  puts "You entered: #{command}"
end

do_the_thing while true