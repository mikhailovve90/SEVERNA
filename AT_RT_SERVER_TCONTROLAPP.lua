	
	local g_Logs=true --вести логи
	local g_delay=5 --пауза (сек) таймаут между запросами серверов друг другу
	local g_MainServerNum="MainServerFlag" --имя глобальной переменной-номера активного сервера
 	local g_ReInit=false --необходимость повторной инициализации приоритетов
 	local g_noConnect=false --отсутствие связи с партнером
	local g_FirstServerNameSuffix='N1' --суффикс в имени 1-го сервера
	local g_SecondServerNameSuffix='N2' --суффикс в имени 2-го сервера
	local g_IamFirst = false -- флаг первого сервера
	local g_NodeName = Core.getName() --выдает имя_узла (c .Loader)
	local g_PartnerName='' -- имя приложения-партнера по резерву 
	local ScreenID="DIAGN"
	--local User="(система)"
	--local event =require("./_events_desc"); -- считаем описание классов аварийных сообщений
--	local Servers={-- список серверов
	--				['N1']={},
		--			['N2']={},
			--		}

--	Core.addEvent( g_NodeName , event.w, 1 ,"Source", User, "", os.time(), ScreenID )
			local g_counter=0 --счетчик итераций
			local g_partner_counter=0 --счетчик итераций на узле -партнере
			local g_partner_oldcounter=1 --счетчик итераций на узле -партнере (предыдущее значение)
	
	--определяем номер сервера: 1 или 2 -----------------------------------------
	--(по имени узла, где в конце обязательно то что содержится в g_FirstServerNameSuffix или g_SecondServerNameSuffix)------------------
	if string.match(g_NodeName , g_FirstServerNameSuffix) ~= nil then -- если в имени узла содержится признак 1-го сервера
		g_IamFirst = true --Это первый сервер
		g_PartnerName=string.gsub(g_NodeName, g_FirstServerNameSuffix, g_SecondServerNameSuffix)--узнаем имя приложения-партнера по резерву 
	elseif string.match(g_NodeName , g_SecondServerNameSuffix) ~= nil then -- это сервер №2
		g_IamFirst = false --Это второй сервер
	    g_PartnerName=string.gsub(g_NodeName, g_SecondServerNameSuffix, g_FirstServerNameSuffix)--узнаем имя приложения-партнера по резерву 
	else
		if g_Logs then
			Core.addLogMsg("В именах узлов не содержится признаков 1-го или 2-го сервера")	
		end --		if g_Logs
		return -- завершить
	end --if string.match(g_NodeName , g_FirstServerNameSuffix) ~= nil
--///////////инициализация скрипта
		--os.sleep(0.1)
	local g_MainServerNumber=Core[g_MainServerNum] --получаем из ядра номер основного сервера
	--0local g_MainServerNumber=Core.directGet(g_PartnerName, 1, g_MainServerNum, 0)
--Core.directGet(ip:port | appName, tout, signalId|signalName, cellIndex [, archTime, archOffset])
	if not g_MainServerNumber or g_MainServerNumber<1 or g_MainServerNumber>2 then -- если основной сервер не определен
			g_MainServerNumber=1 -- им становится первый
			Core[g_MainServerNum]=g_MainServerNumber
	end --if not g_MainServerNumber

local function Init()
--/////////-- определение роли сервера в системе --///////////////
			if g_MainServerNumber==1 and g_IamFirst==true then --если сервер первый и он должен быть основным
					Core.setReserve(g_NodeName, false) -- основной
					Core.ServerAppValid[0]=0
			elseif g_MainServerNumber==2 and g_IamFirst==true then --если сервер первый и он должен быть резервным
					Core.setReserve(g_NodeName, true)-- резервный
--								Core.setReserve(g_PartnerName, false)
			elseif g_MainServerNumber==2 and g_IamFirst==false then --если сервер второй и он должен быть основным
	 				Core.setReserve(g_NodeName, false) --основной
								--	Core.setReserve(g_PartnerName, true)
			elseif g_MainServerNumber==1 and g_IamFirst==false then --если сервер второй и он должен быть резервным
					Core.setReserve(g_NodeName, true)-- резервный
					Core.ServerAppValid[1]=0
		--							Core.setReserve(g_PartnerName, false)
			end--if Core[g_MainServerNum]==1

end --Init()

