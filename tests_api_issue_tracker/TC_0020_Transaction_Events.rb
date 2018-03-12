# frozen_string_literal: true
=begin
————————————————————————————————————————————————————————————————————————————————
SUMT.run d:'tests_api_issue_tracker', f:%w[TC_0020_Transaction_Events.rb]

https://github.com/SketchUp/api-issue-tracker/issues/20
reported by @prachtan

Copyright 2018 MSP-Greg
License: The MIT License (MIT)
————————————————————————————————————————————————————————————————————————————————
=end

class TC_0020_Transaction_Events < SUMT::TestCase

  def setup
    @model = Sketchup.active_model
    @ents  = @model.entities
    @ents_obs ||= EntitiesObs.new
    @mod_obs  ||= ModelObs.new
    @mod_obs.events_clear!
    @ents_obs.events_clear!
  end

  def teardown
    @ents.remove_observer  @ents_obs
    @model.remove_observer @mod_obs
  end

  class EntitiesObs < Sketchup::EntitiesObserver
      include SUMT::ObserverEvtToQueue
  end

  class ModelObs < Sketchup::EntitiesObserver
      include SUMT::ObserverEvtToQueue
  end

  def add_edge
    edges = @ents.add_edges [ [0,0,0], [100,0,0] ]
    [ ["ModelObs" , :onTransactionStart , @model     ],
      ["EntitiesObs", :onElementAdded     , @ents, edges[0] ],
      ["ModelObs" , :onTransactionCommit, @model     ]
    ]
  end

  def msg_queue(exp, act)
    str = ''.dup
    str << "—————————————————————————————————————————————————————————————————————— Expected\n"
    exp.each { |i| str << "#{i.inspect}\n" }
    str << "—————————————————————————————————————————————————————————————————————— Actual\n"
    act.each { |i| str <<  "#{i.inspect}\n" }
    str
  end
  
  # @ents.add_observer first
  def test_model_entities_add
    start_with_empty_model

    @ents.add_observer @ents_obs
    @model.add_observer @mod_obs

    exp = add_edge
    assert_equal exp, OBS_QUEUE, msg_queue(exp, OBS_QUEUE)
  end

  # @model.add_observer first
  def test_entities_model_add
    start_with_empty_model

    @model.add_observer @mod_obs
    @ents.add_observer @ents_obs

    exp = add_edge
    assert_equal exp, OBS_QUEUE, msg_queue(exp, OBS_QUEUE)
  end


end # class
