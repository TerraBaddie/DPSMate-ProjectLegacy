-- Global Variables
DPSMate.Modules.DetailsRageGained = {}

-- Local variables
local DetailsArr, DetailsTotal, RageArr, DetailsUser, DetailsSelected = {}, 0, {}, "", 1
local DetailsArrComp, DetailsTotalComp, RageArrComp, DetailsUserComp, DetailsSelectedComp = {}, 0, {}, "", 1
local g, g2, g3, gComp, gCompLine
local curKey = 1
local db, cbt, ecbt = {}, 0, {}
local toggleGraph, toggleIndividual, toggleMode = false, false, false

local _G = getglobal
local tinsert = table.insert
local tgetn = table.getn
local strformat = string.format
local floor = math.floor
local ceil = math.ceil
local max = math.max

----------------------------------------------------
-- MAIN DETAILS
----------------------------------------------------
function DPSMate.Modules.DetailsRageGained:UpdateDetails(obj, key)
	curKey = key
	db, cbt, ecbt = DPSMate:GetMode(key)
	DetailsUser = obj.user
	DetailsUserComp = nil
	DPSMate_Details_RageGained.proc = "None"
	UIDropDownMenu_SetSelectedValue(DPSMate_Details_RageGained_DiagramLegend_Procs, "None")
	UIDropDownMenu_Initialize(DPSMate_Details_RageGained_DiagramLegend_Procs, DPSMate.Modules.DetailsRageGained.ProcsDropDown)

	DPSMate_Details_RageGained_Title:SetText("Rage gained by "..obj.user)
	local activity = (ecbt and ecbt[obj.user]) or 0
	local combatTime = cbt or 0
	local activityPercent = 0
	if combatTime > 0 then
		activityPercent = 100*((activity+1)/combatTime)
	end
	DPSMate_Details_RageGained_SubTitle:SetText(DPSMate.L["activity"]..strformat("%.2f", activity+1).."s "..DPSMate.L["of"].." "..strformat("%.2f", combatTime).."s ("..strformat("%.2f", activityPercent).."%)")
	DPSMate_Details_RageGained:Show()

	DetailsArr, DetailsTotal, RageArr = DPSMate.Modules.RageGained:EvalTable(DPSMateUser[DetailsUser], curKey)

	if not g then
		g = DPSMate.Options.graph:CreateGraphPieChart("RageGainedPieChart", DPSMate_Details_RageGained_Diagram, "CENTER", "CENTER", 0, 0, 200, 200)
		g2 = DPSMate.Options.graph:CreateGraphLine("RageGainedLineGraph", DPSMate_Details_RageGained_DiagramLine, "CENTER", "CENTER", 0, 0, 850, 230)
		g3 = DPSMate.Options.graph:CreateStackedGraph("RageGainedStackedGraph", DPSMate_Details_RageGained_DiagramLine, "CENTER", "CENTER", 0, 0, 850, 230)
		g3:SetGridColor({0.5,0.5,0.5,0.5})
		g3:SetAxisDrawing(true,true)
		g3:SetAxisColor({1.0,1.0,1.0,1.0})
		g3:SetAutoScale(true)
		g3:SetYLabels(true, false)
		g3:SetXLabels(true)
	end

	self:ScrollFrame_Update()
	self:SelectDetailsButton(1)
	self:UpdatePieGraph(g)
	if toggleGraph then
		if g2 then g2:Hide() end
		self:UpdateStackedGraph(g3)
	else
		if g3 then g3:Hide() end
		self:UpdateLineGraph(g2)
	end

	DPSMate_Details_CompareRageGained:Hide()
	DPSMate_Details_CompareRageGained_Graph:Hide()
	DPSMate_Details_RageGained:SetScale((DPSMateSettings["targetscale"] or 0.58)/UIParent:GetScale())
end

