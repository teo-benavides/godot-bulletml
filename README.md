# BulletML Addon for Godot 3
## Overview
This addon lets you use [BulletML](https://www.asahi-net.or.jp/~cs8k-cyu/bulletml/index_e.html) scripts in your game to spawn bullet patterns, mainly for bullet hell games.  
I highly recommend checking out the example scene found in `addons/bulletml/example.tscn` to see an example of how you can set up things.
## Quick Start
1. Download the addon and enable it from Project -> Project Settings -> Plugins.
2. Create bullet scenes by using `BulletMLBulletInstance` as the root node, or by extending the `BulletMLBulletInstance` script.  
Optional: also create enemy scenes and treat them as bullets.
3. Create a `BulletMLBulletRegistry` resource in your project and add bullets to it.
4. Add a `BulletMLBulletEmitter` node to the scene where you want to spawn bullets in, and set its `script_filename` property to the name of the BulletML file you want it to run. You must not set the whole path, but rather just the filename, as the path containing BulletML scripts will be loaded by `BulletMLScriptRepository` later.  
If making a typical scroller shmup, I recommend the script file to be something that spawns the enemy waves in the stage, so this becomes your main emitter that controls the flow of the stage.
5. In some script's `_ready()`, preferrably the one controlling your game's general flow, do the following actions:
    - Call `BulletMLScriptRepository.load_scripts(path: String)`, passing in the path to the folder containing your BulletML scripts.
    - Set `BulletMLSpawnManager.bullet_registry` to the `BulletMLBulletRegistry` resource you previously created.
    - Set `BulletMLContext.spawn_parent` to a `NodePath` pointing to the node you'd like to spawn bullets under.
    - Start your emitter with `start()`  
    
    Example:  
    ```gdscript
    const SCRIPTS_PATH = "res://addons/bulletml/example/bulletml_scripts/"
    const REGISTRY_PATH = "res://addons/bulletml/example/other/bullet_registry.tres"
    export(NodePath) var emitter_path # Should be the path to a BulletMLBulletEmitter

    func _ready():
        BulletMLScriptRepository.load_scripts(SCRIPTS_PATH)
        BulletMLSpawnManager.bullet_registry = load(REGISTRY_PATH)
        BulletMLContext.spawn_parent = get_path()
        get_node(emitter_path).start()
    ```

## Nodes
This addon adds 2 new nodes you can use.
### ![](addons/bulletml/icons/comet-blue.svg) BulletMLBulletInstance
A bullet which can be spawned by BulletML.  
Extend this in your bullet scenes to allow them to be spawned by the addon.
#### Properties
`initialize_position` (`bool`):  
Initialize position internally.  
Disable if you want to set the position via the editor.  
Defaults to `true`.

`exempt_from_group` (`bool`):  
Exempt from the `bulletml_bullet_instances` group.  
If you free bullets using `call_group()`, this is useful for keeping it alive.  
Defaults to `false`.

`rotates` (`bool`):  
Whether the bullet rotates depending on its direction.  
Defaults to `true`.  
#### Methods  
`start()` -> `void`:  
Used internally.  
Executes any BulletML corresponding to this bullet.

`destroy()` -> `void`:  
Destroy the bullet.  
Emits the signal `destroyed` and runs `queue_free()`.

### ![](addons/bulletml/icons/gun-blue.svg) BulletMLBulletEmitter  
Executes the BulletML script provided in `script_filename`, or a temporary script previously loaded through `BulletMLScriptRepository.load_temp_script(script: String)`.  
Extends `BulletMLBulletInstance`.
#### Properties
`use_temp_script` (`bool`):  
Whether to use the temporary script loaded via BulletMLScriptRepository.load_temp_script().  
Defaults to `false`.

`script_filename` (`String`):  
Filename of the BulletML script to run.  
Note that you don't need to provide the whole path, but just the filename itself, as you have previously loaded the path via `BulletMLScriptRepository.load_scripts(path: String)`.  
#### Methods  
`start()` -> `void`:  
Start execution of the BulletML script indicated by script_filename, or the temp script loaded via `BulletMLScriptRepository.load_temp_script(script: String)` if `use_temp_script` is set to `true`.  

`stop()` -> `void`:  
Stop BulletML script execution.

`resume()` -> `void`:  
Resume BulletML script execution.
## AutoLoads  
### BulletMLContext  
#### Properties  
`player_position` (`Vector2`):  
Update this every `_process()` or `_physics_process()` in your game.  
It's used for bullets which aim at the player.  

`spawn_parent` (`NodePath`):  
Where bullets will be spawned.  
You must set this before starting any `BulletMLBulletEmitter`s.
#### Methods
`time()` -> `float`:  
Can be used from within BulletML scripts to get the current game time.  
Simply use `time()` wherever you need it from within your scripts.  
Useful for some patterns.  
### BulletMLScriptRepository
#### Methods
`load_scripts(path: String)` -> `void`:  
Load BulletML scripts (XML files) from the given path.  
You must call this before starting any `BulletMLBulletEmitter`s.  

`load_temp_script(script: String)` -> `void`:  
Load a temporary script.
You must pass in a full script (not a filename, but the script contents) which can later be run from `BulletMLBulletEmitter`s with `use_temp_script` set to `true`.
### BulletMLSpawnManager
#### Properties
`bullet_registry` (`BulletMLBulletRegistry`):  
Resource holding bullet scenes with their type strings.  
You must set this before starting any `BulletMLBulletEmitter`s.

#### Signals  
`bullet_destroyed(bullet_type: String)`
Emitted when a `BulletMLBulletInstance` is destroyed, before its `queue_free()`.

## Resources
### BulletMLBulletRegistry  
Has an `entries` Dictionary, which should be populated by bullet type strings in the keys, and scenes extending `BulletMLBulletInstance` in the values.  
You must assign a `BulletMLBulletRegistry` resource to `BulletMLSpawnManager.bullet_registry` for bullets to be able to spawn.

## Differences with standard BulletML
- No `<bulletml>` node.
- `NUMBER` values can be any valid GDScript expression, meaning you can use built-in functions like `lerp()`, `rand_range()`, etc.
    - Functions defined in `BulletMLContext` can be used within these expressions.
    - `time()` is one such function.
    - `$rand` and `$rank` cannot be used. `$rand` would be redundant, `$rank` you could implement yourself depending on your game's requirements, for example by using an AutoLoad with a rank property or by modifying `BulletMLContext` and adding a function that returns rank.
- BulletML scripts require an `<action>` with `label="top"`, which is the action that will be run upon executing that script.
- `<bullet>`s can have a `type` attribute, which indicates the bullet type, a string that is used for fetching the bullet scene from the `BulletMLBulletRegistry`
- `<bullet>`s can have a `shooter` attribute, a string that corresponds to a BulletML script filename (just the filename, not the whole path). Upon being spawned, the bullet will execute the script pointed to by `shooter`. Example: `<bullet type="example" shooter="example.xml">`
- `<wait>` and `<term>` use seconds instead of frames.