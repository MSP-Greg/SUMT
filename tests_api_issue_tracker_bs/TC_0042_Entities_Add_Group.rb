# frozen_string_literal: true
=begin
————————————————————————————————————————————————————————————————————————————————
SUMT.run d:'tests_api_issue_tracker_bs', f:%w[TC_0042_Entities_Add_Group.rb]
SUMT.run d:'tests_api_issue_tracker_bs', f:%w[TC_0042_Entities_Add_Group.rb], gu:true, gl:true

https://github.com/SketchUp/api-issue-tracker/issues/42
reported by @Eneroth

Copyright 2018 MSP-Greg
License: The MIT License (MIT)

Notes: Both the Ruby console reporting and the UDPReceiver show that all
  Minitest code finishes before the Bug Splat

————————————————————————————————————————————————————————————————————————————————
=end

class TC_0042_Entities_Add_Group < SUMT::TestCase

  def xxx_test_group_in_group
#    group = Sketchup.active_model.active_entities.add_group
    group = Sketchup.active_model.entities.add_group
    grp_ents = group.entities
    face = grp_ents.add_face(
      ORIGIN,
      Geom::Point3d.new(1.m, 0, 0),
      Geom::Point3d.new(1.m, 1.m, 0),
      Geom::Point3d.new(0, 1.m, 0)
    )
    assert_equal 5, grp_ents.length

    # tried adding both face and face & edges, both Bug Splat
    new_ents = [face, face.edges].flatten
    inner_grp = grp_ents.add_group new_ents
    tr = Geom::Transformation.translation [5.m,0,0]
    inner_grp.transformation = tr
    assert_equal 6, grp_ents.length
  end

  def test_group_in_group_2
#    act_ents = Sketchup.active_model.active_entities
    act_ents = Sketchup.active_model.entities
    face = act_ents.add_face(
      ORIGIN,
      Geom::Point3d.new(1.m, 0, 0),
      Geom::Point3d.new(1.m, 1.m, 0),
      Geom::Point3d.new(0, 1.m, 0)
    )
    group = act_ents.add_group [face, face.edges].flatten
    grp_ents = group.entities
    assert_equal 5, grp_ents.length
    inner_grp = grp_ents.add_group [face, face.edges].flatten
    tr = Geom::Transformation.translation [5.m,0,0]
    inner_grp.transformation = tr
  end

  
end