----------------------------------------------------
-- COMPARE WINDOW
----------------------------------------------------
function DPSMate.Modules.DetailsRageGained:UpdateCompare(obj, key, comp)
	self:UpdateDetails(obj, key)

	DetailsUserComp = comp
	DPSMate_Details_CompareRageGained_Title:SetText("Rage gained by "..comp)
	DetailsArrComp, DetailsTotalComp, RageArrComp = DPSMate.Modules.RageGained:EvalTable(DPSMateUser[DetailsUserComp], curKey)

	if not gComp then
		gComp = DPSMate.Options.graph:CreateGraphPieChart("RageGainedPieChartComp", DPSMate_Details_CompareRageGained_Diagram, "CENTER", "CENTER", 0, 0, 200, 200)
		gCompLine = DPSMate.Options.graph:CreateGraphLine("RageGainedLineGraphComp", DPSMate_Details_CompareRageGained_Graph, "CENTER", "CENTER", 0, 0, 850, 230)
	end

	self:UpdatePieGraph(gComp, true)
	self:UpdateLineGraph(gCompLine, DetailsUserComp)

	DPSMate_Details_CompareRageGained:Show()
	DPSMate_Details_CompareRageGained_Graph:Show()
end

----------------------------------------------------
-- SCROLL FRAME: list of abilities + rage %
----------------------------------------------------
function DPSMate.Modules.DetailsRageGained:ScrollFrame_Update()
	local obj = DPSMate_Details_RageGained_Log_ScrollFrame
	local len = tgetn(DetailsArr)
	FauxScrollFrame_Update(obj, len, 10, 24)

	local offset = FauxScrollFrame_GetOffset(obj) or 0
	local line
	for line = 1, 10 do
		local lineplusoffset = line + offset
		local btn = _G("DPSMate_Details_RageGained_Log_ScrollButton"..line)
		local nameF = _G("DPSMate_Details_RageGained_Log_ScrollButton"..line.."_Name")
		local valF = _G("DPSMate_Details_RageGained_Log_ScrollButton"..line.."_Value")
		local iconF = _G("DPSMate_Details_RageGained_Log_ScrollButton"..line.."_Icon")

		local selectedF = _G("DPSMate_Details_RageGained_Log_ScrollButton"..line.."_selected")
		if selectedF then selectedF:Hide() end

		if DetailsArr[lineplusoffset] then
			local value = RageArr[lineplusoffset] or 0
			local ability = DPSMate:GetAbilityById(DetailsArr[lineplusoffset])

			if ability and value > 0 then
				nameF:SetText(ability)
				if DetailsTotal > 0 then
					valF:SetText(value.." ("..strformat("%.2f", value*100/DetailsTotal).."%)")
				else
					valF:SetText(value)
				end
				iconF:SetTexture(DPSMate.BabbleSpell:GetSpellIcon(ability))
				if len < 10 then
					btn:SetWidth(235)
					nameF:SetWidth(125)
				else
					btn:SetWidth(220)
					nameF:SetWidth(110)
				end
				if DetailsSelected == lineplusoffset and selectedF then selectedF:Show() end
				btn:Show()
			else
				btn:Hide()
			end
		else
			btn:Hide()
		end
	end
end

----------------------------------------------------
-- PIE GRAPH
----------------------------------------------------
function DPSMate.Modules.DetailsRageGained:UpdatePieGraph(gg, isCompare)
	local uArr, mArr, total = DetailsArr, RageArr, DetailsTotal
	if isCompare then
		uArr, mArr, total = DetailsArrComp, RageArrComp, DetailsTotalComp
	end

	gg:ResetPie()
	if not total or total <= 0 then
		gg:Hide()
		return
	end

	local i
	for i = 1, tgetn(uArr) do
		local ability = DPSMate:GetAbilityById(uArr[i])
		local value = mArr[i] or 0
		if ability and value > 0 then
			gg:AddPie(value*100/total, 0, ability)
		end
	end
	gg:Show()
end

----------------------------------------------------
-- TIME / LINE GRAPH
----------------------------------------------------
function DPSMate.Modules.DetailsRageGained:SortLineTable(cname, abilityOnly)
	local newArr = {}
	local byTime = {}
	local user = cname or DetailsUser

	if not DPSMateUser[user] or not db[DPSMateUser[user][1]] then
		return newArr
	end

	local ability, val, time, amount
	for ability, val in pairs(db[DPSMateUser[user][1]]) do
		if ability ~= "i" and (not abilityOnly or ability == abilityOnly) and type(val) == "table" and val["i"] then
			for time, amount in pairs(val["i"]) do
				if type(time) == "number" and type(amount) == "number" then
					byTime[time] = (byTime[time] or 0) + amount
				end
			end
		end
	end

	for time, amount in pairs(byTime) do
		local i = 1
		while true do
			if not newArr[i] then
				tinsert(newArr, i, {time, amount})
				break
			elseif time <= newArr[i][1] then
				tinsert(newArr, i, {time, amount})
				break
			end
			i = i + 1
		end
	end

	return newArr
