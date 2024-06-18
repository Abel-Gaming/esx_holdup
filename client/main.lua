local holdingup = false
local store = ""
local secondsRemaining = 0
local blipRobbery = nil
ESX = exports["es_extended"]:getSharedObject()

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function drawTxt(x,y ,width,height,scale, text, r,g,b,a, outline)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    if(outline)then
	    SetTextOutline()
	end
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end

RegisterNetEvent('esx_holdup:currentlyrobbing')
AddEventHandler('esx_holdup:currentlyrobbing', function(robb, secondsRemaining)
	holdingup = true
	store = robb
	storeSecondsRemaining = secondsRemaining
end)

RegisterNetEvent('esx_holdup:killblip')
AddEventHandler('esx_holdup:killblip', function()
    RemoveBlip(blipRobbery)
end)

RegisterNetEvent('esx_holdup:setblip')
AddEventHandler('esx_holdup:setblip', function(position)
    blipRobbery = AddBlipForCoord(position.x, position.y, position.z)
    SetBlipSprite(blipRobbery , 161)
    SetBlipScale(blipRobbery , 2.0)
    SetBlipColour(blipRobbery, 3)
    PulseBlip(blipRobbery)
end)

RegisterNetEvent('esx_holdup:toofarlocal')
AddEventHandler('esx_holdup:toofarlocal', function(robb)
	holdingup = false
	ESX.ShowNotification(_U('robbery_cancelled'))
	robbingName = ""
	secondsRemaining = 0
	incircle = false
end)


RegisterNetEvent('esx_holdup:robberycomplete')
AddEventHandler('esx_holdup:robberycomplete', function(robb)
	holdingup = false
	ESX.ShowNotification(_U('robbery_cancelled') .. Stores[store].reward)
	store = ""
	secondsRemaining = 0
	incircle = false
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if holdingup then
			Citizen.Wait(1000)
			if(Stores[store].secondsRemaining > 0)then
				Stores[store].secondsRemaining = Stores[store].secondsRemaining - 1
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		local pos = GetEntityCoords(GetPlayerPed(-1), true)

		-- Draw the markers and be able to rob the stores
		for k,v in pairs(Stores)do
			local pos2 = v.position
			if(Vdist(pos.x, pos.y, pos.z, pos2.x, pos2.y, pos2.z) < 15.0)then
				if not holdingup then
					DrawMarker(1, v.position.x, v.position.y, v.position.z - 1, 0, 0, 0, 0, 0, 0, 1.0001, 1.0001, 1.5001, 1555, 0, 0,255, 0, 0, 0,0)
					if(Vdist(pos.x, pos.y, pos.z, pos2.x, pos2.y, pos2.z) < 1.0)then
						if (incircle == false) then
							DisplayHelpText(_U('press_to_rob') .. v.nameofstore)
						end
						incircle = true
						if IsControlJustReleased(1, 51) then
							TriggerServerEvent('esx_holdup:rob', k)
						end
					elseif(Vdist(pos.x, pos.y, pos.z, pos2.x, pos2.y, pos2.z) > 1.0)then
						incircle = false
					end
				end
			end
		end

		-- Check the distance from the store if a robbery is in progress
		if holdingup then
			drawTxt(0.66, 1.44, 1.0,1.0,0.4, _U('robbery_of') .. Stores[store].secondsRemaining .. _U('seconds_remaining'), 255, 255, 255, 255)
			local pos2 = Stores[store].position
			if(Vdist(pos.x, pos.y, pos.z, pos2.x, pos2.y, pos2.z) > 13)then
				TriggerServerEvent('esx_holdup:toofar', store)
			end
		end

		Citizen.Wait(0)
	end
end)
