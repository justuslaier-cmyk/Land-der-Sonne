extends SceneTree

# Package 2.2: three independent deterministic diplomatic/war outcomes.
func _initialize() -> void:
    for scenario in range(3):
        var settings := GalaxyModel.defaults()
        settings["seed"] = 731900 + scenario
        var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
        GalaxyStrategy.prepare(world)
        if world["ai"].is_empty():
            _fail("Missing rival in scenario %d" % scenario)
            return
        var rival := int(world["ai"][0]["id"])
        if not world["contacts"].has(rival):
            world["contacts"].append(rival)
        world["relations"][str(rival)] = 90
        world["credits"] = 200
        world["tick"] = 20
        if scenario == 0:
            if not GalaxyStrategy.negotiate_treaty(world, rival, "trade") or int(world["credits"]) != 185:
                _fail("Trade negotiation did not charge real deposit")
                return
            world["tick"] = 22
            GalaxyStrategy.advance_diplomacy(world)
            if not world["trade_pacts"].has(rival) or world["diplomatic_treaties"].is_empty():
                _fail("Trade treaty not ratified")
                return
        elif scenario == 1:
            if not GalaxyStrategy.negotiate_treaty(world, rival, "alliance") or int(world["credits"]) != 160:
                _fail("Alliance negotiation did not charge deposit")
                return
            world["relations"][str(rival)] = -90
            world["tick"] = 22
            GalaxyStrategy.advance_diplomacy(world)
            if world["alliances"].has(rival) or not world["diplomatic_negotiations"].is_empty():
                _fail("Diplomatic breakdown did not cancel alliance")
                return
        else:
            if not GalaxyStrategy.declare_war(world, rival):
                _fail("War declaration rejected")
                return
            world["credits"] = 69
            if GalaxyStrategy.offer_peace(world, rival):
                _fail("Unfunded peace accepted")
                return
            world["credits"] = 70
            if not GalaxyStrategy.offer_peace(world, rival) or int(world["credits"]) != 0:
                _fail("Peace settlement did not debit treasury")
                return
            if GalaxyStrategy.declare_war(world, rival):
                _fail("Immediate re-declaration bypassed truce")
                return
            world["tick"] = 25
            if not GalaxyStrategy.declare_war(world, rival):
                _fail("Expired truce still blocks war")
                return
        if not GalaxyModel.save_game(world, 2 + scenario):
            _fail("Scenario save failed")
            return
        var restored := GalaxyModel.load_game(2 + scenario)
        if JSON.stringify(restored["wars"]) != JSON.stringify(world["wars"]) or JSON.stringify(restored["diplomatic_treaties"]) != JSON.stringify(world["diplomatic_treaties"]):
            _fail("Scenario diplomacy state lost on load")
            return
    print("GALAXY_CONFLICT_NEGOTIATION_MATRIX_PASS: trade ratification, failed alliance, funded peace and truce")
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_CONFLICT_NEGOTIATION_MATRIX_FAILURE: " + message)
    quit(1)
