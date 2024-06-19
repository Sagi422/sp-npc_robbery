local aimingAtNPC = false
local QBCore = exports['qb-core']:GetCoreObject()
local canrob = true

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        local currentWeapon = GetSelectedPedWeapon(playerPed)

        if canrob and IsPedAPlayer(playerPed) and IsPedArmed(playerPed, 7) and currentWeapon ~= GetHashKey("WEAPON_UNARMED") then
            local hit, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
            if hit and GetEntityType(entity) == 1 and IsPedHuman(entity) and not IsPedAPlayer(entity) then
                local npcPed = entity
                local npcPos = GetEntityCoords(npcPed)
                local distance = GetDistanceBetweenCoords(playerPos, npcPos, true)

                if distance <= 15.0 and not IsEntityDead(npcPed) then
                    aimingAtNPC = true

                    SetBlockingOfNonTemporaryEvents(npcPed, true)
                    SetPedFleeAttributes(npcPed, 0, false)
                    SetPedCombatAttributes(npcPed, 17, true)
                    SetPedCombatAttributes(npcPed, 46, true)

                    TaskHandsUp(npcPed, -1, playerPed, -1, true)

                    QBCore.Functions.Progressbar("rob_npc", "Robbing NPC", 5000, false, true, {
                        disableMovement = false,
                        disableCarMovement = false,
                        disableMouse = false,
                        disableCombat = false,
                    }, {}, {}, {}, function()
                        if not IsEntityDead(npcPed) then
                            ClearPedTasks(npcPed)
                            local amount = math.random(Config.minamount, Config.maxamount)
                            TriggerServerEvent("adddmoney:addMoney", amount)
                            QBCore.Functions.Notify("You robbed him of $" .. amount)
                            canrob = false
                            TaskSmartFleePed(npcPed, playerPed, 100.0, -1, false, false)
                        else
                            QBCore.Functions.Notify("The NPC is dead. Robbery failed.", "error")
                        end
                        Citizen.Wait(Config.cooldown)
                        canrob = true
                    end, function()
                        -- Cancel
                        ClearPedTasks(npcPed)
                        QBCore.Functions.Notify("Robbery canceled", "error")
                    end)
                else
                    aimingAtNPC = false
                end
            else
                aimingAtNPC = false
            end
        else
            aimingAtNPC = false
        end
    end
end)
