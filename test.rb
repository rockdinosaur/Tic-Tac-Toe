a = 1
b = 2

loop do

  loop do
    puts b
    b += 1
    break if b >= 5
  end

  puts a
  break
end
