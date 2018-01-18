--******************************************************************
--********************* РАЗДЕЛ ИНИЦИАЛИЗАЦИИ ***********************
--******************************************************************

--******************************************************************
-- инициализация элементов дат (глобальных переменных) временем в формате unix epoch 

function InitDate()

        for i = 0, LastIndex_m do 
			Core.Archive_T[i].D[0] = epoch[i+1] 
        end
		Core.DateFirst = Core.Archive_T[FirstIndex_m].D[0] 	-- DateFirst - дата первой записи архива в формате UNIX-epoch
		Core.DateLast = Core.Archive_T[LastIndex_m].D[0] 	-- DateLast - дата последней записи архива в формате UNIX-epoch
    return DateFirst, DateLast
end

--******************************************************************
--  инициализация глобальных переменных архива (тепловая энергия)

function InitQ()

    for x = 0, LastIndex_m do
        
        for i = 0, 23 do Core.Archive_T[x].HA[0].Q[i] = math.random()*100 end
        for i = 0, 30 do Core.Archive_T[x].DA[0].Q[i] = math.random()*100 end
        for i = 0, 11 do Core.Archive_T[x].MA[0].Q[i] = math.random()*100 end
        for i = 0, 3 do Core.Archive_T[x].QA[0].Q[i] = math.random()*100 end
        for i = 0, 0 do Core.Archive_T[x].YA[0].Q[i] = math.random()*100 end
    end
end

--******************************************************************
--  инициализация глобальных переменных архива (расход газа)

function InitGas()

    for x = 0, LastIndex_m do
        for i = 0, 23 do Core.Archive_T[x].HA[0].Gas[i] = math.random()*100 end
        for i = 0, 30 do Core.Archive_T[x].DA[0].Gas[i] = math.random()*100 end
        for i = 0, 11 do Core.Archive_T[x].MA[0].Gas[i] = math.random()*100 end
        for i = 0, 3 do Core.Archive_T[x].QA[0].Gas[i] = math.random()*100 end
        for i = 0, 0 do Core.Archive_T[x].YA[0].Gas[i] = math.random()*100 end
    end
end

--******************************************************************
--  инициализация глобальных переменных архива (расхода воды - артскважина 1)

function InitWaterA1()

    for x = 0, LastIndex_m do
        for i = 0, 23 do Core.Archive_T[x].HA[0].Water_A1[i] = math.random()*100 end
        for i = 0, 30 do Core.Archive_T[x].DA[0].Water_A1[i] = math.random()*100 end
        for i = 0, 11 do Core.Archive_T[x].MA[0].Water_A1[i] = math.random()*100 end
        for i = 0, 3 do Core.Archive_T[x].QA[0].Water_A1[i] = math.random()*100 end
        for i = 0, 0 do Core.Archive_T[x].YA[0].Water_A1[i] = math.random()*100 end
    end
end

--******************************************************************
--  инициализация глобальных переменных архива (расхода воды - артскважина 2)

function InitWaterA2()

    for x = 0, LastIndex_m do
        for i = 0, 23 do Core.Archive_T[x].HA[0].Water_A2[i] = math.random()*100 end
        for i = 0, 30 do Core.Archive_T[x].DA[0].Water_A2[i] = math.random()*100 end
        for i = 0, 11 do Core.Archive_T[x].MA[0].Water_A2[i] = math.random()*100 end
        for i = 0, 3 do Core.Archive_T[x].QA[0].Water_A2[i] = math.random()*100 end
        for i = 0, 0 do Core.Archive_T[x].YA[0].Water_A2[i] = math.random()*100 end
    end
end

--******************************************************************
--  инициализация глобальных переменных архива (расхода воды - артскважина 3)

function InitWaterA3()

    for x = 0, LastIndex_m do
        for i = 0, 23 do Core.Archive_T[x].HA[0].Water_A3[i] = math.random()*100 end
        for i = 0, 30 do Core.Archive_T[x].DA[0].Water_A3[i] = math.random()*100 end
        for i = 0, 11 do Core.Archive_T[x].MA[0].Water_A3[i] = math.random()*100 end
        for i = 0, 3 do Core.Archive_T[x].QA[0].Water_A3[i] = math.random()*100 end
        for i = 0, 0 do Core.Archive_T[x].YA[0].Water_A3[i] = math.random()*100 end
    end
end

--******************************************************************
--  инициализация глобальных переменных архива (расхода воды - артскважина 4)

function InitWaterA4()

    for x = 0, LastIndex_m do
        for i = 0, 23 do Core.Archive_T[x].HA[0].Water_A4[i] = math.random()*100 end
        for i = 0, 30 do Core.Archive_T[x].DA[0].Water_A4[i] = math.random()*100 end
        for i = 0, 11 do Core.Archive_T[x].MA[0].Water_A4[i] = math.random()*100 end
        for i = 0, 3 do Core.Archive_T[x].QA[0].Water_A4[i] = math.random()*100 end
        for i = 0, 0 do Core.Archive_T[x].YA[0].Water_A4[i] = math.random()*100 end
    end
