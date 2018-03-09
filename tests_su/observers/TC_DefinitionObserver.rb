# frozen_string_literal: true
=begin
————————————————————————————————————————————————————————————————————————————————
SUMT.run_su_tests %w[TC_DefinitionObserver.rb]

Copyright 2018 MSP-Greg
License: The MIT License (MIT)
————————————————————————————————————————————————————————————————————————————————
=end

# class Sketchup::DefinitionObserver
# http://ruby.sketchup.com/Sketchup/DefinitionObserver.html
class TC_DefinitionObserver < SUMT::TestCase

  PTS = [ [0,0,0], [100,0,0], [100,100,0], [0,100,0] ]

  TRANS = Geom::Transformation.new Geom::Point3d.new(0,0,100)

  class DefObs < Sketchup::DefinitionObserver
    include SUMT::ObserverEvtToHsh
  end

  def self.ste_setup
    @@obs = DefObs.new
  end

  def self.ste_teardown
    @@obs = nil
  end

  def setup
    start_with_empty_model
    @model = Sketchup.active_model
    @ents  = @model.entities
    @defs  = @model.definitions
    @def   = @defs.add "DefinitionObserver"
    @def.entities.add_face PTS
#    @obs ||= DefObs.new
#    @obs.events_clear!
    @@obs.events_clear!
  end

  def teardown
#    @def.remove_observer(@obs) unless @def.deleted?
    @def.remove_observer(@@obs) unless @def.deleted?
  end

  def test_onComponentInstanceAdded
    @def.add_observer @@obs
    inst  = @ents.add_instance @def, TRANS

    assert_obs_event  :onComponentInstanceAdded, @def, inst
    assert_obs_event  :onChangeEntity, @def
    assert_obs_events 2
  end

  def test_onComponentInstanceRemoved
    inst  = @ents.add_instance @def, TRANS
    @def.add_observer @@obs
    @ents.erase_entities inst

    assert_obs_event  :onComponentInstanceRemoved, @def, inst
    assert_obs_event  :onChangeEntity, @def
    assert_obs_events 2
  end

  #————————————————————————————————————————— Below inherited from EntityObserver

  def test_onChangeEntity
    @def.add_observer @@obs
    @def.name = "DefinitionObserver1"

    assert_obs_event  :onChangeEntity, @def
    assert_obs_events
  end

  def test_onEraseEntity_remove
    skip("Sketchup::DefinitionList#remove SU2018") if SU_VERS_INT < 18
    @def.add_observer @@obs
    @defs.remove(@def)

    assert_obs_event  :onChangeEntity, @def
    assert_obs_event  :onEraseEntity, @def
    assert_obs_events 2
  end

  def test_onEraseEntity_purge
    @def.add_observer @@obs
    @defs.purge_unused

    assert_obs_event  :onChangeEntity, @def
    assert_obs_event  :onEraseEntity , @def
    assert_obs_events 2
  end
end
