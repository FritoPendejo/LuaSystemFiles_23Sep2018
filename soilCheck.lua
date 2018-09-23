

if (tonumber(soilH201)<=soilThres) then
	soilNow="dry"
	print("soil is dry")
	else
	print("soil is wet")
	end
	
dofile("watering.lua")
