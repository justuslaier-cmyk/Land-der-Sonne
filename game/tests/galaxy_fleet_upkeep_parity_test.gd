extends SceneTree

# Same upkeep and supply scarcity rules for player and rival fleets.
func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 822517
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    GalaxyAI.prepare(world)
    world["credits"] = 0
    var player_fleet: Dictionary = world["fleets"][0]
    player_fleet["location"] = 0
    player_fleet["destination"] = -1
    world["fleet_logistics"]["supply"] = 40
    GalaxyStrategy.advance_fleet_logistics(world)
    if int(world["credits"]) != 0 or int(world["fleet_logistics"]["maintenance_paid"]) != 0:
        _fail("Player received free fleet upkeep")
        return
    if int(world["fleet_logistics"]["supply"]) != 36:
        _fail("Unpaid player fleet replenished at friendly port")
        return
    world["credits"] = 100
    GalaxyStrategy.advance_fleet_logistics(world)
    if int(world["fleet_logistics"]["supply"]) != 44 or int(world["fleet_logistics"]["maintenance_paid"]) < 1:
        _fail("Funded player fleet failed to replenish")
        return
    if world["ai"].is_empty():
        _fail("No rival")
        return
    var rival := int(world["ai"][0]["id"])
    var key := str(rival)
    world["ai_treasury"][key] = 0
    world["ai_fleet_logistics"][key] = {"supply": 40, "maintenance_paid": 0, "attrition": 0}
    var rival_fleet: Dictionary = {}
    for fleet in world["ai_fleets"]:
        if int(fleet["owner"]) == rival:
            rival_fleet = fleet
            break
    if rival_fleet.is_empty():
        _fail("No rival fleet")
        return
    rival_fleet["location"] = int(world["ai"][0]["capital"])
    GalaxyAI.tick(world)
    if int(world["ai_treasury"][key]) != 0 or int(world["ai_fleet_logistics"][key]["supply"]) > 36:
        _fail("Unfunded rival fleet gained free supplies")
        return
    print("GALAXY_FLEET_UPKEEP_PARITY_PASS: both fleets pay upkeep and suffer unpaid supply loss")
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_FLEET_UPKEEP_PARITY_FAILURE: " + message)
    quit(1)
