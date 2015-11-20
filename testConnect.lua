wifi.setmode(wifi.STATION)
wifi.sta.config("Illuminati","jarektalib666")
gpio14 = 5

print('aaaaaaaaaa')
print(wifi.sta.status())
local readData = function() 
    status,temp,humi,temp_decimial,humi_decimial = dht.readxx(gpio14)
    if( status == dht.OK ) then
      print("DHT Temperaturee:"..temp..";".."Humidity:"..humi)
    elseif( status == dht.ERROR_CHECKSUM ) then
    print( "DHT Checksum error." );
    elseif( status == dht.ERROR_TIMEOUT ) then
      print( "DHT Time out." );
    end
end
local sendData = function()
    conn=net.createConnection(net.TCP, 0) 
    conn:on("receive", function(conn, pl) print(pl) end)
    --conn:on("sent", function(conn) numreq = numreq + 1 end)
    conn:on("connection", function(conn) conn:send("GET /temperaturaget?temperature="..temp.." HTTP/1.1\r\nHost: termometr.senhadri.pl\r\n"
        .."Connection: close\r\nAccept: */*\r\n\r\n") end)
    conn:on("disconnection", function(conn) conn:close() end)
    conn:connect(80, "termometr.senhadri.pl")
end
tmr.alarm(1, 1000, 1, readData)
tmr.alarm(0, 3000, 1, sendData)