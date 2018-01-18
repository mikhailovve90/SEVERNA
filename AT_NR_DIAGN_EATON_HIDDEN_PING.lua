--приложение для проверки пинга категории устройств
while(true)do

	local UPS1 = os.spawn("HiddenPing.exe", "192.168.1.41", true)
	if UPS1==0 then
		Core['GSP_SEV_KSSEV_DIAGN_UPS1_CONNECTION'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_UPS1_CONNECTION'] = 2;
	end

	local UPS2 = os.spawn("HiddenPing.exe", "192.168.1.42", true)
	if UPS2==0 then
		Core['GSP_SEV_KSSEV_DIAGN_UPS2_CONNECTION'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_UPS2_CONNECTION'] = 2;
	end

	os.sleep(3)
end 

