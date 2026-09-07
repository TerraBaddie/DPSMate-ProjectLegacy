-- Global Variables
DPSMate.Modules.ManaGained = {}
DPSMate.Modules.ManaGained.Hist = "ManaGained"

DPSMate.Options.Options[1]["args"]["managained"] = {
	order = 520,
	type = 'toggle',
	name = DPSMate.L["managained"],
	desc = DPSMate.L["show"].." "..DPSMate.L["managained"]..".",
	get = function()
		return DPSMateSettings["windows"][DPSMate.Options.Dewdrop:GetOpenedParent().Key]["options"][1]["managained"]
	end,
	set = function()
		DPSMate.Options:ToggleDrewDrop(1, "managained", DPSMate.Options.Dewdrop:GetOpenedParent())
	end,
}

-- Register the module
DPSMate:Register("managained", DPSMate.Modules.ManaGained, DPSMate.L["managained"])

local tinsert   = table.insert
local strformat = string.format

----------------------------------------------------
-- DATA HELPERS
----------------------------------------------------
-- arr = DPSMate:GetMode(k) = ManaGained table
-- structure: arr[userID][abilityID] = amount OR {amount, ...}
function DPSMate.Modules.ManaGained:GetSortedTable(arr, k)
	local b, a, total = {}, {}, 0

	for cat, val in pairs(arr) do
		local name = DPSMate:GetUserById(cat)
		if DPSMate:ApplyFilter(k, name) then
			local CV = 0
			for ability, amount in pairs(val) do
				if type(amount) == "table" then
					CV = CV + (amount[1] or 0)
				else
					CV = CV + (amount or 0)
				end
			end

			local i = 1
			while true do
				if not b[i] then
					tinsert(b, i, CV)
					tinsert(a, i, name)
					break
				else
					if b[i] < CV then
						tinsert(b, i, CV)
						tinsert(a, i, name)
						break
					end
				end
				i = i + 1
			end
			total = total + CV
		end
	end

	return b, total, a
end

-- Returns: abilityIDs (a), totalMana, per-ability amounts (b)
function DPSMate.Modules.ManaGained:EvalTable(user, k)
	local a, b, temp, total = {}, {}, {}, 0
	local arr = DPSMate:GetMode(k)

	if not user or not user[1] then return a, total, b end
	if not arr[user[1]] then return a, total, b end

	for ability, val in pairs(arr[user[1]]) do
		if ability ~= "i" then
			local CV = (type(val) == "table" and val[1]) or val or 0
			if CV > 0 and DPSMate:GetAbilityById(ability) then
				temp[ability] = (temp[ability] or 0) + CV
			end
		end
	end

	for ability, val in pairs(temp) do
		local i = 1
		while true do
			if not b[i] then
				tinsert(b, i, val)
				tinsert(a, i, ability)
				break
			else
				if b[i] < val then
					tinsert(b, i, val)
					tinsert(a, i, ability)
					break
				end
			end
			i = i + 1
		end
		total = total + val
	end

	return a, total, b
end

----------------------------------------------------
-- WINDOW VALUES (main list)
----------------------------------------------------
function DPSMate.Modules.ManaGained:GetSettingValues(arr, cbt, k)
	local name, value, perc = {}, {}, {}
	local sortedTable, total, a = DPSMate.Modules.ManaGained:GetSortedTable(arr, k)
	local strt = {[1] = "", [2] = ""}

	for cat, val in pairs(sortedTable) do
		local mana, tot, sort = val, total, sortedTable[1]
		if mana == 0 then break end

		local str = {[1] = "", [2] = ""}

		if DPSMateSettings["columnsmana"] and DPSMateSettings["columnsmana"][1] then
			str[1] = " "..DPSMate:Commas(mana, k)
			strt[2] = DPSMate:Commas(tot, k)
		end
		if DPSMateSettings["columnsmana"] and DPSMateSettings["columnsmana"][2] then
			str[2] = " ("..strformat("%.1f", 100*mana/tot).."%)"
		end

		tinsert(name, a[cat])
		tinsert(value, str[1]..str[2])
		tinsert(perc, 100*(mana/sort))
	end

	return name, value, perc, strt
end

----------------------------------------------------
-- TOOLTIP (hover over name in main window)
----------------------------------------------------
function DPSMate.Modules.ManaGained:ShowTooltip(user, k)
	local a, total, amounts = DPSMate.Modules.ManaGained:EvalTable(DPSMateUser[user], k)
	if not a or not total or total == 0 then return end

	if DPSMateSettings["informativetooltips"] then
		for i = 1, DPSMateSettings["subviewrows"] do
			if not a[i] or not amounts[i] then break end
			local abilityName = DPSMate:GetAbilityById(a[i])
			if abilityName then
				GameTooltip:AddDoubleLine(
					i..". "..abilityName,
					amounts[i].." ("..strformat("%.2f", 100*amounts[i]/total).."%)",
					1, 1, 1, 1, 1, 1
				)
			end
		end
	end
end

----------------------------------------------------
-- OPEN DETAILS WINDOWS
----------------------------------------------------
function DPSMate.Modules.ManaGained:OpenDetails(obj, key, bool)
	if bool then
		if DPSMate.Modules.DetailsManaGained and DPSMate.Modules.DetailsManaGained.UpdateCompare then
			DPSMate.Modules.DetailsManaGained:UpdateCompare(obj, key, bool)
		end
	else
		if DPSMate.Modules.DetailsManaGained and DPSMate.Modules.DetailsManaGained.UpdateDetails then
			DPSMate.Modules.DetailsManaGained:UpdateDetails(obj, key)
		end
	end
end

function DPSMate.Modules.ManaGained:OpenTotalDetails(obj, key)
	-- If you ever add a "total mana" breakdown window, hook it here.
	-- For now we keep this empty or you can safely comment out callers.
end
