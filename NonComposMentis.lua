NCM = {}

function NCM.OnLoad()

	-- reputation values
	NCM.reps_loaded = false;
	NCM.prev_reps = {};

	-- rep changes for this play session
	NCM.has_session_data = false;
	NCM.play_session = {};

	-- farming sessions
	NCM.farm_limit_max = 60 * 5; -- 5m
	NCM.farm_limit_min = 10;
	NCM.farm_session = nil;
	NCM.farm_started = nil;
	NCM.farm_last = nil;
	NCM.farm_delta = nil;
end

function NCM.OnReady()

	-- init database
	_G.NonComposMentisDB = _G.NonComposMentisDB or {};
	_G.NonComposMentisDB.opts	= _G.NonComposMentisDB.opts or {};
	_G.NonComposMentisDB.farms	= _G.NonComposMentisDB.farms or {};

	NCMOptionsFrame.name = 'Non Compos Mentis';
	InterfaceOptions_AddCategory(NCMOptionsFrame);

	NCM.StartFrame();
end

function NCM.ShowOptions()

	InterfaceOptionsFrame_OpenToCategory(NCMOptionsFrame.name);
end

function NCM.OptionClick(button, name)

	if (name == 'hide') then
		if (_G.NonComposMentisDB.opts.hide) then
			NCM.Show();
		else
			NCM.Hide();
		end
	end

end

function NCM.OnSaving()

	NCM.EndSession();

	local point, relativeTo, relativePoint, xOfs, yOfs = NCM.UIFrame:GetPoint()
	_G.NonComposMentisDB.opts.frameRef = relativePoint;
	_G.NonComposMentisDB.opts.frameX = xOfs;
	_G.NonComposMentisDB.opts.frameY = yOfs;
	_G.NonComposMentisDB.opts.frameW = NCM.UIFrame:GetWidth();
	_G.NonComposMentisDB.opts.frameH = NCM.UIFrame:GetHeight();
end

function NCM.OnEvent(frame, event, ...)

	if (event == 'ADDON_LOADED') then
		local name = ...;
		if name == 'NonComposMentis' then
			NCM.OnReady();
		end
	end

	if (event == 'PLAYER_LOGOUT') then

		NCM.OnSaving();
	end

	if (event == 'PLAYER_TARGET_CHANGED') then
	end

	if (event == 'LOOT_OPENED') then
	end

	if (event == 'LOOT_CLOSED') then
	end

	if (event == 'PLAYER_ALIVE') then
		NCM.UpdateFrame();
	end	

	if (event == 'CHAT_MSG_COMBAT_FACTION_CHANGE') then
		NCM.UpdateFrame();
	end
end

function NCM.OnUpdate()

	NCM.TryEndSession()
end

function NCM.StartFrame()

	NCM.UIFrame = _G["NCMFrame"];

	NCM.UpdateFrame();

	if (_G.NonComposMentisDB.opts.hide) then
		NCM.UIFrame:Hide();
		NCMOptionsFrameCheck1:SetChecked(false);
	else
		NCM.UIFrame:Show();
		NCMOptionsFrameCheck1:SetChecked(true);
	end
end

function NCM.Show()
	_G.NonComposMentisDB.opts.hide = false;
	NCM.UIFrame:Show();
	NCMOptionsFrameCheck1:SetChecked(true);
	print("Non Compos Mentis: Visible");
end

function NCM.Hide()
	_G.NonComposMentisDB.opts.hide = true;
	NCM.UIFrame:Hide();
	NCMOptionsFrameCheck1:SetChecked(false);
	print("Non Compos Mentis: Hidden");
end

function NCM.HideButton()
	_G.NonComposMentisDB.opts.hide = true;
	NCM.UIFrame:Hide();
	NCMOptionsFrameCheck1:SetChecked(false);
	print("Non Compos Mentis: Hidden");
	print("    Use \"/ncm show\" to show again");
end


