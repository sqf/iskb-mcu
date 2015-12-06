wifi.setmode(wifi.STATION)
require('configuration')
wifi.sta.config(ssid, pass)
gpio14 = 5
gpio12 = 6
gpio.mode(gpio12, gpio.INT)
print('aaaaaaaaaa')
print(wifi.sta.status())

local readTempAndHumi = function () 
    local status, temp, humi = dht.readxx(gpio14)
    local measurements = {temperature, humidity, status}
    if (status == dht.OK) then
        measurements.temperature = temp;
        measurements.humidity = humi;
        measurements.status = "OK";
        print("DHT Temperature:"..temp..";".."Humidity:"..humi);
        return measurements;
    elseif (status == dht.ERROR_CHECKSUM) then
        measurements.temperature = 0;
        measurements.humidity = 0;
        measurements.status = "Sensor checksum error.";
        print("Sensor checksum error.");
        return measurements;
    elseif (status == dht.ERROR_TIMEOUT) then
        measurements.temperature = 0;
        measurements.humidity = 0;
        measurements.status = "Sensor time out.";
        print("Sensor time out.");
        return measurements;
    end
end
local generatePostMessage = function (route, map)
    local keysAndValues = "";
    for key, value in pairs(map) do
        keysAndValues = keysAndValues..key.."="..value.."&"
    end
    local keysAndValues = string.sub(keysAndValues, 1, string.len(keysAndValues) - 1); -- deleting "&" at end
    local contentLength = string.len(keysAndValues);
    return "POST "..route.." HTTP/1.1\r\nHost: "..targetHost.."\r\n"
            .."Content-Type: application/x-www-form-urlencoded\r\nContent-Length: "
            ..contentLength.."\r\n\r\n"..keysAndValues.."\r\n\r\n"
end

function makeRequest(message)
    conn = net.createConnection(net.TCP, 0) 
    conn:on("receive", function(conn, pl) print(pl) end)
    conn:connect(80, targetHost)
    conn:on("connection",
        function(conn)
            conn:send(message)
        end
    )
    conn:on("disconnection", function(conn) conn:close() end)
end

local readAndThenSendTempAndHumi = function ()
    local map = readTempAndHumi();
    map.place_name = placeName;
    local postMessage = generatePostMessage("/measurement", map);
    makeRequest(postMessage);
end

local sendMovement = function ()
    local map = {place_name = placeName};
    local postMessage = generatePostMessage("/movement", map);
    makeRequest(postMessage);
end

gpio.trig(gpio12, "up", sendMovement)
tmr.alarm(1, interval, 1, readAndThenSendTempAndHumi)
