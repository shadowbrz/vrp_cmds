local cfg = module("vrp_cmds", "cfg/commands")
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local htmlEntities = module("vrp", "lib/htmlEntities")
vRPcmd = {}
vRP = Proxy.getInterface("vRP")
vRPidd = Proxy.getInterface("vrp_id_display")
vRPh = Proxy.getInterface("vrp_adv_homes")
vRPclient = Tunnel.getInterface("vRP")
CMDclient = Tunnel.getInterface("vrp_cmds")
IDDclient = Tunnel.getInterface("vrp_id_display")
GNclient = Tunnel.getInterface("vrp_adv_garages")
Tunnel.bindInterface("vrp_cmds",vRPcmd)

AddEventHandler("chatMessage", function(p, color, msg)
    if msg:sub(1, 1) == "/" then
        CancelEvent()
        text = splitString(msg, " ")
        cmd = text[1]
		args = text[2]
		for k,v in ipairs(text) do
          if k > 2 then
		    args = args.." "..v
          end
		end
		for k,v in pairs(cfg.commands) do
          if cmd == k then
		    v.action(p,color,args)
          end
		end
    end
end)

-- add tp areas areas on player first spawn
AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
  if first_spawn then
    local teleports = vRP.getSData("vRP:cmd:teleports")
    local tps = json.decode(teleports)
	if tps == nil then
	  tps = {}
	end
    for k,v in pairs(tps) do
	  if v.active then
		vRPcmd.setTpIn(source,k,v.pos_in.x,v.pos_in.y,v.pos_in.z,v.pos_in.h,v.pos_out.x,v.pos_out.y,v.pos_out.z,v.pos_out.h)
		vRPcmd.setTpOut(source,k,v.pos_in.x,v.pos_in.y,v.pos_in.z,v.pos_in.h,v.pos_out.x,v.pos_out.y,v.pos_out.z,v.pos_out.h)
	  end
    end
  end
end)

function vRPcmd.setTpIn(user,name,pos_in_x,pos_in_y,pos_in_z,pos_in_h,pos_out_x,pos_out_y,pos_out_z,pos_out_h)
  Citizen.CreateThread(function()
	vRP.setArea(user,"vRP:cmd:tp:in:"..name,pos_in_x,pos_in_y,pos_in_z,1,1.5,function(player, area)
		CMDclient.teleport(player,pos_out_x,pos_out_y,pos_out_z,pos_out_h)
		vRPclient.removeNamedMarker(player,"vRP:cmd:tp:out:"..name)
		vRP.removeArea(player,"vRP:cmd:tp:out:"..name)
		SetTimeout(5000,function() 
		  vRPcmd.setTpOut(player,name,pos_in_x,pos_in_y,pos_in_z,pos_in_h,pos_out_x,pos_out_y,pos_out_z,pos_out_h)
		end)
	end,nil)
	vRPclient.setNamedMarker(user,"vRP:cmd:tp:in:"..name, pos_in_x,pos_in_y,pos_in_z-1,0.7,0.7,0.5,255,226,0,125,150)
  end)
end

function vRPcmd.setTpOut(user,name,pos_in_x,pos_in_y,pos_in_z,pos_in_h,pos_out_x,pos_out_y,pos_out_z,pos_out_h)
  Citizen.CreateThread(function()
	vRP.setArea(user,"vRP:cmd:tp:out:"..name,pos_out_x,pos_out_y,pos_out_z,1,1.5,function(player, area)
		CMDclient.teleport(player,pos_in_x,pos_in_y,pos_in_z,pos_in_h)
		vRPclient.removeNamedMarker(player,"vRP:cmd:tp:in:"..name)
		vRP.removeArea(player,"vRP:cmd:tp:in:"..name)
		SetTimeout(5000,function() 
		  vRPcmd.setTpIn(player,name,pos_in_x,pos_in_y,pos_in_z,pos_in_h,pos_out_x,pos_out_y,pos_out_z,pos_out_h)
		end)
	end,nil)
	vRPclient.setNamedMarker(user,"vRP:cmd:tp:out:"..name, pos_out_x,pos_out_y,pos_out_z-1,0.7,0.7,0.5,255,226,0,125,150)
  end)
end