local function SwitchServers() --функция переключения серверов
--Core.setReserve(g_NodeName, true) --сделаем основным
						g_MainServerNumber=Core[g_MainServerNum] --получаем из ядра номер основного сервера
						if g_MainServerNumber==1 and g_IamFirst==false then 
							Core.setReserve(g_NodeName, true) -- резервный
							Core.addEvent("Второй сервер выведен в резерв",101,1, 'Сервер №1','Система','SRV1RES', os.time(), ScreenID )
							Core.addLogMsg("Второй сервер выведен в резерв")
						elseif g_MainServerNumber==2 and g_IamFirst==true then
							Core.setReserve(g_NodeName, true) -- резервный
							Core.addEvent("Первый сервер выведен в резерв",101, 1 ,'Сервер №2', 'Система', 'SRV2RES', os.time(), ScreenID )
							Core.addLogMsg("1 сервер выведен в резерв")
						elseif g_MainServerNumber==2 and g_IamFirst==false then 
							Core.setReserve(g_NodeName, false) -- основной
							Core.addEvent("Второй сервер назначен основным", 101,0 ,'Сервер №2', 'Система', 'SRV2RES', os.time(), ScreenID )
							Core.addLogMsg("Второй сервер стал основным")
						elseif g_MainServerNumber==1 and g_IamFirst==true then 
							Core.setReserve(g_NodeName, false) -- основной
							Core.addEvent("Первый сервер назначен основным",101,0, 'Сервер №1','Система','SRV1RES', os.time(), ScreenID )						
							Core.addLogMsg("1 сервер стал основным")
						end-- if (g_MainServerNumber==1 


end --SwitchServers()


Init()

while true do

--здесь код, который анализирует состояния узлов в процессе работы
    -- и осуществляет переключения в резерв и в основной
		
--определение счетчиков итераций для определения состояния приложений
-- (приложение ведет свой счетчик и отслеживает счетчик партнера. если тот остановился - приложение считается рухнувшим)
-- счетчики ведутся в глобальной переменной ServerAppValid ( тип WORD, разрмерность 2)
	--	Core.addEvent( g_NodeName , event.w, 1 ,"Source", User, "", os.time(), ScreenID )

			if g_IamFirst==true then --если это первый сервер
					g_counter=Core.ServerAppValid[0] --ячейка этого сервера (обрабатываем)
					g_partner_counter=Core.ServerAppValid[1]--ячейка сервера-партнера (отслеживаем)
			else --if g_IamFirst==true
					g_counter=Core.ServerAppValid[1] --ячейка этого сервера (обрабатываем)
					g_partner_counter=Core.ServerAppValid[0]--ячейка сервера-партнера (отслеживаем)
			end --if g_IamFirst==true

-- в зависимости от состояния сети
			if Core.getLatency(g_PartnerName)== -1 then --если партнер не отвечает по сети	
				if g_noConnect==false then 
					Core.setReserve(g_NodeName, false) --сделаем основным
					if g_IamFirst==true then -- обновим флаги
						Core[g_MainServerNum]=1
						Core.addEvent("Потеряна связь со 2-м сервером. 1-й сервер стал основным")--,10000, 1 ,'Сервер №1', 'Система', 'SRV2RES', os.time(), ScreenID )
						Core.addLogMsg("Потеряна связь со 2-м сервером. 1-й сервер стал основным ".. os.time())
					else
						Core[g_MainServerNum]=2
						Core.addEvent("Потеряна связь со 1-м сервером. 2-й сервер стал основным")--,10000, 1 ,'Сервер №2', 'Система', 'SRV1RES', os.time(), ScreenID )
						Core.addLogMsg("Потеряна связь со 1-м сервером. 2-й сервер стал основным ".. os.time())

					end--if g_IamFirst==true
					g_noConnect=true
				end--if g_noConnect==false
					--g_ReInit=true-- обрыв связи случился
			else	--если партнер доступен в сети	
					g_noConnect=false
					if g_partner_counter==g_partner_oldcounter then --счетчик итераций партнера остановился 
						g_ReInit=true --зафиксирована остановка узла
						
						--Core.addLogMsg("Приложение-партнер остановлено")
						if Core.isReserved(g_NodeName,1)==true then --если узел в резерве
							Core.setReserve(g_NodeName, false) --сделаем основным

							if g_IamFirst==true then -- обновим флаги
								Core[g_MainServerNum]=1
							else
								Core[g_MainServerNum]=2
							end --if g_IamFirst
						end--	if Core.isReserved(g_NodeName,1)
					end--if g_partner_counter==g_partner_oldcounter
			end--if Core.getLatency(g_PartnerName)
			
--.....обработем собственный счетчик итераций	
			if g_counter<65535 then --если значение счетчика не переполнено (для переменной типа WORD)
					g_counter=g_counter+1--увеличим значение счетчика
			else --if g_counter<65535 
					g_counter=0 --обнулим для исключения переполнения стека памяти
			end--	if counter<65535 then
			-- обновим значение глобальной переменной
			if g_IamFirst==true then --если это первый сервер
					Core.ServerAppValid[0]=g_counter
			else --если это 2-й сервер
					Core.ServerAppValid[1]=g_counter
			end --if g_IamFirst==true
					
			Core.onExtChange({g_MainServerNum}, SwitchServers, {})
			--Core.setMessage("c="..tostring(g_counter).. " pc=" ..tostring(g_partner_counter).. " opc=" ..tostring(g_partner_oldcounter))	
			g_partner_oldcounter=g_partner_counter --сохраним в нашем приложении значение счетчика узла-партнера
			os.sleep(g_delay) --ждем

end--while true
