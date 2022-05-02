HardcoreDeath_ChatFrame_OnEvent = ChatFrame_OnEvent
local LastTarget = ""
local LastMsg = ""
local LastTime = ""
local gfind = string.gmatch or string.gfind
local msg = ""
local dead = nil
local death = ""
local lastsliderPlayed = 0
if HardcoreDeath_Screenshot == nil then HardcoreDeath_Screenshot = true end
if HardcoreDeath_World == nil then HardcoreDeath_World = true end
--if not HardcoreDeath_Log then HardcoreDeath_Log = {} end


local frame = CreateFrame("FRAME", "HardcoreDeath_FriendFrame");
frame:RegisterEvent("FRIENDLIST_UPDATE");
local function HardcoreDeath_eventHandler(self, event, ...)

	if HardcoreDeath_Find then
		for i=0, 200 do
			local name, level, class, area = GetFriendInfo(i)

			if (name == HardcoreDeath_Find) then
				ddate = date("!%y%m%d%H%M")
				
				if (class == "Druid") then ccol = "|cffff7c0a"
				elseif (class == "Hunter") then ccol = "|cffaad372"
				elseif (class == "Mage") then ccol = "|cff3dc7eb"
				elseif (class == "Paladin") then ccol = "|cfff48cba"
				elseif (class == "Priest") then ccol = "|cffffffff"
				elseif (class == "Rogue") then ccol = "|cfffff468"
				elseif (class == "Shaman") then ccol = "|cff0070dd"
				elseif (class == "Warlock") then ccol = "|cff8788ee"
				elseif (class == "Warrior") then ccol = "|cffc69b6d" end

				DEFAULT_CHAT_FRAME:AddMessage("|cffbe5eff[HardcoreDeath]|r |cfffff000A tragedy has occurred. |r"..ccol..name.."|r|cfffff000 the |r"..ccol..class.." |cfffff000has died in "..area.." at level "..level..". May this sacrifice not be forgotten.|r")
				table.insert(HardcoreDeath_Log, ddate .. "&" .. name .. "&" .. level .. "&" .. class .. "&" .. area)
				if (HardcoreDeathLogGUI:IsVisible()) then GenerateLog() end
				i = 200
			end
		end
	end

end
frame:SetScript("OnEvent", HardcoreDeath_eventHandler);

--pfUI.api.strsplit
local function hcstrsplit(delimiter, subject)
  if not subject then return nil end
  local delimiter, fields = delimiter or ":", {}
  local pattern = string.format("([^%s]+)", delimiter)
  string.gsub(subject, pattern, function(c) fields[table.getn(fields)+1] = c end)
  return unpack(fields)
end


-- Check if Hardcore by scaning the spellbook
local function ishc()
	local i = 1
	while true do
	local spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)
		if not spellName then
			do break end
		end

		if spellName == "Hardcore" and spellRank == "Challenge" then
			return true
		end
     
		i = i + 1
	end
end

local function prepare(template)
	template = gsub(template, "%(", "%%(") -- fix ( in string
    template = gsub(template, "%)", "%%)") -- fix ) in string
    template = gsub(template, "%d%$","")
    template = gsub(template, "%%s", "(.+)")
    return gsub(template, "%%d", "(%%d+)")
end

-- Find world chat
local function FindWorld()
	for i=1,50 do
		local id, name = GetChannelName(i)
		if (name == "world") then
			return id
		end
		end
	return nil
end

-- Format /played (Idea by [Calcyon])
local function FormatTime(s)
	
	local days = floor(s/24/60/60); s = mod(s, 24*60*60);
	local hours = floor(s/60/60); s = mod(s, 60*60);
	local minutes = floor(s/60); s = mod(s, 60);
	local seconds = s;
	
	local timeText = "";
	if (days ~= 0) then
		timeText = timeText..format("%dd ", days);
	end
	if (days ~= 0 or hours ~= 0) then
		timeText = timeText..format("%dhr ", hours);
	end
	if (days ~= 0 or hours ~= 0 or minutes ~= 0) then
		timeText = timeText..format("%dm ", minutes);
	end	
	timeText = timeText..format("%ds", seconds);
	
	return timeText;
end

