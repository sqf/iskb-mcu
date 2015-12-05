gpio14 = 5
local readData = function() 
print('wszedlem se w readDat2a')
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
tmr.alarm(1, 400, 1, readData)