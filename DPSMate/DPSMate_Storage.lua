-- DPSMate STORAGE_SPLIT1
--
-- Storage hardening only.  Runtime table names and shapes stay compatible with
-- normal DPSMate code.  This file repairs old oversized data as it is loaded:
--   1) old Threat graph timestamps are rebucketed to whole seconds;
--   2) segment/name metadata is forced back to the configured segment cap.
--
-- Heavy SavedVariables are owned by companion data addons so WoW writes several
-- smaller per-character files instead of one giant DPSMate.lua failure domain.

DPSMate.Storage = DPSMate.Storage or {}

local Storage = DPSMate.Storage
local floor = math.floor
local tremove = table.remove
local getn = table.getn
local type = type
local pairs = pairs
local tonumber = tonumber

function Storage:RebucketThreatTimeline(t)
    if type(t) ~= "table" then return end

    local rebuilt = {}
    local changed = false
    for k, v in pairs(t) do
        if type(k) == "number" and type(v) == "number" then
            local nk = floor(k)
            rebuilt[nk] = (rebuilt[nk] or 0) + v
            if nk ~= k then changed = true end
        else
            rebuilt[k] = v
        end
    end

    if changed then
        for k in pairs(t) do
            t[k] = nil
        end
        for k, v in pairs(rebuilt) do
            t[k] = v
        end
    end
end

function Storage:NormalizeThreatNode(node)
    if type(node) ~= "table" then return end

    if type(node["i"]) == "table" then
        self:RebucketThreatTimeline(node["i"])
    end

    for k, v in pairs(node) do
        if k ~= "i" and type(v) == "table" then
            self:NormalizeThreatNode(v)
        end
    end
end

function Storage:TrimList(t, limit)
    if type(t) ~= "table" then return end
    while getn(t) > limit do
        tremove(t, getn(t))
    end
end

function Storage:NormalizeLoadedData()
    -- Existing builds stored Threat timeline points at raw fractional combat
    -- timestamps.  Merge those old points into the same one-second buckets used
    -- by Damage/Healing/resource graphs before any module reads the database.
    if type(DPSMateThreat) == "table" then
        self:NormalizeThreatNode(DPSMateThreat)
    end

    -- DPSMate's configured history cap defaults to 8.  Older CreateSegment code
    -- did not trim the names list and could leave combat-time metadata one entry
    -- over the cap.  Only trim data that was already intended to be bounded.
    local limit = 8
    if DPSMateSettings and tonumber(DPSMateSettings["datasegments"]) then
        limit = tonumber(DPSMateSettings["datasegments"])
    end
    if limit < 1 then limit = 1 end

    if type(DPSMateHistory) == "table" then
        for _, v in pairs(DPSMateHistory) do
            if type(v) == "table" then
                self:TrimList(v, limit)
            end
        end
    end

    if type(DPSMateCombatTime) == "table" and type(DPSMateCombatTime["segments"]) == "table" then
        self:TrimList(DPSMateCombatTime["segments"], limit)
    end
end

Storage:NormalizeLoadedData()
