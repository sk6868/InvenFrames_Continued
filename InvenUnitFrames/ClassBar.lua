local IUF = InvenUnitFrames
local playerClass = select(2, UnitClass("player"))
local SM = LibStub("LibSharedMedia-3.0")

local _G = _G
local select = _G.select
local floor = _G.floor
local unpack = _G.unpack
local min = _G.math.min
local GetTime = _G.GetTime
local GetSpellInfo = _G.GetSpellInfo
local GetTotemInfo = _G.GetTotemInfo
local GetTotemTimeLeft = _G.GetTotemTimeLeft

local classBarBorderColor = { 0.45, 0.45, 0.45, 1 }

local function setClassBar(frame, object, frameLevel, visible)
	frame:SetParent(object)
	frame:SetFrameLevel(frameLevel or object.classBar:GetFrameLevel())
	if visible then
		frame:HookScript("OnShow", visible)
		frame:HookScript("OnHide", visible)
	end
	frame:SetToplevel(nil)
	if frame == TotemFrame then
		local totem, totemChild, totemChildWidth, totemChildHeight, totemChildTexture
		for i = 1, MAX_TOTEMS do
			totem = _G["TotemFrameTotem"..i]
			for j = 1, select("#", totem:GetChildren()) do
				totemChild = select(j, totem:GetChildren())
				if not totemChild:GetName() then
					totemChildWidth = floor(totemChild:GetWidth() + 0.1)
					totemChildHeight = floor(totemChild:GetHeight() + 0.1)
					if totemChildWidth == 38 and totemChildWidth == totemChildHeight then
						for k = 1, select("#", totemChild:GetRegions()) do
							totemChildTexture = select(k, totemChild:GetRegions())
							if totemChildTexture:GetObjectType() == "Texture" and totemChildTexture:GetDrawLayer() == "OVERLAY" then
								totemChild:SetSize(32, 32)
								totemChildTexture:SetTexture("Interface\\AddOns\\InvenUnitFrames\\Texture\\CircleBorder")
								break
							end
						end
						break
					end
				end
			end
		end
		TotemFrameTotem2:ClearAllPoints()
		TotemFrameTotem1:ClearAllPoints()
		TotemFrameTotem1:SetPoint("RIGHT", TotemFrameTotem2, "LEFT", 4, 0)
	end
end

local function createClassBar(object)
	object:SetFrameLevel(4)
	object.classBar = CreateFrame("Frame", object:GetName().."_ClassBar", object)
	object.classBar:SetFrameLevel(3)
end

local function updateTotemDurationText()
	local totem
	if IUF.db.classBar.pos == "TOP" then
		for i = 1, MAX_TOTEMS do
			totem = _G["TotemFrameTotem"..i]
			totem.duration:ClearAllPoints()
			totem.duration:SetPoint("BOTTOM", totem, "TOP", 0, -4)
		end
	else
		for i = 1, MAX_TOTEMS do
			totem = _G["TotemFrameTotem"..i]
			totem.duration:ClearAllPoints()
			totem.duration:SetPoint("TOP", totem, "BOTTOM", 0, 5)
		end
	end
end

local function createAddOnClassBar(object)
	local f = CreateFrame("Frame", nil, object)
	f:SetFrameLevel(5)
	f:SetHeight(16)
	object.classBar.addOn = f
	f.bg = f:CreateTexture(nil, "BACKGROUND", nil, -5)
	f.bg:SetAllPoints()
	f.bg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
	f.bg:SetVertexColor(0, 0, 0, 1)
	return f
end

local function updateAddOnBorder(f)
	local w = (floor(f:GetWidth() + 0.1) - 2) / f.num
	if w ~= f.width then
		f.width = w
		local m, M, cur
		for i = 1, f.num do
			if not f.anchors[i] then
				f.anchors[i] = f:CreateTexture(nil, "BACKGROUND", nil, 0)
				f.anchors[i]:SetHeight(f.height - 4)
				if f.needStatusBar then
					f.anchors[i].bar = CreateFrame("StatusBar", nil, f)
					f.anchors[i].bar:SetFrameLevel(f:GetFrameLevel())
					f.anchors[i].bar:SetID(i)
					f.anchors[i].bar:SetStatusBarTexture(SM:Fetch("statusbar", IUF.db.classBar.texture or "Smooth v2"))
					f.anchors[i].bar:SetStatusBarColor(1, 0.82, 0)
					f.anchors[i].bar:SetMinMaxValues(0, 1)
					f.anchors[i].bar:SetValue(1)
					f.anchors[i].bar.text = f.anchors[i].bar:CreateFontString(nil, "OVERLAY", "FriendsFont_Small")
					f.anchors[i].bar.text:SetPoint("CENTER", 0, 0)
					if f.needStatusBarIcon then
						f.anchors[i].bar:SetPoint("TOPLEFT", f.anchors[i], "TOPLEFT", f.height - 5, 0)
						f.anchors[i].bar:SetPoint("BOTTOMRIGHT", f.anchors[i], "BOTTOMRIGHT", 0, 0)
						f.anchors[i].bar.icon = f.anchors[i].bar:CreateTexture(nil, "BORDER")
						f.anchors[i].bar.icon:SetSize(f.height - 4, f.height - 4)
						f.anchors[i].bar.icon:SetPoint("TOPLEFT", f.anchors[i], "TOPLEFT", -1, 0)
						f.anchors[i].bar.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
					else
						f.anchors[i].bar:SetAllPoints(f.anchors[i])
					end
					f.anchors[i].bar.click = CreateFrame("Button", nil, f.anchors[i].bar)
					f.anchors[i].bar.click:SetAllPoints(f.anchors[i])
					f.anchors[i].bar.click:SetFrameLevel(f:GetFrameLevel() + 1)
					f.anchors[i].bar.click:SetID(i)
				else
					--f.anchors[i]:SetTexture(1, 1, 1)
				end
				if i == 1 then
					f.anchors[i]:SetPoint("TOPLEFT", 2, -2)
				else
					f.anchors[i]:SetPoint("TOPLEFT", f.anchors[i - 1], "TOPRIGHT", 2, 0)
					f.anchors[i].s = f:CreateTexture(nil, "ARTWORK")
					f.anchors[i].s:SetSize(f.height, f.height)
					f.anchors[i].s:SetPoint("CENTER", f.anchors[i], "LEFT", 0, 0)
					f.anchors[i].s:SetTexture("Interface\\AddOns\\InvenUnitFrames\\Texture\\SmallIconBorder3")
					f.anchors[i].s:SetVertexColor(unpack(classBarBorderColor))
				end
			end
			f.anchors[i]:Show()
			f.anchors[i]:SetWidth(w - 2)
			if f.anchors[i].s then
				f.anchors[i].s:Show()
			end
			if f.anchors[i].bar then
				f.anchors[i].bar:Show()
				m, M = f.anchors[i].bar:GetMinMaxValues()
				cur = f.anchors[i].bar:GetValue()
				f.anchors[i].bar:SetMinMaxValues(m - 1, M + 1)
				f.anchors[i].bar:SetValue(cur + 1)
				f.anchors[i].bar:SetMinMaxValues(m, M)
				f.anchors[i].bar:SetValue(cur)
			end
		end
		for i = f.num + 1, #f.anchors do
			f.anchors[i]:Hide()
			if f.anchors[i].s then
				f.anchors[i].s:Hide()
			end
			if f.anchors[i].bar then
				f.anchors[i].bar:Hide()
			end
		end
	end
end

local function setAddOnBorder(f, num, statusBar, statusBarIcon)
	if not f.anchors then
		f:EnableMouse(true)
		f.anchors, f.height = {}, floor(f:GetHeight() + 0.1)
		f.needStatusBar, f.needStatusBarIcon = statusBar, statusBar and statusBarIcon
		local bgLeft = f:CreateTexture(nil, "ARTWORK")
		bgLeft:SetSize(f.height / 2, f.height)
		bgLeft:SetPoint("TOPLEFT", 0, 0)
		bgLeft:SetTexture("Interface\\AddOns\\InvenUnitFrames\\Texture\\SmallIconBorder")
		bgLeft:SetTexCoord(0, 0.5, 0, 1)
		bgLeft:SetVertexColor(unpack(classBarBorderColor))
		local bgRight = f:CreateTexture(nil, "ARTWORK")
		bgRight:SetSize(f.height / 2, f.height)
		bgRight:SetPoint("TOPRIGHT", 0, 0)
		bgRight:SetTexture("Interface\\AddOns\\InvenUnitFrames\\Texture\\SmallIconBorder")
		bgRight:SetTexCoord(0.5, 1, 0, 1)
		bgRight:SetVertexColor(unpack(classBarBorderColor))
		local bgMid = f:CreateTexture(nil, "ARTWORK")
		bgMid:SetPoint("TOPLEFT", bgLeft, "TOPRIGHT", 0, 0)
		bgMid:SetPoint("BOTTOMRIGHT", bgRight, "BOTTOMLEFT", 0, 0)
		bgMid:SetTexture("Interface\\AddOns\\InvenUnitFrames\\Texture\\SmallIconBorder")
		bgMid:SetTexCoord(0.35, 0.65, 0, 1)
		bgMid:SetVertexColor(unpack(classBarBorderColor))
		f:SetScript("OnSizeChanged", updateAddOnBorder)
		f:SetScript("OnShow", updateAddOnBorder)
	end
	f.num = num or 1
	updateAddOnBorder(f)
end

function secondsToTime(seconds)
	if seconds >= 86400 then
		return ceil(seconds / 86400).."d"
	elseif seconds >= 3600 then
		return ceil(seconds / 86400).."h"
	elseif seconds >= 60 then
		return ceil(seconds / 60).."m"
	else
		return floor(seconds + 0.5)
	end
end

