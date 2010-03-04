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

function NCM.OnDragStart(frame)
	NCM.UIFrame:StartMoving();
	NCM.UIFrame.isMoving = true;
	--GameTooltip:Hide()
end

function NCM.OnDragStop(frame)
	NCM.UIFrame:StopMovingOrSizing();
	NCM.UIFrame.isMoving = false;
end

function NCM.StartFrame()

	NCM.UIFrame = CreateFrame("Frame",nil,UIParent);
	NCM.UIFrame:SetFrameStrata("BACKGROUND")
	NCM.UIFrame:SetWidth(200)
	NCM.UIFrame:SetHeight(200)

	NCM.UIFrame.texture = NCM.UIFrame:CreateTexture()
	NCM.UIFrame.texture:SetAllPoints(NCM.UIFrame)
	NCM.UIFrame.texture:SetTexture(0, 0, 0)
	

	-- position the parent frame
	local frameRef = "CENTER";
	local frameX = 0;
	local frameY = 0;
	if (_G.NonComposMentisDB.opts.frameRef) then
		frameRef	= _G.NonComposMentisDB.opts.frameRef;
		frameX		= _G.NonComposMentisDB.opts.frameX;
		frameY		= _G.NonComposMentisDB.opts.frameY;

		NCM.UIFrame:SetWidth(_G.NonComposMentisDB.opts.frameW);
	end
	NCM.UIFrame:SetPoint(frameRef, frameX, frameY);

	-- make it draggable
	NCM.UIFrame:SetMovable(true);
	NCM.UIFrame:EnableMouse(true);
	NCM.UIFrame:SetScript("OnDragStart", NCM.OnDragStart);
	NCM.UIFrame:SetScript("OnDragStop", NCM.OnDragStop);
	NCM.UIFrame:RegisterForDrag("LeftButton");

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
