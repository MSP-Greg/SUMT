# frozen_string_literal: true
=begin 
————————————————————————————————————————————————————————————————————————————————
SUMT.run_su_tests %w[TC_EntitiesObserver.rb]

Copyright 2018 MSP-Greg
License: The MIT License (MIT)
————————————————————————————————————————————————————————————————————————————————
=end

# class Sketchup::EntitiesObserver
# http://ruby.sketchup.com/Sketchup/EntitiesObserver.html
class TC_EntitiesObserver < SUMT::TestCase

  PTS = [ [0,0,0], [100,0,0], [100,100,0], [0,100,0] ]
  
  class EntitiesObs < Sketchup::EntitiesObserver
      include SUMT::ObserverEvtToHsh
  end

  def setup
    start_with_empty_model
    @model = Sketchup.active_model
    @ents  = @model.entities
    @obs ||= EntitiesObs.new
    @obs.events_clear!
  end

  def teardown
    @ents.remove_observer @obs
    Sketchup.undo
  end
  
  def test_onActiveSectionPlaneChanged
    @ents.add_observer @obs
  end

  def test_onElementAdded
    @ents.add_observer @obs
    face = @ents.add_face PTS

    assert_obs_event  :onElementAdded, @ents, 5
    assert_obs_events
  end
  
  def test_onElementModified
    face = @ents.add_face PTS
    @ents.add_observer @obs
    face.reverse!

    assert_obs_event  :onElementModified, @ents, face, 1
    assert_obs_events
  end

  # Checks for entityID parameter
  def test_onElementRemoved_edge
    edges = @ents.add_edges PTS[0,2]
    @ents.add_observer @obs
    id = edges[0].entityID
    @ents.erase_entities edges
    assert_obs_event  :onElementRemoved, @ents, id, 1
    assert_obs_events
    Sketchup.undo  #erase
  end

  # Does not check for entityID, as last call may vary
  def test_onElementRemoved_face
    face = @ents.add_face PTS
    @ents.add_observer @obs
    @ents.erase_entities face.edges
    assert_obs_event  :onElementRemoved, @ents, 5
    assert_obs_events
    Sketchup.undo  #erase
  end

  def test_onEraseEntities
    face = @ents.add_face PTS
    @ents.add_observer @obs
    face.edges[0].erase!

    # Three remaining edges all have property changes (faces, all_connected)
    assert_obs_event  :onElementModified, @ents, 3
    assert_obs_event  :onElementRemoved , @ents, 2
    assert_obs_event  :onEraseEntities  , @ents, 1
    assert_obs_events 3

    Sketchup.undo  # erase
  end
end
