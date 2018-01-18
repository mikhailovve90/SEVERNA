--******************************************************************
--********************* РАЗДЕЛ ИНИЦИАЛИЗАЦИИ ***********************
--******************************************************************

--******************************************************************
-- инициализация элементов дат (глобальных переменных)

function InitDate()
	
	for y = 0, 2 do					
        for i = 0, LastIndex_m do			 
			Core.Meter_E[y].Archive_E[i].D[0] = epoch[i+1] 
		end
	end
		Core.DateFirst = Core.Meter_E[metnum].Archive_E[FirstIndex_m].D[0] 	-- DateFirst - дата первой записи архива
		Core.DateLast = Core.Meter_E[metnum].Archive_E[LastIndex_m].D[0] 	-- DateLast - дата последней записи архива
    return DateFirst, DateLast
end

--******************************************************************
-- инициализация глобальных переменных архива (активная энергия - приём)

function InitEaReceive()

	for y = 0, 2 do	
	    for x = 0, LastIndex_m do
	        for i = 0, 47 do Core.Meter_E[y].Archive_E[x].HHA[0].Ea_Receive[i] = math.random()*100 end	
	        for i = 0, 23 do Core.Meter_E[y].Archive_E[x].HA[0].Ea_Receive[i] = math.random()*100 end	
	        for i = 0, 30 do Core.Meter_E[y].Archive_E[x].DA[0].Ea_Receive[i] = math.random()*100 end
	        for i = 0, 11 do Core.Meter_E[y].Archive_E[x].MA[0].Ea_Receive[i] = math.random()*100 end
			for i = 0, 3 do Core.Meter_E[y].Archive_E[x].QA[0].Ea_Receive[i] = math.random()*100 end
			for i = 0, 0 do Core.Meter_E[y].Archive_E[x].YA[0].Ea_Receive[i] = math.random()*100 end
	    end
	end
end

--******************************************************************
-- инициализация глобальных переменных архива (реактивная энергия - приём)

function InitErReceive()

	for y = 0, 2 do
	    for x = 0, LastIndex_m do
	        for i = 0, 47 do Core.Meter_E[y].Archive_E[x].HHA[0].Er_Receive[i] = math.random()*100 end
	        for i = 0, 23 do Core.Meter_E[y].Archive_E[x].HA[0].Er_Receive[i] = math.random()*100 end
	        for i = 0, 30 do Core.Meter_E[y].Archive_E[x].DA[0].Er_Receive[i] = math.random()*100 end
	        for i = 0, 11 do Core.Meter_E[y].Archive_E[x].MA[0].Er_Receive[i] = math.random()*100 end
	        for i = 0, 3 do Core.Meter_E[y].Archive_E[x].QA[0].Er_Receive[i] = math.random()*100 end
	        for i = 0, 0 do Core.Meter_E[y].Archive_E[x].YA[0].Er_Receive[i] = math.random()*100 end
	    end
	end
end

--******************************************************************
-- инициализация глобальных переменных архива (активная мощность - приём)

function InitPaReceive()

	for y = 0, 2 do
	    for x = 0, LastIndex_m do
	        for i = 0, 47 do Core.Meter_E[y].Archive_E[x].HHA[0].Pa_Receive[i] = math.random()*100 end
	        for i = 0, 23 do Core.Meter_E[y].Archive_E[x].HA[0].Pa_Receive[i] = math.random()*100 end
	        for i = 0, 30 do Core.Meter_E[y].Archive_E[x].DA[0].Pa_Receive[i] = math.random()*100 end
	        for i = 0, 11 do Core.Meter_E[y].Archive_E[x].MA[0].Pa_Receive[i] = math.random()*100 end
	        for i = 0, 3 do Core.Meter_E[y].Archive_E[x].QA[0].Pa_Receive[i] = math.random()*100 end
	        for i = 0, 0 do Core.Meter_E[y].Archive_E[x].YA[0].Pa_Receive[i] = math.random()*100 end
	    end
	end
end

--******************************************************************
-- инициализация глобальных переменных архива (активная энергия - выдача)

