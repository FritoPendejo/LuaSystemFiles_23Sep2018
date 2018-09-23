genCall =  function(code,data) print('hi frito') end

if (delayGo=="yes") then
    dofile("delaying.lua")
	print("proceed to delay")
	gpio.write(1,gpio.LOW)
    end
	
if (soilNow=="dry" and delayGo=="no") then
print("watering time")
watering=1	
gpio.write(1,gpio.HIGH)
waterCount=waterCount+1
	if (waterCount==1) then
		current, usec, rate = rtctime.get()
		rq:schedule({
			url = "http://app.plantgroup.co/api/valves/777/record_event/",
            method = http.post,
            headers = 'Content-Type: application/json\r\n',
            body = '{"event_type":1,"created_at":'..current..'}',
            callback = function(code,data) print('response data:'..data) end
            })
	end
end

if (waterCount >= (waterDuration/systemClock)+1) then
	print("watering ended")
	gpio.write(1,gpio.LOW)
	current, usec, rate = rtctime.get()
	rq:schedule({
			url = "http://app.plantgroup.co/api/valves/777/record_event/",
            method = http.post,
            headers = 'Content-Type: application/json\r\n',
            body = '{"event_type":2,"created_at":'..current..'}',
            callback = function(code,data) print('response data:'..data) end
			})
	soilNow="wet"
	waterCount=0
    delayGo="yes"
    watering=0
	end
	

