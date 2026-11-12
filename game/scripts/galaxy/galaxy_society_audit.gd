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
        if opening + produced - consumed - dispatched + int(ledger.get("arrived", 0)) + int(ledger.get("returned", 0)) != ending:
            errors.append("Goods ledger conservation violated")
        if household_goods != ending:
            errors.append("Household goods differ from ledger closing stock")
        var returned := int(ledger.get("returned", 0))
        var arrivals := int(ledger.get("arrived", 0))
        if returned < 0 or arrivals < 0 or int(ledger.get("transit_after", 0)) < 0:
            errors.append("Negative freight settlement flow")
        if int(ledger.get("transit_before", 0)) + dispatched - arrivals - returned != int(ledger.get("transit_after", 0)):
            errors.append("Freight transit conservation violated")
        # Returned cargo is credited to local stock before production.
        if opening + produced - consumed - dispatched + arrivals + returned != ending:
            errors.append("Combined household and freight goods balance violated")
    if not ledger.is_empty() and int(world.get("civilian_taxes", 0)) != taxes:
        errors.append("Civilian tax totals differ from market assessments")
    var budget: Dictionary = world.get("public_budget_ledger", {})
    if not budget.is_empty() and int(budget.get("year", -1)) == int(world.get("tick", 0)):
        var receipts := int(budget.get("tax_receipts", -1))
        var spending := int(budget.get("welfare_spending", -1))
        var opening_credits := int(budget.get("opening", -1))
        var closing_credits := int(budget.get("closing", -1))
        var allocated := 0
        for recipient in budget.get("recipients", []):
            allocated += int(recipient.get("cost", 0))
            if int(recipient.get("cost", 0)) < 0:
                errors.append("Negative public service allocation")
        if mini(receipts, mini(spending, mini(opening_credits, closing_credits))) < 0:
            errors.append("Negative public budget balance")
        if opening_credits + receipts - spending != closing_credits or allocated != spending:
            errors.append("Public budget conservation violated")
        if receipts != taxes:
            errors.append("Public tax transfer differs from civilian assessment")
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
