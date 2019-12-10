#Constants seen by end user (can change for languages etc)
TEXT_OPTS = 'Options: '
TEXT_QUIT = ' q - Quit. '
TEXT_NOOPT = 'Input not recognised.'
TEXT_UNMATCHED = 'Unmatched " or ' + "'"
TEXT_TOO_FEW_ARGS = 'Not enough arguments to option '
TEXT_TOO_MANY_ARGS = 'Too many arguments to option '
TEXT_ARG_NOT_KNOWN = 'Arguments not recognised. '
TEXT_ABORT = 'Exiting.'

class Menu
  def initialize(functions, #Hash object. Key = trigger string, Value = [ Procudure to run, min # of args, max # of args ]
      descriptions, #Hash object. Key = option string, Value = [ Description string, Array of aliases ]
            #Note that if we you want to capture options, add them to description
            #Everything in description will be captured as an option if possible
            #Functions should have value[0] = -1, and value[1] = nil
      banner,
      indent = '> ',
      options_on_unrecognised = false
        )


    ## Check Types are correct
    raise TypeError.new('Argument "functions" must be a Hash.') if !(functions.is_a? Hash)
    #raise ArgumentError.new('Argument "functions" cannot be empty.') if functions.size == 0
    functions.each_with_index do |(k, v), i|
      raise TypeError.new('Argument "functions" at index ' + i.to_s + ': key must be a non-empty String.') if (!(k.is_a?(String) && k.strip == k) || k.empty?)
      raise TypeError.new('Argument "functions" at index ' + i.to_s + ': value must be an Array.') if !(v.is_a? Array)
      raise ArgumentError.new('Argument "functions" at index ' + i.to_s + ': value is of the wrong format') if !(v.size == 3)
      raise TypeError.new('Argument "functions" at index ' + i.to_s + ': value[0] must be a Proc.') if !(v[0].is_a? Proc)
      raise TypeError.new('Argument "functions" at index ' + i.to_s + ': value[1] must be an Integer.') if !(v[1].is_a? Integer)
      raise TypeError.new('Argument "functions" at index ' + i.to_s + ': value[2] must be an Integer.') if !(v[2].is_a? Integer)
      raise ArgumentError.new('Argument "functions" at index ' + i.to_s + ': max/min args are invalid.') if !(0 <= v[1] && (v[1] <= v[2] || v[2] < 0))
    end
    raise TypeError.new('Argument "descriptions" must be hash.') if !(descriptions.is_a? Hash)
    #raise ArgumentError.new('Argument "descriptions" cannot be empty.') if descriptions.size == 0
    descriptions.each_with_index do |(k, v), i|
      raise TypeError.new('Argument "descriptions" at index ' + i.to_s + ': key must be a non-empty String.') if (!(k.is_a?(String) && k.strip == k) || k.empty?)
      raise TypeError.new('Argument "descriptions" at index ' + i.to_s + ': value must be an Array.') if !(v.is_a? Array)
      raise ArgumentError.new('Argument "descriptions" at index ' + i.to_s + ': value is of the wrong format.') if (v.size != 2)
      raise TypeError.new('Argument "descriptions" at index ' + i.to_s + ': value[0] must be a String.') if !(v[0].is_a? String)
      raise TypeError.new('Argument "descriptions" at index ' + i.to_s + ': value[1] must be an Array.') if !(v[1].is_a? Array)
      v[1].each do |a|
        if !(a.is_a?(String) && a.strip == a) || a.empty?
          raise TypeError.new('Argument "descriptions" at index ' + i.to_s + ': aliases must be non-empty Strings.') end
      end
    end
    raise TypeError.new('Argument "banner" must be a String.') if !(banner.is_a? String)
    raise TypeError.new('Argument "indent" must be a String.') if !(indent.is_a? String)
    if !(options_on_unrecognised == false || options_on_unrecognised == true)
      raise TypeError.new('Argument "options_on_unrecognised" must be a TrueClass or FalseClass.') end

    @funct, @desc, @indent, @opts_on_fail = functions, descriptions, indent, options_on_unrecognised
  end


  attr_accessor :indent #Maybe add type controls on indent...

  def print_banner
    print @banner
  end

  def print_options
    puts TEXT_OPTS
    @desc.each do |k, v|
      puts ' ' + k + ' - ' + v[0]
    end
    puts TEXT_QUIT
  end


  def idle
    loop do
      begin
        print @indent
        input = gets.chomp.lstrip
        break if input.strip == 'q' || input.strip == 'Q'
        found = false
        @funct.each do |k, v|
          if input.index(Regexp.new(k + '\b')) == 0
            found = true
            argv = process(k, input)  #The Proc is provided with an Array of arguments
            if argv.size < v[1]
              raise ArgumentError.new(TEXT_TOO_FEW_ARGS + k)
            elsif v[2] >= 0 && argv.size > v[2]
              raise ArgumentError.new(TEXT_TOO_MANY_ARGS + k)
            else
              v[0].call(argv)
            end
            break
          end

          if @desc.key? k
            @desc[k][1].each do |a|
              if input.index(Regexp.new(a + '\b')) == 0
                found = true
                argv = process(a, input)
                if argv.size < v[1]
                  raise ArgumentError.new(TEXT_TOO_FEW_ARGS + k)
                elsif v[2] >= 0 && argv.size > v[2]
                  raise ArgumentError.new(TEXT_TOO_MANY_ARGS + k)
                else
                  v[0].call(argv)
                end
                break
              end
            end
            break if found
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


private
  def process(f, input)
    argv = Array.new
    input.slice!(Regexp.new('\b' + f + '($|\s)+'))
    input.lstrip!

    while !input.empty? do
      state = 0
      #Description of state:
      #0: not in any quotes
      #1: in outer double quotes
      #2: in outer single quotes
      #We dropper inners if the outers are closed
      for j in 0..input.length - 1 do
        if input[j] == "\""
          case state
          when 0
            state = 1
          when 1
            state = 0
          when 2

          end
        elsif input[j] == "'"
          case state
          when 0
            state = 2
          when 1

          when 2
            state = 0
          end
        end

        if  input[j] == " " && state == 0
          argv.push(input.slice!(0,j))
          input.lstrip!
          break
        end

        if j == input.length - 1
          if state == 0
            argv.push(input.slice!(0, j+1))
            input.lstrip!
          else
            raise ArgumentError.new(TEXT_UNMATCHED)
          end
          break
        end
      end #end for
    end   #end while

    return argv
  end

end