function InitEaReturn()

	for y = 0, 2 do
	    for x = 0, LastIndex_m do
	        for i = 0, 47 do Core.Meter_E[y].Archive_E[x].HHA[0].Ea_Return[i] = math.random()*100 end
	        for i = 0, 23 do Core.Meter_E[y].Archive_E[x].HA[0].Ea_Return[i] = math.random()*100 end
	        for i = 0, 30 do Core.Meter_E[y].Archive_E[x].DA[0].Ea_Return[i] = math.random()*100 end
	        for i = 0, 11 do Core.Meter_E[y].Archive_E[x].MA[0].Ea_Return[i] = math.random()*100 end
	        for i = 0, 3 do Core.Meter_E[y].Archive_E[x].QA[0].Ea_Return[i] = math.random()*100 end	        
	        for i = 0, 0 do Core.Meter_E[y].Archive_E[x].YA[0].Ea_Return[i] = math.random()*100 end	 
	    end
	end
end

--******************************************************************
-- инициализация глобальных переменных архива (реактивная энергия - выдача)

function InitErReturn()

	for y = 0, 2 do
	    for x = 0, LastIndex_m do
	        for i = 0, 47 do Core.Meter_E[y].Archive_E[x].HHA[0].Er_Return[i] = math.random()*100 end
	        for i = 0, 23 do Core.Meter_E[y].Archive_E[x].HA[0].Er_Return[i] = math.random()*100 end
	        for i = 0, 30 do Core.Meter_E[y].Archive_E[x].DA[0].Er_Return[i] = math.random()*100 end
	        for i = 0, 11 do Core.Meter_E[y].Archive_E[x].MA[0].Er_Return[i] = math.random()*100 end
	        for i = 0, 3 do Core.Meter_E[y].Archive_E[x].QA[0].Er_Return[i] = math.random()*100 end
	        for i = 0, 0 do Core.Meter_E[y].Archive_E[x].YA[0].Er_Return[i] = math.random()*100 end
	    end
	end
end

--******************************************************************
-- инициализация глобальных переменных архива (активная мощность - выдача)

function InitPaReturn()

	for y = 0, 2 do
	    for x = 0, LastIndex_m do
	        for i = 0, 47 do Core.Meter_E[y].Archive_E[x].HHA[0].Pa_Return[i] = math.random()*100 end
	        for i = 0, 23 do Core.Meter_E[y].Archive_E[x].HA[0].Pa_Return[i] = math.random()*100 end
	        for i = 0, 30 do Core.Meter_E[y].Archive_E[x].DA[0].Pa_Return[i] = math.random()*100 end
	        for i = 0, 11 do Core.Meter_E[y].Archive_E[x].MA[0].Pa_Return[i] = math.random()*100 end
	        for i = 0, 3 do Core.Meter_E[y].Archive_E[x].QA[0].Pa_Return[i] = math.random()*100 end
	        for i = 0, 0 do Core.Meter_E[y].Archive_E[x].YA[0].Pa_Return[i] = math.random()*100 end
	    end
	end
end


Core.DateSelectorPressed_E = 1		--  инициализация нажатия "календаря"
Core.HalfHourButtonPressed_E = 1	--  инициализация нажатия кнопки "Часовой архив"

ChangeBehaviorTextFieldHA()  	-- инициализация видимости текстовых ячеек (месячный архив)
ConvertDateToEpoch()         	-- создание таблицы с датами epoch ([k]-->[v] и таблицы обратной epoch [v]-->[k)
InitDate()             			-- инициализация глобальных переменных архива (дат)
ConvertEpochToDate()			-- преобразование времени epoch в формат времени DD-MM-YYYY
InitEaReceive()         		-- инициализация глобальных переменных архива (активная энергия - приём)
InitErReceive()         		-- инициализация глобальных переменных архива (реактивная энергия - приём)
InitPaReceive()         		-- инициализация глобальных переменных архива (активная мощность - приём)
InitEaReturn()          		-- инициализация глобальных переменных архива (активная энергия - отдача)
InitErReturn()          		-- инициализация глобальных переменных архива (реактивная энергия - отдача)
InitPaReturn()          		-- инициализация глобальных переменных архива (активная мощность - отдача)
