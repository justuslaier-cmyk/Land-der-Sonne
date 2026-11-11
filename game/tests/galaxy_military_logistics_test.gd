extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 120303
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    world["credits"] = 300
    world["alloys"] = 50
    if int(world["fleet_logistics"]["supply"]) != 100:
        _fail("Fleet supply default incorrect")
        return
    var fleet: Dictionary = world["fleets"][0]
    var original := int(fleet["strength"])
    var upkeep := GalaxyStrategy.fleet_upkeep(world)
    if upkeep < 1:
        _fail("Fleet upkeep must be positive")
        return
    var forecast: Dictionary = GalaxyStrategy.income_forecast(world)
    if not forecast.has("credits"):
        _fail("Fleet upkeep missing from economy forecast")
        return
    world["fleet_logistics"]["supply"] = 20
    var reduced := GalaxyStrategy.fleet_attack_power(world)
    world["fleet_logistics"]["supply"] = 100
    if reduced >= GalaxyStrategy.fleet_attack_power(world):
        _fail("Low supply does not reduce combat effectiveness")
        return
    world["fleet_logistics"]["supply"] = 0
    GalaxyStrategy.advance_fleet_logistics(world)
    if int(fleet["strength"]) != original:
        _fail("Friendly dock should replenish supply without attrition")
        return
    if not GalaxyStrategy.service_fleet(world):
        _fail("Fleet servicing in owned territory rejected")
        return
    if int(world["fleet_logistics"]["supply"]) <= 8:
        _fail("Fleet service did not replenish supply")
        return
    if not GalaxyModel.save_game(world):
        _fail("Fleet logistics save failed")
        return
    var loaded := GalaxyModel.load_game()
    GalaxyStrategy.prepare(loaded)
    if int(loaded["fleet_logistics"]["supply"]) != int(world["fleet_logistics"]["supply"]):
        _fail("Fleet supply not persisted")
        return
    var hostile := -1
    for star in world["stars"]:
        if int(star["owner"]) > 0:
            hostile = int(star["id"])
            break
    if hostile < 0:
        _fail("No rival-owned system")
        return
    var enemy := int(world["stars"][hostile]["owner"])
    if not world["wars"].has(enemy):
        world["wars"].append(enemy)
    fleet["location"] = hostile
    fleet["destination"] = -1
    fleet["strength"] = 40
    world["fleet_logistics"]["supply"] = 100
    var result := GalaxyStrategy.attack(world, hostile)
    if result == "Ungültiges Ziel." or world["battle_reports"].size() != 1:
        _fail("Battle report missing")
        return
    var report: Dictionary = world["battle_reports"][0]
    if int(report["strength_before"]) != 40 or int(report["losses"]) != 40 - int(fleet["strength"]):
        _fail("Battle loss accounting incorrect")
        return
    if int(report["supply_after"]) != 80:
        _fail("Battle supply expenditure missing")
        return
    world["stars"][hostile]["owner"] = enemy
    fleet["location"] = hostile
    fleet["destination"] = -1
    world["fleet_logistics"]["supply"] = 0
    var before := int(fleet["strength"])
    GalaxyStrategy.advance_fleet_logistics(world)
    if int(fleet["strength"]) != maxi(0, before - 1):
        _fail("Unsupplied hostile fleet suffers no attrition")
        return
    print("GALAXY_MILITARY_LOGISTICS_PASS: supply, upkeep, servicing, combat losses and persistence")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
