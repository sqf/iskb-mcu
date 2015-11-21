wifi.setmode(wifi.STATION)
wifi.sta.config("Illuminati","jarektalib666")
gpio14 = 5
gpio12 = 6
motionSensor = 0
gpio.mode(gpio12,gpio.INPUT)
print('aaaaaaaaaa')
print(wifi.sta.status())
local readData = function() 
    status,temp,humi,temp_decimial,humi_decimial = dht.readxx(gpio14)
    if( status == dht.OK ) then
      print("DHT Temperature:"..temp..";".."Humidity:"..humi)
    elseif( status == dht.ERROR_CHECKSUM ) then
    print( "DHT Checksum error." );
    elseif( status == dht.ERROR_TIMEOUT ) then
      print( "DHT Time out." );
    end
    motionSensor = gpio.read(gpio12)
    print(motionSensor)
end
local sendData = function()
    conn=net.createConnection(net.TCP, 0) 
    conn:on("receive", function(conn, pl) print(pl) end)
    conn:on("connection", function(conn) conn:send("POST /temperature HTTP/1.1\r\nHost: termometr.senhadri.pl\r\n"
        .."Content-Type: application/x-www-form-urlencoded\r\nContent-Length: 17\r\n\r\ntemperature="..temp.."\r\n\r\n") end)
    conn:on("disconnection", function(conn) conn:close() end)
    conn:connect(80, "termometr.senhadri.pl")
end
tmr.alarm(1, 1000, 1, readData)
tmr.alarm(0, 3000, 1, sendData)
