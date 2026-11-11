extends RefCounted
class_name GalaxyCivilians

# Autonomous civilian demographics and enterprise accounts. This layer never
# orders military fleets or spends state credits. Every population unit is an
# aggregate of households, not a directly controlled player resource.
static func prepare(world: Dictionary) -> void:
    if world.has("civilian_worlds"):
        return
    var settlements: Dictionary = {}
    for star in world["stars"]:
        if int(star["owner"]) != 0:
            continue
        var key := str(star["id"])
        settlements[key] = {"population": 24 if int(star["id"]) == 0 else 6, "capacity": 80 + int(star["resource"]) * 12, "jobs": 20 + int(star["resource"]) * 7, "satisfaction": 65, "private_capital": 45, "goods": 30, "output": 0, "taxes": 0}
    world["civilian_worlds"] = settlements
    world["civilian_trade"] = []
    world["civilian_taxes"] = 0
    world["civilian_migration"] = 0
    world["civilian_approval"] = 65
    world["civilian_petitions"] = []

# Aggregate age cohorts; no individual citizens are simulated.
static func demographic_defaults(population: int) -> Dictionary:
    var count := maxi(1, population)
    var children := count / 5
    var elders := count / 8
    return {"children": children, "working_age": count - children - elders, "elders": elders,
        "births": 0, "deaths": 0, "employed": 0, "unemployed": 0}

static func advance_demographics(market: Dictionary, population_before: int, population_after: int, year: int) -> void:
    var demographic: Dictionary = market.get("demographics", demographic_defaults(population_before))
    var children := maxi(0, int(demographic.get("children", 0)))
    var workers := maxi(0, int(demographic.get("working_age", 0)))
    var elders := maxi(0, int(demographic.get("elders", 0)))
    var delta := population_before - children - workers - elders
    workers = maxi(0, workers + delta)
    var births := 0
    var deaths := 0
    if year > 0 and year % 5 == 0 and children > 0:
        children -= 1
        workers += 1
    if year > 0 and year % 12 == 0 and workers > 1:
        workers -= 1
        elders += 1
    if year > 0 and year % 15 == 0 and elders > 0:
        elders -= 1
        deaths = 1
    var target := maxi(1, population_after)
    var current := children + workers + elders
    if current < target:
        births = target - current
        children += births
    elif current > target:
        var excess := current - target
        var take := mini(excess, workers)
        workers -= take
        excess -= take
        take = mini(excess, children)
        children -= take
        excess -= take
        elders = maxi(0, elders - excess)
    var employed := mini(workers, maxi(0, int(market.get("jobs", 0))))
    market["demographics"] = {"children": children, "working_age": workers, "elders": elders,
        "births": births, "deaths": deaths, "employed": employed, "unemployed": workers - employed}

