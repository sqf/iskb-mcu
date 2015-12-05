wifi.setmode(wifi.STATION)
require('configuration')
wifi.sta.config(ssid, pass)
gpio14 = 5
gpio12 = 6
gpio.mode(gpio12, gpio.INT)
print('aaaaaaaaaa')
print(wifi.sta.status())

local readAndThenSendData = function() 
    local status, temp, humi = dht.readxx(gpio14)
    if (status == dht.OK) then
        sendData(temp, humi, "OK")
        print("DHT Temperature:"..temp..";".."Humidity:"..humi)
    elseif (status == dht.ERROR_CHECKSUM) then
        sendFault("DHT Checksum error.")
        print("DHT Checksum error.");
    elseif (status == dht.ERROR_TIMEOUT) then
        sendFault("DHT Time out.");
        print("DHT Time out.");
    else
        sendFault("Unknown sensor error.");
    end
end

function sendFault(status)
    local key = 6
    local contentLength = string.len(status) + key
    conn = net.createConnection(net.TCP, 0) 
    conn:on("receive", function(conn, pl) print(pl) end)
    conn:on("connection", function(conn) conn:send("POST /measurement HTTP/1.1\r\nHost: iskb.senhadri.pl\r\n"
        .."Content-Type: application/x-www-form-urlencoded\r\nContent-Length: "..contentLength..
        "\r\n\r\nstatus="..status.."\r\n\r\n") end)
    conn:on("disconnection", function(conn) conn:close() end)
    conn:connect(80, "iskb.senhadri.pl")
end

function sendData(temp, humi, status)
    local key = 42
    local contentLength = string.len(temp..humi..placeName..status) + key
    conn = net.createConnection(net.TCP, 0) 
    conn:on("receive", function(conn, pl) print(pl) end)
    conn:on("connection", function(conn) conn:send("POST /measurement HTTP/1.1\r\nHost: iskb.senhadri.pl\r\n"
        .."Content-Type: application/x-www-form-urlencoded\r\nContent-Length: "..contentLength..
        "\r\n\r\ntemperature="..temp.."&humidity="..humi.."&place_name="..placeName..
        "&status="..status.."\r\n\r\n") end)
    conn:on("disconnection", function(conn) conn:close() end)
    conn:connect(80, "iskb.senhadri.pl")
end

local sendMovement = function()
    print("movement!!!")
    local key = 11
    local contentLength = string.len(placeName) + key
    conn = net.createConnection(net.TCP, 0) 
    conn:on("receive", function(conn, pl) print(pl) end)
    conn:on("connection", function(conn) conn:send("POST /movement HTTP/1.1\r\nHost: iskb.senhadri.pl\r\n"
        .."Content-Type: application/x-www-form-urlencoded\r\nContent-Length: "..contentLength.."\r\n\r\nplace_name="..placeName.."\r\n\r\n") end)
    conn:on("disconnection", function(conn) conn:close() end)
    conn:connect(80, "iskb.senhadri.pl")
end

gpio.trig(gpio12, "up", sendMovement)
tmr.alarm(1, 3000, 1, readAndThenSendData)
--tmr.alarm(0, 3000, 1, sendTempAndHumi)
