# frozen_string_literal: true
=begin
————————————————————————————————————————————————————————————————————————————————
SUMT.run d:'tests_api_issue_tracker', f:%w[TC_0056_Texture_Change_EntObs.rb]

Copyright 2018 MSP-Greg
License: The MIT License (MIT)
————————————————————————————————————————————————————————————————————————————————
=end

class TC_0056_Texture_Change_EntObs < SUMT::TestCase

  class EntitiesObs < Sketchup::EntitiesObserver
      include SUMT::ObserverEvtToHsh
  end

  def test_change_texture_twice
    obs   = EntitiesObs.new
    obs.events_clear!
    model = start_with_empty_model
    ents  = model.entities
    mat   = model.materials.add '0056'
    
    mat.texture = get_test_file 'test_small.jpg'
    mat.colorize_type = Sketchup::Material::COLORIZE_TINT
    mat.color = [128, 128, 0]

    face = model.entities.add_face [ [0,0,0], [100,0,0], [100,100,0], [0,100,0] ]
    face.material = mat
    
    pt_array = []

    pt_array[0] = Geom::Point3d.new(3,0,0)
    pt_array[1] = Geom::Point3d.new(0,0,0)

    model.entities.add_observer obs

    face.position_material(mat, pt_array, true)
    assert_obs_event :onElementModified, 1, ents, face
    
    pt_array[0] = Geom::Point3d.new(0,3,0)
    pt_array[1] = Geom::Point3d.new(0,3,0)
    
    face.position_material(mat, pt_array, true)
    assert_obs_event :onElementModified, 2, ents, face

  end

end