# Copyright:: Copyright 2015 Trimble Navigation Ltd.
# License:: All Rights Reserved.
# Original Author:: Thomas Thomassen


# class Sketchup::ComponentDefinition
# http://www.sketchup.com/intl/developer/docs/ourdoc/componentdefinition
class TC_ComponentDefinition < SUMT::TestCase

  TRANS = Geom::Transformation.new(ORIGIN)
  TEST_JPG = get_test_file "Test.jpg"

  def setup
    start_with_empty_model
    @model = Sketchup.active_model
  end

  def teardown
    @model.definitions.purge_unused
  end

  class SUMTEvilEntityObserver < Sketchup::EntityObserver

    def onChangeEntity(entity)
      SUMT::FileReporter.io.puts "-------------------- SUMTEvilEntityObserver"
      Sketchup.active_model.definitions.purge_unused
    end

  end # class

  class SUMTEvilDefinitionsObserver < Sketchup::DefinitionsObserver

    def onComponentPropertiesChanged(definitions, definition)
      definitions.purge_unused
    end

  end # class


  def create_test_image
    entities = @model.entities
    image = @model.entities.add_image(TEST_JPG, ORIGIN, 1.m)
    image
  end

  def create_test_instance
    @model.start_operation(self.name, true)
    @do_abort = true
    entities = @model.entities
    definition = @model.definitions.add("Door")
    definition.entities.add_line(ORIGIN, [0, 0, 10])
    instance = entities.add_instance(definition, TRANS)
    yield instance, definition
    instance   = nil
    definition = nil
    @model.definitions.purge_unused
    @model.abort_operation if @do_abort
    @do_abort = false
    @model.definitions.purge_unused
  end

  def corrupt_attribute_data(definition, path, value, key = "value")
    # Naive path interpreter, doesn't account for keys with escaped : character.
    keys = path.dup

    schema_name = keys.shift
    schema = definition.attribute_dictionary(schema_name, false)
    schema_type = keys.shift

    dictionary = schema
    until dictionary.nil? || keys.empty?
      dictionary = dictionary.attribute_dictionary(keys.shift, false)
    end
    dictionary[key] = value

    nil
  end


  # ========================================================================== #
  # method Sketchup::ComponentDefinition.count_used_instances
  # http://www.sketchup.com/intl/developer/docs/ourdoc/componentdefinition#count_used_instances

  def test_count_used_instances_api_example
    skip("Implemented in SU2016") if SU_VERS_INT < 16
    definitions = @model.definitions
    # Below is needed to stop intermittent test errors
    definitions.purge_unused

    path = Sketchup.find_support_file('Bed.skp',
      'Components/Components Sampler/')
    definition = definitions.load(path)
    number = definition.count_used_instances
  end

  def test_count_used_instances
    skip("Implemented in SU2016") if SU_VERS_INT < 16

    definitions = @model.definitions
    # Below is needed to stop intermittent test errors
    definitions.purge_unused

    # Create a definition but don't add it to the model.
    definition1 = definitions.add('Foo')
    definition1.entities.add_cpoint(ORIGIN)
    assert_equal(0, definition1.count_used_instances)

    # Create a new definition and add the first one a couple of time.
    definition2 = definitions.add('Foo')
    definition2.entities.add_cpoint(ORIGIN)
    definition2.entities.add_instance(definition1, ORIGIN)
    definition2.entities.add_instance(definition1, ORIGIN)
    assert_equal(0, definition1.count_used_instances)
    assert_equal(0, definition2.count_used_instances)

    # Add the definitions to the model - this will make them 'used'.
    @model.entities.add_instance(definition1, ORIGIN)
    assert_equal(1, definition1.count_used_instances)
    @model.entities.add_instance(definition2, ORIGIN)
    assert_equal(3, definition1.count_used_instances)
    assert_equal(1, definition2.count_used_instances)
  end

  def test_count_used_instances_incorrect_number_of_arguments_one
    skip("Implemented in SU2016") if SU_VERS_INT < 16

    definitions = @model.definitions
    # Below is needed to stop intermittent test errors
    definitions.purge_unused

    definition = definitions.add('Foo')
    definition.entities.add_cpoint(ORIGIN)
    assert_raises(ArgumentError) { definition.count_used_instances 123 }
  end


  # ========================================================================== #
  # method Sketchup::ComponentDefinition.load
  # http://www.sketchup.com/intl/developer/docs/ourdoc/componentdefinition#load

  def xxx_test_load_evil_definitions_observer_without_operation
    entities = @model.entities

    observer = SUMTEvilDefinitionsObserver.new
    @model.definitions.add_observer(observer)

    fbr = Fiber.new do |model|
      path = Sketchup.find_support_file('Bed.skp',
      'Components/Components Sampler/')
      Fiber.yield model.definitions.load(path)
    end
      
    definition = fbr.resume @model

    assert_kind_of(Sketchup::ComponentDefinition, definition)
    assert(definition.deleted?, "Definition not deleted")

    assert_raises(TypeError) { definition.name }
  ensure
    @model.definitions.remove_observer(observer)
    observer = nil
    fbr = nil
  end

  def xxx_test_load_evil_definitions_observer_without_operation
    entities = @model.entities

    observer = SUMTEvilDefinitionsObserver.new
    @model.definitions.add_observer(observer)

    @model.start_operation("SUMT", true)


    path = Sketchup.find_support_file('Bed.skp',
      'Components/Components Sampler/')
    definition = @model.definitions.load(path)

    @model.commit_operation

    assert_kind_of(Sketchup::ComponentDefinition, definition)
    assert(definition.deleted?, "Definition not deleted")

    assert_raises(TypeError) { definition.name }
  ensure
    @model.definitions.remove_observer(observer)
    Sketchup.undo
    observer = nil
  end


  # ========================================================================== #
  # method Sketchup::ComponentDefinition.name=
  # http://www.sketchup.com/intl/developer/docs/ourdoc/componentdefinition#name=

  def xxx_test_name_Set_evil_entities_observer_without_operation
    entities = @model.entities
