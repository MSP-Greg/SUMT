# Copyright:: Copyright 2016 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen





class TC_InstancePath < SUMT::TestCase

  def setup
    start_with_empty_model
#    @path = create_test_instances
  end

  # Model > ComponentInstance > Group1 > Group2 > Group3 > Edge
  def create_test_instances
    model = Sketchup.active_model
    model.start_operation(self.name, true)
    definition = model.definitions.add(self.name)
    group1 = definition.entities.add_group
    group2 = group1.entities.add_group
    group2.transform!([10, 20, 30])
    group3 = group2.entities.add_group
    edge = group3.entities.add_line([10, 10, 10], [20, 20, 20])
    tr = Geom::Transformation.new([20, 30, 40])
    instance = model.entities.add_instance(definition, tr)
    path = [instance, group1, group2, group3, edge]
    inst_path = Sketchup::InstancePath.new path
    yield inst_path, path
    path.each { |e| e = nil }
    path = nil
#    model.definitions.purge_unused
    model.abort_operation
  end

  def create_invalid_instance_path
    create_test_instances do |inst_path, path|
      Sketchup.active_model.entities.clear!
      Sketchup.active_model.definitions.purge_unused
      yield inst_path, path
    end
  end

  def compute_expected_transformation(path)
    instances = path.select { |entity|
      entity.is_a?(Sketchup::Group) || entity.is_a?(Sketchup::ComponentInstance)
    }
    tr = Geom::Transformation.new
    instances.each { |instance| tr = tr * instance.transformation }
    tr
  end


  # ========================================================================== #
  # class Sketchup::InstancePath

  def test_introduction_api_example
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    # TODO:
  end


  # ========================================================================== #
  # method Sketchup::InstancePath.initialize

  def test_initialize_api_example
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    model = Sketchup.active_model
    group = model.entities.add_group
    edge = group.entities.add_line([10, 10, 10], [20, 20, 20])
    path = Sketchup::InstancePath.new([group, edge])
  end

  def test_initialize_from_valid_array
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      assert_equal(path.size, inst_path.to_a.size)
      assert(inst_path.valid?)
    end
  end

  def test_initialize_from_valid_array_one_instance
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, _path|
      path = [_path.first]
      instance_path = Sketchup::InstancePath.new(path)
      assert_equal(path.size, instance_path.to_a.size)
      assert(instance_path.valid?)
    end
  end

  def test_initialize_invalid_path
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    path = [123, 456, 678]
#    Sketchup.active_model.entities.clear!
    assert_raises(ArgumentError) {
      instance_path = Sketchup::InstancePath.new(path)
    }
  end

  def test_initialize_invalid_path_entities
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, _path|
      path = _path.reverse
      assert_raises(ArgumentError) {
        instance_path = Sketchup::InstancePath.new(path)
      }
    end
  end

  def test_initialize_deleted_entities
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      Sketchup.active_model.entities.clear!
      assert_raises(ArgumentError) {
        instance_path = Sketchup::InstancePath.new(path)
      }
    end
  end


  # ========================================================================== #
  # method Sketchup::InstancePath.to_a
  
  def test_to_a
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      result = inst_path.to_a
      assert_kind_of(Array, result)
      assert_equal(path, result)
    end
  end

  def test_to_a_empty_path
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    path = []
    instance_path = Sketchup::InstancePath.new(path)
    result = instance_path.to_a
    assert_kind_of(Array, result)
    assert_equal(path, result)
  end

  def test_to_a_deleted_entities
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_invalid_instance_path do |inst_path, path|
      assert_raises(TypeError) { inst_path.to_a }
    end
  end

  def test_to_a_incorrect_number_of_arguments_one
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      assert_raises(ArgumentError) { inst_path.to_a(nil) }
    end
  end


  # ========================================================================== #
  # method Sketchup::InstancePath.include?
  
  def test_include_Query
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      path.each { |item| assert(inst_path.include?(item), "item: #{item}") }
      refute(inst_path.include?(Sketchup.active_model))
      refute(inst_path.include?(nil))
    end
  end

  def test_include_Query_deleted_entities
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_invalid_instance_path do |inst_path, path|
      assert_raises(TypeError) { inst_path.include?(nil) }
    end
  end

  def test_include_Query_incorrect_number_of_arguments_zero
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      assert_raises(ArgumentError) { inst_path.include? }
    end
  end

  def test_include_Query_incorrect_number_of_arguments_two
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      assert_raises(ArgumentError) { inst_path.include?(nil, nil) }
    end
  end

  def test_length_size
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      assert_equal(path.length, inst_path.length)
      assert_equal(path.size, inst_path.size)
    end
  end

  def test_size_deleted_entities
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_invalid_instance_path do |inst_path, path|
      assert_raises(TypeError) { inst_path.size }
    end
  end

  def test_size_incorrect_number_of_arguments_one
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      assert_raises(ArgumentError) { inst_path.size(nil) }
    end
  end

  def test_length_deleted_entities
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_invalid_instance_path do |inst_path, path|
      assert_raises(TypeError) { inst_path.length }
    end
  end

  def test_length_incorrect_number_of_arguments_one
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      assert_raises(ArgumentError) { inst_path.length(nil) }
    end
  end


  # ========================================================================== #
  # method Sketchup::InstancePath.leaf
  
  def test_leaf
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      assert_equal(path.last, inst_path.leaf)
    end
  end

  def test_leaf_instance_path_empty
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    instance_path = Sketchup::InstancePath.new([])
    assert_nil(instance_path.leaf)
  end

  def test_leaf_deleted_entities
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_invalid_instance_path do |inst_path, path|
      assert_raises(TypeError) { inst_path.leaf }
    end
  end

  def test_leaf_incorrect_number_of_arguments_one
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      assert_raises(ArgumentError) { inst_path.leaf(nil) }
    end
  end


  # ========================================================================== #
  # method Sketchup::InstancePath.root
  
  def test_root
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      assert_equal(path.first, inst_path.root)
    end
  end

  def test_root_instance_path_empty
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    instance_path = Sketchup::InstancePath.new([])
    assert_nil(instance_path.root)
  end

  def test_root_deleted_entities
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_invalid_instance_path do |inst_path, path|
      assert_raises(TypeError) { inst_path.root }
    end
  end

  def test_root_incorrect_number_of_arguments_one
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      assert_raises(ArgumentError) { inst_path.root(nil) }
    end
  end


  # ========================================================================== #
  # method Sketchup::InstancePath.valid?
  
  def test_valid_Query
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      assert(inst_path.valid?)
    end
  end

  def test_valid_Query_instance_path_empty
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    instance_path = Sketchup::InstancePath.new([])
    refute(instance_path.valid?)
  end

  def test_valid_Query_deleted_entities
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_invalid_instance_path do |inst_path, path|
      refute(inst_path.valid?)
    end
  end

  def test_valid_Query_incorrect_number_of_arguments_one
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      assert_raises(ArgumentError) { inst_path.valid?(nil) }
    end
  end


  # ========================================================================== #
  # method Sketchup::InstancePath.empty?
  
  def test_empty_Query
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      refute(inst_path.empty?)
    end
  end

  def test_empty_Query_instance_path_empty
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    instance_path = Sketchup::InstancePath.new([])
    assert(instance_path.empty?)
  end

  def test_empty_Query_deleted_entities
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_invalid_instance_path do |inst_path, path|
      assert_raises(TypeError) { inst_path.empty? }
    end
  end

  def test_empty_Query_incorrect_number_of_arguments_one
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      assert_raises(ArgumentError) { inst_path.empty?(nil) }
    end
  end


  # ========================================================================== #
  # method Sketchup::InstancePath.persistent_id_path
  
  def test_persistent_id_path
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      result = inst_path.persistent_id_path
      expected = path.map { |entity| entity.persistent_id }.join('.')
      assert_equal(expected, result)
    end
  end

  def test_persistent_id_path_instance_path_empty
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    instance_path = Sketchup::InstancePath.new([])
    result = instance_path.persistent_id_path
    expected = ''
    assert_equal(expected, result)
  end

  def test_persistent_id_path_deleted_entities
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_invalid_instance_path do |inst_path, path|
      assert_raises(TypeError) { inst_path.persistent_id_path }
    end
  end

  def test_persistent_id_path_incorrect_number_of_arguments_one
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      assert_raises(ArgumentError) { inst_path.persistent_id_path(nil) }
    end
  end


  # ========================================================================== #
  # method Sketchup::InstancePath.transformation
  
  def test_transformation
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      result = inst_path.transformation
      expected = compute_expected_transformation(path)
      assert_equal(expected.to_a, result.to_a)
    end
  end

  def test_transformation_one_argument
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
    result = inst_path.transformation(1)
      expected = compute_expected_transformation(path[0, 2])
      assert_equal(expected.to_a, result.to_a)
    end
  end

  def test_transformation_instance_path_empty
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    path = []
    instance_path = Sketchup::InstancePath.new(path)
    result = instance_path.transformation
    expected = compute_expected_transformation(path)
    assert_equal(expected.to_a, result.to_a)
  end

  def test_transformation_deleted_entities
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_invalid_instance_path do |inst_path, path|
      assert_raises(TypeError) { inst_path.transformation }
    end
  end

  def test_transformation_invalid_argument_nil
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      assert_raises(TypeError) { inst_path.transformation(nil) }
    end
  end

  def test_transformation_incorrect_number_of_arguments_two
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      assert_raises(ArgumentError) { inst_path.transformation(1, 1) }
    end
  end

  def test_transformation_invalid_argument_less_than_zero
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      assert_raises(IndexError) { inst_path.transformation(-1) }
    end
  end

  def test_transformation_invalid_argument_index_out_of_bounds
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      assert_raises(IndexError) { inst_path.transformation(999999) }
    end
  end


  # ========================================================================== #
  # method Sketchup::InstancePath.==
  
  def test_Operator_Equal
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      instance_path1 = Sketchup::InstancePath.new(path)
      instance_path2 = Sketchup::InstancePath.new(path)
      assert(instance_path1 == instance_path2)
    end
  end

  def test_Operator_Equal_not_equal
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      instance_path2 = Sketchup::InstancePath.new([])
      refute(inst_path == instance_path2)
    end
  end

  def test_Operator_Equal_deleted_entities
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      create_invalid_instance_path do |_inst_path, _path|
        inst_path1 = _inst_path
        inst_path2 = Sketchup::InstancePath.new([])
        refute(inst_path  == inst_path1)
        refute(inst_path1 == inst_path)
        assert(inst_path  == inst_path)
        assert(inst_path1 == inst_path1)
      end
    end
  end

  def test_Operator_Equal_compare_against_other_types
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      refute(inst_path == nil)
      refute(inst_path == 123)
      refute(inst_path == 'hello')
    end
  end


  # ========================================================================== #
  # method Sketchup::InstancePath.[]
  
  def test_Operator_Get
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      assert_equal(path[0], inst_path[0])
    end
  end

  def test_Operator_Get_leaf
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      index = path.size - 1
      assert_equal(path[index], inst_path[index])
    end
  end

  def test_Operator_Get_no_leaf
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, _path|
      path = _path[0...-1]
      index = path.size - 1
      instance_path = Sketchup::InstancePath.new(path)
      assert_equal(path[index], instance_path[index])
    end
  end

  def test_Operator_Get_deleted_entities
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_invalid_instance_path do |inst_path, path|
      assert_raises(TypeError) { inst_path[0] }
    end
  end

  def test_Operator_Get_invalid_argument_less_than_zero
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, _path|
      assert_raises(IndexError) { inst_path[-1] }
    end
  end

  def test_Operator_Get_invalid_argument_index_out_of_bounds
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, _path|
      assert_raises(IndexError) { inst_path[999999] }
    end
  end

  def test_Operator_Get_invalid_argument_nil
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, _path|
      assert_raises(TypeError) { inst_path[nil] }
    end
  end

  def test_Operator_Get_incorrect_number_of_arguments_zero
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, _path|
      assert_raises(ArgumentError) { inst_path[] }
    end
  end

  def test_Operator_Get_incorrect_number_of_arguments_two
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, _path|
      assert_raises(ArgumentError) { inst_path[1, 2] }
    end
  end


  # ========================================================================== #
  # method Sketchup::InstancePath.each
  
  def test_each
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, path|
      assert_kind_of(Enumerable, inst_path)
      inst_path.each { |entity|
        assert_kind_of(Sketchup::Entity, entity)
        assert_includes(path, entity)
      }
    end
  end

  def test_each_deleted_entities
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_invalid_instance_path do |inst_path, path|
      assert_raises(TypeError) { inst_path.each {} }
    end
  end

  def test_each_incorrect_number_of_arguments_one
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |inst_path, _path|
      assert_raises(ArgumentError) { inst_path.each(nil) {} }
    end
  end

end # class
