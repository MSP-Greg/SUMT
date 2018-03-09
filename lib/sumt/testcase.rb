# frozen_string_literal: true

#———————————————————————————————————————————————————————————————————————————————
#
# Copyright 2013-2014 Trimble Navigation Ltd.
# License: The MIT License (MIT)
#
#———————————————————————————————————————————————————————————————————————————————

module SUMT

# Provides SketchUp specific methods for test classes.  A few of the attributes/methods
# are available as both class and instance methods to make their use easier.  Some are
# pull directly from testup-2, as they are currently used in the SketchUp test suite.
#
class TestCase < Minitest::Test

  # @!macro [new] temp_dir
  #   @!attribute [r] temp_dir
  #   Returns a temp folder of \<Sketchup.temp_dir\>/SUMT/\<klass\>, creates if
  #   it doesn't exist.
  #   @return [string]

  # @!macro [new] get_test_file
  #   @!method get_test_file(fn, _dir = nil)
  #   Gets a test file by name/ext from either an 'asset/<ext> folder at the level
  #   of the test or above, or from a folder with a name matching the test class.
  #   See the layout of the SketchUp tests for examples.
  #   @param [String] fn file name
  #   @param [String] _dir optional directory name
  #   @return [String] the full path to the file

  # @!macro [new] start_with_empty_model
  #   @!method start_with_empty_model(clr_schemas: true)
  #   Clears model of Entities, CompDefs, Layers, Materials, Pages, Styles, and
  #   (optionally) schemas.
  #   @param [boolean] clr_schemas: if false, schemas are not cleared/purged.


  SKETCHUP_UNIT_TOLERANCE  = 1.0e-3
  SKETCHUP_FLOAT_TOLERANCE = 1.0e-10
  SKETCHUP_RANGE_MAX = -1.0e30
  SKETCHUP_RANGE_MIN =  1.0e30

  SU_VERS_INT = Sketchup.version.to_i
  C_CS = 'Components/Components Sampler/'
  IFC  = Sketchup.find_support_file("IFC 2x3.skc", "Classifications")

  include SUMT::Assertions

  class << self

    # @!macro get_test_file
    def get_test_file(tfn, _dir = nil)
      # first, try directory named as the class
      dir = _dir || File.dirname("#{SUMT.test_dir}/#{fn}")
      klass = self.is_a?(Module) ? self.name : self.class.name
      full_fn = "#{dir}/#{klass}/#{tfn}"
      return full_fn if File.exist? full_fn

      # now try in assets/ext
      ext = File.extname(tfn)[1..-1]
      if File.exist? (t = "#{dir}/assets/#{ext}/#{tfn}")
        t
      elsif File.exist? (t = "#{SUMT.test_dir}/assets/#{ext}/#{tfn}")
        t
      else
        puts "Cannot find file #{tfn} in\n\n" \
          "#{dir}/#{klass}\n" \
          "#{dir}/assets/#{ext}\n" \
          "#{SUMT.test_dir}/assets/#{ext}"
        raise ArgumentError
      end
    end

    # @!macro start_with_empty_model
    def start_with_empty_model(clr_schemas: true)
      abort   = true
      ents    = false
      defs    = false
      lyrs    = false
      mats    = false
      pages   = false
      styles  = false
      schemas = false

      model = Sketchup.active_model
      model.active_view.camera.aspect_ratio = 0.0

      while model.close_active; end
      ents    = model.entities.length    != 0
      defs    = model.definitions.length != 0
      mats    = model.materials.length   != 0
      pages   = model.pages.length       != 0
      schemas = SU_VERS_INT >= 15 && clr_schemas && model.classifications.length != 0

      lyrs    = model.layers.length      > 1
      styles  = model.styles.length      > 1


      if ents || defs || lyrs || mats || pages || styles || schemas
        # $stdout.write " Clearing Model "
        model.start_operation('SUMT Empty Model', true)
        if ents
          model.entities.each { |entity|
            next unless entity.respond_to? :locked=
            entity.locked = false if entity.locked?
          }
          model.entities.clear!
        end

        model.definitions.purge_unused if defs && model.definitions.length != 0

        if lyrs
          model.active_layer = nil if model.active_layer
          model.layers.purge_unused
        end

        if mats
          model.materials.current = nil if model.materials.current
          model.materials.purge_unused
        end

        if schemas
          # SUMT::FileReporter.io.puts "Cleared Schemas"
          ary = model.classifications.keys
          c   = model.classifications
          ary.each { |k| c.unload_schema k }
        end

        model.pages.each { |page| model.pages.erase(page) } if pages
        model.styles.purge_unused if styles
        model.commit_operation
      end
      model
    end

    # @!macro temp_dir
    def temp_dir
      klass = self.is_a?(Module) ? self.name : self.class.name
      tmp = "#{Sketchup.temp_dir}/SUMT/#{klass}".freeze
      FileUtils.mkdir_p(tmp) unless Dir.exist?(tmp)
      tmp
    end