function ChatFrame_OnEvent(event)

  if (event == "CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS" or
	  event == "CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES" or
	  event == "CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS" or
	  event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS" or
	  event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES" or
	  --event == "CHAT_MSG_COMBAT_FRIENDLYPLAYER_HITS" or
	  event == "CHAT_MSG_COMBAT_FRIENDLYPLAYER_MISSES" or
	  event == "CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS" or
	  event == "CHAT_MSG_COMBAT_HOSTILEPLAYER_MISSES" or
	  event == "CHAT_MSG_COMBAT_PARTY_HITS" or
	  event == "CHAT_MSG_COMBAT_PARTY_MISSES" or
	  event == "CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES" or
	  event == "CHAT_MSG_COMBAT_PET_HITS" or
	  event == "CHAT_MSG_COMBAT_PET_MISSES" or
	  event == "CHAT_MSG_COMBAT_SELF_HITS" or
	  event == "CHAT_MSG_COMBAT_SELF_MISSES" or
	  event == "CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE" or
	  event == "CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE" or
	  event == "CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE" or
	  event == "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS" or
	  event == "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF" or
	  event == "CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE" or
	  event == "CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE" or
	  event == "CHAT_MSG_SPELL_PARTY_DAMAGE" or
	  event == "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE" or
	  event == "CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE" or
	  event == "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE" or
	  event == "CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE" or
	  event == "CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE" or
	  event == "CHAT_MSG_SPELL_PET_DAMAGE" or
	  --event == "CHAT_MSG_SPELL_SELF_DAMAGE" or
      event == "CHAT_MSG_COMBAT_FRIENDLY_DEATH") then
	  
	    -- me target
		local hcdSPELLLOGSCHOOLOTHERSELF = prepare(SPELLLOGSCHOOLOTHERSELF) -- %s's %s hits you for %d %s damage.
		local hcdSPELLLOGCRITSCHOOLOTHERSELF = prepare(SPELLLOGCRITSCHOOLOTHERSELF) -- %s's %s crits you for %d %s damage.
		local hcdSPELLLOGOTHERSELF = prepare(SPELLLOGOTHERSELF) -- %s's %s hits you for %d.
		local hcdSPELLLOGCRITOTHERSELF = prepare(SPELLLOGCRITOTHERSELF) -- %s's %s crits you for %d.
		local hcdPERIODICAURADAMAGEOTHERSELF = prepare(PERIODICAURADAMAGEOTHERSELF) -- "You suffer %d %s damage from %s's %s."; -- You suffer 3 frost damage from Rabbit's Ice Nova.
		local hcdCOMBATHITOTHERSELF = prepare(COMBATHITOTHERSELF) -- %s hits you for %d.
		local hcdCOMBATHITCRITOTHERSELF = prepare(COMBATHITCRITOTHERSELF) -- %s crits you for %d.
		local hcdCOMBATHITSCHOOLOTHERSELF = prepare(COMBATHITSCHOOLOTHERSELF) -- %s hits you for %d %s damage.
		local hcdCOMBATHITCRITSCHOOLOTHERSELF = prepare(COMBATHITCRITSCHOOLOTHERSELF) -- %s crits you for %d %s damage.
		
		local source = UnitName("player")
		local target = UnitName("player")
		local school = "physical"
		local attack = "Auto Hit"
			
		if arg1 then
			if arg1 ~= "You die." then
				LastMsg = arg1
			end
			
			-- me target
			-- %s's %s hits you for %d %s damage.
			for source, attack, damage, school in string.gfind(arg1, hcdSPELLLOGSCHOOLOTHERSELF) do
				LastTarget = source
				LastTime = GetTime()
				return
			end

			   -- %s's %s crits you for %d %s damage.
			  for source, attack, damage, school in string.gfind(arg1, hcdSPELLLOGCRITSCHOOLOTHERSELF) do
				LastTarget = source
				LastTime = GetTime()
				return
			  end

			   -- %s's %s hits you for %d.
			  for source, attack, damage in string.gfind(arg1, hcdSPELLLOGOTHERSELF) do
				LastTarget = source
				LastTime = GetTime()
				return
			  end

			   -- %s's %s crits you for %d.
			  for source, attack, damage in string.gfind(arg1, hcdSPELLLOGCRITOTHERSELF) do
				LastTarget = source
				LastTime = GetTime()
				return
			  end

			  -- "You suffer %d %s damage from %s's %s."; -- You suffer 3 frost damage from Rabbit's Ice Nova.
			  for damage, school, source, attack in string.gfind(arg1, hcdPERIODICAURADAMAGEOTHERSELF) do
				LastTarget = source
				LastTime = GetTime()
				return
			  end

			  -- %s hits you for %d.
			  for source, damage in string.gfind(arg1, hcdCOMBATHITOTHERSELF) do
				LastTarget = source
				LastTime = GetTime()
				return
			  end

			  -- %s crits you for %d.
			  for source, damage in string.gfind(arg1, hcdCOMBATHITCRITOTHERSELF) do
				LastTarget = source
				LastTime = GetTime()
				return
			  end

			  -- %s hits you for %d %s damage.
			  for source, damage, school in string.gfind(arg1, hcdCOMBATHITSCHOOLOTHERSELF) do
				LastTarget = source
				LastTime = GetTime()
				return
			  end

			  -- %s crits you for %d %s damage.
			  for source, damage, school in string.gfind(arg1, hcdCOMBATHITCRITSCHOOLOTHERSELF) do
				LastTarget = source
				LastTime = GetTime()
				return
			  end
		end
		
		if event == "CHAT_MSG_COMBAT_FRIENDLY_DEATH" then
			if arg1 == "You die." then
				dead = true

				if ishc() and UnitLevel("player") ~= 60 then
					if (GetTime() - LastTime) >= 5 then
						if GetZoneText() == "Duskwood" then
							death = "I forgot that you can't AoE in Duskwood and died to an Unseen"
						else
							death = "I died to an unknown cause"
							DEFAULT_CHAT_FRAME:AddMessage("If you got this message, please screenshot your combat log and send it to Lexie#4024 on discord and tell me what happened.");
						end
					end

					-- Death Messages
					if strfind(LastMsg, "suffer") and strfind(LastMsg, "fire damage") then
						death = "I died while standing in a fire"
					elseif strfind(LastMsg, "fall and lose") then
						death = "I somehow managed to actually fall to my death"
					elseif strfind(LastMsg, "You are exhausted") then
						death = "I died to fatigue damage"
					elseif strfind(LastMsg, "drowning") then
						death = "I drowned"
					else
						death = "A " .. LastTarget .. " has killed me"
					end
							
					RequestTimePlayed()
				end
			end

		end
    end
	
	if (event == "TIME_PLAYED_MSG") then
			
		if (dead) then
			
			msg = death .. " at level " ..UnitLevel("player") .. " after " .. FormatTime(arg1) .. " /played. In " .. GetSubZoneText() .. " (" .. GetZoneText() .. ")."
			-- Only send the message if they're doing the hardcore challenge
			if ishc() and UnitLevel("player") ~= 60 then
				local wid = FindWorld()
				if wid and HardcoreDeath_World and UnitLevel("player") >= 10 then
					SendChatMessage("[HardcoreDeath] " .. msg, "CHANNEL", nil, wid)
				end
				if not IsInGuild() then
					DEFAULT_CHAT_FRAME:AddMessage("|cffbe5eff[[HardcoreDeath]|r " .. msg)
				else
					SendChatMessage("[HardcoreDeath] " .. msg, "GUILD", nil)
				end
				-- Screenshot (Idea by [Sorgis])
				if HardcoreDeath_Screenshot then
					Screenshot()
					DEFAULT_CHAT_FRAME:AddMessage("|cffbe5eff[HardcoreDeath]|r A screenshot of your death has been saved to ..\\Screenshots")
				end
			end
			return
		end
	end
	
	if (event == "CHAT_MSG_SYSTEM") then
		_, _, chr = string.find(arg1,"A tragedy has occurred. Hardcore character (%a+)")
		if (chr) then
			HardcoreDeath_Find = chr
			AddFriend(chr)
			return
		end
		
		_, _, addedfriend = string.find(arg1,"(%a+) added to friends")
		_, _, alreadyfriend = string.find(arg1,"(%a+) is already your friend")
		_, _, removedfriend = string.find(arg1,"(%a+) removed from friends")
		if (addedfriend or removedfriend or alreadyfriend) then
			if (removedfriend == HardcoreDeath_Find) then
				HardcoreDeath_Find = nil
				return
			elseif (alreadyfriend == HardcoreDeath_Find) then
				HardcoreDeath_Find = nil
				return
			elseif (addedfriend == HardcoreDeath_Find) then 
				RemoveFriend(addedfriend)
				return
			end
		end
	end
	
  HardcoreDeath_ChatFrame_OnEvent(event);
