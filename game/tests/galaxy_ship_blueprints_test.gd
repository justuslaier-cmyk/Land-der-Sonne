extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 120101
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    world["credits"] = 500
    world["alloys"] = 200
    if GalaxyStrategy.set_ship_role(world, "unknown"):
        _fail("Unknown ship role accepted")
        return
    if not GalaxyStrategy.set_ship_role(world, "artillery"):
        _fail("Artillery role rejected")
        return
    if not GalaxyStrategy.configure_ship(world, 2, 2, 2):
        _fail("Valid ship design rejected")
        return
    var blueprint: Dictionary = GalaxyStrategy.ship_blueprint(world)
    if bool(blueprint["allowed"]) or GalaxyStrategy.build_ships(world):
        _fail("Advanced engine built without research")
        return
    world["research_fields"]["propulsion"] = 2
    blueprint = GalaxyStrategy.ship_blueprint(world)
    if not bool(blueprint["allowed"]) or int(blueprint["alloys"]) != 30 or int(blueprint["credits"]) != 60:
        _fail("Blueprint costs or research unlock incorrect")
        return
    var original_strength := int(world["fleets"][0]["strength"])
    if not GalaxyStrategy.build_ships(world):
        _fail("Researched ship could not be built")
        return
    if int(world["fleets"][0]["strength"]) != original_strength + int(blueprint["strength"]):
        _fail("Built ship did not increase fleet strength")
        return
    if int(world["credits"]) != 440 or int(world["alloys"]) != 170:
        _fail("Ship construction resources incorrect")
        return
    if world["ship_registry"].size() != 1 or str(world["ship_registry"][0]["role"]) != "artillery":
        _fail("Ship registry not updated")
        return
    if not GalaxyModel.save_game(world):
        _fail("Ship registry save failed")
        return
    var loaded := GalaxyModel.load_game()
    GalaxyStrategy.prepare(loaded)
    if loaded["ship_registry"].size() != 1 or str(loaded["ship_role"]) != "artillery":
        _fail("Ship design history not persisted")
        return
    print("GALAXY_SHIP_BLUEPRINTS_PASS: research gate, roles, costs, fleet strength and persistence")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
