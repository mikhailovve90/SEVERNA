--    hidden ping для опроса всех устройств в системе по ip-адресу

while(true)do
	--  Опрос коммутаторов Huawei  
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

	
	--  Опрос ИБП
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


	-- Опрос преобразователей Лантан

	-- УСО Э
	local Lantan1 = os.spawn("HiddenPing.exe", "192.168.1.104", true)
	if Lantan1==0 then
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[0]'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[0]'] = 2;
	end

	local Lantan2 = os.spawn("HiddenPing.exe", "192.168.1.105", true)
	if Lantan2==0 then
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[1]'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[1]'] = 2;
	end

	local Lantan3 = os.spawn("HiddenPing.exe", "192.168.1.106", true)
	if Lantan3==0 then
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[2]'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[2]'] = 2;
	end

	local Lantan4 = os.spawn("HiddenPing.exe", "192.168.1.107", true)
	if Lantan4==0 then
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[3]'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[3]'] = 2;
	end

	local Lantan5 = os.spawn("HiddenPing.exe", "192.168.1.108", true)
	if Lantan5==0 then
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[4]'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[4]'] = 2;
	end

	local Lantan6 = os.spawn("HiddenPing.exe", "192.168.1.109", true)
	if Lantan6==0 then
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[5]'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[5]'] = 2;
	end

 -- УСО КТП1
	local Lantan7 = os.spawn("HiddenPing.exe", "192.168.1.25", true)
	if Lantan7==0 then
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[6]'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[6]'] = 2;
	end

	local Lantan8 = os.spawn("HiddenPing.exe", "192.168.1.26", true)
	if Lantan8==0 then
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[7]'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[7]'] = 2;
	end

--УСО ГЩУ

	local Lantan9 = os.spawn("HiddenPing.exe", "192.168.1.45", true)
	if Lantan9==0 then
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[8]'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[8]'] = 2;
	end

	local Lantan10 = os.spawn("HiddenPing.exe", "192.168.1.46", true)
	if Lantan10==0 then
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[9]'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[9]'] = 2;
	end

	local Lantan11 = os.spawn("HiddenPing.exe", "192.168.1.47", true)
	if Lantan11==0 then
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[10]'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[10]'] = 2;
	end

	local Lantan12 = os.spawn("HiddenPing.exe", "192.168.1.48", true)
	if Lantan12==0 then
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[11]'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[11]'] = 2;
	end

--УСО КТП2

	local Lantan13 = os.spawn("HiddenPing.exe", "192.168.1.35", true)
	if Lantan13==0 then
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[12]'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[12]'] = 2;
	end

	local Lantan14 = os.spawn("HiddenPing.exe", "192.168.1.36", true)
	if Lantan14==0 then
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[13]'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[13]'] = 2;
	end

--УСО К

	local Lantan15 = os.spawn("HiddenPing.exe", "192.168.1.74", true)
	if Lantan15==0 then
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[14]'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[14]'] = 2;
	end

	local Lantan16 = os.spawn("HiddenPing.exe", "192.168.1.75", true)
	if Lantan16==0 then
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[15]'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[15]'] = 2;
	end

	local Lantan17 = os.spawn("HiddenPing.exe", "192.168.1.76", true)
	if Lantan17==0 then
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[16]'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[16]'] = 2;
	end

	local Lantan18 = os.spawn("HiddenPing.exe", "192.168.1.77", true)
	if Lantan18==0 then
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[17]'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[17]'] = 2;
	end

	local Lantan19 = os.spawn("HiddenPing.exe", "192.168.1.78", true)
	if Lantan19==0 then
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[18]'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[18]'] = 2;
	end

	local Lantan20 = os.spawn("HiddenPing.exe", "192.168.1.79", true)
	if Lantan20==0 then
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[19]'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[19]'] = 2;
	end

--УСО П

	local Lantan21 = os.spawn("HiddenPing.exe", "192.168.1.65", true)
	if Lantan21==0 then
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[20]'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[20]'] = 2;
	end

	local Lantan22 = os.spawn("HiddenPing.exe", "192.168.1.66", true)
	if Lantan22==0 then
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[21]'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[21]'] = 2;
	end

--САУ ВОС

	local Lantan23 = os.spawn("HiddenPing.exe", "192.168.1.55", true)
	if Lantan23==0 then
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[22]'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[22]'] = 2;
	end

	local Lantan24 = os.spawn("HiddenPing.exe", "192.168.1.56", true)
	if Lantan24==0 then
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[23]'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[23]'] = 2;
	end

	local Lantan25 = os.spawn("HiddenPing.exe", "192.168.1.57", true)
	if Lantan25==0 then
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[24]'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[24]'] = 2;
	end

	local Lantan26 = os.spawn("HiddenPing.exe", "192.168.1.58", true)
	if Lantan26==0 then
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[25]'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[25]'] = 2;
	end

--КОС 1

	local Lantan27 = os.spawn("HiddenPing.exe", "192.168.1.85", true)
	if Lantan27==0 then
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[26]'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[26]'] = 2;
	end

--КОС 2

	local Lantan28 = os.spawn("HiddenPing.exe", "192.168.1.95", true)
	if Lantan28==0 then
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[27]'] = 1;
	else
		Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[27]'] = 2;
	end


	os.sleep(3)
end 
 