-- присваиваем категорию события
local AS=10000  
local WS=10100 
local TS=101  
screen_id = 'DIAGN'


-- создаем функцию
local function Add_Event(signal, fields, cond)
	local user=''
	local DT_POSIX=os.time()				
	if cond[1]  then --если  "Сигнал" равен условию (1) то вызываем  событие с параметрами (сообщение, категория, появление/исчезновение, источник, пользователь, ууайди, время, мета)
		Core.addEvent(fields.msg, fields.cat, 1, fields.source, user, signal..fields.cat, DT_POSIX ,screen_id) 
		if Log then 
			Core.addLogMsg(DT.." ".."(Появл.) ".. fields.msg.." "..user.." "..signal.." "..fields.cat) 
		end 
	elseif cond[2] then  -- другое условие и то же самое
		Core.addEvent(fields.msg, fields.cat, 0, fields.source, user, signal..fields.cat, DT_POSIX, screen_id) 
		if Log then 
			Core.addLogMsg(DT.." ".."(Исчезн.)"..fields.msg.." "..user.." "..signal.." "..fields.cat) 
		end 
	
	end
end

local simple_signals =      
{
	['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[0]']=            
	{
		['msg']='Потеря связи',                   
		['cat']=AS,
		['state']=2,
		['source']='Лантан CS3102 №1',
		['eval']= 	function(table )
						Add_Event(table[1],table[2],{Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[0]']==2 ,Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[0]']==1})           
					end
	},
	
	['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[1]']=            
	{
		['msg']='Потеря связи',                   
		['cat']=AS,
		['state']=2,
		['source']='Лантан CS3102 №2',
		['eval']= 	function(table )
						Add_Event(table[1],table[2],{Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[1]']==2 ,Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[1]']==1})           
					end
	},
	
	['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[2]']=            
	{
		['msg']='Потеря связи',                   
		['cat']=AS,
		['state']=2,
		['source']='Лантан CS3102 №3',
		['eval']= 	function(table )
						Add_Event(table[1],table[2],{Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[2]']==2 ,Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[2]']==1})           
					end
	},

	['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[3]']=            
	{
		['msg']='Потеря связи',                   
		['cat']=AS,
		['state']=2,
		['source']='Лантан CS3102 №4',
		['eval']= 	function(table )
						Add_Event(table[1],table[2],{Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[3]']==2 ,Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[3]']==1})           
					end
	},
	
	['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[4]']=            
	{
		['msg']='Потеря связи',                   
		['cat']=AS,
		['state']=2,
		['source']='Лантан CS3102 №5',
		['eval']= 	function(table )
						Add_Event(table[1],table[2],{Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[4]']==2 ,Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[4]']==1})           
					end
	},
	
	['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[5]']=            
	{
		['msg']='Потеря связи',                   
		['cat']=AS,
		['state']=2,
		['source']='Лантан CS3102 №6',
		['eval']= 	function(table )
						Add_Event(table[1],table[2],{Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[5]']==2 ,Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[5]']==1})           
					end
	},
	
	['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[6]']=            
	{
		['msg']='Потеря связи',                   
		['cat']=AS,
		['state']=2,
		['source']='Лантан CS3102 №7',
		['eval']= 	function(table )
						Add_Event(table[1],table[2],{Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[6]']==2 ,Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[6]']==1})           
					end
	},
	
	['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[7]']=            
	{
		['msg']='Потеря связи',                   
		['cat']=AS,
		['state']=2,
		['source']='Лантан CS3102 №8',
		['eval']= 	function(table )
						Add_Event(table[1],table[2],{Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[7]']==2 ,Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[7]']==1})           
					end
	},
	
	['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[8]']=            
	{
		['msg']='Потеря связи',                   
		['cat']=AS,
		['state']=2,
		['source']='Лантан CS3102 №9',
		['eval']= 	function(table )
						Add_Event(table[1],table[2],{Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[8]']==2 ,Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[8]']==1})           
					end
	},
	
	['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[9]']=            
	{
		['msg']='Потеря связи',                   
		['cat']=AS,
		['state']=2,
		['source']='Лантан CS3102 №10',
		['eval']= 	function(table )
						Add_Event(table[1],table[2],{Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[9]']==2 ,Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[9]']==1})           
					end
	},
	
	['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[10]']=            
	{
		['msg']='Потеря связи',                   
		['cat']=AS,
		['state']=2,
		['source']='Лантан CS3102 №11',
		['eval']= 	function(table )
						Add_Event(table[1],table[2],{Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[10]']==2 ,Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[10]']==1})           
					end
	},
	
	['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[11]']=            
	{
		['msg']='Потеря связи',                   
		['cat']=AS,
		['state']=2,
		['source']='Лантан CS3102 №12',
		['eval']= 	function(table )
						Add_Event(table[1],table[2],{Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[11]']==2 ,Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[11]']==1})           
					end
	},
	
	['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[12]']=            
	{
		['msg']='Потеря связи',                   
		['cat']=AS,
		['state']=2,
		['source']='Лантан CS3102 №13',
		['eval']= 	function(table )
						Add_Event(table[1],table[2],{Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[12]']==2 ,Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[12]']==1})           
					end
	},
	
	['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[13]']=            
	{
		['msg']='Потеря связи',                   
		['cat']=AS,
		['state']=2,
		['source']='Лантан CS3102 №14',
		['eval']= 	function(table )
						Add_Event(table[1],table[2],{Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[13]']==2 ,Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[13]']==1})           
					end
	},
	
	['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[14]']=            
	{
		['msg']='Потеря связи',                   
		['cat']=AS,
		['state']=2,
		['source']='Лантан CS3102 №15',
		['eval']= 	function(table )
						Add_Event(table[1],table[2],{Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[14]']==2 ,Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[14]']==1})           
					end
	},
	
	['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[15]']=            
	{
		['msg']='Потеря связи',                   
		['cat']=AS,
		['state']=2,
		['source']='Лантан CS3102 №16',
		['eval']= 	function(table )
						Add_Event(table[1],table[2],{Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[15]']==2 ,Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[15]']==1})           
					end
	},
	
	['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[16]']=            
	{
		['msg']='Потеря связи',                   
		['cat']=AS,
		['state']=2,
		['source']='Лантан CS3102 №17',
		['eval']= 	function(table )
						Add_Event(table[1],table[2],{Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[16]']==2 ,Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[16]']==1})           
					end
	},
	
