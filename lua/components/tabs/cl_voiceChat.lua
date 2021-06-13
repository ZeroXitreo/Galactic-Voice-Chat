local component = {}
component.dependencies = {"theme", "voiceChat", "menu"}
component.title = "Voice Chat"
component.description = "Enables you to edit the design of your own chat line"
component.icon = "music"
component.width = 280

function component:InitializeTab(parent)
	// Create the window
	self.window = vgui.Create("DPanel", parent);
	self.window:Dock(FILL)
	self.window.Paint = nil
	// TODO: save it another way (possibly button; OR a way to call this when closing the menu/change tab!)

	// Category List
	self.categoryList = vgui.Create("DCategoryList", self.window);
	self.categoryList:Dock(FILL);

	// VoiceMode
	self.VoiceModeCategory = self:createCategoryPanel("Voice Mode");
	self.VoiceMode = self:createComboBox(self.VoiceModeCategory);
	self.VoiceMode:AddChoice("Sequence", galactic.voiceChat.bars.SEQUENCE, LocalPlayer().GVCSettings.VoiceMode == galactic.voiceChat.bars.SEQUENCE);
	self.VoiceMode:AddChoice("Bottom", galactic.voiceChat.bars.BOTTOM, LocalPlayer().GVCSettings.VoiceMode == galactic.voiceChat.bars.BOTTOM);
	self.VoiceMode:AddChoice("Top", galactic.voiceChat.bars.TOP, LocalPlayer().GVCSettings.VoiceMode == galactic.voiceChat.bars.TOP);
	self.VoiceMode:AddChoice("Center", galactic.voiceChat.bars.CENTER, LocalPlayer().GVCSettings.VoiceMode == galactic.voiceChat.bars.CENTER);
	self.VoiceMode:AddChoice("Reverse", galactic.voiceChat.bars.REVERSE, LocalPlayer().GVCSettings.VoiceMode == galactic.voiceChat.bars.REVERSE);
	function self.VoiceMode:OnSelect(index, value, data)
		LocalPlayer().GVCSettings.VoiceMode = data
		galactic.voiceChat:Save()
	end

	// PointsPerSecond
	self.NodeCategory = self:createCategoryPanel("Nodes");
	self.PointsPerSecond = self:createNumSlider("Nodes Per Second", self.NodeCategory, 4, 32, function(self, value)
		if LocalPlayer().GVCSettings.PointsPerSecond != math.Round(value) then
			LocalPlayer().GVCSettings.PointsPerSecond = math.Round(value)
			galactic.voiceChat:Save()
		end
	end)
	self.PointsPerSecond:SetValue(LocalPlayer().GVCSettings.PointsPerSecond)

	// PointsWidth
	self.PointsWidth = self:createNumSlider("Node Width", self.NodeCategory, 1, 16, function(self, value)
		if LocalPlayer().GVCSettings.PointsWidth != math.Round(value) then
			LocalPlayer().GVCSettings.PointsWidth = math.Round(value)
			galactic.voiceChat:Save()
		end
	end)
	self.PointsWidth:SetValue(LocalPlayer().GVCSettings.PointsWidth)

	// PointsGap
	self.PointsGap = self:createNumSlider("Node Gap", self.NodeCategory, 0, 4, function(self, value)
		if LocalPlayer().GVCSettings.PointsGap != math.Round(value) then
			LocalPlayer().GVCSettings.PointsGap = math.Round(value)
			galactic.voiceChat:Save()
		end
	end)
	self.PointsGap:SetValue(LocalPlayer().GVCSettings.PointsGap)
end




function component:createCategoryPanel(name)
	local panel = vgui.Create("DPanel")
	panel.Paint = nil
	panel:Dock(FILL)
	panel:DockPadding(0, 0, 0, 10)

	local category = self.categoryList:Add(name)
	category:SetContents(panel)

	return panel
end

function component:createNumSlider(name, panel, min, max, func)

	local numSlider = vgui.Create("DNumSlider", panel);
	numSlider:Dock(TOP);
	numSlider:DockMargin(10, 10, 10, 0);
	numSlider:SetText(name);
	numSlider:SetTall(20);
	numSlider:SetMin(min);
	numSlider:SetMax(max);
	numSlider:SetDecimals(0);
	numSlider:SetDark(true);
	numSlider.OnValueChanged = func;

	return numSlider;
end

function component:createComboBox(panel)

	local ComboBx = vgui.Create("DComboBox", panel)
	ComboBx:Dock(TOP);
	ComboBx:DockMargin(10, 10, 10, 0);

	return ComboBx;
end

galactic:Register(component)
