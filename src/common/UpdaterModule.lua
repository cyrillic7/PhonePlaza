--
-- Author: SuperM
-- Date: 2015-11-26 15:50:10
--

require "lfs"

local UpdaterModule = class("UpdaterModule", function()
	local node = display.newNode()
	node:setNodeEventEnabled(true)
	return node
end)

local f = cc.FileUtils:getInstance()

UpdaterModule.STATES = {
    kDownStart = "downloadStart",
    kDownDone = "downloadDone",
    kUncompressStart = "uncompressStart",
    kUncompressDone = "uncompressDone",
    unknown = "stateUnknown",
}

UpdaterModule.ERRORS = {
    kCreateFile = "errorCreateFile",
    kNetwork = "errorNetwork",
    kNoNewVersion = "errorNoNewVersion",
    kUncompress = "errorUncompress",
    unknown = "errorUnknown"
}

function UpdaterModule:ctor()
    if not self.u then 
        self.u = Updater:create() 
        self.u:retain()
    end
end

function UpdaterModule:onCleanup()
	if self.u then
        self.u:unregisterScriptHandler()
        self.u:release()
        self.u = nil
    end
    -- 删除文件
    if self.uzip then
    	os.remove(self.uzip)
    	self.uzip = nil
    end
    --[[if self.utmp then
    	UpdaterModule:rmdir(self.utmp)
    	self.utmp = nil
    end]]
end

function UpdaterModule:existDir(dirPath)
    return f:isDirectoryExist(dirPath)
end

function UpdaterModule:mkdir(path)
    if not UpdaterModule:existDir(path) then
        return lfs.mkdir(path)
    end
    return true
end

function UpdaterModule:rmdir(path)
    print("UpdaterModule.rmdir:", path)
    if UpdaterModule:existDir(path) then
        local function _rmdir(path)
            local iter, dir_obj = lfs.dir(path)
            while true do
                local dir = iter(dir_obj)
                if dir == nil then break end
                if dir ~= "." and dir ~= ".." then
                    local curDir = path..dir
                    local mode = lfs.attributes(curDir, "mode") 
                    if mode == "directory" then
                        _rmdir(curDir.."/")
                    elseif mode == "file" then
                        os.remove(curDir)
                    end
                end
            end
            local succ, des = os.remove(path)
            if des then print(des) end
            return succ
        end
        _rmdir(path)
    end
    return true
end

function UpdaterModule:update(url,uzip,utmp,handler)
    if handler then
        self.u:registerScriptHandler(handler)
    end
    --UpdaterModule:rmdir(utmp)
    -- 删除文件
    if self.uzip then
        os.remove(self.uzip)
        self.uzip = nil
    end
    --[[if self.utmp then
        UpdaterModule:rmdir(self.utmp)
        self.utmp = nil
    end]]
    self.u:update(url, uzip, utmp, false)

    self.uzip = uzip
    self.utmp = utmp
end

function UpdaterModule:updateFile(url,fileName,handler,bAbsolute)
    if handler then
        self.u:registerScriptHandler(handler)
    end

    local filePath = ""
    if not bAbsolute then
        filePath = cc.FileUtils:getInstance():getWritablePath().."download/"
    end
    filePath = filePath..fileName
    self.u:update(url, filePath)
end

return UpdaterModule