end

-- Options
SLASH_HARDCOREDEATH1, SLASH_HARDCOREDEATH2 = "/hcd", "/hardcoredeath"
SlashCmdList["HARDCOREDEATH"] = function(message)
	local commandlist = { }
	local command

	for command in gfind(message, "[^ ]+") do
		table.insert(commandlist, string.lower(command))
	end

	-- toggle screenshot
	if commandlist[1] == "ss" then
		if HardcoreDeath_Screenshot then
			HardcoreDeath_Screenshot = false
		else
			HardcoreDeath_Screenshot = true
		end
		DEFAULT_CHAT_FRAME:AddMessage("|cffbe5eff[HardcoreDeath]|r Automatically Screenshot Death:|cffbe5eff ".. tostring(HardcoreDeath_Screenshot))
	elseif commandlist[1] == "world" then
		if HardcoreDeath_World then
			HardcoreDeath_World = false
		else
			HardcoreDeath_World = true
		end
		DEFAULT_CHAT_FRAME:AddMessage("|cffbe5eff[HardcoreDeath]|r Send death messages to world :|cffbe5eff ".. tostring(HardcoreDeath_World))
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffbe5eff[HardcoreDeath]|r v2.0.0rc1")
		DEFAULT_CHAT_FRAME:AddMessage("|cffbe5eff/hcd ss|cffaaaaaa - |rAutomatically Screenshot Death: |cffbe5eff".. tostring(HardcoreDeath_Screenshot))
		DEFAULT_CHAT_FRAME:AddMessage("|cffbe5eff/hcd world|cffaaaaaa - |rSend death messages to world :|cffbe5eff ".. tostring(HardcoreDeath_World))
	end