local function createTotem(object, num, pos, shown)
	object.totem = CreateFrame("Frame", nil, object)
	pos = pos or "TOP"
	object.totem:SetPoint(pos.."LEFT", 0, 0)
	object.totem:SetPoint(pos.."RIGHT", 0, 0)
	object.totem:SetHeight(14)
	object.totem:SetFrameLevel(object:GetFrameLevel())
	num = min(num or MAX_TOTEMS, MAX_TOTEMS)
	setAddOnBorder(object.totem, num, true, true)

	local function updateTotem(anchors, i)
		anchors[i].bar.timeLeft = GetTotemTimeLeft(anchors[i].bar:GetID())
		anchors[i].bar:SetValue(anchors[i].bar.timeLeft)
		anchors[i].bar.text:SetText(secondsToTime(anchors[i].bar.timeLeft))
	end

	object.totem:SetScript("OnEvent", function(self)
		local visible, haveTotem, name, icon
		for i = 1, self.num do
			haveTotem, name, self.anchors[i].bar.startTime, self.anchors[i].bar.duration, icon = GetTotemInfo(self.anchors[i].bar:GetID())
			if haveTotem and self.anchors[i].bar.duration > 0 then
				visible = true
				self.anchors[i].bar:Show()
				self.anchors[i].bar.icon:SetTexture(icon)
				self.anchors[i].bar:SetMinMaxValues(0, self.anchors[i].bar.duration)
				updateTotem(self.anchors, i)
			else
				self.anchors[i].bar:Hide()
				self.anchors[i].bar.startTime, self.anchors[i].bar.duration, self.anchors[i].bar.timeLeft = nil
			end
		end
		if visible then
			self:Show()
		else
			self:Hide()
		end
	end)

	local function totemOnEnter(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
		GameTooltip:SetTotem(self:GetID())
	end

	for i = 1, object.totem.num do
		object.totem.anchors[i].bar.click:SetScript("OnEnter", totemOnEnter)
		object.totem.anchors[i].bar.click:SetScript("OnLeave", GameTooltip_Hide)
	end

	object.totem.onEvent = object.totem:GetScript("OnEvent")
	object.totem:RegisterEvent("PLAYER_TOTEM_UPDATE")
	object.totem:RegisterEvent("PLAYER_ENTERING_WORLD")
	object.totem:Hide()
	object.totem:SetScript("OnUpdate", function(self, timer)
		self.timer = (self.timer or 0) + timer
		if self.timer > 0.1 then
			self.timer = 0
			for i = 1, self.num do
				if self.anchors[i].bar.duration then
					updateTotem(self.anchors, i)
				end
			end
		end
	end)
	if shown then
		object.totem:SetScript("OnShow", shown)
		object.totem:SetScript("OnHide", shown)
	end
end

--[[
local function findBuffById(id, filter)
	local name, rank = GetSpellInfo(id)
	--if name then
		local buff = select(11, UnitBuff("player", name, rank, filter))
		if buff == id then
			return true
		elseif buff then
			rank = 1
			buff = select(11, UnitBuff("player", rank, filter))
			while buff do
				if buff == id then
					return true
				end
				rank = rank + 1
				buff = select(11, UnitBuff("player", rank, filter))
			end
		end
	--end
	return nil
end
]]--

local function findBuffById(id, filter)
	local name, rank = GetSpellInfo(id)
	local _,_,_,stack,_,_,_,_,_,_,buff = UnitBuff("player", name, rank, filter)
	if buff == id then
		return true, stack
	end
	return nil
end

if playerClass == "DRUID" then
	local function updateVisible()	-- DRUID
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				if TotemFrame:IsShown() then
					IUF.units.player.classBar:SetAlpha(1)
					if EclipseBarFrame:IsShown() then
						PlayerFrameAlternateManaBar:SetAlpha(0)
						IUF.units.player.classBar:SetHeight(64)
					elseif PlayerFrameAlternateManaBar:IsShown() then
						PlayerFrameAlternateManaBar:SetAlpha(1)
						IUF.units.player.classBar:SetHeight(57)
					else
						IUF.units.player.classBar:SetHeight(42)
					end
				elseif EclipseBarFrame:IsShown() then
					IUF.units.player.classBar:SetAlpha(1)
					PlayerFrameAlternateManaBar:SetAlpha(0)
					IUF.units.player.classBar:SetHeight(30)
				elseif PlayerFrameAlternateManaBar:IsShown() then
					IUF.units.player.classBar:SetAlpha(1)
					IUF.units.player.classBar:SetHeight(13)
					PlayerFrameAlternateManaBar:SetAlpha(1)
				else
					IUF.units.player.classBar:SetAlpha(0)
					IUF.units.player.classBar:SetHeight(0.001)
				end
			elseif IUF.units.player.classBar.addOn.totem:IsShown() then
				if IUF.units.player.classBar.addOn.mana:IsShown() or IUF.units.player.classBar.addOn.eclipse:IsShown() then
					IUF.units.player.classBar:SetHeight(29)
					IUF.units.player.classBar.addOn:SetHeight(28)
				else
					IUF.units.player.classBar:SetHeight(15)
					IUF.units.player.classBar.addOn:SetHeight(14)
				end
			elseif IUF.units.player.classBar.addOn.mana:IsShown() or IUF.units.player.classBar.addOn.eclipse:IsShown() or IUF.units.player.classBar.addOn.totem:IsShown() then
				IUF.units.player.classBar:SetHeight(15)
				IUF.units.player.classBar.addOn:SetHeight(14)
			else
				IUF.units.player.classBar:SetHeight(0.001)
				IUF.units.player.classBar.addOn:SetHeight(0.001)
			end
		else
			IUF.units.player.classBar:SetHeight(0.001)
			IUF.units.player.classBar.addOn:SetHeight(0.001)
		end
	end

	function IUF:CreateClassBar(object)	-- DRUID
		createClassBar(object)
		object = createAddOnClassBar(object)

		local abs = _G.math.abs
		local max = _G.math.max
		local UnitPower = _G.UnitPower
		local UnitPowerMax = _G.UnitPowerMax
		local UnitPowerType = _G.UnitPowerType
		local UnitHasVehicleUI = _G.UnitHasVehicleUI
		local GetSpecialization = _G.GetSpecialization
		local GetShapeshiftFormID = _G.GetShapeshiftFormID
		--local GetEclipseDirection = _G.GetEclipseDirection

		local ECLIPSE_BAR_SOLAR_BUFF_ID = 164545	-- Solar Empowerment
		local ECLIPSE_BAR_LUNAR_BUFF_ID = 164547	-- Lunar Empowerment
		local ECLIPSE_BAR_SOLAR_BUFF = GetSpellInfo(ECLIPSE_BAR_SOLAR_BUFF_ID)
		local ECLIPSE_BAR_LUNAR_BUFF = GetSpellInfo(ECLIPSE_BAR_LUNAR_BUFF_ID)

		object.mana = CreateFrame("Frame", nil, object)
		object.mana:SetPoint("TOPLEFT", 0, 0)
		object.mana:SetPoint("TOPRIGHT", 0, 0)
		object.mana:SetHeight(14)
		object.mana:SetFrameLevel(object:GetFrameLevel())
		setAddOnBorder(object.mana, 1, true)
		object.mana.text = object.mana:CreateFontString(nil, "OVERLAY", "FriendsFont_Small")
		object.mana.text:SetPoint("CENTER", 0, 0)
		object.mana:SetScript("OnEvent", function(self, event, _, powerType)
			if event == "UNIT_POWER_FREQUENT" or event == "UNIT_POWER" then
				if powerType == "MANA" then
					self.cur = UnitPower("player", 0)
					self.anchors[1].bar:SetValue(self.cur)
					IUF:SetStatusBarValue(self.text, 2, self.cur, self.max)
				end
			elseif event == "UNIT_MAXPOWER" then
				if powerType == "MANA" then
					self.max, self.cur = UnitPowerMax("player", 0), UnitPower("player", 0)
					self.anchors[1].bar:SetMinMaxValues(0, self.max)
					self.anchors[1].bar:SetValue(self.cur)
					IUF:SetStatusBarValue(self.text, 2, self.cur, self.max)
				end
			elseif UnitPowerType("player") == 0 or UnitHasVehicleUI("player") then
				if self:IsShown() then
					self:Hide()
					self:UnregisterEvent("UNIT_MAXPOWER")
					self:UnregisterEvent("UNIT_POWER")
					self:UnregisterEvent("UNIT_POWER_FREQUENT")
					updateVisible()
				end
			else
				if not self:IsShown() then
					self:Show()
					self:RegisterUnitEvent("UNIT_MAXPOWER", "player")
					self:RegisterUnitEvent("UNIT_POWER", "player")
					self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
					updateVisible()
				end
				self:GetScript("OnEvent")(self, "UNIT_MAXPOWER", nil, "MANA")
			end
		end)
		object.mana:RegisterEvent("PLAYER_ENTERING_WORLD")
		object.mana:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
		object.mana:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
		object.mana:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
		object.mana:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
		object.mana:Hide()

		object.eclipse = CreateFrame("Frame", nil, object)
		object.eclipse:SetPoint("TOPLEFT", 0, 0)
		object.eclipse:SetPoint("TOPRIGHT", 0, 0)
		object.eclipse:SetHeight(14)
		object.eclipse:SetFrameLevel(object:GetFrameLevel())
		setAddOnBorder(object.eclipse, 1)
		object.eclipse.moon = object.eclipse:CreateTexture(nil, "BACKGROUND", nil, -3)
		object.eclipse.moon:SetVertexColor(0.13, 0.2, 0.5, 0.8)
		object.eclipse.moon:SetPoint("TOPLEFT", object.eclipse.anchors[1], "TOPLEFT", 0, 0)
		object.eclipse.moon:SetPoint("BOTTOMRIGHT", object.eclipse.anchors[1], "BOTTOM", 0, 0)
		
		object.eclipse.moonflash = CreateFrame("Frame", nil, object.eclipse)
		--object.eclipse.moonflash:GetFrameLevel(object.eclipse.flash:GetFrameLevel())
		object.eclipse.moonflash.tex = object.eclipse.moonflash:CreateTexture(nil, "BORDER")
		object.eclipse.moonflash.tex:SetBlendMode("ADD")
		object.eclipse.moonflash.tex:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
		object.eclipse.moonflash.tex:SetPoint("TOPLEFT", object.eclipse.anchors[1], "TOPLEFT", 0, 0)
		object.eclipse.moonflash.tex:SetPoint("BOTTOMRIGHT", object.eclipse.anchors[1], "BOTTOM", 0, 0)
		object.eclipse.moonflash:Hide()
		object.eclipse.moontext = object.eclipse:CreateFontString(nil, "OVERLAY", "FriendsFont_Small")
		object.eclipse.moontext:SetPoint("CENTER", object.eclipse.moonflash, "CENTER", 0, 0)
		
		object.eclipse.sun = object.eclipse:CreateTexture(nil, "BACKGROUND", nil, -3)
		object.eclipse.sun:SetVertexColor(0.51, 0.23, 0.03, 0.8)
		object.eclipse.sun:SetPoint("TOPRIGHT", object.eclipse.anchors[1], "TOPRIGHT", 0, 0)
		object.eclipse.sun:SetPoint("BOTTOMLEFT", object.eclipse.anchors[1], "BOTTOM", 0, 0)
		
		object.eclipse.sunflash = CreateFrame("Frame", nil, object.eclipse)
		object.eclipse.sunflash.tex = object.eclipse.sunflash:CreateTexture(nil, "BORDER")
		object.eclipse.sunflash.tex:SetBlendMode("ADD")
		object.eclipse.sunflash.tex:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
		object.eclipse.sunflash.tex:SetPoint("TOPRIGHT", object.eclipse.anchors[1], "TOPRIGHT", 0, 0)
		object.eclipse.sunflash.tex:SetPoint("BOTTOMLEFT", object.eclipse.anchors[1], "BOTTOM", 0, 0)
		object.eclipse.sunflash:Hide()
		object.eclipse.suntext = object.eclipse:CreateFontString(nil, "OVERLAY", "FriendsFont_Small")
		object.eclipse.suntext:SetPoint("CENTER", object.eclipse.sunflash, "CENTER", 0, 0)

		object.eclipse:Hide()

		object.eclipse:SetScript("OnEvent", function(self, event, dir, powerType)
			if event == "UNIT_AURA" then
				local found, stacks = findBuffById(ECLIPSE_BAR_SOLAR_BUFF_ID, "PLAYER")
				if found then
					if self.sunflash.anchor ~= self.sun then
						self.sunflash.anchor = self.sun
						self.sunflash:SetAllPoints(self.sun)
						self.sunflash.tex:SetVertexColor(0.97, 0.84, 0.22, 0.75)
						IUF:RegisterFlash(self.sunflash)
					end
					object.eclipse.suntext:SetFormattedText("%d", stacks)
				else
					if (self.sunflash.anchor or self.sunflash:IsShown()) then
						self.sunflash.anchor = nil
						IUF:UnregisterFlash(self.sunflash)
					end
					object.eclipse.suntext:SetText("")
				end
				found, stacks = findBuffById(ECLIPSE_BAR_LUNAR_BUFF_ID, "PLAYER")
				if found then
					if self.moonflash.anchor ~= self.moon then
						self.moonflash.anchor = self.moon
						self.moonflash:SetAllPoints(self.moon)
						self.moonflash.tex:SetVertexColor(0.35, 0.65, 0.87, 0.75)
						IUF:RegisterFlash(self.moonflash)
					end
					object.eclipse.moontext:SetFormattedText("%d", stacks)
				else
					if (self.moonflash.anchor or self.moonflash:IsShown()) then
						self.moonflash.anchor = nil
						IUF:UnregisterFlash(self.moonflash)
					end
					object.eclipse.moontext:SetText("")
				end
			elseif GetSpecialization() == 1 and not UnitHasVehicleUI("player") and (not GetShapeshiftFormID() or GetShapeshiftFormID() == MOONKIN_FORM) then
				if not self:IsShown() then
					self:Show()
					--self:RegisterEvent("ECLIPSE_DIRECTION_CHANGE")
					self:RegisterUnitEvent("UNIT_AURA", "player")
					updateVisible()
				end
				self.sunflash.anchor = nil
				self.moonflash.anchor = nil
				--self:onEvent("ECLIPSE_DIRECTION_CHANGE", GetEclipseDirection() or "none")
				self:onEvent("UNIT_AURA")
			elseif self:IsShown() then
				self:Hide()
				self.sunflash.anchor = nil
				self.moonflash.anchor = nil
				IUF:UnregisterFlash(self.sunflash)
				IUF:UnregisterFlash(self.moonflash)
				--self:UnregisterEvent("ECLIPSE_DIRECTION_CHANGE")
				self:UnregisterEvent("UNIT_AURA")
				updateVisible()
			end
		end)
		object.eclipse.onEvent = object.eclipse:GetScript("OnEvent")
		object.eclipse:RegisterEvent("PLAYER_ENTERING_WORLD")
		object.eclipse:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
		object.eclipse:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
		object.eclipse:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
		object.eclipse:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
		object.eclipse:SetScript("OnEnter", function(self)
			GameTooltip_SetDefaultAnchor(GameTooltip, self)
			GameTooltip:SetText(BALANCE, 1, 1, 1)
			GameTooltip:AddLine(BALANCE_TOOLTIP, nil, nil, nil, true)
			GameTooltip:Show()
		end)
		object.eclipse:SetScript("OnLeave", GameTooltip_Hide)

		createTotem(object, 3, "BOTTOM", updateVisible)
	end

	function IUF:ClassBarSetup(object)	-- DRUID
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				IUF.units.player.classBar.addOn:Hide()
				if not object.classBar.setupBlizzard then
					object.classBar.setupBlizzard = true
					setClassBar(PlayerFrameAlternateManaBar, object, nil, updateVisible)
					PlayerFrameAlternateManaBar:SetScript("OnMouseUp", nil)
					PlayerFrameAlternateManaBar.SetPoint = PlayerFrameAlternateManaBar.GetPoint
					setClassBar(EclipseBarFrame, object, nil, updateVisible)
					setClassBar(TotemFrame, object, 4, updateVisible)
				end
				PlayerFrameAlternateManaBar:SetStatusBarTexture(SM:Fetch("statusbar", IUF.db.classBar.texture or "Smooth v2"))
				PlayerFrameAlternateManaBar:SetStatusBarColor(self.colordb.power[0][1], self.colordb.power[0][2], self.colordb.power[0][3])
				PlayerFrameAlternateManaBar:ClearAllPoints()
				EclipseBarFrame:ClearAllPoints()
				TotemFrameTotem2:ClearAllPoints()
				PlayerFrameAlternateManaBar.DefaultBorder:ClearAllPoints()
				if IUF.db.classBar.pos == "BOTTOM" then
					EclipseBarFrame.SetPoint(PlayerFrameAlternateManaBar, "TOPLEFT", object.classBar, "TOPLEFT", 12, 0)
					EclipseBarFrame.SetPoint(PlayerFrameAlternateManaBar, "TOPRIGHT", object.classBar, "TOPRIGHT", -12, 0)
					PlayerFrameAlternateManaBar.DefaultBorder:SetPoint("TOPLEFT", 4, 0)
					PlayerFrameAlternateManaBar.DefaultBorder:SetPoint("TOPRIGHT", -4, 0)
					PlayerFrameAlternateManaBar.DefaultBorder:SetTexCoord(0.125, 0.25, 1, 0)
					PlayerFrameAlternateManaBar.DefaultBorderLeft:SetTexCoord(0, 0.125, 1, 0)
					PlayerFrameAlternateManaBar.DefaultBorderRight:SetTexCoord(0.125, 0, 1, 0)
					EclipseBarFrame:SetPoint("TOP", object.classBar, "TOP", 0, 6)
					TotemFrameTotem2:SetPoint("BOTTOM", object.classBar, "BOTTOM", 0, 9)
				else
					PlayerFrameAlternateManaBar:ClearAllPoints()
					EclipseBarFrame.SetPoint(PlayerFrameAlternateManaBar, "BOTTOMLEFT", object.classBar, "BOTTOMLEFT", 12, 0)
					EclipseBarFrame.SetPoint(PlayerFrameAlternateManaBar, "BOTTOMRIGHT", object.classBar, "BOTTOMRIGHT", -12, 0)
					PlayerFrameAlternateManaBar.DefaultBorder:SetPoint("BOTTOMLEFT", 4, 0)
					PlayerFrameAlternateManaBar.DefaultBorder:SetPoint("BOTTOMRIGHT", -4, 0)
					PlayerFrameAlternateManaBar.DefaultBorder:SetTexCoord(0.125, 0.25, 0, 1)
					PlayerFrameAlternateManaBar.DefaultBorderLeft:SetTexCoord(0, 0.125, 0, 1)
					PlayerFrameAlternateManaBar.DefaultBorderRight:SetTexCoord(0.125, 0, 0, 1)
					EclipseBarFrame:SetPoint("BOTTOM", object.classBar, "BOTTOM", 0, -6)
					TotemFrameTotem2:SetPoint("TOP", object.classBar, "TOP", 0, -8)
				end
				updateTotemDurationText()
			else
				if object.classBar.setupBlizzard then
					PlayerFrameAlternateManaBar:ClearAllPoints()
					EclipseBarFrame.SetPoint(PlayerFrameAlternateManaBar, "BOTTOM", UIParent, "TOP", 0, 2000)
					EclipseBarFrame:ClearAllPoints()
					EclipseBarFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
					TotemFrameTotem2:ClearAllPoints()
					TotemFrameTotem2:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				end
				object.classBar.addOn:Show()
				object.classBar.addOn:ClearAllPoints()
				object.classBar.addOn.mana:ClearAllPoints()
				object.classBar.addOn.eclipse:ClearAllPoints()
				object.classBar.addOn.totem:ClearAllPoints()
				local tex = SM:Fetch("statusbar", IUF.db.classBar.texture or "Smooth v2")
				object.classBar.addOn.mana.anchors[1].bar:SetStatusBarTexture(tex)
				object.classBar.addOn.mana.anchors[1].bar:SetStatusBarColor(self.colordb.power[0][1], self.colordb.power[0][2], self.colordb.power[0][3])
				object.classBar.addOn.eclipse.moon:SetTexture(tex)
				object.classBar.addOn.eclipse.sun:SetTexture(tex)
				for _, v in pairs(object.classBar.addOn.totem.anchors) do
					v.bar:SetStatusBarTexture(tex)
				end
				if IUF.db.classBar.pos == "BOTTOM" then
					object.classBar.addOn:SetPoint("TOPLEFT", object.classBar, "TOPLEFT", 0, 0)
					object.classBar.addOn:SetPoint("TOPRIGHT", object.classBar, "TOPRIGHT", 0, 0)
					object.classBar.addOn.mana:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.mana:SetPoint("TOPRIGHT", 0, 0)
					--object.classBar.addOn.eclipse:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.eclipse:SetPoint("TOPLEFT", 0, -1*object.classBar.addOn.mana:GetHeight())
					--object.classBar.addOn.eclipse:SetPoint("TOPRIGHT", 0, 0)
					object.classBar.addOn.eclipse:SetPoint("TOPRIGHT", 0, -1*object.classBar.addOn.mana:GetHeight())
					object.classBar.addOn.totem:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMRIGHT", 0, 0)
				else
					object.classBar.addOn:SetPoint("BOTTOMLEFT", object.classBar, "BOTTOMLEFT", 0, 0)
					object.classBar.addOn:SetPoint("BOTTOMRIGHT", object.classBar, "BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.mana:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.mana:SetPoint("BOTTOMRIGHT", 0, 0)
					--object.classBar.addOn.eclipse:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.eclipse:SetPoint("BOTTOMLEFT", 0, object.classBar.addOn.mana:GetHeight())
					--object.classBar.addOn.eclipse:SetPoint("BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.eclipse:SetPoint("BOTTOMRIGHT", 0, object.classBar.addOn.mana:GetHeight())
					object.classBar.addOn.totem:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPRIGHT", 0, 0)
				end
			end
			updateVisible()
		else
			if object.classBar.setupBlizzard then
				PlayerFrameAlternateManaBar:ClearAllPoints()
				EclipseBarFrame.SetPoint(PlayerFrameAlternateManaBar, "BOTTOM", UIParent, "TOP", 0, 2000)
				EclipseBarFrame:ClearAllPoints()
				EclipseBarFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				TotemFrameTotem2:ClearAllPoints()
				TotemFrameTotem2:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
			end
			object.classBar.addOn:Hide()
		end
	end
elseif playerClass == "DEATHKNIGHT" then
	if RuneFrame:GetParent() == UIParent and select(2, RuneFrame:GetPoint()) == PlayerFrame then
		RuneFrame:SetParent(PlayerFrame)
	end

	local function updateVisible()	-- DEATHKNIGHT
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				if TotemFrame:IsShown() then
					IUF.units.player.classBar:SetHeight(38)
				elseif RuneFrame:IsShown() then
					IUF.units.player.classBar:SetHeight(24)
				else
					IUF.units.player.classBar:SetHeight(0.001)
				end
			else
				if IUF.units.player.classBar.addOn.totem:IsShown() and IUF.units.player.classBar.addOn.bar:IsShown() then
					IUF.units.player.classBar:SetHeight(29)
					IUF.units.player.classBar.addOn:SetHeight(28)
				elseif IUF.units.player.classBar.addOn.totem:IsShown() or IUF.units.player.classBar.addOn.bar:IsShown() then
					IUF.units.player.classBar:SetHeight(15)
					IUF.units.player.classBar.addOn:SetHeight(14)
				else
					IUF.units.player.classBar:SetHeight(0.001)
					IUF.units.player.classBar.addOn:SetHeight(0.001)
				end
			end
		else
			IUF.units.player.classBar:SetHeight(0.001)
			IUF.units.player.classBar.addOn:SetHeight(0.001)
		end
	end

	function IUF:CreateClassBar(object)	-- DEATHKNIGHT
		createClassBar(object)
		object = createAddOnClassBar(object)

		local ipairs = _G.ipairs
		local GetTime = _G.GetTime
		--local GetRuneType = _G.GetRuneType
		local GetRuneCooldown = _G.GetRuneCooldown

		--local runes = { "BLOOD", "UNHOLY", "FROST", "DEATH" }
		--local runeOrder = { 1, 2, 5, 6, 3, 4 }
		local runeOrder = { 1, 2, 3, 4, 5, 6 }
		--[[
		local runeColors = {
			{ 1, 0.25, 0.25 },	-- BLOOD
			{ 0.2, 1, 0.2 },	-- UNHOLY
			{ 0, 0.7, 1 },		-- FROST
			{ 0.8, 0.1, 1 },	-- DEATH
		}
		]]--
		local runeColor = { 0, 0.7, 1 }

		object.bar = CreateFrame("Frame", nil, object)
		object.bar:SetPoint("TOPLEFT", 0, 0)
		object.bar:SetPoint("TOPRIGHT", 0, 0)
		object.bar:SetHeight(14)
		object.bar:SetFrameLevel(object:GetFrameLevel())
		object.bar:Hide()
		setAddOnBorder(object.bar, #runeOrder, true)

		for _, btn in ipairs(object.bar.anchors) do
			btn.bar.flash = CreateFrame("Frame", nil, btn.bar)
			btn.bar.flash:SetFrameLevel(btn.bar:GetFrameLevel())
			btn.bar.flash:SetAllPoints()
			btn.bar.flash.tex = btn.bar.flash:CreateTexture(nil, "OVERLAY")
			btn.bar.flash.tex:SetBlendMode("ADD")
			btn.bar.flash.tex:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
			btn.bar.flash.tex:SetAllPoints()
			btn.bar.flash:Hide()
			btn.bar.texture = btn.bar:GetStatusBarTexture()
		end

		local curTime

		local function runeOnUpdate(bar)
			curTime = GetTime()
			bar:SetValue(curTime)
			bar.text:SetText(secondsToTime(bar.endTime - curTime))
		end

		local function updateRuneCooldown(btn, id)
			local start, duration, runeReady = GetRuneCooldown(id)
			if runeReady then
				if btn.bar:GetScript("OnUpdate") then
					btn.bar:SetScript("OnUpdate", nil)
				end
				btn.bar.endTime = nil
				btn.bar.text:SetText("")
				btn.bar:SetMinMaxValues(0, 1)
				btn.bar:SetValue(1)
				btn.bar.texture:SetAlpha(1)
			else
				IUF:UIFrameFlashStop(btn.bar.flash)
				btn.bar.texture:SetAlpha(0.5)
				btn.bar.endTime = start + duration
				btn.bar:SetMinMaxValues(start, btn.bar.endTime)
				runeOnUpdate(btn.bar)
				if not btn.bar:GetScript("OnUpdate") then
					btn.bar:SetScript("OnUpdate", runeOnUpdate)
				end
			end
			return runeReady
		end

		local function updateRune(btn, id, dontShine)
			--local rune = GetRuneType(id)
			btn:SetAlpha(0.35)
			--if rune then
				--btn:SetVertexColor(unpack(runeColors[rune]))
				btn:SetVertexColor(runeColor[1], runeColor[2], runeColor[3])
				--btn.bar:SetStatusBarColor(unpack(runeColors[rune]))
				btn.bar:SetStatusBarColor(runeColor[1], runeColor[2], runeColor[3])
				--btn.bar.flash.tex:SetVertexColor(unpack(runeColors[rune]))
				btn.bar.flash.tex:SetVertexColor(runeColor[1], runeColor[2], runeColor[3])
				btn.bar.flash.tex:SetAlpha(0.25)
				btn.bar:Show()
				IUF:UIFrameFlashStop(btn.bar.flash)
				btn.bar.flash:Hide()
				updateRuneCooldown(btn, id)
			--else
			--	btn:SeVertexColor(0, 0, 0)
			--	btn.bar:Hide()
			--	if btn.bar:GetScript("OnUpdate") then
			--		btn.bar:SetScript("OnUpdate", nil)
			--	end
			--	--btn.rune = nil
			--end
		end

		object.bar:SetScript("OnEvent", function(self, event, id, isEnergize)
			if event == "RUNE_POWER_UPDATE" then
				if runeOrder[id] then
					if updateRuneCooldown(self.anchors[runeOrder[id]], id) then
						IUF:UIFrameFlash(self.anchors[runeOrder[id]].bar.flash, 0.25, 0.25, 0.5)
					end
				end
			elseif event == "RUNE_TYPE_UPDATE" then
				if runeOrder[id] then
					updateRune(self.anchors[runeOrder[id]], id)
				end
			else
				if UnitHasVehicleUI("player") then
					if self:IsShown() then
						self:Hide()
						updateVisible()
					end
				else
					if not self:IsShown() then
						self:Show()
						updateVisible()
					end
					for rune, id in ipairs(runeOrder) do
						updateRune(self.anchors[rune], id, true)
					end
				end
			end
		end)
		object.bar:RegisterEvent("PLAYER_ENTERING_WORLD")
		object.bar:RegisterEvent("RUNE_POWER_UPDATE")
		object.bar:RegisterEvent("RUNE_TYPE_UPDATE")
		object.bar:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
		object.bar:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")

		createTotem(object, 1, "BOTTOM", updateVisible)
	end

	function IUF:ClassBarSetup(object)	-- DEATHKNIGHT
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				object.classBar.addOn:Hide()
				if not object.classBar.setupBlizzard then
					object.classBar.setupBlizzard = true
					setClassBar(RuneFrame, object, nil, updateVisible)
					setClassBar(TotemFrame, object, 4, updateVisible)
					TotemFrameTotem1:ClearAllPoints()
					TotemFrameTotem2:ClearAllPoints()
					TotemFrameTotem2:SetPoint("LEFT", TotemFrameTotem1, "RIGHT", -4, 0)
				end
				RuneFrame:ClearAllPoints()
				TotemFrameTotem1:ClearAllPoints()
				if IUF.db.classBar.pos == "BOTTOM" then
					RuneFrame:SetPoint("TOP", object.classBar, "TOP", 1, 0)
					TotemFrameTotem1:SetPoint("TOPRIGHT", RuneFrame, "TOPLEFT", 1, 7)
				else
					RuneFrame:SetPoint("BOTTOM", object.classBar, "BOTTOM", 1, 2)
					TotemFrameTotem1:SetPoint("BOTTOMRIGHT", RuneFrame, "BOTTOMLEFT", 1, -7)
				end
				updateTotemDurationText()
			else
				if object.classBar.setupBlizzard then
					TotemFrameTotem1:ClearAllPoints()
					TotemFrameTotem1:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
					RuneFrame:ClearAllPoints()
					RuneFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				end
				object.classBar.addOn:Show()
				object.classBar.addOn:ClearAllPoints()
				object.classBar.addOn.bar:ClearAllPoints()
				object.classBar.addOn.totem:ClearAllPoints()
				local tex = SM:Fetch("statusbar", IUF.db.classBar.texture or "Smooth v2")
				for _, v in pairs(object.classBar.addOn.totem.anchors) do
					v.bar:SetStatusBarTexture(tex)
				end
				for _, v in pairs(object.classBar.addOn.bar.anchors) do
					v:SetTexture(tex)
					v.bar:SetStatusBarTexture(tex)
					v.bar.flash.tex:SetTexture(tex)
				end
				if IUF.db.classBar.pos == "BOTTOM" then
					object.classBar.addOn:SetPoint("TOPLEFT", object.classBar, "TOPLEFT", 0, 0)
					object.classBar.addOn:SetPoint("TOPRIGHT", object.classBar, "TOPRIGHT", 0, 0)
					object.classBar.addOn.bar:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.bar:SetPoint("TOPRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMRIGHT", 0, 0)
				else
					object.classBar.addOn:SetPoint("BOTTOMLEFT", object.classBar, "BOTTOMLEFT", 0, 0)
					object.classBar.addOn:SetPoint("BOTTOMRIGHT", object.classBar, "BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.bar:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.bar:SetPoint("BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPRIGHT", 0, 0)
				end
			end
			updateVisible()
		else
			if object.classBar.setupBlizzard then
				TotemFrameTotem1:ClearAllPoints()
				TotemFrameTotem1:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				RuneFrame:ClearAllPoints()
				RuneFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
			end
			object.classBar.addOn:Hide()
		end
	end
elseif playerClass == "PRIEST" then
	local function updateVisible()	-- PRIEST
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				if TotemFrame:IsShown() then
					IUF.units.player.classBar:SetHeight(42)
				elseif PriestBarFrame:IsShown() then
					IUF.units.player.classBar:SetHeight(34)
				else
					IUF.units.player.classBar:SetHeight(0.001)
				end
			else
				if IUF.units.player.classBar.addOn.totem:IsShown() then
					IUF.units.player.classBar:SetHeight(15)
					IUF.units.player.classBar.addOn:SetHeight(14)
				else
					IUF.units.player.classBar:SetHeight(0.001)
					IUF.units.player.classBar.addOn:SetHeight(0.001)
				end
			end
		else
			IUF.units.player.classBar:SetHeight(0.001)
			IUF.units.player.classBar.addOn:SetHeight(0.001)
		end
	end

	function IUF:CreateClassBar(object)	-- PRIEST
		createClassBar(object)
		object = createAddOnClassBar(object)

		local UnitPower = _G.UnitPower
		local UnitLevel = _G.UnitLevel
		local UnitHasVehicleUI = _G.UnitHasVehicleUI

		createTotem(object, MAX_TOTEMS, "BOTTOM", updateVisible)
	end

	function IUF:ClassBarSetup(object)	-- PRIEST
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				object.classBar.addOn:Hide()
				if not object.classBar.setupBlizzard then
					object.classBar.setupBlizzard = true
					setClassBar(PriestBarFrame, object, nil, updateVisible)
					setClassBar(TotemFrame, object, 4, updateVisible)
					for i = 1, select("#", PriestBarFrame:GetRegions()) do
						PriestBarFrame.background = select(i, PriestBarFrame:GetRegions())
						if PriestBarFrame.background:GetObjectType() == "Texture" and PriestBarFrame.background:GetDrawLayer() == "BACKGROUND" then
							break
						else
							PriestBarFrame.background = nil
						end
					end
				end
				PriestBarFrame:ClearAllPoints()
				TotemFrameTotem2:ClearAllPoints()
				if PriestBarFrame.background then
					PriestBarFrame.background:ClearAllPoints()
					if IUF.db.classBar.pos == "BOTTOM" then
						TotemFrameTotem2:SetPoint("BOTTOM", object.classBar, "BOTTOM", -19, 9)
						PriestBarFrame:SetPoint("TOP", object.classBar, "TOP", 0, 2)
						PriestBarFrame.background:SetAllPoints()
						PriestBarFrame.background:SetTexCoord(0.00390625, 0.62500000, 0.00781250, 0.42968750)
						for i = 1, PRIEST_BAR_NUM_ORBS do
							_G["PriestBarFrameOrb"..i].highlight:ClearAllPoints()
							_G["PriestBarFrameOrb"..i].highlight:SetPoint("TOP", 0, -1)
							_G["PriestBarFrameOrb"..i].highlight:SetTexCoord(0.00390625, 0.29296875, 0.44531250, 0.78906250)
						end
					else
						TotemFrameTotem2:SetPoint("TOP", object.classBar, "TOP", -19, -8)
						PriestBarFrame:SetPoint("BOTTOM", object.classBar, "BOTTOM", 0, -18)
						PriestBarFrame.background:SetPoint("TOPLEFT", 0, 16)
						PriestBarFrame.background:SetPoint("BOTTOMRIGHT", 0, 16)
						PriestBarFrame.background:SetTexCoord(0.00390625, 0.62500000, 0.42968750, 0.00781250)
						for i = 1, PRIEST_BAR_NUM_ORBS do
							_G["PriestBarFrameOrb"..i].highlight:ClearAllPoints()
							_G["PriestBarFrameOrb"..i].highlight:SetPoint("BOTTOM", 0, 1)
							_G["PriestBarFrameOrb"..i].highlight:SetTexCoord(0.00390625, 0.29296875, 0.78906250, 0.44531250)
						end
					end
				elseif IUF.db.classBar.pos == "BOTTOM" then
					TotemFrameTotem2:SetPoint("BOTTOM", object.classBar, "BOTTOM", -19, 9)
					PriestBarFrame:SetPoint("TOP", object.classBar, "TOP", 0, 2)
				else
					TotemFrameTotem2:SetPoint("TOP", object.classBar, "TOP", -19, -8)
					PriestBarFrame:SetPoint("BOTTOM", object.classBar, "BOTTOM", 0, -18)
				end
				updateTotemDurationText()
			else
				if object.classBar.setupBlizzard then
					TotemFrameTotem2:ClearAllPoints()
					TotemFrameTotem2:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
					PriestBarFrame:ClearAllPoints()
					PriestBarFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				end
				object.classBar.addOn:Show()
				object.classBar.addOn:ClearAllPoints()
				object.classBar.addOn.totem:ClearAllPoints()
				local tex = SM:Fetch("statusbar", IUF.db.classBar.texture or "Smooth v2")
				for _, v in pairs(object.classBar.addOn.totem.anchors) do
					v.bar:SetStatusBarTexture(tex)
				end
				if IUF.db.classBar.pos == "BOTTOM" then
					object.classBar.addOn:SetPoint("TOPLEFT", object.classBar, "TOPLEFT", 0, 0)
					object.classBar.addOn:SetPoint("TOPRIGHT", object.classBar, "TOPRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMRIGHT", 0, 0)
				else
					object.classBar.addOn:SetPoint("BOTTOMLEFT", object.classBar, "BOTTOMLEFT", 0, 0)
					object.classBar.addOn:SetPoint("BOTTOMRIGHT", object.classBar, "BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPRIGHT", 0, 0)
				end
			end
			updateVisible()
		else
			if object.classBar.setupBlizzard then
				TotemFrameTotem2:ClearAllPoints()
				TotemFrameTotem2:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				PriestBarFrame:ClearAllPoints()
				PriestBarFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
			end
			object.classBar.addOn:Hide()
		end
	end
elseif playerClass == "PALADIN" then
	local function updateVisible()	-- PALADIN
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				if TotemFrame:IsShown() then
					IUF.units.player.classBar:SetHeight(40)
				elseif PaladinPowerBar:IsShown() then
					IUF.units.player.classBar:SetHeight(38)
				else
					IUF.units.player.classBar:SetHeight(0.001)
				end
			else
				if IUF.units.player.classBar.addOn.totem:IsShown() and IUF.units.player.classBar.addOn.bar:IsShown() then
					IUF.units.player.classBar:SetHeight(29)
					IUF.units.player.classBar.addOn:SetHeight(28)
				elseif IUF.units.player.classBar.addOn.totem:IsShown() or IUF.units.player.classBar.addOn.bar:IsShown() then
					IUF.units.player.classBar:SetHeight(15)
					IUF.units.player.classBar.addOn:SetHeight(14)
				else
					IUF.units.player.classBar:SetHeight(0.001)
					IUF.units.player.classBar.addOn:SetHeight(0.001)
				end
			end
		else
			IUF.units.player.classBar:SetHeight(0.001)
			IUF.units.player.classBar.addOn:SetHeight(0.001)
		end
	end

	function IUF:CreateClassBar(object)	-- PALADIN
		createClassBar(object)
		object = createAddOnClassBar(object)

		local UnitPower = _G.UnitPower
		local UnitLevel = _G.UnitLevel
		local UnitHasVehicleUI = _G.UnitHasVehicleUI

		object.bar = CreateFrame("Frame", nil, object)
		object.bar:SetPoint("TOPLEFT", 0, 0)
		object.bar:SetPoint("TOPRIGHT", 0, 0)
		object.bar:SetHeight(14)
		object.bar:SetFrameLevel(object:GetFrameLevel())
		setAddOnBorder(object.bar, 5)

		for _, btn in ipairs(object.bar.anchors) do
			btn:SetAlpha(0)
			btn:SetVertexColor(0.95, 0.9, 0.2)
			btn.flash = object.bar:CreateTexture(nil, "BORDER")
			btn.flash:SetVertexColor(0.95, 0.9, 0.2)
			btn.flash:SetBlendMode("ADD")
			btn.flash:SetAllPoints(btn)
			btn.flash:Hide()
		end

		object.bar:SetScript("OnEvent", function(self, event, _, powerType)
			if event == "UNIT_POWER_FREQUENT" or event == "UNIT_DISPLAYPOWER" then
				if powerType == "HOLY_POWER" or event == "UNIT_DISPLAYPOWER" then
					self.holy = UnitPower("player", SPELL_POWER_HOLY_POWER)
					self.holyMax = UnitPowerMax("player", SPELL_POWER_HOLY_POWER)
					if self.num ~= self.holyMax then
						setAddOnBorder(self, self.holyMax)
					end
					for i = 1, self.holy do
						self.anchors[i]:SetAlpha(1)
					end
					for i = self.prevHoly + 1, self.holy do
						IUF:UIFrameFlash(self.anchors[i].flash, 0.25, 0.25, 0.5)
					end
					for i = self.holy + 1, self.holyMax do
						self.anchors[i]:SetAlpha(0)
						IUF:UIFrameFlashStop(self.anchors[i].flash)
					end
					self.prevHoly = self.holy
				end
			elseif UnitLevel("player") >= PALADINPOWERBAR_SHOW_LEVEL and not UnitHasVehicleUI("player") then
				if GetSpecialization() == SPEC_PALADIN_RETRIBUTION then
					if not self:IsShown() then
						self:Show()
						self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
						self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
						updateVisible()
					end
					self.prevHoly = UnitPower("player", SPELL_POWER_HOLY_POWER)
					self:GetScript("OnEvent")(self, "UNIT_POWER_FREQUENT", nil, "HOLY_POWER")
				else
					self:UnregisterEvent("UNIT_POWER_FREQUENT")
					self:UnregisterEvent("UNIT_DISPLAYPOWER")
					self:Hide()
					updateVisible()
				end
			elseif self:IsShown() then
				self:Hide()
				self:UnregisterEvent("UNIT_POWER_FREQUENT")
				self:UnregisterEvent("UNIT_DISPLAYPOWER")
				updateVisible()
			end
		end)
		object.bar:RegisterEvent("PLAYER_ENTERING_WORLD")
		object.bar:RegisterEvent("PLAYER_LEVEL_UP")
		object.bar:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
		object.bar:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
		object.bar:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
		object.bar:Hide()

		createTotem(object, 1, "BOTTOM", updateVisible)
	end

	function IUF:ClassBarSetup(object)	-- PALADIN
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				object.classBar.addOn:Hide()
				if not object.classBar.setupBlizzard then
					object.classBar.setupBlizzard = true
					setClassBar(PaladinPowerBar, object, nil, updateVisible)
					setClassBar(TotemFrame, object, 4, updateVisible)
					TotemFrameTotem1:ClearAllPoints()
					TotemFrameTotem2:ClearAllPoints()
					TotemFrameTotem2:SetPoint("LEFT", TotemFrameTotem1, "RIGHT", -4, 0)
				end
				TotemFrameTotem1:ClearAllPoints()
				PaladinPowerBar:ClearAllPoints()
				PaladinPowerBarBG:ClearAllPoints()
				PaladinPowerBarBankBG:ClearAllPoints()
				PaladinPowerBarGlowBGTexture:ClearAllPoints()
				PaladinPowerBarRune1:ClearAllPoints()
				PaladinPowerBarRune4:ClearAllPoints()
				PaladinPowerBarRune5:ClearAllPoints()
				if IUF.db.classBar.pos == "BOTTOM" then
					TotemFrameTotem1:SetPoint("RIGHT", PaladinPowerBar, "LEFT", 20, 0)
					PaladinPowerBar:ClearAllPoints()
					PaladinPowerBar:SetPoint("TOP", object.classBar, "TOP", 0, 7)
					PaladinPowerBarBG:SetPoint("TOP", 0, 0)
					PaladinPowerBarBG:SetTexCoord(0.00390625, 0.53515625, 0.00781250, 0.31250000)
					PaladinPowerBarBankBG:SetPoint("TOP", 0, -29)
					PaladinPowerBarBankBG:SetTexCoord(0.00390625, 0.27343750, 0.64843750, 0.77343750)
					PaladinPowerBarGlowBGTexture:SetPoint("TOP", 0, 0)
					PaladinPowerBarGlowBGTexture:SetTexCoord(0.00390625, 0.53515625, 0.32812500, 0.63281250)
					PaladinPowerBarRune1:SetPoint("TOPLEFT", 21, -11)
					PaladinPowerBarRune4:SetPoint("TOPLEFT", 67, -28)
					PaladinPowerBarRune5:SetPoint("TOPLEFT", 43, -28)
					PaladinPowerBarRune1Texture:SetTexCoord(0.00390625, 0.14453125, 0.78906250, 0.96093750)
					PaladinPowerBarRune2Texture:SetTexCoord(0.15234375, 0.27343750, 0.78906250, 0.92187500)
					PaladinPowerBarRune3Texture:SetTexCoord(0.28125000, 0.38671875, 0.64843750, 0.81250000)
					PaladinPowerBarRune4Texture:SetTexCoord(0.28125000, 0.38671875, 0.82812500, 0.92187500)
					PaladinPowerBarRune5Texture:SetTexCoord(0.39453125, 0.49609375, 0.64843750, 0.74218750)
				else
					TotemFrameTotem1:SetPoint("RIGHT", PaladinPowerBar, "LEFT", 20, 0)
					PaladinPowerBar:SetPoint("BOTTOM", object.classBar, "BOTTOM", 0, -7)
					PaladinPowerBarBG:SetPoint("BOTTOM", 0, 0)
					PaladinPowerBarBG:SetTexCoord(0.00390625, 0.53515625, 0.31250000, 0.00781250)
					PaladinPowerBarBankBG:SetPoint("BOTTOM", 0, 29)
					PaladinPowerBarBankBG:SetTexCoord(0.00390625, 0.27343750, 0.77343750, 0.64843750)
					PaladinPowerBarGlowBGTexture:SetPoint("BOTTOM", 0, 0)
					PaladinPowerBarGlowBGTexture:SetTexCoord(0.00390625, 0.53515625, 0.63281250, 0.32812500)
					PaladinPowerBarRune1:SetPoint("BOTTOMLEFT", 21, 11)
					PaladinPowerBarRune4:SetPoint("BOTTOMLEFT", 67, 28)
					PaladinPowerBarRune5:SetPoint("BOTTOMLEFT", 43, 28)
					PaladinPowerBarRune1Texture:SetTexCoord(0.00390625, 0.14453125, 0.96093750, 0.78906250)
					PaladinPowerBarRune2Texture:SetTexCoord(0.15234375, 0.27343750, 0.92187500, 0.78906250)
					PaladinPowerBarRune3Texture:SetTexCoord(0.28125000, 0.38671875, 0.81250000, 0.64843750)
					PaladinPowerBarRune4Texture:SetTexCoord(0.28125000, 0.38671875, 0.92187500, 0.82812500)
					PaladinPowerBarRune5Texture:SetTexCoord(0.39453125, 0.49609375, 0.74218750, 0.64843750)
				end
				updateTotemDurationText()
			else
				if object.classBar.setupBlizzard then
					TotemFrameTotem2:ClearAllPoints()
					TotemFrameTotem2:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
					PaladinPowerBar:ClearAllPoints()
					PaladinPowerBar:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				end
				object.classBar.addOn:Show()
				object.classBar.addOn:ClearAllPoints()
				object.classBar.addOn.bar:ClearAllPoints()
				object.classBar.addOn.totem:ClearAllPoints()
				local tex = SM:Fetch("statusbar", IUF.db.classBar.texture or "Smooth v2")
				for _, v in pairs(object.classBar.addOn.totem.anchors) do
					v.bar:SetStatusBarTexture(tex)
				end
				for _, v in pairs(object.classBar.addOn.bar.anchors) do
					v:SetTexture(tex)
					v.flash:SetTexture(tex)
				end
				if IUF.db.classBar.pos == "BOTTOM" then
					object.classBar.addOn:SetPoint("TOPLEFT", object.classBar, "TOPLEFT", 0, 0)
					object.classBar.addOn:SetPoint("TOPRIGHT", object.classBar, "TOPRIGHT", 0, 0)
					object.classBar.addOn.bar:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.bar:SetPoint("TOPRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMRIGHT", 0, 0)
				else
					object.classBar.addOn:SetPoint("BOTTOMLEFT", object.classBar, "BOTTOMLEFT", 0, 0)
					object.classBar.addOn:SetPoint("BOTTOMRIGHT", object.classBar, "BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.bar:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.bar:SetPoint("BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPRIGHT", 0, 0)
				end
			end
			updateVisible()
		else
			if object.classBar.setupBlizzard then
				TotemFrameTotem2:ClearAllPoints()
				TotemFrameTotem2:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				PaladinPowerBar:ClearAllPoints()
				PaladinPowerBar:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
			end
			object.classBar.addOn:Hide()
		end
	end
elseif playerClass == "MONK" then
	local function updateVisible()	-- MONK
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				if TotemFrame:IsShown() then
					IUF.units.player.classBar:SetHeight(MonkHarmonyBar:IsShown() and 63 or 42)
				else
					IUF.units.player.classBar:SetHeight(MonkHarmonyBar:IsShown() and 30 or 0.001)
				end
			else
				local h = 0
				if IUF.units.player.classBar.addOn.mana:IsShown() then
					h = h + 14
				end
				if IUF.units.player.classBar.addOn.bar:IsShown() then
					h = h + 14
				end
				if IUF.units.player.classBar.addOn.totem:IsShown() then
					h = h + 14
				end
				if h > 0 then
					IUF.units.player.classBar:SetHeight(h + 1)
					IUF.units.player.classBar.addOn:SetHeight(h)
				else
					IUF.units.player.classBar:SetHeight(0.001)
					IUF.units.player.classBar.addOn:SetHeight(0.001)
				end
			end
		else
			IUF.units.player.classBar:SetHeight(0.001)
			IUF.units.player.classBar.addOn:SetHeight(0.001)
		end
	end

	function IUF:CreateClassBar(object)	-- MONK
		createClassBar(object)
		object = createAddOnClassBar(object)

		local UnitPower = _G.UnitPower
		local UnitPowerMax = _G.UnitPowerMax
		local UnitPowerType = _G.UnitPowerType
		local UnitHasVehicleUI = _G.UnitHasVehicleUI

		object.mana = CreateFrame("Frame", nil, object)
		object.mana:SetPoint("TOPLEFT", 0, 0)
		object.mana:SetPoint("TOPRIGHT", 0, 0)
		object.mana:SetHeight(14)
		object.mana:SetFrameLevel(object:GetFrameLevel())
		setAddOnBorder(object.mana, 1, true)
		object.mana.text = object.mana:CreateFontString(nil, "OVERLAY", "FriendsFont_Small")
		object.mana.text:SetPoint("CENTER", 0, 0)
		object.mana:SetScript("OnEvent", function(self, event, _, powerType)
			if event == "UNIT_POWER_FREQUENT" or event == "UNIT_POWER" then
				if powerType == "MANA" then
					self.cur = UnitPower("player", 0)
					self.anchors[1].bar:SetValue(self.cur)
					IUF:SetStatusBarValue(self.text, 2, self.cur, self.max)
				end
			elseif event == "UNIT_MAXPOWER" then
				if powerType == "MANA" then
					self.max, self.cur = UnitPowerMax("player", 0), UnitPower("player", 0)
					self.anchors[1].bar:SetMinMaxValues(0, self.max)
					self.anchors[1].bar:SetValue(self.cur)
					IUF:SetStatusBarValue(self.text, 2, self.cur, self.max)
				end
			elseif GetSpecialization() == SPEC_MONK_MISTWEAVER and UnitPowerType("player") ~= 0 and not UnitHasVehicleUI("player") then
				if not self:IsShown() then
					self:Show()
					self:SetHeight(14)
					self:SetAlpha(1)
					self:RegisterUnitEvent("UNIT_MAXPOWER", "player")
					self:RegisterUnitEvent("UNIT_POWER", "player")
					self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
					updateVisible()
				end
				self:GetScript("OnEvent")(self, "UNIT_MAXPOWER", nil, "MANA")
			elseif self:IsShown() then
				self:Hide()
				self:SetHeight(0.001)
				self:SetAlpha(0)
				self:UnregisterEvent("UNIT_MAXPOWER")
				self:UnregisterEvent("UNIT_POWER")
				self:UnregisterEvent("UNIT_POWER_FREQUENT")
				updateVisible()
			end
		end)
		object.mana:RegisterEvent("PLAYER_ENTERING_WORLD")
		object.mana:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
		object.mana:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
		object.mana:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
		object.mana:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
		object.mana:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
		object.mana:SetAlpha(0)
		object.mana:SetHeight(0.001)
		object.mana:Hide()

		object.bar = CreateFrame("Frame", nil, object)
		object.bar:SetPoint("TOPLEFT", 0, 0)
		object.bar:SetPoint("TOPRIGHT", 0, 0)
		object.bar:SetHeight(14)
		object.bar:SetFrameLevel(object:GetFrameLevel())
		setAddOnBorder(object.bar, 5)

		for _, btn in ipairs(object.bar.anchors) do
			btn:SetAlpha(0)
			btn:SetVertexColor(0.71, 1, 0.92)
			btn.flash = object.bar:CreateTexture(nil, "BORDER")
			btn.flash:SetVertexColor(0.71, 1, 0.92)
			btn.flash:SetBlendMode("ADD")
			btn.flash:SetAllPoints(btn)
			btn.flash:Hide()
		end

		local SPELL_POWER_CHI = SPELL_POWER_CHI or SPELL_POWER_LIGHT_FORCE

		local function updateChi(self)
			self.chi = UnitPower("player", SPELL_POWER_CHI)
			self.chiMax = UnitPowerMax("player", SPELL_POWER_CHI)
			if self.num ~= self.chiMax then
				setAddOnBorder(self, self.chiMax)
			end
			for i = 1, self.chi do
				self.anchors[i]:SetAlpha(1)
			end
			for i = self.prevChi + 1, self.chi do
				IUF:UIFrameFlash(self.anchors[i].flash, 0.25, 0.25, 0.5)
			end
			for i = self.chi + 1, self.chiMax do
				self.anchors[i]:SetAlpha(0)
				IUF:UIFrameFlashStop(self.anchors[i].flash)
			end
			self.prevChi = self.chi
		end

		object.bar:SetScript("OnEvent", function(self, event, _, powerType)
			if event == "UNIT_POWER_FREQUENT" then
				if powerType == "CHI" then
					updateChi(self)
				end
			elseif event == "UNIT_DISPLAYPOWER" or event == "PLAYER_TALENT_UPDATE" then
				self.prevChi = UnitPower("player", chi)
				updateChi(self)
			elseif not UnitHasVehicleUI("player") then
				if (GetSpecialization() == SPEC_MONK_WINDWALKER) then
					if not self:IsShown() then
						self:Show()
						self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
						self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
						updateVisible()
					end
					self.prevChi = UnitPower("player", chi)
					updateChi(self)
				else
					self:UnregisterEvent("UNIT_POWER_FREQUENT")
					self:UnregisterEvent("UNIT_DISPLAYPOWER")
					self:Hide()
					updateVisible()
				end
			elseif self:IsShown() then
				self:Hide()
				self:UnregisterEvent("UNIT_POWER_FREQUENT")
				self:UnregisterEvent("UNIT_DISPLAYPOWER")
				updateVisible()
			end
		end)
		object.bar:RegisterEvent("PLAYER_ENTERING_WORLD")
		object.bar:RegisterEvent("PLAYER_TALENT_UPDATE")
		object.bar:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
		object.bar:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
		object.bar:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
		object.bar:Hide()

		createTotem(object, 1, "BOTTOM", updateVisible)
	end

	function IUF:ClassBarSetup(object)	-- MONK
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				object.classBar.addOn:Hide()
				if not object.classBar.setupBlizzard then
					object.classBar.setupBlizzard = true
					setClassBar(MonkHarmonyBar, object, nil, updateVisible)
					setClassBar(PlayerFrameAlternateManaBar, object, 4, updateVisible)
					PlayerFrameAlternateManaBar:SetScript("OnMouseUp", nil)
					PlayerFrameAlternateManaBar.SetPoint = PlayerFrameAlternateManaBar.GetPoint
					setClassBar(TotemFrame, object, 5, updateVisible)
					for i = 1, select("#", MonkHarmonyBar:GetRegions()) do
						MonkHarmonyBar.hasBackground = select(i, MonkHarmonyBar:GetRegions())
						if MonkHarmonyBar.hasBackground:GetObjectType() == "Texture" and MonkHarmonyBar.hasBackground:GetName() == "MonkHarmonyBarGlow" then
							if MonkHarmonyBar.hasBackground:GetDrawLayer() == "BACKGROUND" then
								MonkHarmonyBar.backgroundShadow = MonkHarmonyBar.hasBackground
							elseif MonkHarmonyBar.hasBackground:GetDrawLayer() == "BORDER" then
								MonkHarmonyBar.background = MonkHarmonyBar.hasBackground
							end
						end
					end
					MonkHarmonyBar.hasBackground = (MonkHarmonyBar.background and MonkHarmonyBar.backgroundShadow) and true or nil
				end
				MonkHarmonyBar:ClearAllPoints()
				PlayerFrameAlternateManaBar:ClearAllPoints()
				PlayerFrameAlternateManaBar:SetStatusBarTexture(SM:Fetch("statusbar", IUF.db.classBar.texture or "Smooth v2"))
				PlayerFrameAlternateManaBar:SetStatusBarColor(self.colordb.power[0][1], self.colordb.power[0][2], self.colordb.power[0][3])
				TotemFrameTotem2:ClearAllPoints()
				if IUF.db.classBar.pos == "BOTTOM" then
					TotemFrameTotem2:SetPoint("BOTTOM", object.classBar, "BOTTOM", -19, 9)
					MonkHarmonyBar:SetPoint("TOP", object.classBar, "TOP", 0, 20)
					PlayerFrameAlternateManaBar:ClearAllPoints()
					MonkHarmonyBar.SetPoint(PlayerFrameAlternateManaBar, "BOTTOM", MonkHarmonyBar, "BOTTOM", 0, 10)
					if MonkHarmonyBar.hasBackground then
						MonkHarmonyBar.background:SetTexCoord(0.00390625, 0.53515625, 0.35937500, 0.69531250)
						MonkHarmonyBar.backgroundShadow:SetTexCoord(0.00390625, 0.53515625, 0.00781250, 0.34375000)
					end
				else
					TotemFrameTotem2:SetPoint("TOP", object.classBar, "TOP", -19, -8)
					MonkHarmonyBar:SetPoint("BOTTOM", object.classBar, "BOTTOM", 0, -20)
					PlayerFrameAlternateManaBar:ClearAllPoints()
					MonkHarmonyBar.SetPoint(PlayerFrameAlternateManaBar, "TOP", MonkHarmonyBar, "TOP", 0, -10)
					if MonkHarmonyBar.hasBackground then
						MonkHarmonyBar.background:SetTexCoord(0.00390625, 0.53515625, 0.69531250, 0.35937500)
						MonkHarmonyBar.backgroundShadow:SetTexCoord(0.00390625, 0.53515625, 0.34375000, 0.00781250)
					end
				end
				updateTotemDurationText()
			else
				if object.classBar.setupBlizzard then
					TotemFrameTotem2:ClearAllPoints()
					TotemFrameTotem2:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
					MonkHarmonyBar:ClearAllPoints()
					MonkHarmonyBar:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
					PlayerFrameAlternateManaBar:ClearAllPoints()
					MonkHarmonyBar.SetPoint(PlayerFrameAlternateManaBar, "BOTTOM", UIParent, "TOP", 0, 2000)
				end
				object.classBar.addOn:Show()
				object.classBar.addOn:ClearAllPoints()
				object.classBar.addOn.mana:ClearAllPoints()
				object.classBar.addOn.bar:ClearAllPoints()
				object.classBar.addOn.totem:ClearAllPoints()
				local tex = SM:Fetch("statusbar", IUF.db.classBar.texture or "Smooth v2")
				object.classBar.addOn.mana.anchors[1].bar:SetStatusBarTexture(tex)
				object.classBar.addOn.mana.anchors[1].bar:SetStatusBarColor(self.colordb.power[0][1], self.colordb.power[0][2], self.colordb.power[0][3])
				for _, v in pairs(object.classBar.addOn.totem.anchors) do
					v.bar:SetStatusBarTexture(tex)
				end
				for _, v in pairs(object.classBar.addOn.bar.anchors) do
					v:SetTexture(tex)
					v.flash:SetTexture(tex)
				end
				if IUF.db.classBar.pos == "BOTTOM" then
					object.classBar.addOn:SetPoint("TOPLEFT", object.classBar, "TOPLEFT", 0, 0)
					object.classBar.addOn:SetPoint("TOPRIGHT", object.classBar, "TOPRIGHT", 0, 0)
					object.classBar.addOn.mana:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.mana:SetPoint("TOPRIGHT", 0, 0)
					object.classBar.addOn.bar:SetPoint("TOPLEFT", object.classBar.addOn.mana, "BOTTOMLEFT", 0, 0)
					object.classBar.addOn.bar:SetPoint("TOPRIGHT", object.classBar.addOn.mana, "BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMRIGHT", 0, 0)
				else
					object.classBar.addOn:SetPoint("BOTTOMLEFT", object.classBar, "BOTTOMLEFT", 0, 0)
					object.classBar.addOn:SetPoint("BOTTOMRIGHT", object.classBar, "BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.mana:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.mana:SetPoint("BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.bar:SetPoint("BOTTOMLEFT", object.classBar.addOn.mana, "TOPLEFT", 0, 0)
					object.classBar.addOn.bar:SetPoint("BOTTOMRIGHT", object.classBar.addOn.mana, "TOPRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPRIGHT", 0, 0)
				end
			end
			updateVisible()
		else
			if object.classBar.setupBlizzard then
				TotemFrameTotem2:ClearAllPoints()
				TotemFrameTotem2:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				MonkHarmonyBar:ClearAllPoints()
				MonkHarmonyBar:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				PlayerFrameAlternateManaBar:ClearAllPoints()
				MonkHarmonyBar.SetPoint(PlayerFrameAlternateManaBar, "BOTTOM", UIParent, "TOP", 0, 2000)
			end
			object.classBar.addOn:Hide()
		end
	end
elseif playerClass == "WARLOCK" then
	local function updateVisible()	-- WARLOCK
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				if TotemFrame:IsShown() then
					if WarlockPowerFrame:IsShown() then
						IUF.units.player.classBar:SetHeight(64)
					else
						IUF.units.player.classBar:SetHeight(40)
					end
				elseif WarlockPowerFrame:IsShown() then
					IUF.units.player.classBar:SetHeight(28)
				else
					IUF.units.player.classBar:SetHeight(0.001)
				end
			elseif IUF.units.player.classBar.addOn.soulShard:IsShown() then
				if IUF.units.player.classBar.addOn.totem:IsShown() then
					IUF.units.player.classBar:SetHeight(29)
					IUF.units.player.classBar.addOn:SetHeight(28)
				else
					IUF.units.player.classBar:SetHeight(15)
					IUF.units.player.classBar.addOn:SetHeight(14)
				end
			elseif IUF.units.player.classBar.addOn.totem:IsShown() then
					IUF.units.player.classBar:SetHeight(15)
					IUF.units.player.classBar.addOn:SetHeight(14)
			else
				IUF.units.player.classBar:SetHeight(0.001)
				IUF.units.player.classBar.addOn:SetHeight(0.001)
			end
		else
			IUF.units.player.classBar:SetHeight(0.001)
			IUF.units.player.classBar.addOn:SetHeight(0.001)
		end
	end

	function IUF:CreateClassBar(object)	-- WARLOCK
		createClassBar(object)
		object = createAddOnClassBar(object)

		local GetSpecialization = _G.GetSpecialization
		local UnitPower = _G.UnitPower
		local UnitPowerMax = _G.UnitPowerMax
		local UnitBuff = _G.UnitBuff
		local IsPlayerSpell = _G.IsPlayerSpell
		local UnitHasVehicleUI = _G.UnitHasVehicleUI

		object.soulShard = CreateFrame("Frame", nil, object)
		object.soulShard:SetPoint("TOPLEFT", 0, 0)
		object.soulShard:SetPoint("TOPRIGHT", 0, 0)
		object.soulShard:SetHeight(14)
		object.soulShard:SetFrameLevel(object:GetFrameLevel())
		setAddOnBorder(object.soulShard, 5)

		for _, btn in ipairs(object.soulShard.anchors) do
			btn:SetAlpha(0)
			btn:SetVertexColor(0.62, 0.22, 0.76)
			btn.flash = object.soulShard:CreateTexture(nil, "BORDER")
			btn.flash:SetVertexColor(0.62, 0.22, 0.76)
			btn.flash:SetBlendMode("ADD")
			btn.flash:SetAllPoints(btn)
			btn.flash:Hide()
		end

		object.soulShard:SetScript("OnEvent", function(self, event, _, powerType)
			if event == "UNIT_POWER_FREQUENT" or event == "UNIT_DISPLAYPOWER" then
				if powerType == "SOUL_SHARDS" or event == "UNIT_DISPLAYPOWER" then
					self.value = UnitPower("player", SPELL_POWER_SOUL_SHARDS)
					self.max = UnitPowerMax("player", SPELL_POWER_SOUL_SHARDS)
					if self.num ~= self.max then
						setAddOnBorder(self, self.max)
					end
					for i = 1, self.value do
						self.anchors[i]:SetAlpha(1)
					end
					for i = self.prev + 1, self.value do
						IUF:UIFrameFlash(self.anchors[i].flash, 0.25, 0.25, 0.5)
					end
					for i = self.value + 1, self.max do
						self.anchors[i]:SetAlpha(0)
						IUF:UIFrameFlashStop(self.anchors[i].flash)
					end
					self.prev = self.value
				end
			elseif (not UnitHasVehicleUI("player")) then
				if not self:IsShown() then
					self:Show()
					self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
					self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
					updateVisible()
				end
				self.prev = UnitPower("player", SPELL_POWER_SOUL_SHARDS)
				self:GetScript("OnEvent")(self, "UNIT_DISPLAYPOWER")
			elseif self:IsShown() then
				self:Hide()
				self:UnregisterEvent("UNIT_POWER_FREQUENT")
				self:UnregisterEvent("UNIT_DISPLAYPOWER")
				updateVisible()
			end
		end)
		object.soulShard:RegisterEvent("PLAYER_ENTERING_WORLD")
		object.soulShard:RegisterEvent("PLAYER_TALENT_UPDATE")
		object.soulShard:RegisterEvent("SPELLS_CHANGED")
		object.soulShard:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
		object.soulShard:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
		object.soulShard:Hide()

		createTotem(object, MAX_TOTEMS, "BOTTOM", updateVisible)
	end

	function IUF:ClassBarSetup(object)	-- WARLOCK
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				object.classBar.addOn:Hide()
				if not object.classBar.setupBlizzard then
					object.classBar.setupBlizzard = true
					setClassBar(WarlockPowerFrame, object, nil, updateVisible)
					setClassBar(TotemFrame, object, 4, updateVisible)
					local shard, shardBorder
					for i = 1, 4 do
						shard = _G["ShardBarFrameShard"..i]
						for j = 1, select("#", shard:GetRegions()) do
							shardBorder = select(j, shard:GetRegions())
							if shardBorder:GetObjectType() == "Texture" and shardBorder:GetDrawLayer() == "BORDER" then
								shard.shardBorder = shardBorder
								break
							end
						end
					end
				end
				TotemFrameTotem2:ClearAllPoints()
				WarlockPowerFrame:ClearAllPoints()
				if IUF.db.classBar.pos == "BOTTOM" then
					TotemFrameTotem2:SetPoint("BOTTOM", object.classBar, "BOTTOM", -19, 9)
					WarlockPowerFrame:SetPoint("TOP", object.classBar, "TOP", 0, -1)
					local shard
					for i = 1, 4 do
						shard = _G["ShardBarFrameShard"..i]
						shard.shardGlow:ClearAllPoints()
						shard.shardGlow:SetPoint("TOPLEFT", -2, 1)
						shard.shardSmokeA:ClearAllPoints()
						shard.shardSmokeA:SetPoint("TOPLEFT", -8, 5)
						shard.shardFill:ClearAllPoints()
						shard.shardFill:SetPoint("TOPLEFT" , 3, -2)
						shard.shardBorder:ClearAllPoints()
						shard.shardBorder:SetPoint("TOPLEFT", -5, 3)
						shard.shardGlow:SetTexCoord(0.01562500, 0.42187500, 0.14843750, 0.32812500)
						shard.shardSmokeA:SetTexCoord(0.01562500, 0.51562500, 0.34375000, 0.59375000)
						shard.shardSmokeB:SetTexCoord(0.51562500, 0.01562500, 0.34375000, 0.59375000)
						shard.shardFill:SetTexCoord(0.01562500, 0.28125000, 0.00781250, 0.13281250)
						shard.shardBorder:SetTexCoord(0.01562500, 0.82812500, 0.60937500, 0.83593750)
					end
				else
					TotemFrameTotem2:SetPoint("TOP", object.classBar, "TOP", -19, -8)
					WarlockPowerFrame:SetPoint("BOTTOM", object.classBar, "BOTTOM", 0, 1)
					local shard
					for i = 1, 4 do
						shard = _G["ShardBarFrameShard"..i]
						shard.shardGlow:ClearAllPoints()
						shard.shardGlow:SetPoint("TOPLEFT", -2, -3)
						shard.shardSmokeA:ClearAllPoints()
						shard.shardSmokeA:SetPoint("TOPLEFT", -8, 1)
						shard.shardFill:ClearAllPoints()
						shard.shardFill:SetPoint("TOPLEFT" , 3, -6)
						shard.shardBorder:ClearAllPoints()
						shard.shardBorder:SetPoint("TOPLEFT", -5, 2)
						shard.shardGlow:SetTexCoord(0.01562500, 0.42187500, 0.32812500, 0.14843750)
						shard.shardSmokeA:SetTexCoord(0.01562500, 0.51562500, 0.59375000, 0.34375000)
						shard.shardSmokeB:SetTexCoord(0.51562500, 0.01562500, 0.59375000, 0.34375000)
						shard.shardFill:SetTexCoord(0.01562500, 0.28125000, 0.13281250, 0.00781250)
						shard.shardBorder:SetTexCoord(0.01562500, 0.82812500, 0.83593750, 0.60937500)
					end
				end
				updateTotemDurationText()
			else
				if object.classBar.setupBlizzard then
					TotemFrameTotem2:ClearAllPoints()
					TotemFrameTotem2:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
					WarlockPowerFrame:ClearAllPoints()
					WarlockPowerFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				end
				object.classBar.addOn:Show()
				object.classBar.addOn:ClearAllPoints()
				object.classBar.addOn.soulShard:ClearAllPoints()
				--object.classBar.addOn.demonicFury:ClearAllPoints()
				--object.classBar.addOn.burningEmber:ClearAllPoints()
				object.classBar.addOn.totem:ClearAllPoints()
				local tex = SM:Fetch("statusbar", IUF.db.classBar.texture or "Smooth v2")
				for _, v in pairs(object.classBar.addOn.totem.anchors) do
					v.bar:SetStatusBarTexture(tex)
				end
				for _, v in pairs(object.classBar.addOn.soulShard.anchors) do
					v:SetTexture(tex)
					v.flash:SetTexture(tex)
				end

				if IUF.db.classBar.pos == "BOTTOM" then
					object.classBar.addOn:SetPoint("TOPLEFT", object.classBar, "TOPLEFT", 0, 0)
					object.classBar.addOn:SetPoint("TOPRIGHT", object.classBar, "TOPRIGHT", 0, 0)
					object.classBar.addOn.soulShard:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.soulShard:SetPoint("TOPRIGHT", 0, 0)
					--object.classBar.addOn.demonicFury:SetPoint("TOPLEFT", 0, 0)
					--object.classBar.addOn.demonicFury:SetPoint("TOPRIGHT", 0, 0)
					--object.classBar.addOn.burningEmber:SetPoint("TOPLEFT", 0, 0)
					--object.classBar.addOn.burningEmber:SetPoint("TOPRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMRIGHT", 0, 0)
				else
					object.classBar.addOn:SetPoint("BOTTOMLEFT", object.classBar, "BOTTOMLEFT", 0, 0)
					object.classBar.addOn:SetPoint("BOTTOMRIGHT", object.classBar, "BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.soulShard:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.soulShard:SetPoint("BOTTOMRIGHT", 0, 0)
					--object.classBar.addOn.demonicFury:SetPoint("BOTTOMLEFT", 0, 0)
					--object.classBar.addOn.demonicFury:SetPoint("BOTTOMRIGHT", 0, 0)
					--object.classBar.addOn.burningEmber:SetPoint("BOTTOMLEFT", 0, 0)
					--object.classBar.addOn.burningEmber:SetPoint("BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPRIGHT", 0, 0)
				end
			end
			updateVisible()
		else
			if object.classBar.setupBlizzard then
				TotemFrameTotem2:ClearAllPoints()
				TotemFrameTotem2:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				WarlockPowerFrame:ClearAllPoints()
				WarlockPowerFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
			end
			object.classBar.addOn:Hide()
		end
	end
else
	local function updateVisible()	-- OTHER
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				if TotemFrame:IsShown() then
					IUF.units.player.classBar:SetHeight(42)
				else
					IUF.units.player.classBar:SetHeight(0.001)
				end
			elseif IUF.units.player.classBar.addOn.totem:IsShown() then
				IUF.units.player.classBar:SetHeight(15)
				IUF.units.player.classBar.addOn:SetHeight(14)
			else
				IUF.units.player.classBar:SetHeight(0.001)
				IUF.units.player.classBar.addOn:SetHeight(0.001)
			end
		else
			IUF.units.player.classBar:SetHeight(0.001)
			IUF.units.player.classBar.addOn:SetHeight(0.001)
		end
	end

	function IUF:CreateClassBar(object)	-- OTHER
		createClassBar(object)
		object = createAddOnClassBar(object)
		createTotem(object, MAX_TOTEMS, "TOP", updateVisible)
		if playerClass == "SHAMAN" then
			object.totem.anchors[1].bar:SetStatusBarColor(1, 0, 0)
			object.totem.anchors[2].bar:SetStatusBarColor(0, 1, 0)
			object.totem.anchors[3].bar:SetStatusBarColor(0, 1, 1)
			object.totem.anchors[4].bar:SetStatusBarColor(0, 0, 1)
		end
	end

	function IUF:ClassBarSetup(object)	-- OTHER
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				object.classBar.addOn:Hide()
				if not object.classBar.setupBlizzard then
					object.classBar.setupBlizzard = true
					setClassBar(TotemFrame, object, 4, updateVisible)
				end
				TotemFrameTotem2:ClearAllPoints()
				if IUF.db.classBar.pos == "BOTTOM" then
					TotemFrameTotem2:SetPoint("BOTTOM", object.classBar, "BOTTOM", -19, 9)
				else
					TotemFrameTotem2:SetPoint("TOP", object.classBar, "TOP", -19, -8)
				end
				updateTotemDurationText()
			else
				if object.classBar.setupBlizzard then
					TotemFrameTotem2:ClearAllPoints()
					TotemFrameTotem2:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				end
				object.classBar.addOn:Show()
				object.classBar.addOn:ClearAllPoints()
				if IUF.db.classBar.pos == "BOTTOM" then
					object.classBar.addOn:SetPoint("TOPLEFT", object.classBar, "TOPLEFT", 0, 0)
					object.classBar.addOn:SetPoint("TOPRIGHT", object.classBar, "TOPRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMRIGHT", 0, 0)
				else
					object.classBar.addOn:SetPoint("BOTTOMLEFT", object.classBar, "BOTTOMLEFT", 0, 0)
					object.classBar.addOn:SetPoint("BOTTOMRIGHT", object.classBar, "BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPRIGHT", 0, 0)
				end
				local tex = SM:Fetch("statusbar", IUF.db.classBar.texture or "Smooth v2")
				for _, v in pairs(object.classBar.addOn.totem.anchors) do
					v.bar:SetStatusBarTexture(tex)
				end
			end
			updateVisible()
		else
			object.classBar.addOn:Hide()
			if object.classBar.setupBlizzard then
				TotemFrameTotem2:ClearAllPoints()
				TotemFrameTotem2:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
			end
		end
	end
end