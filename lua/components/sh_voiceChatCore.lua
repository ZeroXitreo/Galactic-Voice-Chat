local component = {}
component.dependencies = {"data"}
component.namespace = "voiceChat"
component.title = "Voice Chat Core"

component.netOnPlayerSettingsChanged = "GVCPlayerSettingsChange"
component.tableName = "GVCPlayerSettingsChange"
component.path = "shrun/VoiceChat.txt"
component.bars = {}
component.bars.BOTTOM = 1
component.bars.TOP = 2
component.bars.REVERSE = 3
component.bars.CENTER = 4
component.bars.SEQUENCE = 5

component.VoiceMode = "GVCVoiceMode"
component.PointsPerSecond = "GVCPointsPerSecond"
component.PointsWidth = "GVCPointsWidth"
component.PointsGap = "GVCPointsGap"

function component:Constructor()

	if SERVER then
		util.AddNetworkString(self.netOnPlayerSettingsChanged)

		net.Receive(self.netOnPlayerSettingsChanged, function(len, ply)

			if not ply.GVCSettings then
				for _, pl in ipairs(player.GetAll()) do
					if ply != pl and pl.GVCSettings then
						net.Start(self.netOnPlayerSettingsChanged)
						net.WriteEntity(pl)
						net.WriteCompressedTable(pl.GVCSettings)
						net.Send(ply)
					end
				end
			end

			ply.GVCSettings = net.ReadCompressedTable()

			net.Start(self.netOnPlayerSettingsChanged)
			net.WriteEntity(ply)
			net.WriteCompressedTable(ply.GVCSettings)
			net.SendOmit(ply)
		end)

	else
		net.Receive(self.netOnPlayerSettingsChanged, function(len)
			ply = net.ReadEntity()
			ply.GVCSettings = net.ReadCompressedTable()
		end)

		if LocalPlayer() != NULL then
			self:InitPostEntity()
		end
	end
end

if CLIENT then
	function component:InitPostEntity()
		self:Load()
		self:Upload()
	end

	function component:Load()
		local tbl = galactic.data:GetTable(component.namespace) or {}
		LocalPlayer().GVCSettings = {}
		LocalPlayer().GVCSettings.VoiceMode = tbl.VoiceMode or math.random(1, 6)
		LocalPlayer().GVCSettings.PointsPerSecond = tbl.PointsPerSecond or math.random(4, 33)
		LocalPlayer().GVCSettings.PointsWidth = tbl.PointsWidth or math.random(1, 17)
		LocalPlayer().GVCSettings.PointsGap = tbl.PointsGap or math.random(0, 5)
	end

	function component:Save()
		galactic.data:SetTable(component.namespace, LocalPlayer().GVCSettings)
		self:Upload()
	end

	function component:Upload()
		net.Start(self.netOnPlayerSettingsChanged)
		net.WriteCompressedTable(LocalPlayer().GVCSettings)
		net.SendToServer()
	end
end

galactic:Register(component)