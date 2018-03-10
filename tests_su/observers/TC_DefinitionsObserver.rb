# frozen_string_literal: true
=begin
————————————————————————————————————————————————————————————————————————————————
SUMT.run_su_tests %w[TC_DefinitionsObserver.rb]

Copyright 2018 MSP-Greg
License: The MIT License (MIT)
————————————————————————————————————————————————————————————————————————————————
=end

# class Sketchup::DefinitionsObserver
# http://ruby.sketchup.com/Sketchup/DefinitionsObserver.html
class TC_DefinitionsObserver < SUMT::TestCase

  BED = Sketchup.find_support_file('Bed.skp', C_CS)

  class DefsObs < Sketchup::DefinitionsObserver
    include SUMT::ObserverEvtToHsh
  end

  def setup
    start_with_empty_model
    @model = Sketchup.active_model
    @defs  = @model.definitions
    @obs ||= DefsObs.new
    @obs.events_clear!
  end

  def teardown
    @defs.remove_observer @obs
  end

  def test_onComponentAdded
    @defs.add_observer @obs
    definition = @defs.load(BED)

    # below works, appears that the 'top most' or root def is called last
    # hence, the 2nd parameter matches, may fail in the future
    assert_obs_event  :onComponentAdded, 12, @defs, definition
    assert_obs_event  :onComponentPropertiesChanged, 1, @defs, definition
    assert_obs_events 2
  end

  def test_onComponentPropertiesChanged
    definition = @defs.load(BED)
    @defs.add_observer @obs
    definition.name = "Bed1"

    assert_obs_event  :onComponentPropertiesChanged, 1, @defs, definition
    assert_obs_events
  end

  def test_onComponentRemoved_remove
    skip("Sketchup::DefinitionList#remove SU2018") if SU_VERS_INT < 18

    definition = @defs.load(BED)
    @defs.add_observer @obs
    @defs.remove(definition)

    # below works, appears that the 'top most' or root def is called last
    # hence, the 2nd parameter matches, may fail in the future
    assert_obs_event  :onComponentRemoved, 2, @defs, definition
    assert_obs_events
  end

  def test_onComponentRemoved_purge_unused
    definition = @defs.load(BED)
    @defs.add_observer @obs
    @defs.purge_unused

    # remove definition parameter, as it may be indeterminate
    assert_obs_event  :onComponentRemoved, 24, @defs, nil
    assert_obs_events
  end
end