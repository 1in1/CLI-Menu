#Constants seen by end user (can change for languages etc)
TEXT_OPTS = 'Options: '
TEXT_QUIT = ' q - Quit. '
TEXT_NOOPT = 'Input not recognised.'
TEXT_UNMATCHED = 'Unmatched " or ' + "'"
TEXT_TOO_FEW_ARGS = 'Not enough arguments to option '
TEXT_ARG_NOT_KNOWN = 'Arguments not recognised. '

class Menu
  def initialize(functions, #Hash object. Key = trigger string, Value = Procudure to run
      descriptions, #Hash object. Key = option string, Value = [ # of inputs, Default value, Description string, Array of aliases ]
            #Note that if we you want to capture options, add them to description
            #Everything in description will be captured as an option if possible
            #Functions should have value[0] = -1, and value[1] = nil
      banner,
      indent = '>',
      options_on_unrecognised = false
        )
    begin
      ## Check Types are correct
      raise TypeError.new('Argument "functions" must be a Hash.') if !(functions.is_a? Hash)
      raise ArgumentError.new('Argument "functions" cannot be empty.') if functions.size == 0
      functions.each_with_index do |(k, v), i|
        raise TypeError.new('Argument "functions" at index ' + i.to_s + ': key must be a String.') if !(k.is_a? String)
        raise TypeError.new('Argument "functions" at index ' + i.to_s + ': value must be a Proc.') if !(v.is_a? Proc)
      end
      raise TypeError.new('Argument "descriptions" must be hash.') if !(descriptions.is_a? Hash)
      raise ArgumentError.new('Argument "descriptions" cannot be empty.') if descriptions.size == 0
      descriptions.each_with_index do |(k, v), i|
        raise TypeError.new('Argument "description" at index ' + i.to_s + ': key must be a String.') if !(k.is_a?(String))
        raise ArgumentError.new('Argument "description" at index ' + i.to_s + ': not enough elements in value') if v.size != 4
        raise TypeError.new('Argument "descriptions" at index ' + i.to_s + ': value[0] must be an Integer.') if !(v[0].is_a? Integer)
        raise TypeError.new('Argument "descriptions" at index ' + i.to_s + ': value[2] must be a String.') if !(v[2].is_a? String)
        raise TypeError.new('Argument "descriptions" at index ' + i.to_s + ': value[3] must be an Array.') if !(v[3].is_a? Array)
      end
      raise TypeError.new('Argument "banner" must be a String.') if !(banner.is_a? String)
      raise TypeError.new('Argument "indent" must be a String.') if !(indent.is_a? String)
      raise TypeError.new('Argument "options_on_unrecognised" must be a Boolean.') if !(options_on_unrecognised == false || options_on_unrecognised == true)


      @funct = functions
      @desc = descriptions
      @indent = indent
      @opts_on_fail = options_on_unrecognised

      print banner
      print "\n"

    rescue TypeError => e
      warn e
    rescue ArgumentError => e
      warn e
    end
  end

  def print_options
    puts TEXT_OPTS
    @desc.each do |k, v|
      puts ' ' + k + ' - ' + v[2]
    end
    puts TEXT_QUIT
  end

  def idle
    loop do
      begin
        print @indent
        input = gets.lstrip
        found = false
        @funct.each do |k, v|
          if input.index(k) == 0
            found = true
            input.slice!(k)
            v.call(process(input))  #the Proc is provided with a Hash of the possible options
          end
        end
        if !found
          puts TEXT_NOOPT
          print_options if @opts_on_fail
        end
      rescue ArgumentError => e
        puts e
      end
    end
  end

  def process(input)
    argv = Hash.new

    input.lstrip!
    while !input.empty? do
      @desc.each do |k, v|
        'option loop'
        next if v[0] == -1
        if input.index(Regexp.new('\b' + k + '($|\s)')) == 0  ##TODO ADD CHECKS FOR EMPTY STRINGS K ABOVE
          input.slice!(Regexp.new('\b' + k + '($|\s)+'))
          if v[0] == 0
            argv[k] = true
          else
            argv[k] = Array.new
            for i in 1..v[0] do
              state = 0
              #Description of state:
              #0: not in any quotes
              #1: in outer double quotes
              #2: in outer double quotes, inner single quotes
              #3: in outer single quotes
              #4: in outer single quotes, inner double quotes
              #We dropper inners if the outers are closed
              for j in 0..input.length - 1 do
                if input[j] == '"'
                  case state
                  when 0
                    state = 1
                  when 1, 2
                    state = 0
                  when 3
                    state = 4
                  when 4
                    state = 3
                  end
                elsif input[j] == '"'
                  case state
                  when 0
                    state = 3
                  when 1
                    state = 2
                  when 2
                    state = 1
                  when 3, 4
                    state = 0
                  end
                elsif state == 0 && input[j] == " "
                  argv.push(input.slice!([0..j-1]))
                  break
                elsif j == input.length - 1
                  if state == 0
                    argv.push(input.slice![0..j])
                  else
                    raise ArgumentError.new(TEXT_UNMATCHED)
                  end
                  break
                end
              end

              raise ArgumentError.new(TEXT_TOO_FEW_ARGS + k) if argv.size < i
            end
          end
          break

        else
          raise ArgumentError.new(TEXT_ARG_NOT_KNOWN)
        end
      end
      input.lstrip!
    end

    #Default values otherwise
    @desc.each do |k, v|
      argv[k] = v[1] if (!argv.key?(k)) && (v[0] >= 0)
    end
  end

end


###TESTING
d = {"p"=>[-1, nil, "desc", []], "t"=>[1, "defaulttxt", "anotherdesc", []]}
o = Proc.new do |a| puts a["txt"] end
f = {"p" => o}
m = Menu.new(f, d, "banner text")
m.idle
