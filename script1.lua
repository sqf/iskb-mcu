pin = 4
dht22 = require("dht22_min")
dht22.read(pin)
t = dht22.getTemperature()
h = dht22.getHumidity()

if h == nil then
  print("Error reading from DHT22")
else
  -- temperature in degrees Celsius  and Farenheit
  -- floating point and integer version:
  print("Temperature: "..((t-(t % 10)) / 10).."."..(t % 10).." deg C")
  -- only integer version:
  print("Temperature: "..(9 * t / 50 + 32).."."..(9 * t / 5 % 10).." deg F")
  -- only float point version:
  print("Temperature: "..(9 * t / 50 + 32).." deg F")
  
  -- humidity
  -- floating point and integer version
  print("Humidity: "..((h - (h % 10)) / 10).."."..(h % 10).."%")
end

-- release module
dht22 = nil
package.loaded["dht22"]=nil