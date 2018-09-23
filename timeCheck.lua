function timeCheck()

soilVal= nil
soilFloat= nil

--[[if adc.read(0) == 0 then
    soilVal=0
    else
    soilFloat = 17.229*(2.718^(adc.read(0)*0.0016)) 
    soilVal=string.sub(soilFloat,1,4)
    end]]--

if (stop == nil) then
    tim="bad"
    else
for i=1,intervals do
	if (currentTime <= stop[i] and currentTime >= begin[i]) then
		tim = "good"
		print("checking interval")
		dofile("soilCheck.lua")
		break
	else
		tim="bad"
	end	
end
end

	
if (tim=="bad") then 
	print("time bad")
	gpio.write(1,gpio.LOW)
	soilNow="wet"
	waterCount=0
	delayCount=0
	delayGo="no"
    watering=0
	end

end

tmr.alarm(2,systemClock,tmr.ALARM_AUTO, function() timeCheck() getVariables() rq:its_showtime() tmr.wdclr()end)