end

function DPSMate.Modules.DetailsRageGained:GetSummarizedTable(cname, abilityOnly)
	return DPSMate.Sync:GetSummarizedTable(self:SortLineTable(cname, abilityOnly))
end

function DPSMate.Modules.DetailsRageGained:UpdateLineGraph(gg, cname)
	if g3 then g3:Hide() end

	local abilityOnly = nil
	if toggleIndividual and not cname then
		abilityOnly = DetailsArr[DetailsSelected]
	end
	local sumTable = self:GetSummarizedTable(cname, abilityOnly)
	local count = tgetn(sumTable)

	gg:ResetData()
	if count == 0 then
		gg:Hide()
		return
	end

	local minTime = sumTable[1][1]
	local maxTime = sumTable[1][1]
	local maxMana = sumTable[1][2]
	local i
	for i = 2, count do
		if sumTable[i][1] < minTime then minTime = sumTable[i][1] end
		if sumTable[i][1] > maxTime then maxTime = sumTable[i][1] end
		if sumTable[i][2] > maxMana then maxMana = sumTable[i][2] end
	end

	local xRange = maxTime - minTime
	if xRange < 1 then xRange = 1 end
	if maxMana < 1 then maxMana = 1 end

	gg:SetXAxis(0, xRange)
	gg:SetYAxis(0, maxMana + 200)
	gg:SetGridSpacing(max(1, xRange/10), max(1, maxMana/7))
	gg:SetGridColor({0.5,0.5,0.5,0.5})
	gg:SetAxisDrawing(true,true)
	gg:SetAxisColor({1.0,1.0,1.0,1.0})
	gg:SetAutoScale(true)
	gg:SetYLabels(true, false)
	gg:SetXLabels(true)

	local data = {{0,0}}
	local scaled = DPSMate:ScaleDown(sumTable, minTime)
	local point
	for i = 1, tgetn(scaled) do
		point = scaled[i]
		tinsert(data, {point[1], point[2], self:CheckProcs(DPSMate_Details_RageGained.proc, point[1]+minTime+1)})
	end

	local colors = {{1.0,0.0,0.0,0.8}, {1.0,1.0,0.0,0.8}}
	if cname then
		colors = {{0.2,0.8,0.2,0.8}, {0.5,0.8,0.9,0.8}}
	end
	gg:AddDataSeries(data, colors, self:AddProcPoints(DPSMate_Details_RageGained.proc, data))
	gg:Show()
end

function DPSMate.Modules.DetailsRageGained:UpdateStackedGraph(gg, cname)
	if g2 then g2:Hide() end

	local user = cname or DetailsUser
	local userID = DPSMateUser[user] and DPSMateUser[user][1]
	local data = {}
	local labels = {}
	local totals = {}
	local maxX = 0
	local maxY = 0
	local pointTotals = {}
	local ability, path, time, amount

	if not userID or not db[userID] then
		gg:Hide()
		return
	end

	for ability, path in pairs(db[userID]) do
		if ability ~= "i" and type(path) == "table" and path["i"] and (not toggleIndividual or ability == DetailsArr[DetailsSelected]) then
			local one = {}
			for time, amount in pairs(path["i"]) do
				if type(time) == "number" and type(amount) == "number" then
					local i = 1
					while true do
						if not one[i] then
							tinsert(one, i, {time, amount})
							break
						elseif time <= one[i][1] then
							tinsert(one, i, {time, amount})
							break
						end
						i = i + 1
					end
					pointTotals[time] = (pointTotals[time] or 0) + amount
					if time > maxX then maxX = time end
				end
			end
			if tgetn(one) > 0 then
				local i = 1
				local total = path[1] or 0
				while true do
					if not totals[i] or total <= totals[i] then
						tinsert(totals, i, total)
						tinsert(labels, i, DPSMate:GetAbilityById(ability))
						tinsert(data, i, one)
						break
					end
					i = i + 1
				end
			end
		end
	end

	for time, amount in pairs(pointTotals) do
		if amount > maxY then maxY = amount end
	end
	if tgetn(data) == 0 then
		gg:Hide()
		return
	end
	if maxX < 1 then maxX = 1 end
	if maxY < 1 then maxY = 1 end

	gg:ResetData()
	gg:SetGridSpacing(max(1, maxX/7), max(1, maxY/7))
	gg:AddDataSeries(data, {1.0,0.0,0.0,0.8}, {}, labels)
	gg:Show()
