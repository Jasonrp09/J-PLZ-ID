local postalData = {}

-- Lade die Postleitzahlen aus der JSON-Datei
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        local file = LoadResourceFile(GetCurrentResourceName(), 'j-postals.json')
        if file then
            postalData = json.decode(file)
            print("Postleitzahlen erfolgreich geladen.")
        else
            print("Fehler beim Laden der Postleitzahlen.")
        end
    end
end)


RegisterNetEvent('requestPostalData')
AddEventHandler('requestPostalData', function()
    local _source = source
    TriggerClientEvent('receivePostalData', _source, postalData)
end)
