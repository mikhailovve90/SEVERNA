-- таймер запуска драйвера месячного опроса теплосчётчика (раз в месяц)
local flag = 0;
while ( 1) do
	os.sleep( 2678400);
	local t = os.date( "*t");
	if 01 <= t.day and t.day <= 03 and flag == 0 then
		Core.StartRequestMonth = true;
		flag = 1;
		local strH = string.format( "%02d.%02d.", t.day, t.month ) .. t.year .. " " .. string.format( "%02d:%02d", t.hour, t.min);
		Core.addLogMsg( "SPT943_TIMER_MONTH: запуск драйвера месячного опроса теплосчётчика " .. strH);
	end
	if 03 < t.day then
		Core.StartRequestMonth = false;
		flag = 0;
	end
end