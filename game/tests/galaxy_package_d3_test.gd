extends SceneTree

func _initialize() -> void:
    for seed_value in [11027, 812741, 99001]:
        var settings := GalaxyModel.defaults()
        settings["seed"] = seed_value
        settings["events"] = 0
        var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
        GalaxyStrategy.prepare(world)
        GalaxyStrategy.set_welfare(world, 2)
        var replay := world.duplicate(true)
        if not GalaxyModel.save_game(world, 4):
            _fail("Initial-save failed")
            return
        var initial_loaded := GalaxyModel.load_game(4)
        if initial_loaded.is_empty() or int(initial_loaded["policies"].get("welfare", -1)) != 2:
            _fail("Initial-save lost welfare policy")
            return
        for year in range(125):
            world["tick"] = year
            replay["tick"] = year
            GalaxyStrategy.tick(world)
            GalaxyStrategy.tick(replay)
            if not bool(world["society_audit"]["valid"]):
                _fail("Seed %d year %d: %s" % [seed_value, year, str(world["society_audit"]["errors"])])
                return
            if JSON.stringify(world["society_audit"]) != JSON.stringify(replay["society_audit"]):
                _fail("Audit replay diverged")
                return
            if int(world["credits"]) != int(replay["credits"]):
                _fail("Treasury replay diverged")
                return
            if world["society_audit_history"].size() > 60:
                _fail("Audit history retention exceeded")
                return
            if str(world.get("pending_event", "")) != "":
                GalaxySystems.resolve_event(world, 0)
                GalaxySystems.resolve_event(replay, 0)
        if world["society_audit_history"].size() != 60:
            _fail("Audit history did not reach bounded retention")
            return
        var broken := world.duplicate(true)
        broken["public_budget_ledger"]["closing"] = int(broken["public_budget_ledger"]["closing"]) + 1
        if GalaxySocietyAudit.inspect(broken)["valid"]:
            _fail("Forged public budget accepted")
            return
        broken = world.duplicate(true)
        broken["civilian_goods_ledger"]["transit_after"] = int(broken["civilian_goods_ledger"]["transit_after"]) + 1
        if GalaxySocietyAudit.inspect(broken)["valid"]:
            _fail("Forged freight ledger accepted")
            return

    print("GALAXY_PACKAGE_D3_PASS: 375 simulation years, replay, fiscal/freight corruption and initial save")
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_PACKAGE_D3_FAILURE: " + message)
    quit(1)
