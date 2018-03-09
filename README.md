# @title SUMT ReadMe

# SUMT ReadMe

SUMT is a system for using Minitest (MT) from the SketchUp Ruby console.  All operations are performed by entering `SUMT.run` with one's desired parameters into the Ruby console.

## Why

I've worked with Minitest based test systems in both Ruby and several gems.  Most gems use the Rake::TestTask for running tests.  SUMT is a combination of the two, and has quite a few options.  Testup-2 is a very nice framework (thanks @thomThom), but I wanted something that was quicker to run, in addition to a few more options.

## Installation

1. Fork or download the git repo at https://github.com/MSP-Greg/SUMT.
2. The root of the repo contains a file `sumt_ext.rb`.  Edit the file PATH constant (line 22) to point to the base folder location of the repo (where the file is located).
3. Copy the file to your SketchUp Plugins folder.
4. From the Ruby console, update `Minitest` to a current version.  Normally, `Gem.install 'minitest'` should install/update it.

That's all.  All it loads is seven lines of code.  Until you use it, it takes almost no resources.

## Features

### General

SUMT.run parameter settings are held.  Hence, once entered, simply entering `SUMT.run` will perform the same test run.

The included tests (in the tests_su folder) are based on the tests included with testup-2.  I changed the code used for observers, and most of the other changes are related to speeding up the tests.  If there's an interest in this, the SketchUp tests should probably be moved to a separate repo. 

I've also included the files `debug.rb`, `editor.rb`, and `p4.rb`, but they are not loaded or used.

I have only tested the code on Windows.

### Output options

1. **Console** - Output is always on to the console, using the minimal MT dot output.
2. **File** - Off by default, directory can be set (default is same location as testup-2).  Report includes
results (time, fails, errors, skips) by class.
3. **UDP** - Off by default.  Output is similar to MT verbose output, as each test method is logged before it starts. The included file `udp_receiver.rb` needs to be run from a stand-alone ruby install (can be run inside Visual Code Editor terminal).  If one is having 'Bug Splat' issues, it will show which test caused the 'Bug Splat'.  Currently, address used is `127.0.0.1:50000`, and is fixed.
4. **ReRun** - Off by default.  A yaml list of run tests is generated, which can be used later to rerun the test in the same order.
5. **Debug** - Off by default.  I included this from testup-2, but haven't set it up.  If someone wants this for debugging, feel free to make suggestions or open a PR.

### Directories / Folders

These can be set for the main test file folder, the logging & rerun folder, and SketchUp temp (`Sketchup.temp_dir`) folder.  At present, running the SU tests leaves quite a few files/folders, so a different folder for temp files may be helpful.  Note that this only works due the fact that SU seems to check the ENV settings when called, rather than only on startup.

### Configuration file

A configuration file (yaml) can be generated that will be reloaded at each first use.  It will include all options entered with the command, along with the `save_opt:true` keyword.  I use it for directories, but it can be used for all options.

### Testing features

1. Since MT cannot run tests parallel in SU (there is only one active_model), there are test class `ste_setup` and `ste_teardown` class methods that can be used.  As the `setup` and `teardown` methods run before and after every test in a class/suite, the new methods run before the first test and after the last.

2. Many people subclass `Minitest::Test` in their test code.  Using `SUMT`, you can either subclass that or subclass {SUMT::TestCase}.  Both should work, although you may find the additional methods in {SUMT::TestCase} helpful with SU testing.  Regardless, if you do subclass, you can name the file `helper.rb` and place it in the root of your test folder, and SUMD will automatically load it.

## Options

All options are keywords, many have two means of calling them, a short name and a long name.

<table class='md'>
<thead>
  <tr><th class='c'>Short</th><th>Long</th><th>Default</th><th>Description</th>
  </tr>
</thead>
<tbody>
<tr><td class='c'>d:</td><td>test_dir:</td><td>'tests_su'</td>
    <td>Test directory</td></tr>
<tr><td class='c'>e:</td><td>exclude:</td><td>nil</td>
    <td>Exclude matching tests, should either be a string or a quoted Regexp.  Same as Minitest `-e` or `--exclude`.</td></tr>
<tr><td class='c'>f:</td><td>file_query:</td><td>nil</td>
    <td>Array used to glob for selected test files.  All entries should either be a file name (ending with '.rb') or a folder.</td></tr>
<tr><td class='c'>gd:</td><td>gen_debug:</td><td>false</td>
    <td>Generate MSFT debugger?  Not working yet.</td></tr>
