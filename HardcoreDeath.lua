HardcoreDeath_ChatFrame_OnEvent = ChatFrame_OnEvent
local LastTarget = ""
local LastMsg = ""
local LastTime = ""

-- Checking if we're a hardcore character
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
				--DEFAULT_CHAT_FRAME:AddMessage("DEBUG: " .. LastMsg)
				local msg = ""

				if (GetTime() - LastTime) >= 5 then
					if GetZoneText() == "Duskwood" then
						msg = "I forgot that you can't AoE in Duskwood and died to an Unseen"
					else
						msg = "I died to an unknown cause"
						DEFAULT_CHAT_FRAME:AddMessage("If you got this message, please screenshot your combat log and send it to Lexie#4024 on discord and tell me what happened.");
					end
				end

				if strfind(LastMsg, "suffer") and strfind(LastMsg, "fire damage") then
					msg = "I died while standing in a fire"
				elseif strfind(LastMsg, "fall and lose") then
					msg = "I fell to my death"
				elseif strfind(LastMsg, "You are exhausted") then
					msg = "I died to fatigue damage"
				elseif strfind(LastMsg, "drowning") then
					msg = "I drowned"
				else
					msg = "A " .. LastTarget .. " has killed me"
				end
				if (ishc) and UnitLevel("player") ~= 60 then
					SendChatMessage("[HardcoreDeath] " .. msg .. " at level " ..UnitLevel("player") .. " in " .. GetSubZoneText() .. " (" .. GetZoneText() .. ").", "GUILD", nil)
					--DEFAULT_CHAT_FRAME:AddMessage("Hardcore Death: " .. msg .. " at level " ..UnitLevel("player") .. " in " .. GetSubZoneText() .. " (" .. GetZoneText() .. ").")
					DEFAULT_CHAT_FRAME:AddMessage("Damn! That really sucks. I'm so sorry! I hope you still had fun while getting to level " ..UnitLevel("player") .. ". I'm sure you'll do better next time!")
				end
			end

		end
    end
	
  HardcoreDeath_ChatFrame_OnEvent(event);
end
