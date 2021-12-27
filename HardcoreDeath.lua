HardcoreDeath_ChatFrame_OnEvent = ChatFrame_OnEvent
local LastTarget = ""
local LastMsg = ""
local LastTime = ""
local gfind = string.gmatch or string.gfind
local msg = ""
local dead = nil
local death = ""
if HardcoreDeath_Screenshot == nil then HardcoreDeath_Screenshot = true end
if HardcoreDeath_World == nil then HardcoreDeath_World = true end

-- Check if Hardcore by scaning the spellbook
local function ishc()
	local i = 1
	while true do
	local spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)
		if not spellName then
			do break end
		end

		if spellName == "Hardcore" then
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

local function FindWorld()
	for i=1,50 do
		local id, name = GetChannelName(i)
		if (name == "world") then
			return id
		end
		end
	return nil
end

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
	
	if (event == "TIME_PLAYED_MSG") then
		-- Remember play time
			
		if (dead) then
			
			msg = death .. " at level " ..UnitLevel("player") .. " after " .. FormatTime(arg1) .. " /played. In " .. GetSubZoneText() .. " (" .. GetZoneText() .. ")."
			-- Only send the message if they're doing the hardcore challenge
			if (ishc) and UnitLevel("player") ~= 60 then
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
					DEFAULT_CHAT_FRAME:AddMessage("|cffbe5eff[HardcoreDeath]|r A screenshot of your death has been saved to ..\Screenshots")
				end
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
		DEFAULT_CHAT_FRAME:AddMessage("|cffbe5eff[HardcoreDeath]|r v1.0.6")
		DEFAULT_CHAT_FRAME:AddMessage("|cffbe5eff/hcd ss|cffaaaaaa - |rAutomatically Screenshot Death: |cffbe5eff".. tostring(HardcoreDeath_Screenshot))
		DEFAULT_CHAT_FRAME:AddMessage("|cffbe5eff/hcd world|cffaaaaaa - |rSend death messages to world :|cffbe5eff ".. tostring(HardcoreDeath_World))
	end
end
