--пинг коммутаторов
while(true)do
	
	local Switch1 = os.spawn("HiddenPing.exe", "192.168.1.15", true)
	if Switch1==0 then
		Core['GSP_SEV_KSSEV_DIAGN_UK1_CONNECTION'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_UK1_CONNECTION'] = 2;
	end

	local Switch2 = os.spawn("HiddenPing.exe", "192.168.1.16", true)
	if Switch2==0 then
		Core['GSP_SEV_KSSEV_DIAGN_UK2_CONNECTION'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_UK2_CONNECTION'] = 2;
	end

	local Switch3 = os.spawn("HiddenPing.exe", "192.168.1.150", true)
	if Switch3==0 then
		Core['GSP_SEV_KSSEV_DIAGN_UK3_CONNECTION'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_UK3_CONNECTION'] = 2;
	end

	local Switch4 = os.spawn("HiddenPing.exe", "192.168.1.160", true)
	if Switch4==0 then
		Core['GSP_SEV_KSSEV_DIAGN_UK4_CONNECTION'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_UK4_CONNECTION'] = 2;
	end

	
	os.sleep(3)
end 
 