['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[17]']=            
	{
		['msg']='Потеря связи',                   
		['cat']=AS,
		['state']=2,
		['source']='Лантан CS3102 №18',
		['eval']= 	function(table )
						Add_Event(table[1],table[2],{Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[17]']==2 ,Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[17]']==1})           
					end
	},
	
	['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[18]']=            
	{
		['msg']='Потеря связи',                   
		['cat']=AS,
		['state']=2,
		['source']='Лантан CS3102 №19',
		['eval']= 	function(table )
						Add_Event(table[1],table[2],{Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[18]']==2 ,Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[18]']==1})           
					end
	},
	
	['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[19]']=            
	{
		['msg']='Потеря связи',                   
		['cat']=AS,
		['state']=2,
		['source']='Лантан CS3102 №20',
		['eval']= 	function(table )
						Add_Event(table[1],table[2],{Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[19]']==2 ,Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[19]']==1})           
					end
	},
	
	['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[20]']=            
	{
		['msg']='Потеря связи',                   
		['cat']=AS,
		['state']=2,
		['source']='Лантан CS3102 №21',
		['eval']= 	function(table )
						Add_Event(table[1],table[2],{Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[20]']==2 ,Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[20]']==1})           
					end
	},

['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[21]']=            
	{
		['msg']='Потеря связи',                   
		['cat']=AS,
		['state']=2,
		['source']='Лантан CS3102 №22',
		['eval']= 	function(table )
						Add_Event(table[1],table[2],{Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[21]']==2 ,Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[21]']==1})           
					end
	},

	['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[22]']=            
	{
		['msg']='Потеря связи',                   
		['cat']=AS,
		['state']=2,
		['source']='Лантан CS3102 №23',
		['eval']= 	function(table )
						Add_Event(table[1],table[2],{Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[22]']==2 ,Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[22]']==1})           
					end
	},
		
['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[23]']=            
	{
		['msg']='Потеря связи',                   
		['cat']=AS,
		['state']=2,
		['source']='Лантан CS3102 №24',
		['eval']= 	function(table )
						Add_Event(table[1],table[2],{Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[23]']==2 ,Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[23]']==1})           
					end
	},
	
	['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[24]']=            
	{
		['msg']='Потеря связи',                   
		['cat']=AS,
		['state']=2,
		['source']='Лантан CS3102 №25',
		['eval']= 	function(table )
						Add_Event(table[1],table[2],{Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[24]']==2 ,Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[24]']==1})           
					end
	},
	
	['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[25]']=            
	{
		['msg']='Потеря связи',                   
		['cat']=AS,
		['state']=2,
		['source']='Лантан CS3102 №26',
		['eval']= 	function(table )
						Add_Event(table[1],table[2],{Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[25]']==2 ,Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[25]']==1})           
					end
	},
	
['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[26]']=            
	{
		['msg']='Потеря связи',                   
		['cat']=AS,
		['state']=2,
		['source']='Лантан CS3102 №27',
		['eval']= 	function(table )
						Add_Event(table[1],table[2],{Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[26]']==2 ,Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[26]']==1})           
					end
	},
	
	['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[27]']=            
	{
		['msg']='Потеря связи',                   
		['cat']=AS,
		['state']=2,
		['source']='Лантан CS3102 №28',
		['eval']= 	function(table )
						Add_Event(table[1],table[2],{Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[27]']==2 ,Core['GSP_SEV_KSSEV_DIAGN_LANTAN_CONNECTION[27]']==1})           
					end
	},
	
}

for c_signal,c_fields in pairs (simple_signals)do
	Core.onExtChange ({c_signal}, c_fields.eval, {c_signal, c_fields})
end



Core.waitEvents()