end



local function GenerateLogDates(i,length)

	local output = "==== Date ==== \n\n"
	
	for i=i,length do
		local d,n,l,c,z = hcstrsplit("&", HardcoreDeath_Log[i])
		
		local _,_,y=string.find(d,"(%d%d)")
		local _,_,m=string.find(d,"(%d%d)",3)
		local _,_,D=string.find(d,"(%d%d)",5)
		local _,_,h=string.find(d,"(%d%d)",7)
		local _,_,M=string.find(d,"(%d%d)",9)
		local d = "20"..y.."/"..m.."/"..D.." - "..h..":"..M	
		
		output = output .. d .. "\n"
	end

	return output
end

local function GenerateLogNames(i,length)

	local output = "=== Name === \n\n"
	
	for i=i,length do
		local d,n,l,c,z = hcstrsplit("&", HardcoreDeath_Log[i])
		output = output .. n .. "\n"
	end
	return output
end

local function GenerateLogLevels(i,length)

	local output = "= Level = \n\n"
	
	for i=i,length do
		local d,n,l,c,z = hcstrsplit("&", HardcoreDeath_Log[i])
		output = output .. l .. "\n"
	end
	return output
end

local function GenerateLogClasses(i,length)

	local output = "= Class = \n\n"
	
	for i=i,length do
		local d,n,l,c,z = hcstrsplit("&", HardcoreDeath_Log[i])
		output = output .. c .. "\n"
	end
	return output
end

local function GenerateLogZones(i,length)

	local output = "===== Zone ===== \n\n"
	
	for i=i,length do
		local d,n,l,c,z = hcstrsplit("&", HardcoreDeath_Log[i])
		output = output .. z .. "\n"
	end
	return output
end

function GenerateLog()

	maxV = table.getn(HardcoreDeath_Log) - 29
	if (table.getn(HardcoreDeath_Log) < 30) then maxV = 1 end
	HardcoreDeathLogGUI.slider:SetMinMaxValues(1, maxV)

	local i = HardcoreDeathLogGUI.slider:GetValue()
	length = i+29
	if (length > table.getn(HardcoreDeath_Log)) then length = table.getn(HardcoreDeath_Log) end
	
	local HardcoreDeathLogDates = GenerateLogDates(i,length)
	local HardcoreDeathLogNames = GenerateLogNames(i,length)
	local HardcoreDeathLogLevels = GenerateLogLevels(i,length)
	local HardcoreDeathLogClasses = GenerateLogClasses(i,length)
	local HardcoreDeathLogZones = GenerateLogZones(i,length)
	HardcoreDeathLogGUI.logdates.text:SetText(HardcoreDeathLogDates)
	HardcoreDeathLogGUI.lognames.text:SetText(HardcoreDeathLogNames)
	HardcoreDeathLogGUI.loglevels.text:SetText(HardcoreDeathLogLevels)
	HardcoreDeathLogGUI.logclasses.text:SetText(HardcoreDeathLogClasses)
	HardcoreDeathLogGUI.logzones.text:SetText(HardcoreDeathLogZones)
