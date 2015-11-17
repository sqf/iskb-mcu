pin = 5
status,temp,humi,temp_decimial,humi_decimial = dht.readxx(pin)
if( status == dht.OK ) then
  -- Float firmware using this example
  print("DHT Temperaturee:"..temp..";".."Humidity:"..humi)
elseif( status == dht.ERROR_CHECKSUM ) then
  print( "DHT Checksum error." );
elseif( status == dht.ERROR_TIMEOUT ) then
  print( "DHT Time out." );
end
