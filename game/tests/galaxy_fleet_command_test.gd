extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 120202
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    if GalaxyStrategy.assign_admiral(world, "invalid") or GalaxyStrategy.set_fleet_order(world, "invalid"):
        _fail("Invalid admiral or fleet order accepted")
        return
    var initial_attack := GalaxyStrategy.fleet_attack_power(world)
    if not GalaxyStrategy.assign_admiral(world, "tactician"):
        _fail("Tactician appointment rejected")
        return
    if not GalaxyStrategy.set_fleet_order(world, "assault"):
        _fail("Assault order rejected")
        return
    if GalaxyStrategy.fleet_attack_power(world) != initial_attack + 6:
        _fail("Admiral and assault bonuses not applied to combat")
        return
    if GalaxyStrategy.assign_admiral(world, "tactician") or GalaxyStrategy.set_fleet_order(world, "assault"):
        _fail("Duplicate command changes accepted")
        return
    if not GalaxyStrategy.assign_admiral(world, "navigator"):
        _fail("Navigator appointment rejected")
        return
    var target := -1
    for star in world["stars"]:
        var id := int(star["id"])
        if id != int(world["fleets"][0]["location"]):
            target = id
            break
    if target < 0:
        _fail("No second system generated")
        return
    if not world["known"].has(target):
        world["known"].append(target)
    var navigator: Dictionary = GalaxySystems.route_preview(world, target)
    if not GalaxyStrategy.assign_admiral(world, "none"):
        _fail("Admiral removal rejected")
        return
    var baseline: Dictionary = GalaxySystems.route_preview(world, target)
    if absf(float(navigator["range"]) - float(baseline["range"]) - 25.0) > 0.001:
        _fail("Navigator range not reflected in actual route preview")
        return
    if int(navigator["eta"]) > int(baseline["eta"]):
        _fail("Navigator increased travel time")
        return
    if not GalaxyStrategy.assign_admiral(world, "quartermaster"):
        _fail("Quartermaster appointment rejected")
        return
    if int(GalaxyStrategy.ship_blueprint(world)["credits"]) != 25:
        _fail("Quartermaster shipyard discount missing")
        return
    if not GalaxyStrategy.assign_admiral(world, "none"):
        _fail("Quartermaster removal rejected")
        return
    if not GalaxyStrategy.set_fleet_order(world, "patrol"):
        _fail("Patrol order rejected")
        return
    if str(world["fleet_command"]["order"]) != "patrol" or world["fleet_command_history"].size() != 7:
        _fail("Command history or patrol state incorrect")
        return
    if not GalaxyModel.save_game(world):
        _fail("Fleet command save failed")
        return
    var loaded := GalaxyModel.load_game()
    GalaxyStrategy.prepare(loaded)
    if str(loaded["fleet_command"]["order"]) != "patrol" or str(loaded["fleet_command"]["admiral"]) != "none":
        _fail("Fleet orders or admiral not persisted")
        return
    if loaded["fleet_command_history"].size() != 7:
        _fail("Command history not persisted")
        return
    print("GALAXY_FLEET_COMMAND_PASS: validation, attack, range, travel, orders and persistence")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
