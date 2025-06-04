local postalData = {}

-- Fordere die Postleitzahlen-Daten vom Server an, wenn der Client startet
Citizen.CreateThread(function()
    TriggerServerEvent('requestPostalData')
end)

-- Empfange die Postleitzahlen-Daten vom Server
RegisterNetEvent('receivePostalData')
AddEventHandler('receivePostalData', function(data)
    postalData = data
end)

-- Berechne die Entfernung zwischen zwei Punkten
function calculateDistance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

-- Finde die nächstgelegene Postleitzahl basierend auf der Spielerposition
function getNearestPostal(playerX, playerY)
    local closestPostal = nil
    local closestDistance = math.huge

    for _, postal in ipairs(postalData) do
        local distance = calculateDistance(playerX, playerY, postal.x, postal.y)
        if distance < closestDistance then
            closestDistance = distance
            closestPostal = postal.code
        end
    end

    return closestPostal
end

-- Finde die Koordinaten zu einer PLZ
function getPostalCoordinates(plz)
    for _, postal in ipairs(postalData) do
        if postal.code == plz then
            return postal.x, postal.y
        end
    end
    return nil, nil -- Keine passende PLZ gefunden
end

-- Command für Wegpunkt setzen: /p [PLZ]
RegisterCommand("p", function(source, args)
    local plz = args[1]

    -- Prüfen, ob eine PLZ eingegeben wurde
    if plz == nil then
        TriggerEvent('chat:addMessage', {
            args = {"^1Fehler", "Bitte gib eine Postleitzahl ein!"}
        })
        return
    end

    -- Suche nach den Koordinaten der PLZ
    local x, y = getPostalCoordinates(plz)

    -- Wenn Koordinaten gefunden wurden, Wegpunkt setzen
    if x ~= nil and y ~= nil then
        SetNewWaypoint(x, y)
        TriggerEvent('chat:addMessage', {
            args = {"^2Erfolg", "Wegpunkt zur PLZ " .. plz .. " wurde gesetzt."}
        })
    else
        TriggerEvent('chat:addMessage', {
            args = {"^1Fehler", "Keine gültige Postleitzahl gefunden."}
        })
    end
end, false)

-- HUD-Anzeige über der Minimap für PLZ und Spieler-ID
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500) -- HUD wird alle 500 ms aktualisiert

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local playerX, playerY = playerCoords.x, playerCoords.y

        -- Ermittlung der nächsten PLZ
        local postal = getNearestPostal(playerX, playerY)

        -- Ermittlung der Spieler-ID
        local playerID = GetPlayerServerId(PlayerId())

        -- Sende die Daten an das HTML-UI
        SendNUIMessage({
            plz = postal,
            id = playerID
        })
    end
end)
