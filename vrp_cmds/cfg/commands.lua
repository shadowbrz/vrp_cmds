cfg = {}
local cfg = module("cfg/identity")
-- THIS FILE IS ON SERVER SIDE ( Just reminding you ;) )
--[[ Create Your commands inside the list cfg.commands like so: 
  ["/cmd"] = {
    action = function(p,color,msg)
	  -- function of what the command does
	end
  },
]]
-- p is player, color is {r, g, b} of the message and msg is the message of course.
cfg.commands = {
  ["/pos"] = {
    -- /pos to log postion to file with user name and msg
	action = function(p,color,msg) 
	  local user_id = vRP.getUserId(p)
	  if vRP.hasPermission(user_id,"admin.cmd_pos") then
	    local x,y,z,h = CMDclient.getPlayerPosH(p)
	    file = io.open("cmdPos.txt", "a")
		if file then
		  file:write(GetPlayerName(p).." at ".."{" .. x .. "," .. y .. "," .. z .. "," .. h .. "} wrote: "..(msg or "").."\n")
		end
		file:close()
		TriggerClientEvent('chatMessage', p, "SYSTEM", {255, 0, 0}, "Location sent to file!")
	  else
		TriggerClientEvent('chatMessage', p, "SYSTEM", {255, 0, 0}, "Você não tem permissão para executar este comando!")
	  end
	end
  },
  ["/t"] = {
    -- /t to send message to team from vrp_id_display
	action = function(p,color,msg) 
	  local user_id = vRP.getUserId(p)
	  if vRP.hasPermission(user_id,"player.cmd_team") then
	    if msg ~= nil and msg ~= "" then
	      local player = vRP.getUserSource(user_id)
	      local users = vRP.getUsers()
	      local job = vRP.getUserGroupByType(user_id,"job")
	      local teams = vRPidd.getUserTeamsByGroup(user_id,job)
	      local args = splitString(msg, " ")
		  local specific = args[1]
		  local new_msg = ""
		  for n,m in pairs(args) do
		    if n > 1 then
			  new_msg = new_msg .. " " .. m
			end
		  end
		  local send = {}
		  local sent = ""
		  local special = false
		  
		  if teams then
		    for x,y in pairs(teams) do
			  if specific == y then
			    special = true
			  end
			end
		    local r, g, b = IDDclient.getGroupColour(player,job)
			local tcount = 0
	        for i,t in pairs(teams) do
			  tcount = tcount + 1
			  if tcount == #teams then
			    sent = sent .. t
			  else
			    sent = sent .. t .. " | "
			  end
	          for k,v in pairs(users) do
	            local ujob = vRP.getUserGroupByType(k,"job")
	            local uteams = vRPidd.getUserTeamsByGroup(k,ujob)
			    for l,u in pairs(uteams) do
				  if not special and not send[k] then
		            if u == t then
					    send[k] = v
					end
				  else
					if specific == t then
					    send[k] = v
					end
			      end
				end
			  end
			end
			if special then 
			  msg = new_msg
			  sent = specific
			end
			for k,v in pairs(send) do
		      TriggerClientEvent('chatMessage', v, "["..sent.."] "..job.." | "..GetPlayerName(p), {r, g, b}, msg)
			end
		  else
			TriggerClientEvent('chatMessage', p, "SYSTEM", {255, 0, 0}, "You don't belong to a team!")
	      end
		end
	  else
		TriggerClientEvent('chatMessage', p, "SYSTEM", {255, 0, 0}, "Você não tem permissão para executar este comando!")
	  end
	end
  },
  ["/tp"] = {
    -- /tp to create linked areas that teleport to each other like doors
	action = function(p,color,msg) 
	  local user_id = vRP.getUserId(p)
	  if vRP.hasPermission(user_id,"admin.cmd_tp") then
	    if msg ~= nil then
	      local args = splitString(msg, " ")
	      local exists = false
	      local complete = false
	      if args[1] == "in" then
	        local teleports = vRP.getSData("vRP:cmd:teleports")
			local tps = json.decode(teleports)
			if tps == nil then
			  tps = {}
			end
			for k,v in pairs(tps) do
			  if k == args[2] then
				exists = true
			  end
			end
			local px,py,pz,ph = CMDclient.getPlayerPosH(p)
			if exists then
				tps[args[2]].pos_in = {x = px,y = py,z = pz,h = ph-180}
				TriggerClientEvent('chatMessage', p, "SYSTEM", {255, 0, 0}, "You moved the teleport in for "..args[2].." to this location!")
			else
				tps[args[2]] = {
				  pos_in = {x = px,y = py,z = pz,h = ph-180},
				  pos_out = nil,
				  active = false
				}
				TriggerClientEvent('chatMessage', p, "SYSTEM", {255, 0, 0}, "You created the teleport in for "..args[2].." in this location!")
			end
			vRP.setSData("vRP:cmd:teleports",json.encode(tps))
	      elseif args[1] == "out" then
	        local teleports = vRP.getSData("vRP:cmd:teleports")
			local tps = json.decode(teleports)
			if tps == nil then
			  tps = {}
			end
			for k,v in pairs(tps) do
			  if k == args[2] then
				exists = true
			  end
			end
			local px,py,pz,ph = CMDclient.getPlayerPosH(p)
			if exists then
				tps[args[2]].pos_out = {x = px,y = py,z = pz,h = ph-180}
				TriggerClientEvent('chatMessage', p, "SYSTEM", {255, 0, 0}, "You moved the teleport out for "..args[2].." to this location!")
			else
				tps[args[2]] = {
				  pos_in = nil,
				  pos_out = {x = px,y = py,z = pz,h = ph-180},
				  active = false
				}
				TriggerClientEvent('chatMessage', p, "SYSTEM", {255, 0, 0}, "You created the teleport out for "..args[2].." in this location!")
			end
			vRP.setSData("vRP:cmd:teleports",json.encode(tps))
	      elseif args[1] == "off" then
	        local teleports = vRP.getSData("vRP:cmd:teleports")
			local tps = json.decode(teleports)
			if tps == nil then
			  tps = {}
			end
			for k,v in pairs(tps) do
			  if k == args[2] then
				exists = true
				if v.pos_in and v.pos_out then
					complete = true
				end
			  end
			end
			if exists and complete then
			  tps[args[2]].active = false
			  vRP.setSData("vRP:cmd:teleports",json.encode(tps))
			  vRP.removeArea(-1,"vRP:cmd:tp:in:"..args[2])
			  vRPclient.removeNamedMarker(-1,"vRP:cmd:tp:in:"..args[2])
			  vRP.removeArea(-1,"vRP:cmd:tp:out:"..args[2])
			  vRPclient.removeNamedMarker(-1,"vRP:cmd:tp:out:"..args[2])
			  TriggerClientEvent('chatMessage', p, "SYSTEM", {255, 0, 0}, "You deactivated the teleport for "..args[2].."!")
			elseif exists then
			  TriggerClientEvent('chatMessage', p, "SYSTEM", {255, 0, 0}, "The teleport for "..args[2].." is not complete yet!")
			else
			  TriggerClientEvent('chatMessage', p, "SYSTEM", {255, 0, 0}, "The teleport for "..args[2].." is not created yet!")
			end
	      elseif args[1] == "on" then
	        local teleports = vRP.getSData("vRP:cmd:teleports")
			local tps = json.decode(teleports)
			if tps == nil then
			  tps = {}
			end
			for k,v in pairs(tps) do
			  if k == args[2] then
				exists = true
				if v.pos_in and v.pos_out then
				  complete = true
				end
			  end
			end
			if exists  and complete then
			  tps[args[2]].active = true
			  vRP.setSData("vRP:cmd:teleports",json.encode(tps))
			  local users = vRP.getUsers()
			  for k,v in pairs(users) do
			    vRPcmd.setTpIn(v,args[2],tps[args[2]].pos_in.x,tps[args[2]].pos_in.y,tps[args[2]].pos_in.z,tps[args[2]].pos_in.h,tps[args[2]].pos_out.x,tps[args[2]].pos_out.y,tps[args[2]].pos_out.z,tps[args[2]].pos_out.h)
			    vRPcmd.setTpOut(v,args[2],tps[args[2]].pos_in.x,tps[args[2]].pos_in.y,tps[args[2]].pos_in.z,tps[args[2]].pos_in.h,tps[args[2]].pos_out.x,tps[args[2]].pos_out.y,tps[args[2]].pos_out.z,tps[args[2]].pos_out.h)
			  end
            
			  TriggerClientEvent('chatMessage', p, "SYSTEM", {255, 0, 0}, "You activated the teleport for "..args[2].."!")
			elseif exists then
			  TriggerClientEvent('chatMessage', p, "SYSTEM", {255, 0, 0}, "The teleport for "..args[2].." is not complete yet!")
			else
			  TriggerClientEvent('chatMessage', p, "SYSTEM", {255, 0, 0}, "The teleport for "..args[2].." is not created yet!")
			end
	      elseif args[1] == "del" then
	        local teleports = vRP.getSData("vRP:cmd:teleports")
			local tps = json.decode(teleports)
			if tps == nil then
			  tps = {}
			end
			for k,v in pairs(tps) do
			  if k == args[2] then
				exists = true
				if v.pos_in and v.pos_out then
					complete = true
				end
			  end
			end
			if exists then
			  tps[args[2]] = nil
			  vRP.setSData("vRP:cmd:teleports",json.encode(tps))
			  vRP.removeArea(-1,"vRP:cmd:tp:in:"..args[2])
			  vRPclient.removeNamedMarker(-1,"vRP:cmd:tp:in:"..args[2])
			  vRP.removeArea(-1,"vRP:cmd:tp:out:"..args[2])
			  vRPclient.removeNamedMarker(-1,"vRP:cmd:tp:out:"..args[2])
			  TriggerClientEvent('chatMessage', p, "SYSTEM", {255, 0, 0}, "You deleted the teleport for "..args[2].."!")
			else
			  TriggerClientEvent('chatMessage', p, "SYSTEM", {255, 0, 0}, "The teleport for "..args[2].." is not created yet!")
			end
	      elseif args[1] == "show" then
	        local teleports = vRP.getSData("vRP:cmd:teleports")
			local tps = json.decode(teleports)
			if tps == nil then
			  tps = {}
			end
			local tps_str = ""
			if args[2] == nil then
			  for k,v in pairs(tps) do
			    if v ~= nil then
			      tps_str = tps_str .. " " .. k
				end
			  end
			  TriggerClientEvent('chatMessage', p, "SYSTEM", {255, 0, 0}, "Existing TPs:" .. tps_str)
			  TriggerClientEvent('chatMessage', p, "SYSTEM", {255, 0, 0}, "Usage: /tp show <tpName>")
			else
			  for k,v in pairs(tps) do
			    if k == args[2] then
			      if v ~= nil then
				    TriggerClientEvent('chatMessage', p, "SYSTEM", {255, 0, 0}, "Showing: " .. k)
				    if v.pos_in ~= nil then
				      TriggerClientEvent('chatMessage', p, "SYSTEM", {255, 0, 0}, "In: {" .. v.pos_in.x ..","..v.pos_in.y..","..v.pos_in.z..","..v.pos_in.h.."}")
					end
					if v.pos_out ~= nil then
				      TriggerClientEvent('chatMessage', p, "SYSTEM", {255, 0, 0}, "Out: {" .. v.pos_out.x ..","..v.pos_out.y..","..v.pos_out.z..","..v.pos_out.h.."}")
					end
					if v.active then
				      TriggerClientEvent('chatMessage', p, "SYSTEM", {255, 0, 0}, "State: on")
					else
				      TriggerClientEvent('chatMessage', p, "SYSTEM", {255, 0, 0}, "State: off")
					end
				  end
				end
			  end
			  TriggerClientEvent('chatMessage', p, "SYSTEM", {255, 0, 0}, "Use \"/tp show\" to show all existing TPs.")
			end
	      else
		    TriggerClientEvent('chatMessage', p, "SYSTEM", {255, 0, 0}, "Usage: /tp <in/out/on/off/del/show> <tpName>")
	      end
	    else
		  TriggerClientEvent('chatMessage', p, "SYSTEM", {255, 0, 0}, "Usage: /tp <in/out/on/off/del/show> <tpName>")
	    end
	  else
		TriggerClientEvent('chatMessage', p, "SYSTEM", {255, 0, 0}, "Você não tem permissão para executar este comando!")
	  end
	end
  },
  ["/mascara"] = {
    -- /mask toggles mask on and off
	action = function(p,color,msg)
	  local user_id = vRP.getUserId(p)
	  local handcuffed = vRPclient.isHandcuffed(p)
	if not vRPclient.isInComa(p) and not handcuffed then
	  if vRP.hasPermission(user_id,"player.cmd_mask") then
	    CMDclient.togglePlayerMask(p)
	  else
		TriggerClientEvent('chatMessage', p, "SYSTEM", {255, 0, 0}, "Você não tem permissão para executar este comando!")
	  end
	 end
	end
  },
  ["/placa"] = {
    -- /plate checks vehicle owner
	action = function(p,color,msg) 
	  local user_id = vRP.getUserId(p)
	  local rg = vRP.generateRegistrationNumber()
      local telefone = vRP.generatePhoneNumber()
	  local name = cfg.random_last_names[math.random(1,#cfg.random_last_names)]
	  local firstname = cfg.random_first_names[math.random(1,#cfg.random_first_names)]
	  if vRP.hasPermission(user_id,"police.cmd_plate") then
		if msg then
		    local user_id = vRP.getUserByRegistration(msg)
            if user_id then
              local identity = vRP.getUserIdentity(user_id)
              if identity then
				--TriggerClientEvent('chatMessage', p, "LSPD", {80, 80, 255},"Dono: ^2"..identity.name.." "..identity.firstname.."^0, Idade: ^2"..identity.age)
				TriggerClientEvent("pNotify:SendNotification",p,{text = "<span color='red'>Informações do Veiculo</b> <br />Dono: " ..identity.name.." "..identity.firstname.. "<br />Telefone: " .. identity.phone .. "<br/>RG: " .. identity.registration .. "<br/></span>", type = "info", timeout = (7500),layout = "centerLeft"})
			  else
		        TriggerClientEvent("pNotify:SendNotification",p,{text = "<span color='red'>Veiculo Roubado</b> <br />Dono: " ..name.." "..firstname.. "<br />Telefone: " .. telefone .. "<br/>RG: " .. rg .. "<br/></span>", type = "info", timeout = (7500),layout = "centerLeft"})
              end
            else
		      TriggerClientEvent("pNotify:SendNotification",p,{text = "<span color='red'>Veiculo Roubado</b> <br />Dono: " ..name.." "..firstname.. "<br />Telefone: " .. telefone .. "<br/>RG: " .. rg .. "<br/></span>", type = "info", timeout = (7500),layout = "centerLeft"})
            end
		else
		  TriggerClientEvent('chatMessage', p, "SERVER", {255, 0, 0}, "Use: /placa <placa>")
		end
	  else
		TriggerClientEvent('chatMessage', p, "SERVER", {255, 0, 0}, "Você não tem permissão para executar esse comando!")
	  end
	end
  },
  ["/apreender"] = {
    -- /plate checks vehicle owner
    action = function(p,color,msg)
	local user_id = vRP.getUserId(p)
    if vRP.hasPermission(user_id,"apreender.veiculo") then   
	   if msg then
         local user_id = vRP.getUserByRegistration(msg)
         local ok, vtype, model = GNclient.getNearestOwnedVehicle(vRP.getUserSource(user_id),50000)
         if ok then
             local carros = json.decode(vRP.getSData("apreendido:u"..user_id))
             if not carros then carros = {} end
             carros[model] = true
             vRP.setSData("apreendido:u"..user_id, json.encode(carros))
             TriggerClientEvent('chatMessage', p, "SERVER", {255, 0, 0}, "Veiculo apreendido!")
        end
	   end
	    else
	    TriggerClientEvent('chatMessage', p, "SERVER", {255, 0, 0}, "Você não tem permissão para executar este comando!")	   
      end
     end
  },
  ["/retirar"] = {
    action = function(p,color,msg)
	if CMDclient.getDistance(p,370.871,-1607.528,29.291) < 1 then
        local user_id = vRP.getUserId(p)
        local carros = json.decode(vRP.getSData("apreendido:u"..user_id))
        local apreendido = carros[msg]
        if apreendido then
            if vRP.tryPayment(user_id, 3000) then
                carros[msg] = nil
                vRP.setSData("apreendido:u"..user_id, json.encode(carros))
				TriggerClientEvent("pNotify:SendNotification",p,{text = "<span color='red'>Você pagou R$3000</span>", type = "success", timeout = (3000),layout = "centerLeft"})
            end
        end
		else
        TriggerClientEvent("pNotify:SendNotification",p,{text = "<span color='red'>Você está muito longe</span>", type = "error", timeout = (3000),layout = "centerLeft"})
      end
    end
  },
  ["/consultar"] = {
    action = function(p,color,msg) 
      if CMDclient.getDistance(p,369.830,-1609.027,29.291) < 1 then
        local user_id = vRP.getUserId(p)
        local carros = json.decode(vRP.getSData("apreendido:u"..user_id))
        local text = ""
        for k,v in pairs(carros) do
          text = text .. " " .. k
        end
        TriggerClientEvent('chatMessage', p, "Patio", {80, 80, 255},"Veículos que estão apreendidos: "..text)
      else
         TriggerClientEvent("pNotify:SendNotification",p,{text = "<span color='red'>Você está muito longe</span>", type = "error", timeout = (3000),layout = "centerLeft"})
      end
    end
  },
  ["/casa"] = {
    -- /homes show user homes from adv_homes
	action = function(p,color,msg) 
	  local user_id = vRP.getUserId(p)
	  if vRP.hasPermission(user_id,"player.cmd_homes") then
	      local adresses = vRPh.getUserAddresses(user_id)
		  local homeless = true
	      for k,address in pairs(adresses) do
		    homeless = false
		    TriggerClientEvent('chatMessage', p, "CASA "..k, {255, 0, 0},"Endereço: ^2".. address.home.."^0, Interfone: ^2"..address.number)
		  end
		  if homeless then
		    TriggerClientEvent('chatMessage', p, "SERVER", {255, 0, 0}, "Você não tem nenhuma casa!")
		  end
	  else
		TriggerClientEvent('chatMessage', p, "SERVER", {255, 0, 0}, "Você não tem permissão para executar este comando!")
	  end
	end
  },
  ["/pagarmultas"] = {
    action = function(p,color,msg) 
      if CMDclient.getDistance(p,248.245,222.336,107.180) < 3 then
        local user_id = vRP.getUserId(p)
        local multas = vRP.getUData(user_id,"multas")
        if multas == "" then multas = 0 else multas = tonumber(multas) end
        if vRP.tryPayment(user_id, multas) then
            vRP.setUData(user_id,"multas",0)
            vRP.insertPoliceRecord(user_id, "Pagou ".. multas .." R$ de multa")
			TriggerClientEvent("pNotify:SendNotification",p,{text = "Você pagou R$<span color='red'>" ..multas.. " em multas</span>", type = "success", timeout = (3000),layout = "centerLeft"})
        else
			TriggerClientEvent("pNotify:SendNotification",p,{text = "<span color='red'>Dinheiro insuficiente</span>", type = "error", timeout = (3000),layout = "centerLeft"})
        end
      else
		TriggerClientEvent("pNotify:SendNotification",p,{text = "<span color='red'>Você está muito longe</span>", type = "error", timeout = (3000),layout = "centerLeft"})
      end
    end
  },
  ["/vermultas"] = {
    action = function(p,color,msg) 
      if CMDclient.getDistance(p,246.529,223.064,106.286) < 3 then
        local user_id = vRP.getUserId(p)
        local multas = vRP.getUData(user_id,"multas")
        if multas == "" then multas = 0 else multas = tonumber(multas) end
			TriggerClientEvent('chatMessage', p, "Banco do Brasil", {80, 80, 255},"Você tem ^2R$"..multas.. "^0 em multas pendentes")
        else
			TriggerClientEvent("pNotify:SendNotification",p,{text = "<span color='red'>Você está muito longe</span>", type = "error", timeout = (3000),layout = "centerLeft"})
		end
    end
  },
  ["/multa"] = {
    -- /plate checks vehicle owner
    action = function(p,color,msg) 
      if msg ~= nil then
            local args = splitString(msg, " ")
            local user_id = vRP.getUserId(p)
            local target_id = tonumber(args[1])
            if vRP.hasPermission(user_id,"police.multas") then
                  local identity = vRP.getUserIdentity(target_id)
                  if identity then
                      local multas = vRP.getUData(target_id,"multas")
                      if multas == "" then multas = 0 else multas = tonumber(multas) end
                      TriggerClientEvent('chatMessage', p, "LSPD", {80, 80, 255},"Player: ^2"..identity.name.." "..identity.firstname.."^0, Tem: ^2R$"..multas.. "^0 em multas pendentes")
                  else
                      TriggerClientEvent('chatMessage', p, "SERVER", {255, 0, 0}, "Não há usuário para essa ID!")
                  end
            else
              TriggerClientEvent('chatMessage', p, "SERVER", {255, 0, 0}, "Você não tem permissão para executar este comando!")
            end
      else
            TriggerClientEvent('chatMessage', p, "SERVER", {255, 0, 0}, "Você deve digitar uma ID de usuário!")
      end
    end
  },
  --HERE GOES YOUR COMMANDS
  ["/discord"] = {
    -- /pos to log postion to file with user name and msg
    action = function(p,color,msg) 
        TriggerClientEvent("pNotify:SetQueueMax",p,"global", 8)

                TriggerClientEvent("pNotify:SendNotification",p,{text = "<b style='color:MediumPurple'>https://discord.gg/qEJHv</b> ", type = "info", timeout = (15000),layout = "centerLeft"})
    end
  },
}

return cfg