end

----------------------------------------------------
-- SELECT / HIT STATISTICS
----------------------------------------------------
function DPSMate.Modules.DetailsRageGained:UpdateHitStatistics(abilityID)
	local amount, hits, average, minimum, maximum = 0, 0, 0, nil, nil
	local userID

	if DPSMateUser[DetailsUser] then
		userID = DPSMateUser[DetailsUser][1]
	end

	if userID and db[userID] and abilityID and db[userID][abilityID] then
		local path = db[userID][abilityID]
		if type(path) == "table" then
			amount = path[1] or 0
			hits = path[2] or 0
			minimum = path[3]
			maximum = path[4]
		else
			amount = path or 0
		end
	end

	if hits > 0 then average = amount / hits end

	local amountFrame = DPSMate_Details_RageGained_LogDetails_Healing_Amount0
	local percent = 0
	if hits > 0 then percent = 100 end

	DPSMate_Details_RageGained_LogDetails_Healing_Amount0_Amount:SetText(hits)
	DPSMate_Details_RageGained_LogDetails_Healing_Amount0_Percent:SetText(strformat("%.1f", percent).."%")
	DPSMate_Details_RageGained_LogDetails_Healing_Amount0_StatusBar:SetValue(percent)
	DPSMate_Details_RageGained_LogDetails_Healing_Amount0_StatusBar:SetStatusBarColor(0.3,0.7,1.0,1)
	DPSMate_Details_RageGained_LogDetails_Healing_Average0:SetText(ceil(average))

	if minimum then
		DPSMate_Details_RageGained_LogDetails_Healing_Min0:SetText(minimum)
	else
		DPSMate_Details_RageGained_LogDetails_Healing_Min0:SetText("-")
	end

	if maximum then
		DPSMate_Details_RageGained_LogDetails_Healing_Max0:SetText(maximum)
	else
		DPSMate_Details_RageGained_LogDetails_Healing_Max0:SetText("-")
	end
end

function DPSMate.Modules.DetailsRageGained:SelectDetailsButton(i)
	local obj = DPSMate_Details_RageGained_Log_ScrollFrame
	local lineplusoffset = i + (FauxScrollFrame_GetOffset(obj) or 0)
	local p

	DetailsSelected = lineplusoffset

	for p = 1, 10 do
		local selected = _G("DPSMate_Details_RageGained_Log_ScrollButton"..p.."_selected")
		if selected then selected:Hide() end
	end

	local selected = _G("DPSMate_Details_RageGained_Log_ScrollButton"..i.."_selected")
	if selected and DetailsArr[lineplusoffset] then
		selected:Show()
	end

	self:UpdateHitStatistics(DetailsArr[lineplusoffset])
	if toggleIndividual and g2 then self:UpdateLineGraph(g2) end
end

----------------------------------------------------
-- HEALING-STYLE TABLE GRID / CONTROLS / PROCS
----------------------------------------------------
function DPSMate.Modules.DetailsRageGained:CreateGraphTable()
	local lines = {}
	local i
	for i = 1, 8 do
		lines[i] = DPSMate.Options.graph:DrawLine(DPSMate_Details_RageGained_LogDetails_Healing, 10, 270-i*30, 370, 270-i*30, 20, {0.5,0.5,0.5,0.5}, "BACKGROUND")
		lines[i]:Show()
	end
	lines[9] = DPSMate.Options.graph:DrawLine(DPSMate_Details_RageGained_LogDetails_Healing, 57, 260, 57, 15, 20, {0.5,0.5,0.5,0.5}, "BACKGROUND")
	lines[10] = DPSMate.Options.graph:DrawLine(DPSMate_Details_RageGained_LogDetails_Healing, 192, 260, 192, 15, 20, {0.5,0.5,0.5,0.5}, "BACKGROUND")
	lines[11] = DPSMate.Options.graph:DrawLine(DPSMate_Details_RageGained_LogDetails_Healing, 252, 260, 252, 15, 20, {0.5,0.5,0.5,0.5}, "BACKGROUND")
	lines[12] = DPSMate.Options.graph:DrawLine(DPSMate_Details_RageGained_LogDetails_Healing, 312, 260, 312, 15, 20, {0.5,0.5,0.5,0.5}, "BACKGROUND")
	for i = 9, 12 do lines[i]:Show() end