function NCM.ResetPos()
	NCM.Show();
	NCM.UIFrame:SetWidth(150);
	NCM.UIFrame:ClearAllPoints();
	NCM.UIFrame:SetPoint("CENTER", 0, 0);
end

function NCM.Toggle()

	if (_G.NonComposMentisDB.opts.hide) then
		NCM.Show();
	else
		NCM.Hide();
	end
end

function NCM.FormatNumber(n)

	local s = string.format("%d", n);

	if (string.len(s) > 4) then

		local l = string.len(s);
		s = string.sub(s, 1, l - 3) .. ',' .. string.sub(s, l - 2);
	end

	return s;
end

function NCM.FormatNumberShort(n)

	local s = string.format("%d", n);

	if (n > 999) then

		local l = string.len(s);
		return string.sub(s, 1, l - 3) .. 'k';
	end

	return s;
end

function NCM.FormatPercent(p)

	if (p == 0) then
		return "0%";
	end

	local x = string.format("%.1f", p)

	if (x == "0.0" or x == "99.9") then x = string.format("%.2f", p) end;
	if (x == "0.00" or x == "99.99") then x = string.format("%.3f", p) end;
	if (x == "0.000" or x == "99.999") then x = string.format("%.4f", p) end;

	return x .. '%';
end

function NCM.UpdateFrame()

	NCM.TryEndSession();

	-- update text here...

	local txt = "";
	local indent = "    ";
	local reps = NCM.GetReps();


	--
	-- did we get any reps at all?
	--

	local num_reps = 0;
	for _,_ in pairs(reps) do
		num_reps = num_reps + 1;
	end

	if (num_reps == 0) then
		_G.NCMFrameScrollFrameText:SetText("Reputations not loaded...");
		return
	end


	--
	-- bonuses for humans
	--

	local race = UnitRace("player");
	local factor = 1;

	if (race == 'Human') then
		factor = 1.1;
	end


	--
	-- see what's changed since last update
	--

	local diffs = {};
	local has_diffs = false;

	if (NCM.reps_loaded) then

		for k,v in pairs(reps) do

			local old_v = NCM.prev_reps[k];
			if (old_v) then
				if (not (v == old_v)) then
					diffs[k] = v - old_v;
					has_diffs = true;

					NCM.has_session_data = true;
					NCM.play_session[k] = (NCM.play_session[k] or 0) + diffs[k];
				end
			end
		end

	else
		NCM.reps_loaded = true;
	end

	NCM.prev_reps = reps;

	NCM.CheckDiffsAndIncrement(diffs['Ravenholdt'], 'Ravenholdt', 5 * factor);
	NCM.CheckDiffsAndIncrement(diffs['Bloodsail Buccaneers'], 'Bloodsail Buccaneers', 25 * factor);

	if (NCM.has_session_data and false) then

		txt = txt .. "Changes this session:\n";
		for k,v in pairs(NCM.play_session) do
			txt = txt .. indent .. k .. ": " .. v .. "\n";
		end
		txt = txt .. "\n";
	end


	--
	-- Ravenholdt
	--

	local rh = reps["Ravenholdt"] or 0;
	local rh_remain = 42000 - rh;
	if (rh_remain < 1) then

		txt = txt .. "Ravenholdt: DONE!\n";
	else
		txt = txt .. "Ravenholdt\n";
		txt = txt .. indent .. NCM.FormatNumber(rh_remain) .. " rep remaining\n";

		-- can we still kill members?
		if (rh < 20999) then
			local rh_remain_kill = 20999 - rh;
			local rh_kills = math.ceil(rh_remain_kill / (5 * factor));
			txt = txt .. indent .. "Kills until Revered: " .. rh_kills .. "\n";

			if (NCM.GetSessionLength('Ravenholdt') > 0) then
				local len = NCM.GetSessionLength('Ravenholdt');
				local delta = NCM.GetSessionDelta('Ravenholdt');

				delta = math.floor(delta / (5 * factor));
				local len_remain = (len / delta) * rh_kills;
				local rh_percent = 100 * delta / (delta + rh_kills);

				txt = txt .. indent .. indent .. ""..delta.." in "..NCM.FormatTime(len, "0s").." => "
					..NCM.FormatTime(len_remain, "0s").." to go\n";
				txt = txt .. indent .. indent .. NCM.FormatPercent(rh_percent) .. " complete\n"
			end
		end

		-- junk box turnins
		local rh_boxes = math.ceil(rh_remain / (75 * factor)) * 5;
		txt = txt .. indent .. "Junk boxes to finish: " .. rh_boxes .. "\n";
	end
	txt = txt .. "\n";


	--
	-- Bloodsail Buccaneers
	--

	-- new default is 35500/36000 hostile, which is 6500 below 0/3000 neutral

	local bb = reps["Bloodsail Buccaneers"] or -6500;
	local bb_remain = 9000 - bb;
	if (bb_remain < 1) then

		txt = txt .. "Bloodsail Buccaneers: DONE!\n";
	else
		txt = txt .. "Bloodsail Buccaneers\n";
		txt = txt .. indent .. NCM.FormatNumber(bb_remain) .. " rep remaining\n";

		local bb_bruisers = math.ceil(bb_remain / (25 * factor));
		txt = txt .. indent .. "Bruiser kills to finish: " .. bb_bruisers .. "\n";

		if (NCM.GetSessionLength('Bloodsail Buccaneers') > 0) then
			local len = NCM.GetSessionLength('Bloodsail Buccaneers');
			local delta = NCM.GetSessionDelta('Bloodsail Buccaneers');

			delta = math.floor(delta / (25 * factor));
			local len_remain = (len / delta) * bb_bruisers;
			local bb_percent = 100 * delta / (delta + bb_bruisers);

			txt = txt .. indent .. indent .. ""..delta.." in "..NCM.FormatTime(len, "0s").." => "
				..NCM.FormatTime(len_remain, "0s").." to go\n";
			txt = txt .. indent .. indent .. NCM.FormatPercent(bb_percent) .. " complete\n"
		end
	end
	txt = txt .. "\n";


	--
	-- Darkmoon Faire
	--

	local dmf = reps["Darkmoon Faire"] or 0;
	local dmf_remain = 42000 - dmf;
	if (dmf_remain < 1) then

		txt = txt .. "Darkmoon Faire: DONE!\n";
	else
		txt = txt .. "Darkmoon Faire\n";
		txt = txt .. indent .. NCM.FormatNumber(dmf_remain) .. " rep remaining\n";

		if (dmf < 5000) then
			local dmf_quests = math.ceil((5000 - dmf) / (250 * factor));
			txt = txt .. indent .. "Quests until maxed: " .. dmf_quests .. "\n";
		end

		local dmf_minor = math.ceil(dmf_remain / (25 * factor));
		local dmf_major = math.ceil(dmf_remain / (350 * factor));

		txt = txt .. indent .. "Minor decks to finish: " .. dmf_minor .. "\n";
		txt = txt .. indent .. "Major decks to finish: " .. dmf_major .. "\n";
	end
	txt = txt .. "\n";


	--
	-- Shen'dralar
	--

	local sd = reps["Shen'dralar"] or 0;
	local sd_remain = 42000 - sd;
	if (sd_remain < 1) then

		txt = txt .. "Shen'dralar: DONE!\n";
	else
		txt = txt .. "Shen'dralar\n";
		txt = txt .. indent .. NCM.FormatNumber(sd_remain) .. " rep remaining\n";

		local sd_quests = math.ceil(sd_remain / (500 * factor));
		txt = txt .. indent .. "Quest turnins to finish: " .. sd_quests .. "\n";
	end
	txt = txt .. "\n";



	--
	-- Goblin Factions
	--

	local g1 = reps["Booty Bay"] or 0;
	local g2 = reps["Everlook"] or 0;
	local g3 = reps["Gadgetzan"] or 0;
	local g4 = reps["Ratchet"] or 0;

	local g1_remain = 42000 - g1;
	local g2_remain = 42000 - g2;
	local g3_remain = 42000 - g3;
	local g4_remain = 42000 - g4;

	local most_remain = 0;
	if (g1_remain > most_remain) then most_remain = g1_remain; end
	if (g2_remain > most_remain) then most_remain = g2_remain; end
	if (g3_remain > most_remain) then most_remain = g3_remain; end
	if (g4_remain > most_remain) then most_remain = g4_remain; end

	if (most_remain < 1) then

		txt = txt .. "Goblin Factions: DONE!\n";
	else
		txt = txt .. "Goblin Factions\n";
		txt = txt .. indent .. NCM.FormatNumber(most_remain) .. " rep remaining\n";
		txt = txt .. indent .. indent .. "(" .. NCM.FormatNumberShort(g1_remain) .. "/" .. NCM.FormatNumberShort(g2_remain) .. "/" 
			.. NCM.FormatNumberShort(g3_remain) .. "/" .. NCM.FormatNumberShort(g4_remain) .. ")\n";

		local g_knot = math.ceil(most_remain / (350 * factor));
		local g_ogre = math.ceil(most_remain / (250 * factor));
		
		txt = txt .. indent .. "Free Knot turnins to finish: " .. g_knot .. "\n";
		txt = txt .. indent .. "Orge Tannin turnins to finish: " .. g_ogre .. "\n";

	end




	

	if (false) then
		txt = txt .. "\n";

		for k, v in pairs(reps) do
			txt = txt .. k .. ": " .. v .. "\n";
		end
	end

	if (false) then
		txt = txt .. "\n";
		txt = txt .. "NCM.farm_session: " .. (NCM.farm_session or "nil") .. "\n";
		txt = txt .. "NCM.farm_started: " .. (NCM.farm_started or "nil") .. "\n";
		txt = txt .. "NCM.farm_last: " .. (NCM.farm_last or "nil") .. "\n";
		txt = txt .. "NCM.farm_delta: " .. (NCM.farm_delta or "nil") .. "\n";
		txt = txt .. "\n";
		for k, v in pairs(_G.NonComposMentisDB.farms) do
			txt = txt .. k .. " = " .. v.delta .. " in " .. v.length .. "\n";
		end
	end

	_G.NCMFrameScrollFrameText:SetText(txt);