#@model.start_operation("SUMT", true)
    definition = @model.definitions.add("Evil1")
    definition.entities.add_line(ORIGIN, [0, 0, 10])

    observer = SUMTEvilEntityObserver.new
    definition.add_observer(observer)

    thr = Thread.new {
      definition.name = "Cheese1"
      sleep 0.02
    }
    thr.join
    thr = nil
#@model.commit_operation

    assert_kind_of(Sketchup::ComponentDefinition, definition)
    assert(definition.deleted?, "Definition not deleted")

    assert_raises(TypeError) { definition.name }
  ensure
    definition.remove_observer(observer) if definition.valid?
    observer = nil
#    Sketchup.undo
  end

  def xxx_test_name_Set_evil_definitions_observer_without_operation
#@model.start_operation("SUMT", true)
    entities = @model.entities
    definition = @model.definitions.add("Evil2")
    definition.entities.add_line(ORIGIN, [0, 0, 10])

    observer = SUMTEvilDefinitionsObserver.new
    @model.definitions.add_observer(observer)

    thr = Thread.new {
      definition.name = "Cheese2"
      sleep 0.02
    }
    thr.join
    thr = nil
#    @model.commit_operation

    assert_kind_of(Sketchup::ComponentDefinition, definition)
    assert(definition.deleted?, "Definition not deleted")

    assert_raises(TypeError) { definition.name }
  ensure
    @model.definitions.remove_observer(observer)
    observer = nil
