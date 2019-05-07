class Mode_Edit
  def self.init
    @insert = false
    @bgcurs = "48;5;244"
  end

  def self.getchar
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

  def self.edit(string, from, to)
    #$stdout << "\e[?25l"

    maxlen = string.length
    x = maxlen + 1
    $stdout << "\e[0m#{string}\e[;#{@bgcurs}m "
    char = self.getchar
    while char != "\e" do
      case char
      when "\u0003"
        $stdout << "\e[0m\e[?25h\n"
        exit 0
      when "\e[D" #left
        x -= 1
        if x < 1 then x = 1
        elsif x == maxlen then $stdout << "\e[0m\b \b\b\e[;#{@bgcurs}m#{string[x-1]}"
        else $stdout << "\e[0m\b#{string[x]}\e[D\e[;#{@bgcurs}m\b#{string[x-1]}"
        end
      when "\e[C" #right
        x += 1
        if x > (maxlen+1) then x = maxlen+1
        elsif x == (maxlen+1) then $stdout << "\e[0m\b#{string[x-2]}\e[;#{@bgcurs}m "
        else $stdout << "\e[0m\b#{string[x-2]}\e[C\e[;#{@bgcurs}m\b#{string[x-1]}"
        end
      when /[\n\r]/
        break
      when "\b"
        string.slice!(x-2); maxlen -= 1
        x -= 1
        if x < 1 then x = 0
        else
          $stdout << "\e[0m\e[2K\e[G#{string}\e[#{x}G"
          if x == (maxlen+1) then
            $stdout << "\e[;#{@bgcurs}m "
          else
            $stdout << "\e[C\e[;#{@bgcurs}m\b#{string[x-1]}"
          end
        end
      when /^.$/
        if x == (maxlen+1) then
          string << char; maxlen += 1; x += 1
          $stdout << "\e[0m\b#{char}\e[;#{@bgcurs}m "
        elsif @insert
          string[x-1] = char; x += 1
          # if x == maxlen then
            # $stdout << "\e[0m\b#{string[x-2]}\e[C#{string[x-1]}\e[;#{@bgcurs}mX"
          # else
            $stdout << "\e[0m\b#{string[x-2]}\e[C\e[;#{@bgcurs}m\b#{string[x-1]}"
          # end
            if x == maxlen then $stdout << "X" end
        else
          string.insert(x-1, char); maxlen += 1; x += 1
          $stdout << "\e[0m\e[2K\e[G#{string[0..(x-2)]}\e[;#{@bgcurs}m"
          $stdout << "#{string[x-1]}\e[0m#{string[x..-1]}\e[#{x+1}G"
        end
      end
      char = self.getchar
    end

    return (from + string + to)
  end
end