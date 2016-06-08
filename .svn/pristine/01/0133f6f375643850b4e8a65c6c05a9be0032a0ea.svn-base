--
-- Author: SuperM
-- Date: 2015-12-08 11:24:50
--
StatisticsController = class("StatisticsController")

local StatisticsType ={
		S_INSTALL=0,			--安装
		S_REGISTER =1,			--注册
		S_ACCOUNT_LOGON=2,		--帐号登录
	}

GlobalChannelDef = GlobalChannelDef
if not GlobalChannelDef then
	local resinfo = G_RequireFile("resinfo.txt")
	resinfo = resinfo or {}
	GlobalChannelDef = 
	{
		k_url = "http://qq.719you.com/WS/WSClient.asmx/",	--url地址
		k_session_id = resinfo.k_session_id or "0",				--渠道ID
		k_session_verion = resinfo.k_session_verion or "a01",	--渠道版本
	}
end

function StatisticsController:ctor()
	
end

function StatisticsController:sendStatisticsData(eType)
	eType = eType or StatisticsType.S_INSTALL
	local postUrl = GlobalChannelDef.k_url
	local postData = {}
	if eType == StatisticsType.S_INSTALL then
		postUrl = postUrl.."GameInstall"
		postData["sessionID"]=GlobalChannelDef.k_session_id
		postData["code"]=cc.Crypto:MD5("server"..GlobalChannelDef.k_session_id..GlobalChannelDef.k_session_verion.."lmyspread", false)
		postData["machineCode"]=GlobalPlatInfo.szMachineID
	elseif eType == StatisticsType.S_REGISTER then
		postUrl = postUrl.."AccountsRegister"		
		postData["gameID"]=GlobalUserInfo.dwGameID
		postData["sessionID"]=GlobalChannelDef.k_session_id
		postData["code"]=cc.Crypto:MD5("server"..GlobalChannelDef.k_session_id..GlobalChannelDef.k_session_verion.."lmyspread", false)
		postData["machineCode"]=GlobalPlatInfo.szMachineID
	elseif eType == StatisticsType.S_ACCOUNT_LOGON then
		postUrl = postUrl.."AccountsLogon"		
		postData["gameID"]=GlobalUserInfo.dwGameID
		postData["sessionID"]=GlobalChannelDef.k_session_id
		postData["code"]=cc.Crypto:MD5("server"..GlobalChannelDef.k_session_id..GlobalChannelDef.k_session_verion.."lmyspread", false)
		postData["machineCode"]=GlobalPlatInfo.szMachineID
	end
	-- 创建一个请求，并以 POST 方式发送数据到服务端
	local request = network.createHTTPRequest(function (event)
			if eType == StatisticsType.S_INSTALL and event.name == "completed" then
				SessionManager:sharedManager():setFirstRunSign()
			end
		end, postUrl, "POST")
	for k,v in pairs(postData) do
		request:addPOSTValue(k,v)
	end	 
	-- 开始请求。当请求完成时会调用 callback() 函数
	request:start()
end

return StatisticsController