#    def ste_setup    ; end
#    def ste_teardown ; end

  end # class << self

  # @!macro get_test_file
  def get_test_file(fn, _dir = nil) ; self.class.get_test_file(fn,_dir)    ; end

  # @!macro start_with_empty_model
  def start_with_empty_model(**args)
    self.class.start_with_empty_model(args)
  end

  # @!macro temp_dir
  def temp_dir ; self.class.temp_dir ; end

  def open_new_model
    model = Sketchup.active_model
    if model.respond_to? :close
      model.close true
      Sketchup.file_new if Sketchup.platform == :platform_osx
    else
      Sketchup.file_new
    end
  end

  def discard_model_changes
    model = Sketchup.active_model
    if model.respond_to? :close
      model.close true
      Sketchup.platform == :platform_osx and Sketchup.file_new
    end
  end

  def close_active_model
    model = Sketchup.active_model
    model.respond_to?(:close) and model.close(true)
  end

  def disable_read_only_flag_for_test_models
    return false if Test.respond_to?(:suppress_warnings=)
    source = caller_locations(1,1)[0].absolute_path
    path = File.dirname(source)
    basename = File.basename(source, ".*")
    support_path = File.join(path, basename)
    skp_model_filter = File.join(support_path, '*.skp')
    @read_only_files = []
    Dir.glob(skp_model_filter) { |file|
      if !File.writable?(file)
        @read_only_files << file
        FileUtils.chmod("a+w", file)
      end
    }
    true
  end

  def restore_read_only_flag_for_test_models
    return false if Test.respond_to?(:suppress_warnings=)
    source = caller_locations(1,1)[0].absolute_path
    path = File.dirname(source)
    basename = File.basename(source, ".*")
    support_path = File.join(path, basename)
    skp_model_filter = File.join(support_path, '*.skp')
    @read_only_files.each { |file|
      FileUtils.chmod("a-w", file)
    }
    @read_only_files.clear
    true
  end

  def capture_stdout(verbose = $VERBOSE, &block)
    io_buffer = StringIO.new
    stdout = $stdout
    $stdout = io_buffer
    set_verbose_mode(verbose) {
      block.call
    }
    io_buffer.string.dup
  ensure
    $stdout = stdout
  end

  def capture_stderr(verbose = $VERBOSE, &block)
    io_buffer = StringIO.new
    stderr = $stderr
    $stderr = io_buffer
    set_verbose_mode(verbose) { block.call }
    io_buffer.string.dup
  ensure
    $stderr = stderr
  end

  VERBOSE_SILENT = nil
  VERBOSE_SOME   = false # Default
  VERBOSE_ALL    = true
  def set_verbose_mode(mode, &block)
    verbose = $VERBOSE
    $VERBOSE = mode
    block.call
  ensure
    $VERBOSE = verbose
  end

end # class TestCase
end # module
