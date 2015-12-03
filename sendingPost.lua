wifi.setmode(wifi.STATION)
require('wifiAuth')
wifi.sta.config(ssid, pass)
gpio14 = 5
gpio12 = 6
motionSensor = 0
status = "unknown"
gpio.mode(gpio12,gpio.INT)
print('aaaaaaaaaa')
print(wifi.sta.status())

local readData = function() 
    status,temp,humi,temp_decimial,humi_decimial = dht.readxx(gpio14)
    if( status == dht.OK ) then
        status = "OK"
        print("DHT Temperature:"..temp..";".."Humidity:"..humi)
    elseif( status == dht.ERROR_CHECKSUM ) then
        status = "DHT Checksum error."
        print( "DHT Checksum error." );
    elseif( status == dht.ERROR_TIMEOUT ) then
        temp = 0
        humi = 0
        status = "DHT Time out."
        print( "DHT Time out." );
    end
end

local sendTempAndHumi = function()
    local key = 42
    local contentLength = string.len(temp..humi..placeName..status) + key
    conn = net.createConnection(net.TCP, 0) 
    conn:on("receive", function(conn, pl) print(pl) end)
    conn:on("connection", function(conn) conn:send("POST /sensor1 HTTP/1.1\r\nHost: iskb.senhadri.pl\r\n"
        .."Content-Type: application/x-www-form-urlencoded\r\nContent-Length: "..contentLength.."\r\n\r\ntemperature="..temp.."&humidity="..humi.."&place_name="..placeName
        .."&status="..status.."\r\n\r\n") end)
    conn:on("disconnection", function(conn) conn:close() end)
    conn:connect(80, "iskb.senhadri.pl")
end

local sendMovement = function()
    print("movement!!!")
    local key = 11
    local contentLength = string.len(placeName) + key
    conn = net.createConnection(net.TCP, 0) 
    conn:on("receive", function(conn, pl) print(pl) end)
    conn:on("connection", function(conn) conn:send("POST /movement1 HTTP/1.1\r\nHost: iskb.senhadri.pl\r\n"
        .."Content-Type: application/x-www-form-urlencoded\r\nContent-Length: "..contentLength.."\r\n\r\nplace_name="..placeName.."\r\n\r\n") end)
    conn:on("disconnection", function(conn) conn:close() end)
    conn:connect(80, "iskb.senhadri.pl")
end

gpio.trig(gpio12, "up", sendMovement)
tmr.alarm(1, 3000, 1, readData)
tmr.alarm(0, 3000, 1, sendTempAndHumi)
