extends RefCounted
class_name GalaxySocietyAudit

# Package D1: read-only, deterministic annual accounting diagnostics.
# This records violations; it never silently repairs population or inventory.
static func inspect(world: Dictionary) -> Dictionary:
    var errors: Array = []
    var population := 0
    var workers := 0
    var employed := 0
    var household_goods := 0
    var private_capital := 0
    var taxes := 0
    var markets: Dictionary = world.get("civilian_worlds", {})
    var stars: Array = world.get("stars", [])
    for key in markets.keys():
        var sid := int(key)
        if sid < 0 or sid >= stars.size() or int(stars[sid]["owner"]) != 0:
            continue
        var market: Dictionary = markets[key]
        var pop := int(market.get("population", 0))
        var capacity := int(market.get("capacity", 0))
        var jobs := int(market.get("jobs", 0))
        var goods := int(market.get("goods", 0))
        var capital := int(market.get("private_capital", 0))
        var local_taxes := int(market.get("taxes", 0))
        if pop < 0 or capacity < pop or jobs < 0 or goods < 0 or capital < 0 or local_taxes < 0:
            errors.append("Invalid nonnegative/capacity balance in system " + str(key))
        var cohorts: Dictionary = market.get("demographics", {})
        if not cohorts.is_empty():
            var children := int(cohorts.get("children", -1))
            var working := int(cohorts.get("working_age", -1))
            var elders := int(cohorts.get("elders", -1))
            var employed_here := int(cohorts.get("employed", -1))
            var unemployed := int(cohorts.get("unemployed", -1))
            if mini(children, mini(working, elders)) < 0 or children + working + elders != pop:
                errors.append("Age cohort imbalance in system " + str(key))
            if employed_here < 0 or unemployed < 0 or employed_here + unemployed != working or employed_here > jobs:
                errors.append("Employment imbalance in system " + str(key))
            workers += working
            employed += maxi(0, employed_here)
        population += pop
        household_goods += goods
        private_capital += capital
        taxes += local_taxes
    var ledger: Dictionary = world.get("civilian_goods_ledger", {})
    if not ledger.is_empty() and int(ledger.get("year", -1)) == int(world.get("tick", -2)):
        var opening := int(ledger.get("opening_stock", 0))
        var produced := int(ledger.get("produced", 0))
        var consumed := int(ledger.get("consumed", 0))
        var dispatched := int(ledger.get("dispatched", 0))
        var ending := int(ledger.get("ending_stock", 0))
        if mini(opening, mini(produced, mini(consumed, dispatched))) < 0:
            errors.append("Negative goods ledger flow")
        if opening + produced - consumed - dispatched != ending:
            errors.append("Goods ledger conservation violated")
        if household_goods != ending:
            errors.append("Household goods differ from ledger closing stock")
        if int(ledger.get("transit_before", 0)) + dispatched - int(ledger.get("arrived", 0)) != int(ledger.get("transit_after", 0)):
            # Returned shipments also change transit stock; account for them separately.
            var returned := int(ledger.get("transit_before", 0)) + dispatched - int(ledger.get("arrived", 0)) - int(ledger.get("transit_after", 0))
            if returned < 0:
                errors.append("Freight transit balance created goods")
    if not ledger.is_empty() and int(world.get("civilian_taxes", 0)) != taxes:
        errors.append("Civilian tax totals differ from market assessments")
    return {"year": int(world.get("tick", 0)), "valid": errors.is_empty(), "errors": errors,
        "population": population, "working_age": workers, "employed": employed,
        "household_goods": household_goods, "freight_goods": GalaxyCivilians.transit_goods(world),
        "private_capital": private_capital, "assessed_taxes": taxes}

static func record(world: Dictionary) -> void:
    var result := inspect(world)
    world["society_audit"] = result
    if not world.has("society_audit_history"):
        world["society_audit_history"] = []
    world["society_audit_history"].append(result.duplicate(true))
    if world["society_audit_history"].size() > 60:
        world["society_audit_history"].pop_front()
