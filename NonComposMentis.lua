NCM = {}


function NCM.OnLoad()

	-- set up any config variables here
	--NCM.foo = 'bar';
end

function NCM.OnReady()

	-- init database
	_G.NonComposMentisDB = _G.NonComposMentisDB or {};
	_G.NonComposMentisDB.opts	= _G.NonComposMentisDB.opts or {};
	--_G.NonComposMentisDB.kills	= _G.NonComposMentisDB.kills or {};
	--_G.NonComposMentisDB.loots	= _G.NonComposMentisDB.loots or {};
	--_G.NonComposMentisDB.times	= _G.NonComposMentisDB.times or {};

	NCM.StartFrame();
end

function NCM.OnSaving()

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

	if (event == 'PLAYER_ENTERING_WORLD') then
		NCM.UpdateFrame();
	end	

	if (event == 'CHAT_MSG_COMBAT_FACTION_CHANGE') then
		NCM.UpdateFrame();
	end
end

function NCM.StartFrame()

	NCM.UIFrame = _G["NCMFrame"];

	NCM.UpdateFrame();

	if (_G.NonComposMentisDB.opts.hide) then
		NCM.UIFrame:Hide();
	else
		NCM.UIFrame:Show();
	end
end

function NCM.Show()
	_G.NonComposMentisDB.opts.hide = false;
	NCM.UIFrame:Show();
	print("Non Compos Mentis: Visible");
end

function NCM.Hide()
	_G.NonComposMentisDB.opts.hide = true;
	NCM.UIFrame:Hide();
	print("Non Compos Mentis: Hidden");
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

function NCM.UpdateFrame()

	-- update text here...

	local txt = "";
	local indent = "    ";
	local reps = NCM.GetReps();

	local race = UnitRace("player");
	local factor = 1;

	if (race == 'Human') then
		factor = 1.1;
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
		if (rh < 21000) then
			local rh_remain_kill = 21000 - rh;
			local rh_kills = math.ceil(rh_remain_kill / (5 * factor));
			txt = txt .. indent .. "Kills until Revered: " .. rh_kills .. "\n";
		end

		-- junk box turnins
		local rh_boxes = math.ceil(rh_remain / (75 * factor)) * 5;
		txt = txt .. indent .. "Junk boxes to finish: " .. rh_boxes .. "\n";
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
	end




	

	if (false) then
		txt = txt .. "\n";

		for k, v in pairs(reps) do
			txt = txt .. k .. ": " .. v .. "\n";
		end
	end

	_G.NCMFrameScrollFrameText:SetText(txt);
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
	else
		print "Non Compos Mentis commands:";
		print "   /ncm show - Show frame";
		print "   /ncm hide - Hide frame";
		print "   /ncm toggle - Toggle frame";
		print "   /ncm reset - Reset frame position and size";
	end
end


NCM.Frame = CreateFrame("Frame")
NCM.Frame:Show()
NCM.Frame:SetScript("OnEvent", NCM.OnEvent)
NCM.Frame:RegisterEvent("ADDON_LOADED")
NCM.Frame:RegisterEvent("PLAYER_TARGET_CHANGED")
NCM.Frame:RegisterEvent("LOOT_OPENED")
NCM.Frame:RegisterEvent("LOOT_CLOSED")
NCM.Frame:RegisterEvent("PLAYER_LOGOUT")
NCM.Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
NCM.Frame:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")

NCM.OnLoad()
