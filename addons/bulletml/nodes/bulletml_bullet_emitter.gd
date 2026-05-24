extends BulletMLBulletInstance
class_name BulletMLBulletEmitter

export(bool) var use_temp_script = false
export(String) var script_filename
var top : String
var running = false

func start():
    var script = BulletMLScriptRepository._get_bulletml_temp_parsed_script() if use_temp_script else BulletMLScriptRepository._get_bulletml_parsed_script(script_filename)
    if not script_filename.empty() and not script and not use_temp_script:
        printerr("BulletML script " + script_filename + " not found! Did you load scripts with BulletMLScriptRepository.load_scripts()?")
    if script:
        _runner.actions = script.actions
        _runner.fires = script.fires
        _runner.bullets = script.bullets
        _runner.tops = script.tops

        for top in _runner.tops.slice(1, len(_runner.tops)):
            BulletMLSpawnManager._spawn_emitter(_runner.actions, _runner.fires, _runner.bullets, global_position, top)

        top = _runner.tops[0]
        running = true
        _runner.run_specific(top)
    elif not _runner.actions.empty():
        _runner.run_actions(_actions_local)

func stop():
    if running:
        _runner.stop()
        running = false

func resume():
    if not running:
        running = true
        _runner.run_specific(top)