end


function NCM.CheckDiffsAndIncrement(diff, name, value)

	local lo = math.floor(value);
	local hi = math.ceil(value);

	if (lo == diff) then
		NCM.IncrementSession(name, diff);
	end
	if (lo ~= hi and hi == diff) then
		NCM.IncrementSession(name, diff);
	end
end

---------------------------------------------------------------------------------------------
--
-- functions for farm session handling
--

function NCM.IncrementSession(name, delta)

	-- in a different farm session?
	if (NCM.farm_session and not (NCM.farm_session == name)) then

		NCM.EndSession();
	end

	if (NCM.farm_session == name) then

		NCM.farm_last = GetTime();
		NCM.farm_delta = NCM.farm_delta + delta;
	else

		NCM.farm_session = name;
		NCM.farm_started = GetTime();
		NCM.farm_last = NCM.farm_started;
		NCM.farm_delta = delta;
	end
end

function NCM.GetSessionLength(name)

	local x = 0;

	if (_G.NonComposMentisDB.farms[name]) then

		x = x + _G.NonComposMentisDB.farms[name].length;
	end

	if (NCM.farm_session == name) then

		local t = GetTime() - NCM.farm_started;
		if (t < NCM.farm_limit_min) then t = NCM.farm_limit_min; end

		x = x + t;
	end

	return x;