static func tick(world: Dictionary) -> void:
    prepare(world)
    var settlements: Dictionary = world["civilian_worlds"]
    # A newly acquired system creates its own civilian market; lost systems no
    # longer contribute to domestic taxation or migration.
    for star in world["stars"]:
        var key := str(star["id"])
        if int(star["owner"]) == 0 and not settlements.has(key):
            settlements[key] = {"population": 6, "capacity": 65 + int(star["resource"]) * 12, "jobs": 18 + int(star["resource"]) * 7, "satisfaction": 55, "private_capital": 20, "goods": 15, "output": 0, "taxes": 0}
    var tax_rate: int = [8, 17, 28][clampi(int(world["policies"]["tax"]), 0, 2)]
    var identity: Dictionary = GalaxyIdentity.modifiers(world["empire"])
    var culture_effects: Dictionary = GalaxyIdentity.culture_modifiers(world.get("culture", {}))
    identity["satisfaction"] = int(identity["satisfaction"]) + int(culture_effects["satisfaction"])
    identity["capital"] = int(identity["capital"]) + int(culture_effects["capital"])
    var total_taxes := 0
    var satisfaction_total := 0
    var population_total := 0
    var petitions: Array = []
    var migration := 0
    var trade: Array = []
    var active: Array = []
    for key in settlements.keys():
        var sid := int(key)
        if sid < 0 or sid >= world["stars"].size() or int(world["stars"][sid]["owner"]) != 0:
            continue
        active.append(key)
        var market: Dictionary = settlements[key]
        var population := int(market["population"])
        var old_population := population
        var employment := mini(population, int(market["jobs"]))
        var output := employment * (2 + int(world["stars"][sid]["resource"]) + int(identity["production"])) / 4
        var needs := maxi(1, population / 2 + int(identity["needs"]))
        var stock := int(market["goods"]) + output - needs
        var satisfaction := clampi(int(market["satisfaction"]) + (2 if stock >= needs else -3) - (2 if tax_rate >= 28 else 0) + int(identity["satisfaction"]), 0, 100)
        var earnings := maxi(0, output * (40 + satisfaction) / 100)
        var taxes: int = earnings * tax_rate / 100
        var capital := maxi(0, int(market["private_capital"]) + earnings - taxes - needs + int(identity["capital"]))
        if capital > 80 and int(market["jobs"]) < int(market["capacity"]):
            market["jobs"] = mini(int(market["capacity"]), int(market["jobs"]) + 3)
            capital -= 15
        var growth: int = maxi(0, 1 + int(identity["growth"])) if satisfaction >= 55 and stock >= 0 and population < int(market["capacity"]) else 0
        market["population"] = maxi(1, mini(int(market["capacity"]), population + growth))
        advance_demographics(market, old_population, int(market["population"]), int(world["tick"]))
        market["satisfaction"] = satisfaction
        market["goods"] = maxi(0, stock)
        market["private_capital"] = capital
        market["output"] = output
        market["taxes"] = taxes
        total_taxes += taxes
        satisfaction_total += satisfaction * int(market["population"])
        population_total += int(market["population"])
        if satisfaction < 35:
            petitions.append({"system": sid, "demand": "Versorgung und Steuerentlastung", "urgency": 100 - satisfaction})
    # Civilian freight routes move real goods between surplus and shortage.
    # The state cannot order a shipment: merchants respond to market scarcity.
    for source_key in active:
        var source: Dictionary = settlements[source_key]
        if int(source["goods"]) < 25:
            continue
        var best_key := ""
        var shortage := 0
        for destination_key in active:
            if destination_key == source_key:
                continue
            var destination: Dictionary = settlements[destination_key]
            var demand := maxi(0, int(destination["population"]) / 2 - int(destination["goods"]))
            if demand > shortage:
                shortage = demand
                best_key = str(destination_key)
        if best_key != "":
            var amount := mini(10, mini(shortage, int(source["goods"]) - 15))
            if amount > 0:
                source["goods"] = int(source["goods"]) - amount
                settlements[best_key]["goods"] = int(settlements[best_key]["goods"]) + amount
                trade.append({"from": int(source_key), "to": int(best_key), "goods": amount})
    # Families move for opportunity, independently of the government's wishes.
    if active.size() >= 2:
        var destination_key := ""
        var best_score := -9999
        for key in active:
            var market: Dictionary = settlements[key]
            var score := int(market["satisfaction"]) + int(market["jobs"]) - int(market["population"])
            if int(market["population"]) < int(market["capacity"]) and score > best_score:
                best_score = score
                destination_key = str(key)
        if destination_key != "":
            for key in active:
                if key == destination_key:
                    continue
                var source: Dictionary = settlements[key]
                if int(source["population"]) > 8 and int(source["satisfaction"]) + 12 < int(settlements[destination_key]["satisfaction"]):
                    source["population"] = int(source["population"]) - 1
                    settlements[destination_key]["population"] = int(settlements[destination_key]["population"]) + 1
                    migration += 1
    # Reconcile cohorts after autonomous migration.
    for key in active:
        var market: Dictionary = settlements[key]
        var cohort: Dictionary = market.get("demographics", demographic_defaults(int(market["population"])))
        var sum_cohorts := int(cohort["children"]) + int(cohort["working_age"]) + int(cohort["elders"])
        var difference := int(market["population"]) - sum_cohorts
        cohort["working_age"] = maxi(0, int(cohort["working_age"]) + difference)
        cohort["employed"] = mini(int(cohort["working_age"]), int(market["jobs"]))
        cohort["unemployed"] = int(cohort["working_age"]) - int(cohort["employed"])
        market["demographics"] = cohort
    world["civilian_approval"] = satisfaction_total / maxi(1, population_total)
    world["civilian_petitions"] = petitions
    world["civilian_trade"] = trade
    world["civilian_taxes"] = total_taxes
    world["civilian_migration"] = migration
    if int(world["tick"]) % 8 == 0 and not active.is_empty():
        world["history"].append("Zivile Wirtschaft: %d Steuereinheiten, %d Handelsrouten, %d unabhängige Wanderungen." % [total_taxes, trade.size(), migration])
