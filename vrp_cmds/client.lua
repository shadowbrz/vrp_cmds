local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRPcmd = {}
vRP = Proxy.getInterface("vRP")
vRPserver = Tunnel.getInterface("vRP")
Tunnel.bindInterface("vrp_cmds",vRPcmd)

mask = nil

function vRPcmd.getPlayerPosH()
	x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
	local h = GetEntityHeading(GetPlayerPed(-1))
	return x , y , z , h
end

function vRPcmd.teleport(x,y,z,h)
	vRP.unjail() -- force unjail before a teleportation
    SetEntityCoords(GetPlayerPed(-1), x+0.0001, y+0.0001, z+0.0001, 1,0,0,1)
	SetEntityHeading(GetPlayerPed(-1), h+0.0001)
    vRPserver.updatePos(x+0.0001, y+0.0001, z+0.0001)
end

function vRPcmd.togglePlayerMask()
	local custom = vRP.getCustomization()
	if custom[1][1] == 0 then
	  custom[1] = mask
	else
	  mask = custom[1]
	  custom[1] = {0,0}
	end
	vRP.setCustomization(custom)
end

function DrawSpecialText(m_text, showtime)
	SetTextEntry_2("STRING")
	AddTextComponentString(m_text)
	DrawSubtitleTimed(showtime, 1)
end

function vRPcmd.getDistance(x,y,z)
    return GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), x,y,z, true )
end

-- Multas velocidade
Citizen.CreateThread(function ()
	while true do
		Citizen.Wait(0)
		DrawMarker(29, 248.245,222.336,107.180-1.0001, 0, 0, 0, 0, 0, 0, 1.0001,1.0001,1.0001, 0, 232, 255, 155, 0, 1, 2, 0, 0, 0, 0)
		if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), 248.245,222.336,106.286, true ) < 1 then
			DrawSpecialText("Digite ~y~/pagarmultas~s~")
		end
	end
end)

Citizen.CreateThread(function ()
	while true do
		Citizen.Wait(0)
		DrawMarker(29, 246.529,223.064,107.180-1.0001, 0, 0, 0, 0, 0, 0, 1.0001,1.0001,1.0001, 0, 232, 255, 155, 0, 1, 2, 0, 0, 0, 0)
		if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), 246.529,223.064,106.286, true ) < 1 then
			DrawSpecialText("Digite ~y~/vermultas~s~")
		end
	end
end)

-- Veiculo apreendido
Citizen.CreateThread(function ()
	while true do
		Citizen.Wait(0)
		DrawMarker(29, 370.871,-1607.528,29.991-1.0001, 0, 0, 0, 0, 0, 0, 1.0001,1.0001,1.0001, 0, 232, 255, 155, 0, 1, 2, 0, 0, 0, 0)
		if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), 370.871,-1607.528,29.291, true ) < 1 then
			DrawSpecialText("Digite ~y~/retirar (modelo do veiculo)~s~")
		end
	end
end)

Citizen.CreateThread(function ()
	while true do
		Citizen.Wait(0)
		DrawMarker(29, 369.830,-1609.027,29.991-1.0001, 0, 0, 0, 0, 0, 0, 1.0001,1.0001,1.0001, 0, 232, 255, 155, 0, 1, 2, 0, 0, 0, 0)
		if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), 369.830,-1609.027,29.291, true ) < 1 then
			DrawSpecialText("Digite ~y~/consultar~s~")
		end
	end
end)