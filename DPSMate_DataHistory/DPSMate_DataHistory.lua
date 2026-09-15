-- DPSMate STORAGE_SPLIT3 history bridge.
--
-- STORAGE_SPLIT2 stored every historical category below one DPSMateHistory root,
-- which could still grow to several megabytes. SPLIT3 gives the heavy history
-- groups separate SavedVariables owners while rebuilding the exact same
-- DPSMateHistory runtime shape expected by the original DPSMate modules.
--
-- DPSMateHistory remains declared here temporarily as a LEGACY migration input.
-- Before WoW serializes SavedVariables at logout, the live compatibility wrapper
-- is synchronized back to the split roots and then cleared so it is not written
-- as another giant duplicate copy.

if type(DPSMateHistoryMeta) ~= "table" then DPSMateHistoryMeta = {} end
if type(DPSMateHistoryMeta["names"]) ~= "table" then DPSMateHistoryMeta["names"] = {} end

if type(DPSMateHistoryDamage) ~= "table" then DPSMateHistoryDamage = {} end
if type(DPSMateHistoryTaken) ~= "table" then DPSMateHistoryTaken = {} end
if type(DPSMateHistoryHealing) ~= "table" then DPSMateHistoryHealing = {} end
if type(DPSMateHistoryUtility) ~= "table" then DPSMateHistoryUtility = {} end

local legacy = DPSMateHistory

local function HasEntries(t)
    if type(t) ~= "table" then return false end
    for _ in pairs(t) do return true end
    return false
end

local function EnsureCategory(root, key)
    if type(root[key]) ~= "table" then root[key] = {} end
end

local function MigrateCategory(root, key, legacyKey)
    legacyKey = legacyKey or key
    EnsureCategory(root, key)
    if type(legacy) == "table" and type(legacy[legacyKey]) == "table" and not HasEntries(root[key]) then
        root[key] = legacy[legacyKey]
    end
end

if type(legacy) == "table" and type(legacy["names"]) == "table" and not HasEntries(DPSMateHistoryMeta["names"]) then
    DPSMateHistoryMeta["names"] = legacy["names"]
end

MigrateCategory(DPSMateHistoryDamage, "DMGDone")
MigrateCategory(DPSMateHistoryDamage, "EDDone")
MigrateCategory(DPSMateHistoryTaken, "DMGTaken")
MigrateCategory(DPSMateHistoryTaken, "EDTaken")

MigrateCategory(DPSMateHistoryHealing, "THealing")
MigrateCategory(DPSMateHistoryHealing, "EHealing")
MigrateCategory(DPSMateHistoryHealing, "OHealing")
MigrateCategory(DPSMateHistoryHealing, "EHealingTaken")
MigrateCategory(DPSMateHistoryHealing, "THealingTaken")
MigrateCategory(DPSMateHistoryHealing, "OHealingTaken")
MigrateCategory(DPSMateHistoryHealing, "Absorbs")

MigrateCategory(DPSMateHistoryUtility, "Deaths")
MigrateCategory(DPSMateHistoryUtility, "Interrupts")
MigrateCategory(DPSMateHistoryUtility, "Dispels")
MigrateCategory(DPSMateHistoryUtility, "Auras")
MigrateCategory(DPSMateHistoryUtility, "ManaGained")
MigrateCategory(DPSMateHistoryUtility, "EnergyGained")
MigrateCategory(DPSMateHistoryUtility, "RageGained")
MigrateCategory(DPSMateHistoryUtility, "Threat")
MigrateCategory(DPSMateHistoryUtility, "Fails")
if not HasEntries(DPSMateHistoryUtility["Fails"]) and type(legacy) == "table" and type(legacy["Fail"]) == "table" then
    DPSMateHistoryUtility["Fails"] = legacy["Fail"]
end
MigrateCategory(DPSMateHistoryUtility, "CCBreaker")

local function BuildWrapper()
    DPSMateHistory = {
        names = DPSMateHistoryMeta["names"],
        DMGDone = DPSMateHistoryDamage["DMGDone"],
        EDDone = DPSMateHistoryDamage["EDDone"],
        DMGTaken = DPSMateHistoryTaken["DMGTaken"],
        EDTaken = DPSMateHistoryTaken["EDTaken"],
        THealing = DPSMateHistoryHealing["THealing"],
        EHealing = DPSMateHistoryHealing["EHealing"],
        OHealing = DPSMateHistoryHealing["OHealing"],
        EHealingTaken = DPSMateHistoryHealing["EHealingTaken"],
        THealingTaken = DPSMateHistoryHealing["THealingTaken"],
        OHealingTaken = DPSMateHistoryHealing["OHealingTaken"],
        Absorbs = DPSMateHistoryHealing["Absorbs"],
        Deaths = DPSMateHistoryUtility["Deaths"],
        Interrupts = DPSMateHistoryUtility["Interrupts"],
        Dispels = DPSMateHistoryUtility["Dispels"],
        Auras = DPSMateHistoryUtility["Auras"],
        ManaGained = DPSMateHistoryUtility["ManaGained"],
        EnergyGained = DPSMateHistoryUtility["EnergyGained"],
        RageGained = DPSMateHistoryUtility["RageGained"],
        Threat = DPSMateHistoryUtility["Threat"],
        Fails = DPSMateHistoryUtility["Fails"],
        CCBreaker = DPSMateHistoryUtility["CCBreaker"],
    }
end