end

--******************************************************************
--  инициализация глобальных переменных архива (расхода воды - объект 1)

function InitWaterObj1()

    for x = 0, LastIndex_m do
        for i = 0, 23 do Core.Archive_T[x].HA[0].Water_Obj1[i] = math.random()*100 end
        for i = 0, 30 do Core.Archive_T[x].DA[0].Water_Obj1[i] = math.random()*100 end
        for i = 0, 11 do Core.Archive_T[x].MA[0].Water_Obj1[i] = math.random()*100 end
        for i = 0, 3 do Core.Archive_T[x].QA[0].Water_Obj1[i] = math.random()*100 end
        for i = 0, 0 do Core.Archive_T[x].YA[0].Water_Obj1[i] = math.random()*100 end
    end
end

--******************************************************************
--  инициализация глобальных переменных архива (расхода воды - объект 2)

function InitWaterObj2()

    for x = 0, LastIndex_m do
        for i = 0, 23 do Core.Archive_T[x].HA[0].Water_Obj2[i] = math.random()*100 end
        for i = 0, 30 do Core.Archive_T[x].DA[0].Water_Obj2[i] = math.random()*100 end
        for i = 0, 11 do Core.Archive_T[x].MA[0].Water_Obj2[i] = math.random()*100 end
        for i = 0, 3 do Core.Archive_T[x].QA[0].Water_Obj2[i] = math.random()*100 end
        for i = 0, 0 do Core.Archive_T[x].YA[0].Water_Obj2[i] = math.random()*100 end
    end
end

--******************************************************************
--  инициализация глобальных переменных архива (расхода воды - объект 3)

function InitWaterObj3()

    for x = 0, LastIndex_m do
        for i = 0, 23 do Core.Archive_T[x].HA[0].Water_Obj3[i] = math.random()*100 end
        for i = 0, 30 do Core.Archive_T[x].DA[0].Water_Obj3[i] = math.random()*100 end
        for i = 0, 11 do Core.Archive_T[x].MA[0].Water_Obj3[i] = math.random()*100 end
        for i = 0, 3 do Core.Archive_T[x].QA[0].Water_Obj3[i] = math.random()*100 end
        for i = 0, 0 do Core.Archive_T[x].YA[0].Water_Obj3[i] = math.random()*100 end
    end
end

--******************************************************************
--  инициализация глобальных переменных архива (расхода воды - объект 4)

function InitWaterObj4()
 
    for x = 0, LastIndex_m do
        for i = 0, 23 do Core.Archive_T[x].HA[0].Water_Obj4[i] = math.random()*100 end
        for i = 0, 30 do Core.Archive_T[x].DA[0].Water_Obj4[i] = math.random()*100 end
        for i = 0, 11 do Core.Archive_T[x].MA[0].Water_Obj4[i] = math.random()*100 end
        for i = 0, 3 do Core.Archive_T[x].QA[0].Water_Obj4[i] = math.random()*100 end
        for i = 0, 0 do Core.Archive_T[x].YA[0].Water_Obj4[i] = math.random()*100 end
    end
end


Core.DateSelectorPressed_T = 1	--  инициализация нажатия "календаря"
Core.HourButtonPressed_T = 1	--  инициализация нажатия кнопки "Часовой архив"

ChangeBehaviorTextFieldHA()		-- инициализация координат "y" текстовых ячеек и кнопки
ConvertDateToEpoch()           	-- создание таблицы с датами epoch ([k]-->[v] и таблицы обратной epoch [v]-->[k)
ConvertEpochToDate()			-- преобразование времени epoch в формат времени DD-MM-YYYY
InitDate()                     	-- инициализация глобальных переменных архива (дат)
InitQ()                        	-- инициализация глобальных переменных архива (тепловая энергия)
InitGas()                      	-- инициализация глобальных переменных архива (расход газа)
InitWaterA1()                  	-- инициализация глобальных переменных архива (расхода воды - артскважина 1)
InitWaterA2()                  	-- инициализация глобальных переменных архива (расхода воды - артскважина 2)
InitWaterA3()                  	-- инициализация глобальных переменных архива (расхода воды - артскважина 3)
InitWaterA4()                  	-- инициализация глобальных переменных архива (расхода воды - артскважина 4)
InitWaterObj1()                	-- инициализация глобальных переменных архива (расхода воды - объект 1)
InitWaterObj2()                	-- инициализация глобальных переменных архива (расхода воды - объект 2)
InitWaterObj3()                	-- инициализация глобальных переменных архива (расхода воды - объект 3)
InitWaterObj4()                	-- инициализация глобальных переменных архива (расхода воды - объект 4)
