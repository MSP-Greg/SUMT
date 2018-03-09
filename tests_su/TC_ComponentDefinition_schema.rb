# Copyright:: Copyright 2015 Trimble Navigation Ltd.
# License:: All Rights Reserved.
# Original Author:: Thomas Thomassen


# class Sketchup::ComponentDefinition
# http://www.sketchup.com/intl/developer/docs/ourdoc/componentdefinition
class TC_ComponentDefinition_schema < SUMT::TestCase

  TRANS = Geom::Transformation.new(ORIGIN)
  TEST_JPG = get_test_file "Test.jpg"
  IFC = Sketchup.find_support_file("IFC 2x3.skc", "Classifications")

  def self.ste_setup
    Sketchup.active_model.classifications.load_schema(IFC)
  end

  def self.ste_teardown
    Sketchup.active_model.classifications.unload_schema('IFC 2x3')
  end
  
  def setup
    start_with_empty_model(clr_schemas: false)
    @model = Sketchup.active_model
  end

  def teardown
    @model.definitions.purge_unused
  end

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

  def create_classified_test_instance
    create_test_instance do |instance, definition|
      definition.add_classification("IFC 2x3", "IfcDoor")
      # TODO(thomthom): Replace with set_classification_value when implemented.
      schema = definition.attribute_dictionary("IFC 2x3", false)
      object_type = schema.attribute_dictionary("ObjectType", false)
      object_type.set_attribute("IfcLabel", "value", "SUMT Door")
      yield instance, definition
      definition.remove_classification("IFC 2x3", "IfcDoor") if definition.valid?
    end
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

  def test_add_classification_success
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_test_instance do |instance, definition|
      result = definition.add_classification("IFC 2x3", "IfcDoor")
      assert(result)
      dictionary = definition.attribute_dictionary("IFC 2x3", false)
      assert_kind_of(Sketchup::AttributeDictionary, dictionary)
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

  def test_get_classification_value_string
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_classified_test_instance do |instance, definition|
      path = ["IFC 2x3", "IfcDoor", "ObjectType", "IfcLabel"]
      value = definition.get_classification_value(path)
      assert_kind_of(String, value)
      assert_equal("SUMT Door", value)
    end
  end

  def test_get_classification_value_invalid_key
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_classified_test_instance do |instance, definition|
      path = ["ClassifierPathToHeaven"]
      value = definition.get_classification_value(path)
      assert_nil(value)
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

  def test_get_classification_value_incorrect_number_of_arguments_zero
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_classified_test_instance do |instance, definition|
      assert_raises(ArgumentError) { definition.get_classification_value() }
    end
  end

  def test_get_classification_value_incorrect_number_of_arguments_two
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_classified_test_instance do |instance, definition|
      assert_raises(ArgumentError) { definition.get_classification_value(["IFC 2x3", "IfcDoor"], "Two") }
    end
  end

  def test_get_classification_value_invalid_arguments_string
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_classified_test_instance do |instance, definition|
      assert_raises(TypeError) { definition.get_classification_value("IFC 2x3") }
    end
  end

  def test_get_classification_value_invalid_arguments_number
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_classified_test_instance do |instance, definition|
      assert_raises(TypeError) { definition.get_classification_value(123) }
    end
  end

  def test_get_classification_value_invalid_arguments_point
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_classified_test_instance do |instance, definition|
      assert_raises(TypeError) { definition.get_classification_value(ORIGIN) }
    end
  end

  def test_get_classification_value_invalid_arguments_nil
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_classified_test_instance do |instance, definition|
      assert_raises(TypeError) { definition.get_classification_value(nil) }
    end
  end


  # ========================================================================== #
  # method Sketchup::ComponentDefinition.remove_classification
  # http://www.sketchup.com/intl/developer/docs/ourdoc/componentdefinition#remove_classification

  def test_remove_classification_api_example
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_classified_test_instance do |instance, _def|
      # API Example starts here:
      definition = @model.definitions.first
      assert definition.remove_classification("IFC 2x3", "IfcDoor")
    end
  end

  def test_remove_classification_success
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_classified_test_instance do |instance, definition|
      if SU_VERS_INT < 15
        # SketchUp 2014 was a little bit different.
        result = definition.remove_classification("IFC 2x3", "ifc:IfcDoor")
      else
        result = definition.remove_classification("IFC 2x3", "IfcDoor")
      end
      assert(result)
      dictionary = definition.attribute_dictionary("IFC 2x3", false)
      assert_nil(dictionary)
    end
  end

  def test_remove_classification_success_only_schema_name
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_classified_test_instance do |instance, definition|
      result = definition.remove_classification("IFC 2x3")
      assert(result)
      dictionary = definition.attribute_dictionary("IFC 2x3", false)
      names = definition.attribute_dictionaries.map { |d| d.name }
      refute names.include?("IFC 2x3")
    end
  end

  def test_remove_classification_failure
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_classified_test_instance do |instance, definition|
      result = definition.remove_classification("FooBar", "IfcDoor")
      assert_equal(false, result)
      # Should be two dictionaries, "AppliedSchemaTypes" and "IFC 2x3".
      names = definition.attribute_dictionaries.map { |d| d.name }
      assert(names.include?("AppliedSchemaTypes") && names.include?("IFC 2x3"))
    end
  end

  def test_remove_classification_failure_image_definition
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_test_image()
    definition = @model.definitions.first
    assert(definition.image?, "Failed to set up test.")
    result = definition.remove_classification("FooBar", "IfcDoor")
    assert_equal(false, result)
  end

  def test_remove_classification_invalid_second_argument_nil
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_test_instance do |instance, definition|
      assert_raises(TypeError) { definition.remove_classification("IFC 2x3", nil) }
    end
  end

  def test_set_classification_value_string
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_classified_test_instance do |instance, definition|
      path = ["IFC 2x3", "IfcDoor", "ObjectType", "IfcLabel"]
      result = definition.set_classification_value(path, "Room 101")
      assert_equal(true, result)
      value = definition.get_classification_value(path)
      assert_equal("Room 101", value)
    end
  end

  def test_set_classification_value_invalid_key
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_classified_test_instance do |instance, definition|
      path = ["ClassifierPathToHeaven"]
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

  def test_set_classification_value_invalid_value
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_classified_test_instance do |instance, definition|
      path = ["IFC 2x3", "IfcDoor", "ObjectType", "IfcLabel"]
      assert_raises(TypeError) { definition.set_classification_value(path, 123) }
    end
  end

  def test_set_classification_value_corrupt_attribute_data
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_classified_test_instance do |instance, definition|
      path = ["IFC 2x3", "IfcDoor", "ObjectType", "IfcLabel"]
      corrupt_attribute_data(definition, path, 123, "attribute_type")
      assert_raises(RuntimeError) { definition.set_classification_value(path, "Room 101") }
    end
  end

  def test_set_classification_value_valid_choice_value
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_classified_test_instance do |instance, definition|
      path = ["IFC 2x3", "IfcDoor", "OverallHeight", "instanceAttributes", "pos"]
      assert_raises(NotImplementedError) { definition.set_classification_value(path, "integer") }
    end
  end

  def test_set_classification_value_incorrect_number_of_arguments_zero
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_classified_test_instance do |instance, definition|
      assert_raises(ArgumentError) { definition.set_classification_value() }
    end
  end

  def test_set_classification_value_incorrect_number_of_arguments_three
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_classified_test_instance do |instance, definition|
      path = ["IFC 2x3", "IfcDoor", "ObjectType", "IfcLabel"]
      assert_raises(ArgumentError) { definition.set_classification_value(path, "Room 101", "Tree") }
    end
  end

  def test_set_classification_value_invalid_path_argument_string
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_classified_test_instance do |instance, definition|
      assert_raises(TypeError) { definition.set_classification_value("IFC 2x3", "Room 101") }
    end
  end

  def test_set_classification_value_invalid_path_argument_number
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_classified_test_instance do |instance, definition|
      assert_raises(TypeError) { definition.set_classification_value(123, "Room 101") }
    end
  end

  def test_set_classification_value_invalid_path_argument_point
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_classified_test_instance do |instance, definition|
      assert_raises(TypeError) { definition.set_classification_value(ORIGIN, "Room 101") }
    end
  end

  def test_set_classification_value_invalid_path_argument_nil
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    create_classified_test_instance do |instance, definition|
      assert_raises(TypeError) { definition.set_classification_value(nil, "Room 101") }
    end
  end


end # class
