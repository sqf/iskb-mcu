wifi.setmode(wifi.STATION)
require('configuration')
wifi.sta.config(ssid, pass)
local gpio14 = 5
local gpio12 = 6
gpio.mode(gpio12, gpio.INT)
print('aaaaaaaaaa4')
print(wifi.sta.status())

local function readTempAndHumi() 
    local status, temp, humi = dht.read(gpio14)
    local measurements = {}
    if (status == dht.OK) then
        measurements.temperature = temp
        measurements.humidity = humi
        measurements.status = "OK"
        print("DHT Temperature:"..temp.."".."Humidity:"..humi)
        return measurements
    elseif (status == dht.ERROR_CHECKSUM) then
        measurements.temperature = 0
        measurements.humidity = 0
        measurements.status = "Sensor checksum error."
        print("Sensor checksum error.")
        return measurements
    elseif (status == dht.ERROR_TIMEOUT) then
        measurements.temperature = 0
        measurements.humidity = 0
        measurements.status = "Sensor time out."
        print("Sensor time out.")
        return measurements
    end
end

local function generatePostMessage(requestUri, host, keysAndValuesTable)
    local keysAndValues = "";
    for key, value in pairs(keysAndValuesTable) do
        keysAndValues = keysAndValues..key.."="..value.."&";
    end
    keysAndValues = string.sub(keysAndValues,
        1, string.len(keysAndValues) - 1); -- deleting "&" at end
    local contentLength = string.len(keysAndValues);
    return "POST "..requestUri.." HTTP/1.1\r\nHost: "..host.."\r\n"..
           "Content-Type: application/x-www-form-urlencoded\r\n"..
           "Content-Length: "..contentLength..
           "\r\n\r\n"..keysAndValues
end

local function makeRequest(host, message)
    conn = net.createConnection(net.TCP, 0) 
    conn:connect(80, host)
    conn:on("connection",
        function(conn)
            conn:send(message)
        end
    )
    conn:on("receive", function(conn, pl)
        -- checking respond status
        if (string.sub(pl, 10, 12) ~= "200") then
            print(pl)
        end 
     end)
    conn:on("disconnection", function(conn) conn:close() end)
end

local function readAndThenSendTempAndHumi()
    local measurements = readTempAndHumi()
    measurements.place_name = placeName
    local postMessage = generatePostMessage("/measurement",
        targetHost, measurements)
    makeRequest(targetHost, postMessage)
end

local function sendMovement()
    local movement = {place_name = placeName}
    local postMessage = generatePostMessage("/movement", targetHost, movement)
    makeRequest(targetHost, postMessage)
end

gpio.trig(gpio12, "up", sendMovement)
tmr.alarm(1, interval, 1, readAndThenSendTempAndHumi)
