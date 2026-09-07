-- DPSMate Project Legacy - Bulwark of Faith ManaGained bridge
--
-- Project Legacy restores Bulwark of Faith mana server-side without emitting
-- the normal Vanilla combat-log energize line that DPSMate parses. This file
-- reconstructs ONLY that missing player mana gain from three client-visible
-- facts:
--   1) the player actually blocked an incoming attack,
--   2) Bulwark of Faith is talented, and
--   3) UNIT_MANA confirms that mana really increased immediately after it.
--
-- Important safety behavior:
--   * Normal Spirit regeneration is never recorded as Bulwark.
--   * A Spirit tick coalesced with Bulwark is safe: only the known Bulwark
--     amount is credited.
--   * Mana-cap clipping is respected.
--   * If Project Legacy later starts sending a real "gain Mana from Bulwark"
--     combat-log line, this fallback suppresses itself to prevent double data.
--   * No new SavedVariables are used.

if not DPSMate then return end

DPSMate.ProjectLegacyBulwark = DPSMate.ProjectLegacyBulwark or {}
local PL = DPSMate.ProjectLegacyBulwark

PL.blockWindow = 0.350
PL.settleDelay = 0.750
PL.explicitWindow = 0.900
PL.debug = false
PL.rank = 0
PL.maxRank = 0
PL.talentName = "Bulwark of Faith"
PL.lastMana = nil
PL.lastExplicitBulwarkTime = nil
PL.pending = {}
PL.sessionMana = 0
PL.sessionProcs = 0
PL.lastDecision = "none"

-- Classic/MaNGOS Paladin player_classlevelstats.basemana for levels 1-60.
-- Level 12 = 219, which exactly matches the Project Legacy observation:
-- floor(219 * 3 / 100) = 6 mana at Bulwark rank 3.
PL.paladinBaseMana = {
    [1]=60, [2]=78, [3]=98, [4]=104, [5]=111, [6]=134,
    [7]=143, [8]=153, [9]=179, [10]=192, [11]=205, [12]=219,
    [13]=249, [14]=265, [15]=282, [16]=315, [17]=334, [18]=354,
    [19]=390, [20]=412, [21]=435, [22]=459, [23]=499, [24]=525,
    [25]=552, [26]=579, [27]=621, [28]=648, [29]=675, [30]=702,
    [31]=729, [32]=756, [33]=798, [34]=825, [35]=852, [36]=879,
    [37]=906, [38]=933, [39]=960, [40]=987, [41]=1014, [42]=1041,
    [43]=1068, [44]=1110, [45]=1137, [46]=1164, [47]=1176, [48]=1203,
    [49]=1230, [50]=1257, [51]=1284, [52]=1311, [53]=1338, [54]=1365,
    [55]=1392, [56]=1419, [57]=1446, [58]=1458, [59]=1485, [60]=1512
}

local function Now()
    if GetTime then return GetTime() end
    return 0
end

local function Chat(msg)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[DPSMate Bulwark]|r " .. msg)
    end
end

function PL:Debug(msg)
    if self.debug then Chat(msg) end
end

function PL:IsPlayerPaladin()
    local className, classToken = UnitClass("player")
    if classToken == "PALADIN" then return true end
    if className and string.lower(className) == "paladin" then return true end
    return false
end

function PL:RefreshTalent()
    self.rank = 0
    self.maxRank = 0

    if not self:IsPlayerPaladin() then return end
    if not GetNumTalentTabs or not GetNumTalents or not GetTalentInfo then return end

    local tabs = GetNumTalentTabs() or 0
    local tab
    for tab = 1, tabs do
        local count = GetNumTalents(tab) or 0
        local i
        for i = 1, count do
            local name, texture, tier, column, rank, maxRank = GetTalentInfo(tab, i)
            if name then
                local lower = string.lower(name)
                if lower == "bulwark of faith" or string.find(lower, "bulwark of faith") then
                    self.talentName = name
                    self.rank = tonumber(rank) or 0
                    self.maxRank = tonumber(maxRank) or 0
                    self:Debug("talent " .. name .. " rank=" .. self.rank .. "/" .. self.maxRank)
                    return
                end
            end
        end
    end
end

function PL:GetExpectedGain()
    if not self.rank or self.rank <= 0 then return 0, nil end

    local level = UnitLevel("player") or 0
    local baseMana = self.paladinBaseMana[level]
    if not baseMana then return 0, nil end

    -- Project Legacy's observed behavior is integer truncation.
    local amount = math.floor((baseMana * self.rank) / 100)
    if amount < 0 then amount = 0 end
    return amount, baseMana
end

function PL:IsBlockMessage(msg)
    if not msg then return false end
    local lower = string.lower(msg)
    if string.find(lower, "block") then return true end
    return false
end

