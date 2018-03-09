# Copyright:: Copyright 2015 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen





# class Sketchup::Entity
class TC_Entity < SUMT::TestCase

  def setup
    start_with_empty_model
    @model = Sketchup.active_model
  end

  def teardown
    # ...
  end


  class SUMTEvilEntityObserver < Sketchup::EntityObserver

    def onChangeEntity(entity)
      # puts "#{self.class.name}.onChangeEntity(#{entity})"
      entity.attribute_dictionaries.delete("SUMT")
    end

  end # class


  # ========================================================================== #
  # method Sketchup::Entity.attribute_dictionary

  def test_attribute_dictionary_evil_observer_without_operation
    skip "MSP-Greg"
    edge = @model.entities.add_line(ORIGIN, [5,5,5])

    observer = SUMTEvilEntityObserver.new
    edge.add_observer(observer)

    dictionary = edge.attribute_dictionary("SUMT", true)

    assert_kind_of(Sketchup::AttributeDictionary, dictionary)
    assert(dictionary.deleted?, "Dictionary not deleted")

    assert_raises(TypeError) { dictionary.parent }
  ensure
    #edge.remove_observer(observer)
    observer = nil
  end

  def test_attribute_dictionary_evil_observer_with_operation
    skip "MSP-Greg"
    edge = @model.entities.add_line(ORIGIN, [5,5,5])

    observer = SUMTEvilEntityObserver.new
    edge.add_observer(observer)

    @model.start_operation("SUMT", true)

    dictionary = edge.attribute_dictionary("SUMT", true)

    assert_kind_of(Sketchup::AttributeDictionary, dictionary)
    assert_equal("SUMT", dictionary.name)
    assert(dictionary.valid?, "Dictionary deleted")

    @model.commit_operation

    assert_kind_of(Sketchup::AttributeDictionary, dictionary)
    assert(dictionary.deleted?, "Dictionary not deleted")
  ensure
    # edge.remove_observer(observer)
    observer = nil
    Sketchup.undo
  end


  # ========================================================================== #
  # method Sketchup::Entity.persistent_id

  def test_persistent_id_edge
    skip("Implemented in SU2017") if SU_VERS_INT < 17
    edge = @model.entities.add_line(ORIGIN, [5,5,5])

    result = edge.persistent_id
    assert_kind_of(Integer, result)
    assert(result > 0)
  end

  def test_persistent_id_vertex
    skip("Implemented in SU2017") if SU_VERS_INT < 17
    edge = @model.entities.add_line(ORIGIN, [5,5,5])

    result = edge.start.persistent_id
    assert_kind_of(Integer, result)
    assert(result > 0)
  end

  def test_persistent_id_incorrect_number_of_arguments_one
    skip("Implemented in SU2017") if SU_VERS_INT < 17
    edge = @model.entities.add_line(ORIGIN, [5,5,5])
    assert_raises(ArgumentError) { edge.persistent_id(nil) {} }
  end


end # class
