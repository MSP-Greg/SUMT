# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: All Rights Reserved.
# Original Author:: Thomas Thomassen


# class Sketchup::ClassificationSchema
# http://www.sketchup.com/intl/developer/docs/ourdoc/classificationschema
class TC_ClassificationSchema < SUMT::TestCase

  TEST_MODEL = get_test_file "MultipleClassifications.skp"

  def self.ste_setup
    model = Sketchup.active_model
    model.respond_to?(:close) and model.close(true)
    Sketchup.open_file(TEST_MODEL)
  end

  def self.ste_teardown
    model = Sketchup.active_model
    model.respond_to?(:close) and model.close(true)
  end

  def setup
    @model = open_test_model_with_multiple_schemas()
  end

  def open_test_model_with_multiple_schemas
    # To speed up tests the model is reused is possible. Tests that modify the
    # model should discard the model changes: close_active_model()
    # TODO(thomthom): Add a Ruby API method to expose the `dirty` state of the
    # model - whether it's been modified since last save/open.
    # Model.path must be converted to Ruby style path as SketchUp returns an
    # OS dependant path string.
    model = Sketchup.active_model
    if model.nil? || model.path.gsub("\\", '/') != TEST_MODEL
      # puts "\n------------------------ TC_ClassificationSchema  Opening Model"
      close_active_model()
      Sketchup.open_file(TEST_MODEL)
    end
    Sketchup.active_model
  end


  # ========================================================================== #
  # method Sketchup::ClassificationSchema.<=>
  # http://www.sketchup.com/intl/developer/docs/ourdoc/classificationschema#<=>

  def test_Operator_Sort_api_example
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    schema1 = Sketchup.active_model.classifications["IFC 2x3"]
    schema2 = Sketchup.active_model.classifications["gbXML"]
    # Returns -1
    result = schema1 <=> schema2
    # Returns an array of sorted schemas.
    schemas = Sketchup.active_model.classifications.to_a.sort
  end

  def test_Operator_Sort_equal
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    schema1 = @model.classifications["IFC 2x3"]
    schema2 = @model.classifications["IFC 2x3"]
    assert_equal("IFC 2x3", schema1.name)
    assert_equal("IFC 2x3", schema2.name)
    result = schema1 <=> schema2
    assert(0, result)
  end

  def test_Operator_Sort_less_than
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    schema1 = @model.classifications["IFC 2x3"]
    schema2 = @model.classifications["gbXML"]
    assert_equal("IFC 2x3", schema1.name)
    assert_equal("gbXML", schema2.name)
    result = schema1 <=> schema2
    assert(-1, result)
  end

  def test_Operator_Sort_greater_than
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    schema1 = @model.classifications["gbXML"]
    schema2 = @model.classifications["IFC 2x3"]
    assert_equal("gbXML", schema1.name)
    assert_equal("IFC 2x3", schema2.name)
    result = schema1 <=> schema2
    assert(1, result)
  end

  def test_Operator_Sort_invalid_comparison_type
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    schema = @model.classifications["IFC 2x3"]
    result = schema <=> ORIGIN
    assert_nil(result)
  end


  # ========================================================================== #
  # method Sketchup::ClassificationSchema.==
  # http://www.sketchup.com/intl/developer/docs/ourdoc/classificationschema#==

  
  def test_Operator_Equal_api_example
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    schema1 = Sketchup.active_model.classifications["CityGML 2.0"]
    schema2 = Sketchup.active_model.classifications[0]
# ??????
# dependent on MultipleClassifications.skp
#    assert_equal schema1,schema2
  end

  def test_Operator_Equal_is_equal
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    schema1 = @model.classifications["IFC 2x3"]
    schema2 = @model.classifications["IFC 2x3"]
    assert_equal("IFC 2x3", schema1.name)
    assert_equal("IFC 2x3", schema2.name)
    assert(schema1 == schema2)
  end

  def test_Operator_Equal_is_not_equal
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    schema1 = @model.classifications["IFC 2x3"]
    schema2 = @model.classifications["gbXML"]
    assert_equal("IFC 2x3", schema1.name)
    assert_equal("gbXML", schema2.name)
    assert(!(schema1 == schema2))
    assert(schema1 != schema2)
  end

  def test_Operator_Equal_compare_against_number
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    schema = @model.classifications["IFC 2x3"]
    assert(schema != 3.14)
  end

  def test_Operator_Equal_compare_against_point
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    schema = @model.classifications["IFC 2x3"]
    assert(schema != ORIGIN)
  end


  # ========================================================================== #
  # method Sketchup::ClassificationSchema.name
  # http://www.sketchup.com/intl/developer/docs/ourdoc/classificationschema#name

  def test_name_api_example
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    exp = ['CityGML 2.0', 'IFC 2x3', 'gbXML']
    assert_equal exp, @model.classifications.map { |s| s.name }.sort
  end

  def test_name
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    schema = @model.classifications["IFC 2x3"]
    assert_kind_of(String, schema.name)
    assert_equal("IFC 2x3", schema.name)
  end

  def test_name_incorrect_number_of_arguments_one
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    schema = @model.classifications["IFC 2x3"]
    assert_raises(ArgumentError) { schema.name 1 }
  end


  # ========================================================================== #
  # method Sketchup::ClassificationSchema.namespace
  # http://www.sketchup.com/intl/developer/docs/ourdoc/classificationschema#namespace

  def test_namespace_api_example
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    exp = %w[http://www.gbxml.org/schema
             http://www.iai-tech.org/ifcXML/IFC2x3/FINAL
             http://www.opengis.net/citygml/profiles/base/2.0]
    assert_equal exp, @model.classifications.map { |s| s.namespace }.sort
  end

  def test_namespace
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    schema = @model.classifications["IFC 2x3"]
    assert_kind_of(String, schema.namespace)
    assert_equal "http://www.iai-tech.org/ifcXML/IFC2x3/FINAL", schema.namespace
  end

  def test_namespace_incorrect_number_of_arguments_one
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    schema = @model.classifications["IFC 2x3"]
    assert_raises(ArgumentError) { schema.namespace 1 }
  end


end # class