function PL:MarkExplicitBulwark(msg)
    if not msg then return end
    local lower = string.lower(msg)
    if not string.find(lower, "bulwark of faith") then return end
    if not string.find(lower, "mana") then return end
    if not string.find(lower, "gain") then return end

    local now = Now()
    self.lastExplicitBulwarkTime = now

    local i
    for i = 1, table.getn(self.pending) do
        local p = self.pending[i]
        if p and now - p.lastBlockTime >= 0 and now - p.lastBlockTime <= self.explicitWindow then
            p.explicitBulwark = true
        end
    end

    self:Debug("real Bulwark mana combat-log line detected; fallback suppressed")
end

function PL:NewCluster(now, mana, maxMana, expected, baseMana)
    local p = {
        firstBlockTime = now,
        lastBlockTime = now,
        settleAt = now + self.settleDelay,
        blockCount = 1,
        manaAtStart = mana,
        maxManaAtStart = maxMana,
        gain = 0,
        sawPositiveMana = false,
        hitCap = false,
        expected = expected,
        baseMana = baseMana,
        explicitBulwark = false
    }

    if self.lastExplicitBulwarkTime then
        local dt = now - self.lastExplicitBulwarkTime
        if dt >= 0 and dt <= self.explicitWindow then
            p.explicitBulwark = true
        end
    end

    table.insert(self.pending, p)
    return p
end

function PL:OnBlock(msg, sourceEvent)
    if not self:IsBlockMessage(msg) then return end
    if not self:IsPlayerPaladin() then return end

    if not self.rank or self.rank <= 0 then
        self:RefreshTalent()
    end
    if not self.rank or self.rank <= 0 then return end

    local expected, baseMana = self:GetExpectedGain()
    if not expected or expected <= 0 then return end

    local now = Now()
    local mana = UnitMana("player") or 0
    local maxMana = UnitManaMax("player") or 0

    local p = nil
    local count = table.getn(self.pending)
    if count > 0 then
        local latest = self.pending[count]
        if latest and now - latest.lastBlockTime >= 0 and now - latest.lastBlockTime <= self.blockWindow then
            p = latest
        end
    end

    if p then
        p.blockCount = p.blockCount + 1
        p.lastBlockTime = now
        p.settleAt = now + self.settleDelay
        -- Talent/level changes should not happen mid-cluster, but preserve the
        -- newest expected value if the client somehow reports one.
        p.expected = expected
        p.baseMana = baseMana
    else
        p = self:NewCluster(now, mana, maxMana, expected, baseMana)
    end

    self:Debug("BLOCK x" .. p.blockCount .. " mana=" .. mana .. "/" .. maxMana
        .. " expected=" .. expected .. " | " .. (sourceEvent or "?") .. " | " .. msg)
end

function PL:FindManaCluster(now)
    -- Associate the UNIT_MANA increase with the newest block cluster whose
    -- most recent block is still inside the measured Project Legacy window.
    local i
    for i = table.getn(self.pending), 1, -1 do
        local p = self.pending[i]
        if p then
            local dt = now - p.lastBlockTime
            if dt >= 0 and dt <= self.blockWindow then
                return p
            end
        end
    end
    return nil
end

function PL:OnMana(unit)
    if unit ~= "player" then return end

    local current = UnitMana("player") or 0
    local maxMana = UnitManaMax("player") or 0

    if self.lastMana == nil then
        self.lastMana = current
        return
    end

    local old = self.lastMana
    local delta = current - old
    self.lastMana = current

    if delta <= 0 then return end

    local now = Now()
    local p = self:FindManaCluster(now)
    if not p then return end

    p.gain = p.gain + delta
    p.sawPositiveMana = true
    if current >= maxMana then p.hitCap = true end

    self:Debug("UNIT_MANA +" .. delta .. " assigned to BLOCK cluster; accumulated +"
        .. p.gain .. " expectedTotal=" .. (p.expected * p.blockCount)
        .. (p.hitCap and " CAP" or ""))
end