end


----------------------------------------------------
-- PLAYER LIST: alternate lower-left mode, matching Healing
----------------------------------------------------
function DPSMate.Modules.DetailsRageGained:Player_Update()
	-- Healing-style personal view: only show the player whose
	-- Rage Gained details window is currently open.
	local obj = DPSMate_Details_RageGained_player_ScrollFrame
	local userID, amount, abilityID, abilityPath

	if DPSMateUser[DetailsUser] then
		userID = DPSMateUser[DetailsUser][1]
	end

	amount = 0
	if userID and db[userID] then
		for abilityID, abilityPath in pairs(db[userID]) do
			if abilityID ~= "i" and type(abilityPath) == "table" then
				amount = amount + (abilityPath[1] or 0)
			end
		end
	end

	FauxScrollFrame_SetOffset(obj, 0)
	FauxScrollFrame_Update(obj, 1, 8, 24)

	local line
	for line = 1, 8 do
		local btn = _G("DPSMate_Details_RageGained_player_ScrollButton"..line)
		local nameF = _G("DPSMate_Details_RageGained_player_ScrollButton"..line.."_Name")
		local valF = _G("DPSMate_Details_RageGained_player_ScrollButton"..line.."_Value")
		local iconF = _G("DPSMate_Details_RageGained_player_ScrollButton"..line.."_Icon")
		local selectedF = _G("DPSMate_Details_RageGained_player_ScrollButton"..line.."_selected")

		if line == 1 and userID and DetailsUser then
			local r, gcol, b, img = DPSMate:GetClassColor(DPSMateUser[DetailsUser][2])
			nameF:SetText(DetailsUser)
			nameF:SetTextColor(r, gcol, b)
			valF:SetText(amount.." (100.00%)")
			iconF:SetTexture("Interface\\AddOns\\DPSMate\\images\\class\\"..img)
			btn:SetWidth(235)
			nameF:SetWidth(125)
			btn:Show()
			if selectedF then selectedF:Show() end
		else
			btn:Hide()
			if selectedF then selectedF:Hide() end
		end
	end
end

function DPSMate.Modules.DetailsRageGained:UpdateTotalStatistics()
	local amount, hits, minimum, maximum = 0, 0, nil, nil
	local userID, ability, path
	if DPSMateUser[DetailsUser] then userID = DPSMateUser[DetailsUser][1] end
	if userID and db[userID] then
		for ability, path in pairs(db[userID]) do
			if ability ~= "i" and type(path) == "table" then
				amount = amount + (path[1] or 0)
				hits = hits + (path[2] or 0)
				if path[3] and (not minimum or path[3] < minimum) then minimum = path[3] end
				if path[4] and (not maximum or path[4] > maximum) then maximum = path[4] end
			end
		end
	end
	local average = 0
	if hits > 0 then average = amount/hits end
	DPSMate_Details_RageGained_LogDetails_Healing_Amount0_Amount:SetText(hits)
	DPSMate_Details_RageGained_LogDetails_Healing_Amount0_Percent:SetText("100.0%")
	DPSMate_Details_RageGained_LogDetails_Healing_Amount0_StatusBar:SetValue(100)
	DPSMate_Details_RageGained_LogDetails_Healing_Amount0_StatusBar:SetStatusBarColor(0.3,0.7,1.0,1)
	DPSMate_Details_RageGained_LogDetails_Healing_Average0:SetText(ceil(average))
	DPSMate_Details_RageGained_LogDetails_Healing_Min0:SetText(minimum or "-")
	DPSMate_Details_RageGained_LogDetails_Healing_Max0:SetText(maximum or "-")
end