#    Sketchup.undo
  end

  def test_add_classification_failure
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_test_instance do |instance, definition|
      result = definition.add_classification("FooBar", "IfcDoor")
      assert_equal(false, result)
      dictionaries = definition.attribute_dictionaries
      names = definition.attribute_dictionaries.map { |d| d.name }
      refute names.include?("FooBar")
    end
  end

  def test_add_classification_failure_image_definition
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_test_image()
    definition = @model.definitions.first
    assert(definition.image?, "Failed to set up test.")
    result = definition.add_classification("FooBar", "IfcDoor")
    assert_equal(false, result)
    dictionaries = definition.attribute_dictionaries
    assert_nil(dictionaries)
  end

  def test_add_classification_incorrect_number_of_arguments_zero
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_test_instance do |instance, definition|
      assert_raises(ArgumentError) { definition.add_classification }
    end
  end

  def test_add_classification_incorrect_number_of_arguments_one
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_test_instance do |instance, definition|
      assert_raises(ArgumentError) { definition.add_classification("IFC 2x3") }
    end
  end

  def test_add_classification_incorrect_number_of_arguments_thee
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_test_instance do |instance, definition|
      assert_raises(ArgumentError) { definition.add_classification("IFC 2x3", "IfcDoor", "BogusArgument") }
    end
  end

  def test_add_classification_invalid_first_argument_nil
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_test_instance do |instance, definition|
      assert_raises(TypeError) { definition.add_classification(nil, "IfcDoor") }
    end
  end

  def test_add_classification_invalid_second_argument_nil
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_test_instance do |instance, definition|
      assert_raises(TypeError) { definition.add_classification("IFC 2x3", nil) }
    end
  end

  def test_add_classification_invalid_first_argument_number
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_test_instance do |instance, definition|
      assert_raises(TypeError) { definition.add_classification(3.14, "IfcDoor") }
    end
  end

  def test_add_classification_invalid_second_argument_number
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_test_instance do |instance, definition|
      assert_raises(TypeError) { definition.add_classification("IFC 2x3", 3.14) }
    end
  end

  def test_add_classification_invalid_first_argument_point
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_test_instance do |instance, definition|
      assert_raises(TypeError) { definition.add_classification(ORIGIN, "IfcDoor") }
    end
  end

  def test_add_classification_invalid_second_argument_point
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_test_instance do |instance, definition|
      assert_raises(TypeError) { definition.add_classification("IFC 2x3", ORIGIN) }
    end
  end


  # ========================================================================== #
  # method Sketchup::ComponentDefinition.get_classification_value
  # http://www.sketchup.com/intl/developer/docs/ourdoc/componentdefinition#get_classification_value

  def test_get_classification_value_api_example
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_test_instance do |instance, _def|
      # API Example starts here:
      entities = @model.entities
      definition = entities.grep(Sketchup::ComponentInstance).first.definition
      definition.add_classification("IFC 2x3", "IfcDoor")

      path = ["IFC 2x3", "IfcDoor", "ObjectType", "IfcLabel"]
      value = definition.get_classification_value(path)
    end
  end

  def test_get_classification_image_definition
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_test_image()
    definition = @model.definitions.first
    assert(definition.image?, "Failed to set up test.")

    path = ["IFC 2x3", "IfcDoor", "ObjectType", "IfcLabel"]
    value = definition.get_classification_value(path)
    assert_nil(value)
  end

  def test_remove_classification_failure_image_definition
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_test_image()
    definition = @model.definitions.first
    assert(definition.image?, "Failed to set up test.")
    result = definition.remove_classification("FooBar", "IfcDoor")
    assert_equal(false, result)
  end

  def test_remove_classification_incorrect_number_of_arguments_zero
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_test_instance do |instance, definition|
      assert_raises(ArgumentError) { definition.remove_classification }
    end
  end

  def test_remove_classification_incorrect_number_of_arguments_thee
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_test_instance do |instance, definition|
      assert_raises(ArgumentError) { definition.remove_classification("IFC 2x3", "IfcDoor", "BogusArgument") }
    end
  end

  def test_remove_classification_invalid_first_argument_nil
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_test_instance do |instance, definition|
      assert_raises(TypeError) { definition.remove_classification(nil, "IfcDoor") }
    end
  end

  def test_remove_classification_invalid_second_argument_nil
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_test_instance do |instance, definition|
      assert_raises(TypeError) { definition.remove_classification("IFC 2x3", nil) }
    end
  end

  def test_remove_classification_invalid_first_argument_number
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_test_instance do |instance, definition|
      assert_raises(TypeError) { definition.remove_classification(3.14, "IfcDoor") }
    end
  end

  def test_remove_classification_invalid_second_argument_number
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_test_instance do |instance, definition|
      assert_raises(TypeError) { definition.remove_classification("IFC 2x3", 3.14) }
    end
  end

  def test_remove_classification_invalid_first_argument_point
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_test_instance do |instance, definition|
      assert_raises(TypeError) { definition.remove_classification(ORIGIN, "IfcDoor") }
    end
  end

  def test_remove_classification_invalid_second_argument_point
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_test_instance do |instance, definition|
      assert_raises(TypeError) { definition.remove_classification("IFC 2x3", ORIGIN) }
    end
  end

  def test_set_classification_value_not_classified
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_test_instance do |instance, definition|
      path = ["IFC 2x3", "IfcDoor", "ObjectType", "IfcLabel"]
      result = definition.set_classification_value(path, "Room 101")
      assert_equal(false, result)
    end
  end

  def test_set_classification_image_definition
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_test_image()
    definition = @model.definitions.first
    assert(definition.image?, "Failed to set up test.")

    path = ["IFC 2x3", "IfcDoor", "ObjectType", "IfcLabel"]
    result = definition.set_classification_value(path, "Room 101")
    assert_equal(false, result)
    dictionaries = definition.attribute_dictionaries
    assert_nil(dictionaries)
  end

end # class
