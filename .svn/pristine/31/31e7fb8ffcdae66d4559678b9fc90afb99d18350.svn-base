GlobalPlatInfo={
	dwPlazaVersion=17235969,
	szDownLoadPreUrl = "http://download.719you.com/download/Mobile/",
	szMachineID = "",
	dwTerminal = 5,-- 平台ID
	isInReview = false, -- 是否处于IOS审核
}

GlobalUserInfo={
	dwUserID=0,
	dwGameID=0,
	dwExperience=0,
	lLoveLiness=0,
	szAccounts="",
	szNickName="",
	szPassword="",
	lUserScore=0,
	lGoldBean=0,
	lIngotScore=0,
	lUserInsure=0,
	dwUserMedal=0,
	lUserIngot=0,
	cbGender=0,
	cbMoorMachine=0,
	szUnderWrite="",
	dwGroupID=0,
	szGroupName="",
	dwVipLevel=0,
	cbMemberOrder=0,
	MemberOverDate=0,
	wFaceID=0,
	dwCustomID=0,

	szUserNote="",
	szCompellation="",
	szSeatPhone="",
	cbMoorPassPortID=0,
	cbMoorPhone=0,
	szPassPortID="",
	szMobilePhone="",
	cbInsurePwd=0,
	szQQ="",
	szEMail="",
	szDwellingPlace="",
	dwPayMoney=0,
	dwHornNum=0,

	lLottery = 0,
	szBankPassword = "",
	lPreBankTimeTick = 0
}
GlobalLobbyServerInfo = {
	dwUserID=0,
	lIngot=0,
	lUserScore=0,
	szServerIP="",
	dwServerPort=0,
}

GlobalLogonServerInfo = {
	szServerIP="121.40.31.203",
	dwServerPort=8100,
}
--"121.41.77.64",8100
--"121.40.31.203",8100
GlobalKindGroups = {
	Normal560 = "560",
	Normal450 = "450",
	Normal460 = "460",
	Normal590 = "590",
	Normal430 = "430",-- 6人换牌牛牛
	Normal210 = "210",-- 2人牛牛
	Normal130 = "130",-- 通比牛牛
	Normal30 = "30",-- 百人牛牛
	Match310 = "310",-- 二斗比赛
}

GlobalWebIPs = {
	szHomeWebIP="",
	szActiveWebIP="",
	szMallWebIP="http://121.41.116.223:8090",
	szPayWebIP="",
	szDownLoadWebIP="",
}


if device.platform == "android" then
	local succ,szMachineID = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "getDeviceId", {}, "()Ljava/lang/String;")
	if succ then
		GlobalPlatInfo.szMachineID = "plaza"..string.sub(cc.Crypto:MD5(szMachineID,false),6)
	else
		GlobalPlatInfo.szMachineID = "PLAZAADCACB42134321421341241133A"
	end

elseif device.platform == "ios" then
	local succ,szMachineID = luaoc.callStaticMethod("LuaCallObjcFuncs", "getDeviceId", {})
	if succ then
		GlobalPlatInfo.szMachineID = "plaza"..string.sub(cc.Crypto:MD5(szMachineID,false),6)
	else
		GlobalPlatInfo.szMachineID = "PLAZAADCACB421343214213412411IOS"
	end
else
	GlobalPlatInfo.szMachineID = "PLAZAADCACB42134321421341241133W"
end
