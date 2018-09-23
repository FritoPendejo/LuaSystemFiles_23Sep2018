
-- send data every X ms to thing speak
tmr.alarm(3, thingspeakUpdate, tmr.ALARM_AUTO, function() sendData1() end )
