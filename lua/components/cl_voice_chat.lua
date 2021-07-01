local PlayerVoicePanels = {}

local component = {}
component.namespace = "voiceChatSpec"
component.dependencies = {"theme", "voiceChat", "anchor"}
component.title = "Voice Chat"

function component:Constructor()

	/////////////////////////////////////////////////

	local PANEL = {}
	function PANEL:Init()
		self:Dock(BOTTOM)

		self.Avatar = vgui.Create("AvatarImage", self)
		self.Avatar:Dock(LEFT)
		self.Avatar.Paint = function(self, w, h)
			self:SetWide(h)
			self:DockMargin(0, 0, galactic.theme.rem * .5, 0)
		end

		self.Spectrum = vgui.Create("DPanel", self)
		self.Spectrum:Dock(FILL)
		self.Spectrum.Shell = false
		self.Spectrum.Paint = function(self, w, h)
			if not IsValid(self.ply) then return end

			local settings = self.ply.GVCSettings or {}

			local voice = self.ply:VoiceVolume()
			if self.Shell then
				voice = math.Rand(0, 1)
			end

			// Voice Table to average the volume between bars/nodes
			self.voiceTable = self.voiceTable or {}
			table.insert(self.voiceTable, voice)

			if self.Timer == nil then
				self.Timer = 0;
			end
			self.Timer = self.Timer + RealFrameTime() * settings.PointsPerSecond;

			if self.Bars == nil then
				self.Bars = {};
			end

			if self.Reverse == nil then
				self.Reverse = false;
			end

			while math.ceil(self.Timer) > #self.Bars do
				local sum = 0

				for k,v in pairs(self.voiceTable) do
					sum = sum + v
				end

				table.insert(self.Bars, sum / #self.voiceTable);

				self.voiceTable = {}
			end

			local colBox = GAMEMODE:GetTeamColor(self.ply)



			local offset = 0
			local PointsWidth = settings.PointsWidth * galactic.theme.rem / 16
			local PointsGap = settings.PointsGap * galactic.theme.rem / 16
			local function GetPosPoint(k, v)
				local x = (k - 1 - self.Timer) * (PointsWidth + PointsGap) + w + offset;
				local y = h - v * h;
				return x, y;
			end

			for k,v in pairs(self.Bars) do
				local xPos, yPos = GetPosPoint(k, v);
				// Remove fill
				if xPos < 0 then
					table.remove(self.Bars, k);
					self.Timer = self.Timer - 1;

					if self.Reverse then
						self.Reverse = false;
					else
						self.Reverse = true;
					end
				else
					surface.SetDrawColor(Color(colBox.r,colBox.g,colBox.b,(xPos/w*255)))

					if settings.VoiceMode == galactic.voiceChat.bars.BOTTOM then
						surface.DrawRect(xPos, yPos, PointsWidth, v * h)
					elseif settings.VoiceMode == galactic.voiceChat.bars.TOP then
						surface.DrawRect(xPos, 0, PointsWidth, v * h)
					elseif settings.VoiceMode == galactic.voiceChat.bars.REVERSE then
						surface.DrawRect(xPos, h - v * h/2, PointsWidth, v * h/2)
						surface.DrawRect(xPos, 0, PointsWidth, v * h/2)
					elseif settings.VoiceMode == galactic.voiceChat.bars.CENTER then
						surface.DrawRect(xPos, yPos/2, PointsWidth, v * h)
					elseif k != 1 then
						offset = PointsWidth + PointsGap
						local xPos, yPos = GetPosPoint(k, v);
						local xPos2, yPos2 = GetPosPoint(k-1, self.Bars[k-1]);
						kc = k;
						if self.Reverse then
							kc = kc + 1
						end

						if kc % 2 == 0 then
							surface.DrawLine(xPos2, yPos2 / 2, xPos, h - yPos / 2);
						else
							surface.DrawLine(xPos2, h - yPos2 / 2, xPos, yPos / 2);
						end
					end
				end
			end
		end

		self.LabelName = vgui.Create("DLabel", self)
		self.LabelName:SetFont("GalacticDefault")
		self.LabelName:Dock(FILL)
		self.LabelName.Paint = function(self, w, h)
			self:SetTextColor(galactic.theme.colors.text)
		end

	end
	function PANEL:Paint(w, h)
		if not IsValid(self.ply) then return end
		self:SetSize(galactic.theme.rem * 15, galactic.theme.rem * 2.5)
		self:DockPadding(galactic.theme.rem * .25, galactic.theme.rem * .25, galactic.theme.rem * .25, galactic.theme.rem * .25)
		self:DockMargin(0, galactic.theme.rem * .25, 0, 0)
		draw.RoundedBox(galactic.theme.round, 0, 0, w, h, ColorAlpha(galactic.theme.colors.block, 255 * .9))
	end
	function PANEL:Setup(ply)
		if not ply then self.Spectrum.Shell = true end

		ply = ply or LocalPlayer()

		self.ply = ply
		self.Spectrum.ply = ply
		self.LabelName:SetText(ply:Nick())
		self.Avatar:SetPlayer( ply )
		
		self.Color = team.GetColor( ply:Team() )
		
		self:InvalidateLayout()
	end
	function PANEL:Think()
		if IsValid(self.ply) then
			self.LabelName:SetText(self.ply:Nick())
		end

		if not IsValid(self.ply) then
			GAMEMODE:PlayerEndVoice(self.ply)
		end

		if self.fadeAnim then
			self.fadeAnim:Run()
		end
	end
	function PANEL:FadeOut(anim, delta, data)
		if anim.Finished then
			if IsValid(PlayerVoicePanels[self.ply]) then
				PlayerVoicePanels[self.ply]:Remove()
				PlayerVoicePanels[self.ply] = nil
			end
			return
		end
		
		self:SetAlpha(255 - (255 * delta))
	end
	vgui.Register("GaPlayerVoice", PANEL, "Panel")

	/////////////////////////////////////////////////

	if LocalPlayer():IsValid() then
		self:InitPostEntity()
	end
end

function component:InitPostEntity()
	if galactic.voiceChatContainer then galactic.voiceChatContainer:Remove() end

	self.container = vgui.Create("Panel")
	galactic.voiceChatContainer = self.container
	self.container:ParentToHUD()
	self.container.Paint = function(self, w, h)
		self:SetWide(galactic.theme.rem * 15)
		self:SetPos(ScrW() - self:GetWide() - galactic.theme.rem, galactic.theme.rem)
		self:SetTall(ScrH() - 200)
		//draw.RoundedBox(galactic.theme.round, 0, 0, self:GetWide(), self:GetTall(), ColorAlpha(galactic.theme.colors.greenFaint, 200))
	end

end

function component:PlayerStartVoice(ply)
	if !IsValid(self.container) then return end
	
	//There'd be an exta one if voice_loopback is on, so remove it.
	//GAMEMODE:PlayerEndVoice( ply )


	if IsValid(PlayerVoicePanels[ply]) then

		if PlayerVoicePanels[ply].fadeAnim then
			PlayerVoicePanels[ply].fadeAnim:Stop()
			PlayerVoicePanels[ply].fadeAnim = nil
		end

		PlayerVoicePanels[ply]:SetAlpha(255)

		return false

	end

	if not IsValid(ply) then return end

	local pnl = self.container:Add( "GaPlayerVoice" )
	pnl:Setup(ply)
	
	PlayerVoicePanels[ply] = pnl

	return false
end

function component:PlayerEndVoice(ply)
	local plyVoicePanel = PlayerVoicePanels[ply]
	if IsValid(plyVoicePanel) then
		if plyVoicePanel.fadeAnim then return end

		plyVoicePanel.fadeAnim = Derma_Anim("FadeOut", plyVoicePanel, plyVoicePanel.FadeOut)
		plyVoicePanel.fadeAnim:Start(2)
	end

	return false
end

function component:HUDShouldDraw(name)
	local hideNames = {CHudVoiceStatus = true, CHudVoiceSelfStatus = true}
	if hideNames[name] then
		print(name)
		return false
	end
end

galactic:Register(component)
