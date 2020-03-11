hook.Add("DatabaseInitialized", "[UTime]", function()
	MySQLite.query("CREATE TABLE IF NOT EXISTS utime ( player VARCHAR(17) NOT NULL PRIMARY KEY, totaltime INTEGER NOT NULL, lastvisit INTEGER NOT NULL );")
						
	MsgC(Color(0, 255, 255), "[UTime] ", color_white, "Connected to database!\n")
end)

local function onJoin(ply)
	local uid = ply:SteamID64()

	if !MySQLite and game.SinglePlayer() then 
		timer.Simple(5, function() onJoin(ply) end) 
		return 
	elseif !MySQLite then
		MsgC(Color(0, 255, 255), "[UTime] ", color_white, "This UTime version is only for DarkRP!\n")
		return
	end

	MySQLite.query("SELECT totaltime, lastvisit FROM utime WHERE player = '" .. uid .. "';", function(data)

		if !IsValid(ply) then return end
		local time = 0 

		if (data and data[1]) then
			MySQLite.query("UPDATE utime SET lastvisit = '" .. os.time() .. "' WHERE player = '" .. uid .. "';")
			time = data[1].totaltime
		else
			MySQLite.query("INSERT into utime (player, totaltime, lastvisit) VALUES ('" .. uid .. "', '0', '" .. os.time() .. "');")
		end

		ply:SetUTime(time)
		ply:SetUTimeStart(CurTime())

	end,function()
	
		ply.errorUTime = true
		ply:ChatPrint("[UTime] Your UTime data has errored. Reconnect/Inform a server admin about this issue.")

	end)
end
hook.Add("PlayerInitialSpawn", "UTimeInitialSpawn", onJoin)

local function updatePlayer(ply)
	if (ply.errorUTime || !MySQLite) then return end
	MySQLite.query("UPDATE utime SET totaltime = '" .. math.floor(ply:GetUTimeTotalTime()) .. "' WHERE player = '" .. ply:SteamID64() .. "';")
end
hook.Add("PlayerDisconnected", "UTimeDisconnect", updatePlayer)
