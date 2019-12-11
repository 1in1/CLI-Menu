require '..\Menu.rb'

print_proc = Proc.new do |argv|
  argv.each do |s|
    p s end
  end

f = {"p" => [print_proc, 1, 5]}
d = {"p" => ["Prints the given arguments. Takes at least 1 argument, and up to 5. Equivalent to print, puts.",
                ["print", "puts"] ] }
m = Menu.new(f, d, "This is a banner\n", "~~~~> ", true)
m.print_banner
m.idle