end

-- Log Interface

local HardcoreDeathLogGUI = CreateFrame("Frame", "HardcoreDeathLogGUI", UIParent)
HardcoreDeathLogGUI:Hide()

table.insert(UISpecialFrames, "HardcoreDeathLogGUI")
HardcoreDeathLogGUI:SetScript("OnHide", function()
  ShowUIPanel(GameMenuFrame)
  UpdateMicroButtons()
end)

HardcoreDeathLogGUI:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
HardcoreDeathLogGUI:SetWidth(460)
HardcoreDeathLogGUI:SetHeight(450)
HardcoreDeathLogGUI:SetBackdrop({
  bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
  tile = true, tileSize = 32, edgeSize = 32,
  insets = { left = 11, right = 12, top = 12, bottom = 11 }
})

HardcoreDeathLogGUI.title = CreateFrame("Frame", "HardcoreDeathLogGUITtitle", HardcoreDeathLogGUI)
HardcoreDeathLogGUI.title:SetPoint("TOP", HardcoreDeathLogGUI, "TOP", 0, 12)
HardcoreDeathLogGUI.title:SetWidth(356)
HardcoreDeathLogGUI.title:SetHeight(64)

HardcoreDeathLogGUI.title.tex = HardcoreDeathLogGUI.title:CreateTexture(nil, "MEDIUM")
HardcoreDeathLogGUI.title.tex:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
HardcoreDeathLogGUI.title.tex:SetAllPoints()

HardcoreDeathLogGUI.title.text = HardcoreDeathLogGUI.title:CreateFontString(nil, "HIGH", "GameFontNormal")
HardcoreDeathLogGUI.title.text:SetText("Hardcore Death Log")
HardcoreDeathLogGUI.title.text:SetPoint("TOP", 0, -14)

HardcoreDeathLogGUI.purge = CreateFrame("Button", "HardcoreDeathLogGUICancel", HardcoreDeathLogGUI, "GameMenuButtonTemplate")
HardcoreDeathLogGUI.purge:SetWidth(90)
HardcoreDeathLogGUI.purge:SetPoint("TOP", HardcoreDeathLogGUI, "TOP", 0, 32)
HardcoreDeathLogGUI.purge:SetText("!! PURGE DATA !!")
HardcoreDeathLogGUI.purge:SetScript("OnClick", function()

	HardcoreDeath_Log = {}
	GenerateLog()
	PlaySound("gsTitleOptionOK","SFX")
end)

HardcoreDeathLogGUI.close = CreateFrame("Button", "HardcoreDeathLogGUIOkay", HardcoreDeathLogGUI, "GameMenuButtonTemplate")
HardcoreDeathLogGUI.close:SetWidth(90)
HardcoreDeathLogGUI.close:SetPoint("BOTTOMRIGHT", HardcoreDeathLogGUI, "BOTTOMRIGHT", -17, 17)
HardcoreDeathLogGUI.close:SetText("Close")
HardcoreDeathLogGUI.close:SetScript("OnClick", function()
	HardcoreDeathLogGUI:Hide()
	PlaySound("gsTitleOptionOK","SFX")
end)

HardcoreDeathLogGUI.slider = CreateFrame("Slider", "HardcoreDeathLogGUISlider", HardcoreDeathLogGUI, "OptionsSliderTemplate")
HardcoreDeathLogGUI.slider:SetPoint("RIGHT", HardcoreDeathLogGUI, "RIGHT", -17, -5)
HardcoreDeathLogGUI.slider:SetWidth(20)
HardcoreDeathLogGUI.slider:SetHeight(361)
HardcoreDeathLogGUI.slider:SetOrientation('VERTICAL')
HardcoreDeathLogGUI.slider:SetMinMaxValues(1, 30)
HardcoreDeathLogGUI.slider:SetValue(1)
HardcoreDeathLogGUI.slider:SetValueStep(1)
getglobal(HardcoreDeathLogGUI.slider:GetName() .. 'Low'):SetText('')
getglobal(HardcoreDeathLogGUI.slider:GetName() .. 'High'):SetText('')
getglobal(HardcoreDeathLogGUI.slider:GetName() .. 'Text'):SetText('')
HardcoreDeathLogGUI.slider:SetScript("OnValueChanged",function()

	GenerateLog()

	--if GetTime() > lastsliderPlayed + 1 then
		PlaySound("igMiniMapZoomIn","SFX")
		lastsliderPlayed = GetTime()
	--end
end)