local function SyncRootsFromWrapper()
    if type(DPSMateHistory) ~= "table" then return end

    if type(DPSMateHistory["names"]) == "table" then DPSMateHistoryMeta["names"] = DPSMateHistory["names"] end
    if type(DPSMateHistory["DMGDone"]) == "table" then DPSMateHistoryDamage["DMGDone"] = DPSMateHistory["DMGDone"] end
    if type(DPSMateHistory["EDDone"]) == "table" then DPSMateHistoryDamage["EDDone"] = DPSMateHistory["EDDone"] end
    if type(DPSMateHistory["DMGTaken"]) == "table" then DPSMateHistoryTaken["DMGTaken"] = DPSMateHistory["DMGTaken"] end
    if type(DPSMateHistory["EDTaken"]) == "table" then DPSMateHistoryTaken["EDTaken"] = DPSMateHistory["EDTaken"] end

    if type(DPSMateHistory["THealing"]) == "table" then DPSMateHistoryHealing["THealing"] = DPSMateHistory["THealing"] end
    if type(DPSMateHistory["EHealing"]) == "table" then DPSMateHistoryHealing["EHealing"] = DPSMateHistory["EHealing"] end
    if type(DPSMateHistory["OHealing"]) == "table" then DPSMateHistoryHealing["OHealing"] = DPSMateHistory["OHealing"] end
    if type(DPSMateHistory["EHealingTaken"]) == "table" then DPSMateHistoryHealing["EHealingTaken"] = DPSMateHistory["EHealingTaken"] end
    if type(DPSMateHistory["THealingTaken"]) == "table" then DPSMateHistoryHealing["THealingTaken"] = DPSMateHistory["THealingTaken"] end
    if type(DPSMateHistory["OHealingTaken"]) == "table" then DPSMateHistoryHealing["OHealingTaken"] = DPSMateHistory["OHealingTaken"] end
    if type(DPSMateHistory["Absorbs"]) == "table" then DPSMateHistoryHealing["Absorbs"] = DPSMateHistory["Absorbs"] end

    if type(DPSMateHistory["Deaths"]) == "table" then DPSMateHistoryUtility["Deaths"] = DPSMateHistory["Deaths"] end
    if type(DPSMateHistory["Interrupts"]) == "table" then DPSMateHistoryUtility["Interrupts"] = DPSMateHistory["Interrupts"] end
    if type(DPSMateHistory["Dispels"]) == "table" then DPSMateHistoryUtility["Dispels"] = DPSMateHistory["Dispels"] end
    if type(DPSMateHistory["Auras"]) == "table" then DPSMateHistoryUtility["Auras"] = DPSMateHistory["Auras"] end
    if type(DPSMateHistory["ManaGained"]) == "table" then DPSMateHistoryUtility["ManaGained"] = DPSMateHistory["ManaGained"] end
    if type(DPSMateHistory["EnergyGained"]) == "table" then DPSMateHistoryUtility["EnergyGained"] = DPSMateHistory["EnergyGained"] end
    if type(DPSMateHistory["RageGained"]) == "table" then DPSMateHistoryUtility["RageGained"] = DPSMateHistory["RageGained"] end
    if type(DPSMateHistory["Threat"]) == "table" then DPSMateHistoryUtility["Threat"] = DPSMateHistory["Threat"] end
    if type(DPSMateHistory["Fails"]) == "table" then DPSMateHistoryUtility["Fails"] = DPSMateHistory["Fails"] end
    if type(DPSMateHistory["CCBreaker"]) == "table" then DPSMateHistoryUtility["CCBreaker"] = DPSMateHistory["CCBreaker"] end
end

-- Finished historical deaths are useful; unfinished rolling "last 20 hits"
-- scratch buffers are not displayed by DPSMate once a fight is historical.
local function PruneDeathSegment(segment)
    if type(segment) ~= "table" then return end
    for user, deaths in pairs(segment) do
        if type(deaths) == "table" then
            local kept = {}
            for i=1,table.getn(deaths) do
                local death = deaths[i]
                if type(death) == "table" and type(death["i"]) == "table" and death["i"][1] == 1 then
                    table.insert(kept, death)
                end
            end
            if table.getn(kept) > 0 then segment[user] = kept else segment[user] = nil end
        end
    end
end

local function PruneAllHistoricalDeaths()
    if type(DPSMateHistoryUtility["Deaths"]) ~= "table" then return end
    for _, segment in pairs(DPSMateHistoryUtility["Deaths"]) do
        PruneDeathSegment(segment)
    end
end

BuildWrapper()
PruneAllHistoricalDeaths()

local bridge = CreateFrame("Frame")
bridge:RegisterEvent("PLAYER_LOGIN")
bridge:RegisterEvent("PLAYER_LOGOUT")
bridge:SetScript("OnEvent", function()
    if event == "PLAYER_LOGIN" then
        -- Keep the original CreateSegment behavior, then remove only unfinished
        -- death scratch buffers from the newly archived fight.
        if DPSMate and DPSMate.Options and DPSMate.Options.CreateSegment and not DPSMate.Options._StorageSplit3CreateSegment then
            DPSMate.Options._StorageSplit3CreateSegment = DPSMate.Options.CreateSegment
            DPSMate.Options.CreateSegment = function(self, name)
                DPSMate.Options._StorageSplit3CreateSegment(self, name)
                if DPSMateHistory and DPSMateHistory["Deaths"] and DPSMateHistory["Deaths"][1] then
                    PruneDeathSegment(DPSMateHistory["Deaths"][1])
                end
            end
        end
    elseif event == "PLAYER_LOGOUT" then
        -- Also makes DPSMate's existing Reset command safe: if it replaced the
        -- wrapper with fresh empty tables, those become the new split roots.
        SyncRootsFromWrapper()
        DPSMateHistory = nil
    end
end)
