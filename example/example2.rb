require '..\Menu.rb'

$x = ""
set_string = Proc.new do |argv|
  $x = argv[0].to_s
end
slice_string = Proc.new do |argv|
  argv.map! { |a| a.to_i }
  puts $x.slice(*argv) #We can splat argv into other functions
end
mf = Hash.new
mf['set'] = [set_string, 1, 1]
mf['slice'] = [slice_string, 1, 2]
md = Hash.new
md['set'] = ['Sets string x.', []]
md['slice'] = ['Calls slice on x; integer args only.', []]
m = Menu.new(mf, md, "Inner menu...\n", "--> ", true)


open_m = Proc.new do
  m.print_banner
  m.idle
end
nf = {"m" => [open_m, 0, 0]}
nd = {"m" => ['Move to the other menu.', []]}
n = Menu.new(nf, nd, "Outer menu...\n", "> ", true)
n.print_banner
n.idle
