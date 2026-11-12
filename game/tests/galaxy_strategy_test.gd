extends SceneTree

func _initialize() -> void:
    var cfg := GalaxyModel.defaults()
    cfg["size"] = 100
    cfg["ai_count"] = 5
    var w := GalaxyModel.generate(cfg, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(w)
    if not w.has("civilian_worlds") or not w["civilian_worlds"].has("0"):
        _fail("Independent civilian homeworld missing")
        return
    var civilian_population := int(w["civilian_worlds"]["0"]["population"])
    for year in range(5):
        GalaxyStrategy.tick(w)
    if int(w["civilian_worlds"]["0"]["population"]) <= civilian_population:
        _fail("Civilian population does not grow autonomously")
        return
    if int(w["civilian_taxes"]) < 0 or int(w["civilian_worlds"]["0"]["private_capital"]) < 0:
        _fail("Civilian economic accounting invalid")
        return
    if not GalaxyStrategy.construct(w, 0, "mine"):
        _fail("Mine construction failed")
        return
    if int(w["buildings"]["0"]["mine"]) != 1:
        _fail("Building state missing")
        return
    var counterfactual: Dictionary = w.duplicate(true)
    if not GalaxyStrategy.set_policy(w, 1, 0):
        _fail("Policy setting failed")
        return
    GalaxyStrategy.tick(counterfactual)
    GalaxyStrategy.tick(w)
    if int(w["science"]) < int(counterfactual["science"]) + 4 or int(w["stability"]) < int(counterfactual["stability"]):
        _fail("Policy science bonus or relative stability effect failed")
        return
    if not GalaxyStrategy.configure_ship(w, 2, 2, 1):
        _fail("Ship design failed")
        return
    if GalaxyStrategy.ship_strength(w) < 10:
        _fail("Ship design strength missing")
        return
    # Engine tier 1 requires propulsion research tier 1; this test checks
    # construction after unlocking the prerequisite (gating is tested separately).
    w["research_fields"]["propulsion"] = maxi(1, int(w["research_fields"].get("propulsion", 0)))
    var blueprint: Dictionary = GalaxyStrategy.ship_blueprint(w)
    if not bool(blueprint["allowed"]):
        _fail("Ship blueprint still locked after propulsion prerequisite")
        return
    w["credits"] = maxi(int(w["credits"]), int(blueprint["credits"]))
    w["alloys"] = maxi(int(w["alloys"]), int(blueprint["alloys"]))
    if not GalaxyStrategy.build_ships(w):
        _fail("Ship construction failed despite unlocked blueprint and sufficient resources")
        return
    if GalaxyStrategy.declare_war(w, 1):
        _fail("War without first contact permitted")
        return
    w["contacts"].append(1)
    if not GalaxyStrategy.declare_war(w, 1):
        _fail("War declaration failed")
        return
    if not w["wars"].has(1):
        _fail("War state missing")
        return
    var snapshot := JSON.stringify(w)
    if not GalaxyModel.save_game(w):
        _fail("Strategic save failed")
        return
    var loaded := GalaxyModel.load_game()
    if JSON.stringify(loaded) != snapshot:
        _fail("Strategic save roundtrip failed")
        return
    print("GALAXY_STRATEGY_PASS: buildings, policies, ships, diplomacy, war and persistence")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
