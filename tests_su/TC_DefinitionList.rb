# Copyright:: Copyright 2015 Trimble Navigation Ltd.
# License:: All Rights Reserved.
# Original Author:: Thomas Thomassen





# class Sketchup::DefinitionList
# http://www.sketchup.com/intl/developer/docs/ourdoc/definitionlist
class TC_DefinitionList < SUMT::TestCase

  def setup
    start_with_empty_model()
  end

  def teardown
    # ...
  end


  class SUMTEvilEntityObserver < Sketchup::EntityObserver

    def onChangeEntity(entity)
      # puts "#{self.class.name}.onChangeEntity(#{entity})"
      Sketchup.active_model.definitions.purge_unused
    end

  end # class


  class SUMTEvilDefinitionsObserver < Sketchup::DefinitionsObserver

    def onComponentAdded(definitions, definition)
      # puts "#{self.class.name}.onComponentAdded(#{definition})"
      definitions.purge_unused
    end

  end # class



  # ========================================================================== #
  # method Sketchup::DefinitionList.add
  # http://www.sketchup.com/intl/developer/docs/ourdoc/definitionlist#add

  def xxx_test_add_evil_definitions_observer_without_operation
    model = Sketchup.active_model
    entities = model.entities

    observer = SUMTEvilDefinitionsObserver.new
    model.definitions.add_observer(observer)

    definition = nil
    thr = Thread.new {
      definition = model.definitions.add("SUMT")
      sleep 0.5
    }
    thr.join

    assert_kind_of(Sketchup::ComponentDefinition, definition)
    assert(definition.deleted?, "Definition not deleted")

    assert_raises(TypeError) { definition.name }
  ensure
    model.definitions.remove_observer(observer) if definition.valid?
    observer = nil
  end


end # class
