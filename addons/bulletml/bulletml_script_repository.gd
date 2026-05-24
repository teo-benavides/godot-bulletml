extends Node

var _parsed_scripts : Dictionary = {}
var _temp_script: BulletMLParsedScript

func load_scripts(path: String):
    if not path.ends_with("/") and not path.ends_with("\\"):
        path = path + "/"
    var dir := Directory.new()
    dir.open(path)
    dir.list_dir_begin(true)

    var file = dir.get_next()
    while not file.empty():
        _set_bulletml_parsed_script(file, BulletMLScriptLoader.parse_script(path + file))
        file = dir.get_next()

    dir.list_dir_end()

func load_temp_script(script: String):
    _temp_script = BulletMLScriptLoader.parse_temp_script(script.to_utf8())

func _get_bulletml_parsed_script(script_name : String) -> BulletMLParsedScript:
    var script = _parsed_scripts.get(script_name)
    return script

func _get_bulletml_temp_parsed_script() -> BulletMLParsedScript:
    return _temp_script
  
func _set_bulletml_parsed_script(script_name : String, parsed_script : BulletMLParsedScript):
    _parsed_scripts[script_name] = parsed_script
