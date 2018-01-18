-- !!! Кодировка теста UTF-8
-- УСО Э. ПЛК А1. 
-- таблица соответствия  аналоговых входов ПЛК и тегов (со свойствами).
-- ["A1_1.i1"] - описание входного канала ( например: ПЛК А1_модуль в слоте 1.канал i1).
-- Tag - имя тега без указания источника (УСО, ПЛК и т.д.).
-- Units - единицы измерения величины.
-- Comment - Текстовое описание тега. Применяется при формировании строки сообщений.
-- reliabilityFlag - признак достоверности сигнала. Не заполнять. По умолчанию принимает значение  true.
-- repaireFlag - признак вывода сигнала из опроса. Используется при выводе оборудования в ремонт. Не заполнять. По умолчанию принимает значение false.
-- BR - уровень определения обрыва канала датчика
-- LL - уровень нижней аварийной границы параметра
-- LH - уровень нижней предупредительной границы параметра 
-- HL - уровень  верхней предупредительной границы параметра 
-- HH - уровень верхней аварийной границы параметра
-- SC - уровень определения короткого замыкания канала датчика 
-- BR_check - признак отслеживания скриптом обрыва канала датчика (true/false)
-- LL_check - признак отслеживания скриптом нижней аварийной границы параметра (true/false)
-- LH_check - признак отслеживания скриптом нижней предупредительной границы параметра  (true/false)
-- HL_check - признак отслеживания скриптом верхней предупредительной границы параметра (true/false)
-- HH_check - признак отслеживания скриптом верхней аварийной границы параметра (true/false)
-- SC_check - признак отслеживания скриптом короткого замыкания канала датчика (true/false)


local AI_Signals=  -- таблица соответствия аналоговых входов тэгам - привязка тэгов и их свойств к конкретному каналу ПЛК в формате "ПЛК_Слот.Канал
	{
 		
		["A1_3.i1"]={ Tag="AI_1Q_V", Comment="КРУ-10 кВ. Напряжение на вводе 1 подано", Units ="кВ", reliabilityFlag=true,repaireFlag=false, BR=0, LL=0, LH=8, HL=9, HH=11, SC=12, BR_check=false, LL_check=false, LH_check=false, HL_check=true, HH_check=true, SC_check=false, Source="КРУ-10 кВ. 1-я секция. ТН.",},
		["A1_3.i2"]={ Tag="AI_2Q_V", Comment="КРУ-10 кВ. Напряжение на вводе 2 подано", Units ="кВ", reliabilityFlag=true,repaireFlag=false, BR=0, LL=0, LH=8, HL=9, HH=11, SC=12, BR_check=false, LL_check=false, LH_check=false, HL_check=true, HH_check=true, SC_check=false, Source="КРУ-10 кВ. 2-я секция. ТН.",},
		["A1_3.i3"]={ Tag="AI_SHUOT_V", Comment="КРУ-10 кВ. Напряжение ШУОТ КРУ-10 кВ", Units ="В", reliabilityFlag=true,repaireFlag=false, BR=0, LL=180, LH=190, HL=240, HH=250, SC=290, BR_check=false, LL_check=false, LH_check=false, HL_check=true, HH_check=true, SC_check=false, Source="КРУ-10 кВ. ШУОТ",},
		["A1_3.i4"]={ Tag="AI_X_RES01", Comment="КРУ-10 кВ. Резерв", Units =" ", reliabilityFlag=true,repaireFlag=false, BR=1, LL=2, LH=3, HL=4, HH=5, SC=6, BR_check=false, LL_check=false, LH_check=false, HL_check=true, HH_check=true, SC_check=false, Source="КРУ-10 кВ. УСО Э",},

}

return AI_Signals;