HardcoreDeathLogGUI.logdates = CreateFrame("Frame", "HardcoreDeathLogGUILogDates", HardcoreDeathLogGUI)
HardcoreDeathLogGUI.logdates:SetPoint("TOPLEFT", HardcoreDeathLogGUI, "TOPLEFT", 0, 12)
HardcoreDeathLogGUI.logdates:SetWidth(20)
HardcoreDeathLogGUI.logdates:SetHeight(20)

HardcoreDeathLogGUI.logdates.text = HardcoreDeathLogGUI.logdates:CreateFontString(nil, "HIGH", "GameFontNormal")
HardcoreDeathLogGUI.logdates.text:SetPoint("TOPLEFT", 14, -38)

HardcoreDeathLogGUI.lognames = CreateFrame("Frame", "HardcoreDeathLogGUILogNames", HardcoreDeathLogGUI)
HardcoreDeathLogGUI.lognames:SetPoint("TOPLEFT", HardcoreDeathLogGUI, "TOPLEFT", 0, 12)
HardcoreDeathLogGUI.lognames:SetWidth(20)
HardcoreDeathLogGUI.lognames:SetHeight(20)

HardcoreDeathLogGUI.lognames.text = HardcoreDeathLogGUI.lognames:CreateFontString(nil, "HIGH", "GameFontNormal")
HardcoreDeathLogGUI.lognames.text:SetPoint("TOPLEFT", 114, -38)

HardcoreDeathLogGUI.loglevels = CreateFrame("Frame", "HardcoreDeathLogGUILogLevels", HardcoreDeathLogGUI)
HardcoreDeathLogGUI.loglevels:SetPoint("TOPLEFT", HardcoreDeathLogGUI, "TOPLEFT", 0, 12)
HardcoreDeathLogGUI.loglevels:SetWidth(20)
HardcoreDeathLogGUI.loglevels:SetHeight(20)

HardcoreDeathLogGUI.loglevels.text = HardcoreDeathLogGUI.loglevels:CreateFontString(nil, "HIGH", "GameFontNormal")
HardcoreDeathLogGUI.loglevels.text:SetPoint("TOPLEFT", 200, -38)

HardcoreDeathLogGUI.logclasses = CreateFrame("Frame", "HardcoreDeathLogGUILogClasses", HardcoreDeathLogGUI)
HardcoreDeathLogGUI.logclasses:SetPoint("TOPLEFT", HardcoreDeathLogGUI, "TOPLEFT", 0, 12)
HardcoreDeathLogGUI.logclasses:SetWidth(20)
HardcoreDeathLogGUI.logclasses:SetHeight(20)

HardcoreDeathLogGUI.logclasses.text = HardcoreDeathLogGUI.logclasses:CreateFontString(nil, "HIGH", "GameFontNormal")
HardcoreDeathLogGUI.logclasses.text:SetPoint("TOPLEFT", 264, -38)

HardcoreDeathLogGUI.logzones = CreateFrame("Frame", "HardcoreDeathLogGUILogZones", HardcoreDeathLogGUI)
HardcoreDeathLogGUI.logzones:SetPoint("TOPLEFT", HardcoreDeathLogGUI, "TOPLEFT", 0, 12)
HardcoreDeathLogGUI.logzones:SetWidth(20)
HardcoreDeathLogGUI.logzones:SetHeight(20)

HardcoreDeathLogGUI.logzones.text = HardcoreDeathLogGUI.logzones:CreateFontString(nil, "HIGH", "GameFontNormal")
HardcoreDeathLogGUI.logzones.text:SetPoint("TOPLEFT", 320, -38)


HardcoreDeathLogFrame = CreateFrame("Button", "GameMenuButtonHardcoreDeathLogGUI", GameMenuFrame, "GameMenuButtonTemplate")
HardcoreDeathLogFrame:SetPoint("TOP", GameMenuButtonMacros, "BOTTOM", 0, -1)
HardcoreDeathLogFrame:SetText("Hardcore Death Log")
HardcoreDeathLogFrame:SetScript("OnClick", function()
	HideUIPanel(GameMenuFrame)
	PlaySound("igMainMenuOption","SFX")
	GenerateLog()
	HardcoreDeathLogGUI:Show()
end)

GameMenuButtonLogout:ClearAllPoints()
GameMenuButtonLogout:SetPoint("TOP", HardcoreDeathLogFrame, "BOTTOM", 0, -1)