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

function NCM.UpdateFrame()

	-- update text here...

	local txt = "";
	local indent = "    ";
	local reps = NCM.GetReps();


	local rh = reps["Ravenholdt"] or 0;
	local rh_remain = 42000 - rh;
	if (rh_remain < 1) then

		txt = txt .. "Ravenholdt: DONE!\n";
	else
		txt = txt .. "Ravenholdt\n";
		txt = txt .. indent .. rh_remain .. "rep remaining\n";

		-- can we still kill members?
		if (rh < 21000) then
			local rh_remain_kill = 21000 - rh;
			local rh_kills = math.ceil(rh_remain_kill / 5);
			txt = txt .. indent .. "Kills until Revered: " .. rh_kills .. "\n";
		end

		-- junk box turnins
		local rh_boxes = math.ceil(rh_remain / 75) * 5;
		txt = txt .. indent .. "Junk boxes to finish: " .. rh_boxes .. "\n";
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

NCM.OnLoad()
