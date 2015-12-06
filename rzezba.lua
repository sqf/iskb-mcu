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
    local measurements = {
        {"temperature", "humidity", "status"}
    }
    if (status == dht.OK) then
        measurements[2] = {temp, humi, "ok"};
        print("DHT Temperature:"..temp..";".."Humidity:"..humi);
        return measurements;
    elseif (status == dht.ERROR_CHECKSUM) then
        measurements[2] = {0, 0, "Sensor checksum error."};
        print("Sensor checksum error.");
        return measurements;
    elseif (status == dht.ERROR_TIMEOUT) then
        measurements[2] = {0, 0, "Sensor time out."};
        print("Sensor time out.");
        return measurements;
    end
end
local makePostMessage = function (route, keysAndValuesTable) 
    local numberOfKeys = #keysAndValuesTable[1];
    local keysAndValues = "";
    for i = 1, numberOfKeys, 1
    do
        keysAndValues = keysAndValues..keysAndValuesTable[1][i].."="..keysAndValuesTable[2][i].."&"
    end
    local keysAndValues = string.sub(keysAndValues, 1, string.len(keysAndValues) - 1); -- deleting "&" at end
    print(keysAndValues)
    local contentLength = string.len(keysAndValues);
    print(contentLength)
    return "POST "..route.." HTTP/1.1\r\nHost: "..targetHost.."\r\n"
            .."Content-Type: application/x-www-form-urlencoded\r\nContent-Length: "
            ..contentLength.."\r\n\r\n"..keysAndValues.."\r\n\r\n"
end

function sendData(message)
    conn = net.createConnection(net.TCP, 0) 
    conn:on("receive", function(conn, pl) print(pl) end)
    conn:on("connection",
        function(conn)
            print(message)
            conn:send(message)
        end
    )
    conn:on("disconnection", function(conn) conn:close() end)
    conn:connect(80, targetHost)
end

local readAndThenSendTempAndHumi = function ()
    local keysAndValues = readTempAndHumi();
    table.insert(keysAndValues[1], "place_name");
    table.insert(keysAndValues[2], placeName);
    local postMessage = makePostMessage("/measurement", keysAndValues);
    sendData(postMessage);
end

local sendMovement = function()
    print("movement!!!")
    local constantPart = 11
    local contentLength = string.len(placeName) + constantPart;
    print(contentLength)
    conn = net.createConnection(net.TCP, 0) 
    conn:on("receive", function(conn, pl) print(pl) end)
    conn:on("connection",
        function(conn)
            conn:send("POST /movement HTTP/1.1\r\nHost: iskb.senhadri.pl\r\n"
            .."Content-Type: application/x-www-form-urlencoded\r\nContent-Length: "
            ..contentLength.."\r\n\r\nplace_name="..placeName.."\r\n\r\n")
        end
    )
    conn:on("disconnection", function(conn) conn:close() end)
    conn:connect(80, "iskb.senhadri.pl")
end

gpio.trig(gpio12, "up", sendMovement)
tmr.alarm(1, interval, 1, readAndThenSendTempAndHumi)