function PL:RecordCluster(p)
    if not p then return end
    if p.explicitBulwark then
        self.lastDecision = "skipped: real combat-log Bulwark event"
        self:Debug(self.lastDecision)
        return
    end

    if not p.expected or p.expected <= 0 or p.blockCount <= 0 then return end
    if not p.sawPositiveMana or p.gain <= 0 then
        self.lastDecision = "skipped: no actual mana increase (full mana or no restore)"
        self:Debug(self.lastDecision)
        return
    end

    local expectedTotal = p.expected * p.blockCount
    local creditTotal = 0

    if p.gain >= expectedTotal then
        -- Clean Bulwark (+expected), or Bulwark coalesced with Spirit/another
        -- mana source (+larger). Only credit the exact Bulwark portion.
        creditTotal = expectedTotal
    elseif p.hitCap then
        -- The client actually gained less than the theoretical restore because
        -- the mana pool filled. Never claim more Bulwark mana than was observed.
        creditTotal = p.gain
        if creditTotal > expectedTotal then creditTotal = expectedTotal end
    else
        -- A non-cap positive delta smaller than the known Bulwark total cannot
        -- safely be called Bulwark. Drop it rather than polluting ManaGained.
        self.lastDecision = "skipped: observed +" .. p.gain .. " < expected +" .. expectedTotal .. " away from cap"
        self:Debug(self.lastDecision)
        return
    end

    if creditTotal <= 0 then return end

    local player = UnitName("player")
    if not player or not DPSMate.DB or not DPSMate.DB.ManaGained then return end

    local remaining = creditTotal
    local i
    local recordedProcs = 0
    for i = 1, p.blockCount do
        if remaining <= 0 then break end
        local amount = p.expected
        if amount > remaining then amount = remaining end
        if amount > 0 then
            DPSMate.DB:ManaGained(player, amount, self.talentName or "Bulwark of Faith")
            remaining = remaining - amount
            recordedProcs = recordedProcs + 1
            self.sessionMana = self.sessionMana + amount
            self.sessionProcs = self.sessionProcs + 1
        end
    end

    self.lastDecision = "recorded +" .. creditTotal .. " Bulwark mana across " .. recordedProcs .. " block proc(s)"
    self:Debug(self.lastDecision .. "; observed cluster gain=+" .. p.gain)
end

function PL:OnUpdate()
    if table.getn(self.pending) == 0 then return end

    local now = Now()
    local i = 1
    while i <= table.getn(self.pending) do
        local p = self.pending[i]
        if p and now >= p.settleAt then
            self:RecordCluster(p)
            table.remove(self.pending, i)
        else
            i = i + 1
        end
    end
end

function PL:ResetRuntime(resetSession)
    self.pending = {}
    self.lastMana = UnitMana("player") or 0
    self.lastExplicitBulwarkTime = nil
    self.lastDecision = "none"
    if resetSession then
        self.sessionMana = 0
        self.sessionProcs = 0
    end
end

function PL:Status()
    self:RefreshTalent()
    local expected, baseMana = self:GetExpectedGain()
    local level = UnitLevel("player") or 0
    Chat("status: rank=" .. (self.rank or 0) .. "/" .. (self.maxRank or 0)
        .. " level=" .. level
        .. " baseMana=" .. tostring(baseMana)
        .. " expectedPerBlock=" .. tostring(expected)
        .. " session=" .. self.sessionMana .. " mana / " .. self.sessionProcs .. " proc(s)")
    Chat("last: " .. tostring(self.lastDecision) .. " | debug=" .. (self.debug and "ON" or "OFF"))
end

local frame = CreateFrame("Frame", "DPSMate_ProjectLegacyBulwarkFrame", UIParent)
PL.frame = frame

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterEvent("CHARACTER_POINTS_CHANGED")
frame:RegisterEvent("UNIT_MANA")
frame:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS")
frame:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES")
frame:RegisterEvent("CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS")
frame:RegisterEvent("CHAT_MSG_COMBAT_HOSTILEPLAYER_MISSES")
frame:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE")
frame:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE")
frame:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF")
frame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")

frame:SetScript("OnEvent", function()
    local e = event

    if e == "PLAYER_ENTERING_WORLD" then
        PL:ResetRuntime(true)
        PL:RefreshTalent()
        return
    end

    if e == "PLAYER_LEVEL_UP" or e == "CHARACTER_POINTS_CHANGED" then
        PL:ResetRuntime(false)
        PL:RefreshTalent()
        return
    end

    if e == "UNIT_MANA" then
        PL:OnMana(arg1)
        return
    end

    if e == "CHAT_MSG_SPELL_SELF_BUFF" or e == "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS" then
        PL:MarkExplicitBulwark(arg1)
        return
    end

    if e == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS"
    or e == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES"
    or e == "CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS"
    or e == "CHAT_MSG_COMBAT_HOSTILEPLAYER_MISSES"
    or e == "CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE"
    or e == "CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE" then
        PL:OnBlock(arg1, e)
        return
    end
end)

frame:SetScript("OnUpdate", function()
    PL:OnUpdate()
end)

SLASH_DPSMATE_PROJECTLEGACY_BULWARK1 = "/dmbulwark"
SlashCmdList["DPSMATE_PROJECTLEGACY_BULWARK"] = function(msg)
    local text = string.lower(msg or "")
    if text == "debug on" or text == "debug 1" then
        PL.debug = true
        Chat("debug ON")
    elseif text == "debug off" or text == "debug 0" then
        PL.debug = false
        Chat("debug OFF")
    elseif text == "reset" then
        PL:ResetRuntime(true)
        PL:RefreshTalent()
        Chat("runtime/session counters reset")
    else
        PL:Status()
        Chat("commands: /dmbulwark | /dmbulwark debug on | debug off | reset")
    end
end