end

function NCM.GetSessionDelta(name)

	local x = 0;

	if (_G.NonComposMentisDB.farms[name]) then

		x = x + _G.NonComposMentisDB.farms[name].delta;
	end

	if (NCM.farm_session == name) then

		x = x + NCM.farm_delta;
	end

	return x;
end


function NCM.TryEndSession()

	-- see if the current session should be ended
	-- because too long has passed since the last
	-- event.

	if (NCM.farm_session) then

		local n = GetTime();
		if (n - NCM.farm_last > NCM.farm_limit_max) then

			NCM.EndSession();
		end
	end
end

function NCM.EndSession()

	if (NCM.farm_session) then

		local l = 0;
		local d = 0;

		if (_G.NonComposMentisDB.farms[NCM.farm_session]) then
			l = l + _G.NonComposMentisDB.farms[NCM.farm_session].length;
			d = d + _G.NonComposMentisDB.farms[NCM.farm_session].delta;
		end

		local this_time = NCM.farm_last - NCM.farm_started;
		if (this_time < NCM.farm_limit_min) then this_time = NCM.farm_limit_min; end

		l = l + this_time;
		d = d + NCM.farm_delta;

		_G.NonComposMentisDB.farms[NCM.farm_session] = { length = l, delta = d };
	end

	NCM.farm_session = nil;
	NCM.farm_started = nil;
	NCM.farm_last = nil;
	NCM.farm_delta = nil;

	NCM.UpdateFrame();
