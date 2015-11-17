gpio.mode(4,gpio.OUTPUT)

 

state = 0

 

tmr.alarm(0, 500, 1, function()

    if (state==0) then 

        state = 1

        gpio.write(4, gpio.HIGH) 

        else 

        state = 0

        gpio.write(4, gpio.LOW)     

    end

end)