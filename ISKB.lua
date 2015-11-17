wifi.setmode(wifi.STATION)
wifi.sta.config("Illuminati","jarektalib666")
gpio0 = 3
gpio2 = 4
gpio14 = 5
local timeout = 60000
local tmrtimeout = 6
local lasttemp = -100
local lasthum = -100
local numreq = 0;
local connwait = false;
local numerr = 0;

local httpsend = function(txt)
    if connwait == true then
        numerr = numerr + 1
    else
        connwait = true
        tmr.alarm(tmrtimeout, timeout, 0, function() conn:close() connwait = false numerr = numerr + 1 end)
        conn = net.createConnection(net.TCP, 0) 
        conn:on("receive", function(conn, pl) print(pl) end)
        conn:on("sent", function(conn) numreq = numreq + 1 end)
        
        conn:on("connection", function(conn) conn:send("GET /temperaturaget?temperature=69 HTTP/1.1\r\nHost: termometr.senhadri.pl\r\n"
    .."Connection: close\r\nAccept: */*\r\n\r\n") end)
        conn:on("disconnection", function(conn) conn:close() tmr.stop(tmrtimeout) connwait = false end)
        conn:connect(80, "termometr.senhadri.pl")
    end
end

local checknode    =    function()
    if numerr > 20 then node.restart() end 
    if node.heap() < 1000 then node.restart() end
end
local checkdht = function()
    status,temp,humi,temp_decimial,humi_decimial = dht.readxx(gpio14)
    if( status == dht.OK ) then
      print("DHT Temperaturee:"..temp..";".."Humidity:"..humi)
    elseif( status == dht.ERROR_CHECKSUM ) then
      print( "DHT Checksum error." );
    elseif( status == dht.ERROR_TIMEOUT ) then
      print( "DHT Time out." );
    end
    if t > -400 then 
        lasttemp = temp
        lasthum = humi
        tmr.alarm(2, 50, 0, function() httpsend("&t="..lasttemp.."&h="..lasthum) end)
    else
        tmr.alarm(2, 50, 0, function() httpsend("&msg=dhtproblem") end)
    end
end
tmr.alarm(0, 10000, 1, checkdht)
tmr.alarm(1, 90000, 1, checknode)
