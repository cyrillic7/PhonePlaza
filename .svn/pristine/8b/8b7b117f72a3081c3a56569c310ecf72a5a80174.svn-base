local SessionManager = SessionManager:sharedManager()

local UserDefault = cc.UserDefault:getInstance()

SessionName_SkinID = "SessionName_SkinID"
SessionName_LastAcount = "SessionName_LastAcount"
SessionName_AllAcounts = "SessionName_AllAcounts"
SessionName_LastServerIP = "SessionName_LastServerIP"
SessionName_IsFirstRun = "SessionName_IsFirstRun"

function SessionManager:restoreUserDataEx()
	self.dwSkinID = UserDefault:getIntegerForKey(SessionName_SkinID, 0)
	local strValue = UserDefault:getStringForKey(SessionName_LastAcount)
	if string.len(strValue) > 1 then
		self.lastAcount = json.decode(strValue)
	end
	strValue = UserDefault:getStringForKey(SessionName_AllAcounts)
	if string.len(strValue) > 1 then
		self.allAcounts = json.decode(strValue)
	end	
	strValue = UserDefault:getStringForKey(SessionName_LastServerIP)
	if string.len(strValue) > 6 then
		self.lastServerIP = strValue
	end	
	self.bFirstRun = UserDefault:getIntegerForKey(SessionName_IsFirstRun, 1)
end

function SessionManager:initEx()
    SessionManager:restoreUserDataEx()
end

function SessionManager:getSkinID()
	return self.dwSkinID or 0
end

function SessionManager:setSkinID(dwSkinID)
	if self.dwSkinID ~= dwSkinID then
		self.dwSkinID = dwSkinID
		UserDefault:setIntegerForKey(SessionName_SkinID, dwSkinID)
	end
end

function SessionManager:getLastAcount()
	if self.lastAcount then
		return self.lastAcount
	else
		if self.allAcounts then
			local acount = {}
			for k,v in pairs(self.allAcounts) do
				acount.acount = k
				acount.password = v
				return acount
			end
		end
	end
end

function SessionManager:setLastAcount(newAcount)
	if newAcount.acount and newAcount.password then
		local strAcount = json.encode(newAcount)
		if strAcount then
			self.lastAcount = newAcount
			UserDefault:setStringForKey(SessionName_LastAcount, strAcount)
			-- 保存到全部帐号
			self.allAcounts = self.allAcounts or {}
			self.allAcounts[newAcount.acount] = newAcount.password
			local strAllAcount = json.encode(self.allAcounts)
			UserDefault:setStringForKey(SessionName_AllAcounts, strAllAcount)
		end
	end
end

function SessionManager:getAllAcounts()
	local count = 0
	for k,v in pairs(self.allAcounts) do
		count = count + 1
	end
	return self.allAcounts,count
end

function SessionManager:deleteAcount(delAcount)
	if delAcount.acount then
		if self.lastAcount and self.lastAcount.acount == delAcount.acount then
			UserDefault:setStringForKey(SessionName_LastAcount, "")
			self.lastAcount = nil
		end
		if self.allAcounts then
			self.allAcounts[delAcount.acount] = nil
			local strAllAcount = json.encode(self.allAcounts)
			UserDefault:setStringForKey(SessionName_AllAcounts, strAllAcount)
		end
	end
end

function SessionManager:getLastServerIP()
	return self.lastServerIP
end

function SessionManager:setLastServerIP(lastServerIP)
	if self.lastServerIP ~= lastServerIP then
		self.lastServerIP = lastServerIP
		UserDefault:setStringForKey(SessionName_LastServerIP, lastServerIP)
	end
end

function SessionManager:getIsFirstRun()
	return self.bFirstRun == 1
end

function SessionManager:setFirstRunSign()
	self.bFirstRun = 0
	UserDefault:setIntegerForKey(SessionName_IsFirstRun, 0)
end

SessionManager:initEx()