huawei_signals = {
	"GSP_SEV_KSSEV_DIAGN_UK1_CONNECTION",
	"GSP_SEV_KSSEV_DIAGN_UK2_CONNECTION",
	"GSP_SEV_KSSEV_DIAGN_UK3_CONNECTION",
	"GSP_SEV_KSSEV_DIAGN_UK4_CONNECTION"
}


ping_table = {
	"192.168.1.25",		--УСО КТП1 Лантан 1
	"192.168.1.26",		--УСО КТП1 Лантан 2
	"192.168.1.35",		--УСО КТП2 Лантан 1
	"192.168.1.36",		--УСО КТП2 Лантан 2
	"192.168.1.45",		--УСО ГЩУ Лантан 1
	"192.168.1.46",		--УСО ГЩУ Лантан 2
	"192.168.1.47",		--УСО ГЩУ Лантан 3
	"192.168.1.48",		--УСО ГЩУ Лантан 4
	"192.168.1.55",		--САУ ВОС Лантан 1
	"192.168.1.56",		--САУ ВОС Лантан 2
	"192.168.1.57",		--САУ ВОС Лантан 3
	"192.168.1.58",		--САУ ВОС Лантан 4
	"192.168.1.65",		--УСО П Лантан 1
	"192.168.1.66",		--УСО П Лантан 2
	"192.168.1.74",		--УСО К Лантан 1
	"192.168.1.75",		--УСО К Лантан 2
	"192.168.1.76",		--УСО К Лантан 3
	"192.168.1.77",		--УСО К Лантан 4
	"192.168.1.78",		--УСО К Лантан 5
	"192.168.1.79",		--УСО К Лантан 6
	"192.168.1.85",		--УСО КОС1 Лантан 1
	"192.168.1.95",		--УСО КОС2 Лантан 1
	"192.168.1.104",	--УСО Э Лантан 1
	"192.168.1.105",	--УСО Э Лантан 2
	"192.168.1.106",	--УСО Э Лантан 3
	"192.168.1.107",	--УСО Э Лантан 4
	"192.168.1.108",	--УСО Э Лантан 5
	"192.168.1.109",	--УСО Э Лантан 6
	"192.168.1.15",		--Хуавей 1
	"192.168.1.16",		--Хуавей 2
	"192.168.1.150",	--Хуавей 3
	"192.168.1.160",	--Хуавей 4
	"192.168.1.41"		--ИБП Eaton
}

while true do 
	for i = 1, 28, 1 do 
		ping_success = os.execute('ping -n 2 '..ping_table[i])
			os.sleep(1)
			ping_lantan = {}
		if ping_success then
			Core.addLogMsg(ping_table[i].." online")
			Core["GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION["..(i-1).."]"] = 1
		else
			Core["GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION["..(i-1).."]"] = 2
			Core.addLogMsg(ping_table[i].." offline_offline_offline")
		end
	end

	for i = 29, 32, 1 do 
		ping_success = os.execute('ping -n 2 '..ping_table[i])
		os.sleep(1)
--[[	if ping_success == true then 
 	a = "false" 
	else
	a = "true"
end
Core.addLogMsg(a)]]
			ping_huawei = {}
		if ping_success then
			Core.addLogMsg(ping_table[i].." online")
			Core[huawei_signals[i-28]] = 1
		else
			Core[huawei_signals[i-28]] = 2			
			Core.addLogMsg(ping_table[i].." offline_offline_offline")
		end
	end

	ping_success = os.execute('ping -n 2 '..ping_table[33])
		os.sleep(1)
		if ping_success then
			Core.addLogMsg(ping_table[33].." online")
			Core["GSP_SEV_KSSEV_DIAGN_UPS1_CONNECTION"] = 1
		else
			Core["GSP_SEV_KSSEV_DIAGN_UPS1_CONNECTION"] = 2			
			Core.addLogMsg(ping_table[33].." offline_offline_offline")
		end

os.sleep(5)
end