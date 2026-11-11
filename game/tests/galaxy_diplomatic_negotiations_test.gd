extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 110101
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    if world["ai"].is_empty():
        _fail("No diplomatic rivals")
        return
    var rival := int(world["ai"][0]["id"])
    world["contacts"].append(rival)
    world["relations"][str(rival)] = 70
    world["credits"] = 100
    world["tick"] = 10
    if not GalaxyStrategy.negotiate_treaty(world, rival, "trade"):
        _fail("Eligible trade negotiation rejected")
        return
    if int(world["credits"]) != 85 or world["diplomatic_negotiations"].size() != 1:
        _fail("Negotiation deposit or pending state incorrect")
        return
    if GalaxyStrategy.negotiate_treaty(world, rival, "trade"):
        _fail("Duplicate negotiation accepted")
        return
    GalaxyStrategy.advance_diplomacy(world)
    if world["trade_pacts"].has(rival):
        _fail("Treaty ratified before deadline")
        return
    if not GalaxyModel.save_game(world):
        _fail("Diplomacy save failed")
        return
    var loaded := GalaxyModel.load_game()
    if loaded["diplomatic_negotiations"].size() != 1:
        _fail("Pending negotiation was not persisted")
        return
    world["tick"] = 12
    GalaxyStrategy.advance_diplomacy(world)
    if not world["trade_pacts"].has(rival) or world["diplomatic_treaties"].size() != 1:
        _fail("Successful negotiation did not ratify")
        return
    if GalaxyStrategy.negotiate_treaty(world, rival, "trade"):
        _fail("Already ratified treaty could be negotiated again")
        return
    if not GalaxyStrategy.negotiate_treaty(world, rival, "non_aggression"):
        _fail("Eligible non-aggression negotiation rejected")
        return
    world["relations"][str(rival)] = -100
    world["tick"] = 14
    GalaxyStrategy.advance_diplomacy(world)
    if world.get("non_aggression", []).has(rival):
        _fail("Negotiation ratified despite diplomatic breakdown")
        return
    if not world["diplomatic_negotiations"].is_empty():
        _fail("Failed negotiation not cleared")
        return
    print("GALAXY_DIPLOMATIC_NEGOTIATIONS_PASS: deposit, delay, ratification, failure and persistence")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
