# frozen_string_literal: true
=begin
————————————————————————————————————————————————————————————————————————————————
SUMT.run d:'tests_api_issue_tracker_bs', f:%w[TC_0042_Entities_Add_Group.rb]

https://github.com/SketchUp/api-issue-tracker/issues/42
reported by @Eneroth

Copyright 2018 MSP-Greg
License: The MIT License (MIT)

Notes: Both the Ruby console reporting and the UDPReceiver show that all
  Minitest code finishes before the Bug Splat

————————————————————————————————————————————————————————————————————————————————
=end

class TC_0042_Entities_Add_Group < SUMT::TestCase

  def test_group_in_group
    group = Sketchup.active_model.entities.add_group
    grp_ents = group.entities
    face = grp_ents.add_face(
      ORIGIN,
      Geom::Point3d.new(1.m, 0, 0),
      Geom::Point3d.new(1.m, 1.m, 0),
      Geom::Point3d.new(0, 1.m, 0)
    )
    # tried adding both face and face & edges, both Bug Splat
    new_ents = [face, face.edges].flatten
    grp_ents.add_group(new_ents)
    assert_equal 5, grp_ents.length
  end

end
