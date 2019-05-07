require "io/console"
CURSOR_HIGHLIGHT = ""

buffer = Array.new(1) {Array.new(1) {[Hash.new {|h,k| h[k] = ""}, " "]}}
#require 'pry'; binding.pry

50.times do
  buffer[0] << [{}, "X"]
end

# buffer[0].each do |x|
#   print "#{x[0]}#{x[1]}"
# end

def getchar
  STDIN.echo = false
  STDIN.raw!

  input = STDIN.getc.chr
  if input == "\e" then
    input << STDIN.read_nonblock(3) rescue nil
    input << STDIN.read_nonblock(2) rescue nil
  end
ensure
  STDIN.echo = true
  STDIN.cooked!

  return input
end

TESTRING = "asdfghjklqwertyuiop"
def edit(string)
  print "\e[?25l"

  editing = string.dup
  maxlen = string.length
  x = maxlen + 1
  print "\e[0m#{editing}\e[;#{$bgcurs}m "
  char = getchar
  while char != "\e" do
    case char
    when "\u0003"
      print "\e[0m\e[?25h\n"
      exit 0
    when "\e[D" #left
      x -= 1; if x < 1 then x = 1
    elsif x == maxlen then print "\e[0m\b \b\b\e[;#{$bgcurs}m#{editing[x-1]}"
    else print "\e[0m\b#{editing[x]}\e[D\e[;#{$bgcurs}m\b#{editing[x-1]}"
      end
    when "\e[C" #right
      x += 1; if x > (maxlen+1) then x = maxlen+1
    elsif x == (maxlen+1) then print "\e[0m\b#{editing[x-2]}\e[;#{$bgcurs}m "
    else print "\e[0m\b#{editing[x-2]}\e[C\e[;#{$bgcurs}m\b#{editing[x-1]}"
      end
    when /[\n\r]/
      break
    when "\b"
      editing.slice!(x-2); maxlen -= 1
      x -= 1; if x < 1 then x = 0
      else
        print "\e[0m\e[2K\e[G#{editing}\e[#{x}G"
        if x == (maxlen+1) then
          print "\e[;#{$bgcurs}m "
        else
          print "\e[C\e[;#{$bgcurs}m\b#{editing[x-1]}"
        end
      end
    when /^.$/
      if x == (maxlen+1) then
        editing << char; maxlen += 1; x += 1
        print "\e[0m\b#{char}\e[;#{$bgcurs}m "
      elsif $insert
        editing[x-1] = char; x += 1
        # if x == maxlen then
          # print "\e[0m\b#{editing[x-2]}\e[C#{editing[x-1]}\e[;#{$bgcurs}mX"
        # else
          print "\e[0m\b#{editing[x-2]}\e[C\e[;#{$bgcurs}m\b#{editing[x-1]}"
        # end
          if x == maxlen then print "X" end
      else
        editing.insert(x-1, char); maxlen += 1; x += 1
        print "\e[0m\e[2K\e[G#{editing[0..(x-2)]}\e[;#{$bgcurs}m#{editing[x-1]}\e[0m#{editing[x..-1]}\e[#{x+1}G"
      end
    end
    char = getchar
  end
end

$bgcurs = "48;5;244"
$insert = false
edit(TESTRING)
print "\e[0m\e[?25h\n"