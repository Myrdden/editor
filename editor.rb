CURSOR_HIGHLIGHT = ""

buffer = Array.new(1) {Array.new(1) {[Hash.new {|h,k| h[k] = ""}, ""]}}
#require 'pry'; binding.pry

50.times do
  buffer[0] << ["", "X"]
end

buffer[0].each do |x|
  print "#{x[0]}#{x[1]}"
end
puts