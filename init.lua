uart.setup(0,115200,8,0,1) --establishes communication with the LoRa module
tmr.delay(100)

gpio.mode(4,gpio.OUTPUT)
gpio.mode(1,gpio.OUTPUT) --sets motor controller pin on ESP
gpio.write(1,gpio.LOW) --sets motor controller to OFF

network = "FritoPendejoWiFi_EXT" --enter network ID here
password = "Nb8a6qdq!" --enter password here

--variables below are for watering

waterDuration=0
waterDelay=0
systemClock=60000
thingspeakUpdate=20000
soilThres=0
intervals=0
currentTime=0

Bat1=0
Bat2=0
Temp1=0
Temp2=0

--separate thingspeak channels

controlProbe = "SMQ9OUC4A53N22JE"

deviceID = "Frito-backyard"

valve = "XUCAGL8AGAY96RKL"

--below are watering variables

waterCount=0
soilNow="dry"
delayGo="no"
delayCount=0
watering=0

--variables below are for thingspeak population

soilH201=0
soilH202=0
--all URLs

getURL = "http://app.plantgroup.co/api/controllers/"..deviceID.."/config/"
ts1URL = "http://api.thingspeak.com/update.json?api_key="..controlProbe.."&field1="..soilH202

--wifi configuration

wifi.setmode(wifi.STATION)

station_cfg={}
station_cfg.ssid=network
station_cfg.pwd=password
station_cfg.save=true
wifi.sta.config(station_cfg)

if(wifi.sta.status()==5) then
    gpio.write(4,gpio.LOW)
    else
    gpio.write(4,gpio.HIGH)
    end


dofile('request_queue.lua') --be able to use the request queue functions

rq = RequestQueue()



--return for the config request

function seconds(s)
    local pattern = "(%d+):(%d+)"
    local hours,min=string.match(s,pattern)
    return (hours*3600)+(min*60)
    end

function Intervals()
    stop={}
    begin={}
    for i=1,intervals do
    print(u["config"]["user"]["watering_schedule"][i]["end"])
    print(u["config"]["user"]["watering_schedule"][i]["begin"])
    table.insert(stop,seconds(u["config"]["user"]["watering_schedule"][i]["end"]))
    table.insert(begin,seconds(u["config"]["user"]["watering_schedule"][i]["begin"]))
    end
end

callback = function(code, data)
 if (code < 0) then
     print("HTTP request failed")
     print(code,data)
   else
     print(code, data)
     u=sjson.decode(data)
        thingspeakUpdate=nil
        systemClock=nil
        soilThres=nil
        waterDelay=nil
        waterDuration=nil
        intervals=nil
        currentTime=nil
        thingspeakUpdate=((u["config"]["system"]["sync_interval_seconds"])*1000)
        systemClock=(u["config"]["system"]["system_clock_seconds"])*1000
        soilThres=tonumber((u["config"]["user"]["soil_moisture_threshold"]))
        waterDelay=(u["config"]["user"]["watering_delay_seconds"])*1000
        waterDuration=(u["config"]["user"]["watering_duration_seconds"])*1000
        intervals=table.getn(u["config"]["user"]["watering_schedule"])
        currentTime=seconds((u["local_time"]))
        Intervals()
   end
   end
   
timeGet = function(code,data) 
	if(code<0) then 
		print("HTTP FAILED") 
		else
		currentUNIX = data*60
		print(currentUNIX)
		rtctime.set(currentUNIX,0)
		end
		end
------------------------Receive Data from Wireless Probes / Post Data Functions----------------

function ESPreceiveSoil(val,num)
    if(num==2) then
    soilH201=nil
    soilH201=val
    else
    soilH202=nil
    soilH202=val
    end
end
function ESPreceiveTemp(val,num)
   if(num==2) then
   Temp1=nil
   Temp1=val
   else
   Temp2=nil
   Temp2=val
   end
   end
function ESPreceiveBat(val,num)
    if(num==2) then
    Bat1=nil
    Bat1=val
    else
    Bat2=nil
    Bat2=val
    end
   end
function ESPreceiveID(val)
    ID=val
    end
------------------------Get Variables from Config Portion-----------------------------

function getVariables()
    rq:schedule({
        url = getURL,
        method = http.get,
        callback = callback
        })
    if wifi.sta.status()==5 then
    gpio.write(4,gpio.LOW)
    else
    gpio.write(4,gpio.HIGH)
    end
 end

 -----------------------Sync Time for Timestamp-------------------------------------------
 
 function syncTime()
	rq:schedule({
		url = "http://currentmillis.com/time/minutes-since-unix-epoch.php",
		method = http.get,
		callback = timeGet
        })
	end


------------------------Receive Data from Wireless Probes / Post Data Functions----------------
    
function sendData1()
if wifi.sta.status()==5 then
    gpio.write(4,gpio.LOW)
    else
    gpio.write(4,gpio.HIGH)
    end
  
  rq:schedule({
    url = "http://api.thingspeak.com/update.json?api_key="..controlProbe.."&field1="..soilH201.."&field2="..Bat1.."&field3="..Temp1,
    method = http.get,
    callback = function(code,data) print('hi frito') end
    })
  end



--10s delay before starting with the program, sufficient break execution if needed

syncTime()
getVariables()
rq:its_showtime()

tmr.alarm(0,10000,tmr.ALARM_SINGLE,function() dofile('ThingSpeak.lua')end)
tmr.alarm(1,10000,tmr.ALARM_SINGLE,function() dofile("timeCheck.lua")end)
    
