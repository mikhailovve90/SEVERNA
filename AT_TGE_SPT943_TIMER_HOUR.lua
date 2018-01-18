
-- таймер запуска драйвера часового опроса теплосчётчика (раз в час)
local flag = 0;
while ( 1) do
	os.sleep(60);
	local t = os.date( "*t");
	if 05 <= t.min and t.min <= 07 and flag == 0 then
		Core.StartRequestHour = true;
		flag = 1;
		local strH = string.format( "%02d.%02d.", t.day, t.month ) .. t.year .. " " .. string.format( "%02d:%02d", t.hour, t.min);
		Core.addLogMsg( "SPT943_TIMER_HOUR: запуск драйвера часового опроса теплосчётчика " .. strH);
	end
	if 07 < t.min then
		Core.StartRequestHour = false;
		flag = 0;
	end
end