function DPSMate.Modules.DetailsRageGained:ToggleMode(graphButton)
	-- Dice button: switch between line and stacked graph.
	if graphButton then
		if toggleGraph then
			toggleGraph = false
			if g3 then g3:Hide() end
			if g2 then self:UpdateLineGraph(g2) end
		else
			toggleGraph = true
			if g2 then g2:Hide() end
			if g3 then self:UpdateStackedGraph(g3) end
		end
		return
	end

	-- Coin button: match Healing. Toggle the lower-left pane
	-- between the pie chart and a player list with rage totals and %.
	if toggleMode then
		toggleMode = false
		DPSMate_Details_RageGained_player:Hide()
		DPSMate_Details_RageGained_Diagram:Show()
		if g then self:UpdatePieGraph(g) end
	else
		toggleMode = true
		self:Player_Update()
		DPSMate_Details_RageGained_Diagram:Hide()
		DPSMate_Details_RageGained_player:Show()
	end
end

function DPSMate.Modules.DetailsRageGained:ToggleIndividual()
	-- Disabled for now. Keep this function so the XML button can still
	-- play its normal click sound without changing or redrawing the graph.
	return
end

function DPSMate.Modules.DetailsRageGained:GetAuraGainedArr(k)
	local modes = {["total"]=1,["currentfight"]=2}
	local cat, val, num
	for cat, val in pairs(DPSMateSettings["windows"][k]["options"][2]) do
		if val then
			if string.find(cat, "segment") then
				num = tonumber(string.sub(cat, 8))
				return DPSMateHistory["Auras"][num]
			else
				return DPSMateAurasGained[modes[cat]]
			end
		end
	end
	return {}
end

function DPSMate.Modules.DetailsRageGained:ProcsDropDown()
	local arr = DPSMate.Modules.DetailsRageGained:GetAuraGainedArr(curKey)
	DPSMate_Details_RageGained.proc = "None"
	local function on_click()
		UIDropDownMenu_SetSelectedValue(DPSMate_Details_RageGained_DiagramLegend_Procs, this.value)
		DPSMate_Details_RageGained.proc = this.value
		if not toggleGraph and g2 then DPSMate.Modules.DetailsRageGained:UpdateLineGraph(g2) end
	end
	UIDropDownMenu_AddButton{text="None", value="None", func=on_click}
	if DPSMateUser[DetailsUser] and arr and arr[DPSMateUser[DetailsUser][1]] then
		local cat, val, ability
		for cat, val in pairs(arr[DPSMateUser[DetailsUser][1]]) do
			ability = DPSMate:GetAbilityById(cat)
			if ability and DPSMate:TContains(DPSMate.Parser.procs, ability) then
				UIDropDownMenu_AddButton{text=ability, value=cat, func=on_click}
			end
		end
	end
end

function DPSMate.Modules.DetailsRageGained:CheckProcs(name, val)
	if not name or name == "None" then return false end
	local arr = self:GetAuraGainedArr(curKey)
	local uid = DPSMateUser[DetailsUser] and DPSMateUser[DetailsUser][1]
	local aura = uid and arr and arr[uid] and arr[uid][name]
	local i
	if aura and aura[1] and aura[2] and not aura[4] then
		for i = 1, DPSMate:TableLength(aura[1]) do
			if aura[1][i] and aura[2][i] and val > aura[1][i] and val < aura[2][i] then return true end
		end
	end
	return false
end

function DPSMate.Modules.DetailsRageGained:AddProcPoints(name, dat)
	if not name or name == "None" then return {false, {}} end
	local bool, data, lastVal = false, {}, 0
	local arr = self:GetAuraGainedArr(curKey)
	local uid = DPSMateUser[DetailsUser] and DPSMateUser[DetailsUser][1]
	local aura = uid and arr and arr[uid] and arr[uid][name]
	local cat, val, i, va, add
	if aura and aura[4] and aura[1] then
		for cat, val in pairs(dat) do
			for i = 1, DPSMate:TableLength(aura[1]) do
				if aura[1][i] and aura[1][i] <= val[1] then
					add = true
					for _, va in pairs(data) do if va[1] == aura[1][i] then add = false break end end
					if add then bool = true tinsert(data, {aura[1][i], lastVal, {val[1], val[2]}}) end
				end
			end
			lastVal = {val[1], val[2]}
		end
	end
	return {bool, data}
end

