extends SceneTree

func _initialize() -> void:
    var world := GalaxyModel.generate(GalaxyModel.defaults(), GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    var rival := int(world["ai"][0]["id"])
    world["contacts"] = [rival]
    world["tick"] = 4
    if not GalaxyStrategy.send_communication(world, rival, "news"):
        _fail("Contacted rival cannot receive news")
        return
    var due := int(world["communications"][0]["due"])
    GalaxyStrategy.advance_communications(world)
    if not world["communication_history"].is_empty():
        _fail("News arrived before due year")
        return
    world["tick"] = due
    GalaxyStrategy.advance_communications(world)
    if world["communication_history"].size() != 1 or not world["communications"].is_empty():
        _fail("News not delivered once")
        return
    if GalaxyStrategy.set_market_automation(world, true, 101):
        _fail("Invalid reserve accepted")
        return
    if not GalaxyStrategy.set_market_automation(world, false, 40):
        _fail("Manual override rejected")
        return
    if bool(world["market_automation"]["enabled"]):
        _fail("Manual override not stored")
        return
    world["trade_pacts"] = [rival]
    world["buildings"] = {"0": {"lab": 3}}
    world["tick"] = 6
    GalaxyStrategy.settle_international_market(world)
    GalaxyStrategy.advance_technology_diffusion(world)
    if int(world["technology_diffusion"]["insights"]) != 1:
        _fail("No research diffusion")
        return
    print("GALAXY_PACKAGE_E5_PASS: delayed news, manual market controls, diffusion")
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_PACKAGE_E5_FAILURE: " + message)
    quit(1)
