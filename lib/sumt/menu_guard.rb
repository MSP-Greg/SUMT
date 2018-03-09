# frozen_string_literal: true

#———————————————————————————————————————————————————————————————————————————————
#
# Copyright 2013-2014 Trimble Navigation Ltd.
# License: The MIT License (MIT)
#
#———————————————————————————————————————————————————————————————————————————————

module SUMT

# Only reason for this file is a single test method:
#   `TC_Animation#test_introduction_api_example_1`
#
class MenuGuard

  # Return a top level menu wrapped in a menu guard that prevent the menus
  # from being created multiple times.
  def self.menu(title)
    @@menus ||= {}
    unless @@menus.key?(title)
      @@menus[title] = self.new( UI.menu(title) )
    end
    @@menus[title]
  end

  def initialize(menu)
    @menu = menu
    @guarded_menus = {}
  end

  def add_item(title, &block)
    unless @guarded_menus.key?(title)
      menu = @menu.add_item(title, &block)
      guarded_menu = self.class.new(menu)
      @guarded_menus[title] = guarded_menu
    end
    @guarded_menus[title]
  end

  def add_separator
    # No need for test code to add separators. They would be hard to ensure
    # no duplicates.
  end

  def add_submenu(title)
    unless @guarded_menus.key?(title)
      menu = @menu.add_submenu(title)
      guarded_menu = self.class.new(menu)
      @guarded_menus[title] = guarded_menu
    end
    @guarded_menus[title]
  end

end # class MenuGuard
end # module SUMT