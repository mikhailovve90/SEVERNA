-- таймер запуска драйвера суточного опроса теплосчётчика (раз в сутки)
local flag = 0;
while ( 1) do
	os.sleep( 3600);
	local t = os.date( "*t");
	if 01 <= t.hour and t.hour <= 03 and flag == 0 then
		Core.StartRequestDate = true;
		flag = 1;
		local strH = string.format( "%02d.%02d.", t.day, t.month ) .. t.year .. " " .. string.format( "%02d:%02d", t.hour, t.min);
		Core.addLogMsg( "SPT943_TIMER_DATE: запуск драйвера суточного опроса теплосчётчика " .. strH);
	end
	if 03 < t.hour then
		Core.StartRequestDate = false;
		flag = 0;
	end
end