<tr><td class='c'>gl:</td><td>gen_logs:</td><td>false</td>
    <td>Generate logs files.</td></tr>
<tr><td class='c'>gr:</td><td>gen_rerun:</td><td>false</td>
    <td>Generate rerun file.</td></tr>
<tr><td class='c'>gu:</td><td>gen_udp:</td><td>false</td>
    <td>Generate to udp port.</td></tr>
<tr><td class='c'>ld:</td><td>log_dir:</td><td>nil</td>
    <td>Path to wherever you want log files saved.</td></tr>
<tr><td class='c'>n:</td><td>name:</td><td>nil</td>
    <td>Include matching tests, should either be a string or a quoted Regexp.  Same as Minitest `-n` or `--name`.</td></tr>
<tr><td class='c'>r:</td><td>repeats:</td><td>1</td>
    <td>Repeat test set specified number of times.</td></tr>
<tr><td class='c'>rr:</td><td>rr_file:</td><td>nil</td>
    <td>Use test selection based on rerun file.</td></tr>
<tr><td class='c'>s:</td><td>seed:</td><td>nil</td>
    <td>Random seed for test ordering.  Same as Mintest `-s` or `--seed`.</td></tr>
<tr><td class='c'></td><td>save_opts:</td><td>false</td>
    <td>Saves current options in config file.</td></tr>
<tr><td class='c'>ss:</td><td>show_skip:</td><td>false</td>
    <td>Shows skips in summary section of logs.</td></tr>
<tr><td class='c'>td:</td><td>temp_dir:</td><td>sys temp</td>
    <td>Set the temp dir used by SketchUp for the tests.</td></tr>
<tr><td class='c'>v:</td><td>verbose:</td><td>false</td>
    <td>Same as Mintest --verbose.</td></tr>
</tbody>
</table>

### Run examples

<table class='md'>
<thead>
  <tr><th>Command</th><th>Description</th></tr>
</thead>
<tbody>
<tr><td class='mono'>SUMT.run</td><td>Run default tests (tests_su) in the console</td></tr>
<tr><td class='mono'>SUMT.run r:5</td><td>Run default tests (tests_su) in the console, five repeats</td></tr>
<tr><td class='mono'>SUMT.run f:%w[observers]</td><td>Run tests (tests_su) contained in the `observers` folder</td></tr>
<tr><td class='mono'>SUMT.run f:%w[TC_Entities.rb TC_Entity.rb]</td><td>Run tests (tests_su) contained in the `TC_Entities.rb` & `TC_Entity.rb` files</td></tr>
<tr><td class='mono'>SUMT.run d:'C:\my_tests'</td><td>Run all tests contained in the 'C:\my_tests' folder</td></tr>
<tr><td class='mono'>SUMT.run gl:true, gu:true</td><td>Run all tests and generate both a log file and UDP output</td></tr>
<tr><td class='mono'>SUMT.run ld:'C:/SUMT_logs', td:'C:/SUMT_temp', save_opts:true</td><td>Set log folder to 'C:/SUMT_logs' and SketchUp temp_dir to 'C:/SUMT_temp', save the options to config file</td></tr>
</tbody>
</table>


### ToDo

1. Misc changes to reports.

2. Write more Observer tests.

3. Complete code documentation.

4. Write a test set to check Ruby installation and configuration.

5. Remove SketchUp tests and move to separate repo.

6. If interest, integrate with testup-2 (if possible)...

<style type='text/css'  media='screen'>
  table.md { margin: 0; width: 100%; }
  table.md th, table.md td { border: 0 none #fff; padding: 0.167em 0.5em; text-align: left; }

  table.md thead tr { border-bottom: 1px solid #888; }
  table.md th { vertical-align: bottom; }

  table.md tbody td { vertical-align: top; line-height: 1.30000rem; }
  table.md tr { border-bottom: 1px solid #aaa; }
  table.md tr:nth-child(even) { background: #fff; }
  table.md tr:nth-child(odd)  { background: #fff; }
  table.md th.c, table.md td.c { text-align: center; }
  table.md th.r, table.md td.r { text-align: right; }
  table.md td      a { color: #040; }

  table.md td.prop   { font-family: Montserrat, 'Segoe UI', 'Helvetica Neue', 'Lucida Sans', Verdana, Arial, Helvetica, sans-serif; }

  table.md td.mono   { font-family: 'Roboto Mono', Menlo, 'Lucida Console', 'Courier New', monospace; }
    
  img { margin-top: 0.4em; max-width: 100%; }
</style>
