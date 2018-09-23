delayCount=delayCount+1
print("in delay")
if (delayCount>=waterDelay/systemClock) then
	delayCount=0
	delayGo="no"
	print("delay over")
	end