end

---------------------------------------------------------------------------------------------

function NCM.FormatTime(t, zero)

	if (t == 0) then
		return zero;
	end

	local h = math.floor(t / (60 * 60));
	t = t - (60 * 60 * h);
	local m = math.floor(t / 60);
	t = t - (60 * m);
	local s = t;

	if (h > 0) then
		return string.format("%d:%02d:%02d", h, m, s);
	end

	if (m > 0) then
		return string.format("%d:%02d", m, s);
	end

	return string.format("%d", s).."s";
end

function NCM.Test()

	local reps = NCM.GetReps();

	print(reps);
	for k, v in pairs(reps) do
		print(k, v)
	end
	print "--";
end


function NCM.GetReps()

	local factionMap = {};
	local factionIndex = 1
	repeat
		local name, description, standingId, bottomValue, topValue, earnedValue, atWarWith,
		canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild = GetFactionInfo(factionIndex)

		if name == nil then break end

		if isHeader == nil then
			factionMap[name] = earnedValue;
		end

		factionIndex = factionIndex + 1
	until factionIndex > 200

	return factionMap;
end


SLASH_NONCOMPOSMENTIS1 = '/noncomposmentis';
SLASH_NONCOMPOSMENTIS2 = '/ncm';

function SlashCmdList.NONCOMPOSMENTIS(msg, editbox)
	if (msg == 'show') then
		NCM.Show();
	elseif (msg == 'hide') then
		NCM.Hide();
	elseif (msg == 'toggle') then
		NCM.Toggle();
	elseif (msg == 'reset') then
		NCM.ResetPos();
	elseif (msg == 'test') then 
		NCM.Test();
	elseif (msg == 'opts' or msg == 'options') then 
		NCM.ShowOptions();
	else
		print "Non Compos Mentis commands:";
		print "   /ncm show - Show addon";
		print "   /ncm hide - Hide addon";
		print "   /ncm reset - Reset frame position and size";
		print "   /ncm opts - Show options";
	end
end


NCM.Frame = CreateFrame("Frame")
NCM.Frame:Show()
NCM.Frame:SetScript("OnEvent", NCM.OnEvent)
NCM.Frame:SetScript("OnUpdate", NCM.OnUpdate)
NCM.Frame:RegisterEvent("ADDON_LOADED")
NCM.Frame:RegisterEvent("PLAYER_TARGET_CHANGED")
NCM.Frame:RegisterEvent("LOOT_OPENED")
NCM.Frame:RegisterEvent("LOOT_CLOSED")
NCM.Frame:RegisterEvent("PLAYER_LOGOUT")
NCM.Frame:RegisterEvent("PLAYER_ALIVE")
NCM.Frame:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")

NCM.OnLoad()
