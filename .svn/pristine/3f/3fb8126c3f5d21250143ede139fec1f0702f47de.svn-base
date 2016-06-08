--
-- Author: SuperM
-- Date: 2015-11-26 17:18:57
--
local UpdaterManager = class("UpdaterManager")

UpdaterManager.clientUpdaters = {}

function UpdaterManager:ctor()
    local resinfo = G_RequireFile("resinfo.txt")
    if resinfo and resinfo.url_downloadClient then
        GlobalPlatInfo.szDownLoadPreUrl = resinfo.url_downloadClient
    end
end

function UpdaterManager:getDownLoadCount()
    return #self.clientUpdaters
end

function UpdaterManager:getDownLoadClient(wKindID)
	for i,v in ipairs(self.clientUpdaters) do
		if v.wKindID == wKindID then
			return v
		end
	end
end

function UpdaterManager:getUtempPath(subName)
	return cc.FileUtils:getInstance():getWritablePath()--.."GameClientTemp/"..subName.."/"
end

function UpdaterManager:getUzipPath(szKindName)
	return cc.FileUtils:getInstance():getWritablePath()..szKindName..".zip"
end

function UpdaterManager:downLoadClient(szKindName,wKindID,callBack)
    -- 检查是否已经下载
    if self:getDownLoadClient(wKindID) then
    	return
    end
    local updater = require("common.UpdaterModule").new()
    if updater then
        updater.wKindID = wKindID
    	updater:update(GlobalPlatInfo.szDownLoadPreUrl.."PhoneGames/"..szKindName..".zip"
    				,self:getUzipPath(szKindName),self:getUtempPath(szKindName),function (event,value)
    					self:updaterHandler(updater,event,value,callBack)
    				end)
    	table.insert(self.clientUpdaters,updater)
        return updater
    end
end

function UpdaterManager:updaterHandler(updater,event,value,callBack)
    updater.state = event
    updater.stateValue = value
    if event == "success" or event == "error" then
        for i,v in ipairs(self.clientUpdaters) do
            if v == updater then
                table.remove(self.clientUpdaters,i)
                break
            end
        end
    end
    if callBack then
        callBack(updater)
    end
end

return UpdaterManager