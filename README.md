# CLI-Menu

This is intended to be a safe menu class for building CLI projects. It handles presenting options to the user, retrieving input, parsing it into arguments, and calling the appropriate procedure for the given command.

It will throw a LOT of errors if the input is formatted wrongly - with any luck this'll stop any errors once the menu is initialized. The hope behind this is that you are likely to build static menus, so will only see these errors during development, and then never see them at runtime.


***

To present a menu, you only need to initialize it, and then call idle.
```ruby
m = Menu.new({}, {}, "This is a new menu!")
m.idle
```

To make it do anything interesting, you'll need to populate those first two hashes. This requires a bit of explanation - or see the examples. The constructor begins:
'''ruby
  def initialize(functions,
      descriptions,
      banner,
      indent = '> ',
      options_on_unrecognised = false
        )
'''
I'll break these down below

###functions
This parameter accepts a Hash; let's use `f` in this example. **If you have a function that you want the user to be able to call from the menu, this is where it goes.** Choose a string, say `runme`, that will act as the primary way to call this. If you want to add aliases, pass them in the `descriptions` argument. Each function needs an entry in `f`.

`runme` will be the key for this entry in the hash. We set `f[runme]` to an Array of length 3. This must be of the form `[ myproc, min_args, max_args]`, where
...`myproc` is a Proc that will be called when the user types `runme`
...`min_args` is the minimum number of arguments you want the menu to accept after the command `runme`
...`max_args` is the maximum number

`myproc` will be passed an Array of the arguments that the user typed after `runme`, **all as strings**. Things in quotes `'` or `"` are treated as a single argument, to allow for paths with spaces, etc, but the quotes are not removed.

Note if `f` is empty, all the user will be able to do is exit.

###descriptions
This paramter accepts a Hash; let's use `d` in this example. **Everything the user needs to know to use your menu needs to go here.** There are two obvious use cases for this, so I'll describe both.

1. You have some command that does something when typed from your menu (here, `runme`). You've defined it in `f`. You want it to be listed as a possible option by the menu.
In this case, make an entry in `d` using `runme` as a key.

2. You have some other option or flag that doesn't do anything by itself, but you want it to be listed as a possible option by the menu. Eg, you might want -o to be listed as a way to provide an output path. In this case, make an entry in `d` using `-o` as a key

The value associated with any key in `d` must be of the form `[ desc, aliases ]`, where:
...`desc` is a String describing what the option does. This is displayed by `Menu.print_options`.
...`aliases` is an Array of Strings giving alternative triggers/names. **If you want to add aliases to a function, add them here: the menu will pick up these too.**

###banner, indent, options_on_unrecognised
banner is a String which is printed by Menu.print_banner. indent is a String which is printed to the console when prompting for user input (ie on the same line the user types). options_on_unrecognised is a boolean: if set to true, then every time the user gives an unknown option, Menu.print_options is called.
