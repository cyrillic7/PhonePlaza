--- The helper for update package.
-- It can download resources and uncompress it, 
-- copy new package to res directory,
-- and remove temporery directory.
-- @author zrong(zengrong.net)
-- Creation 2014-07-03

require "lfs"
local updater = {}
updater.STATES = {
    kDownStart = "downloadStart",
    kDownDone = "downloadDone",
    kUncompressStart = "uncompressStart",
    kUncompressDone = "uncompressDone",
    unknown = "stateUnknown",
}

updater.ERRORS = {
    kCreateFile = "errorCreateFile",
    kNetwork = "errorNetwork",
    kNoNewVersion = "errorNoNewVersion",
    kUncompress = "errorUncompress",
    unknown = "errorUnknown";
}

function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

function updater.isState(state)
    for k,v in pairs(updater.STATES) do
        if v == state then
            return true
        end
    end
    return false
end

function updater.clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function updater.vardump(object, label, returnTable)
    local lookupTable = {}
    local result = {}

    local function _v(v)
        if type(v) == "string" then
            v = "\"" .. v .. "\""
        end
        return tostring(v)
    end

    local function _vardump(object, label, indent, nest)
        label = label or ""
        local postfix = ""
        if nest > 1 then postfix = "," end
        if type(object) ~= "table" then
            if type(label) == "string" then
                result[#result +1] = string.format("%s[\"%s\"] = %s%s", indent, label, _v(object), postfix)
            else
                result[#result +1] = string.format("%s%s%s", indent, _v(object), postfix)
            end
        elseif not lookupTable[object] then
            lookupTable[object] = true

            if type(label) == "string" then
                result[#result +1 ] = string.format("%s%s = {", indent, label)
            else
                result[#result +1 ] = string.format("%s{", indent)
            end
            local indent2 = indent .. "    "
            local keys = {}
            local values = {}
            for k, v in pairs(object) do
                keys[#keys + 1] = k
                values[k] = v
            end
            table.sort(keys, function(a, b)
                if type(a) == "number" and type(b) == "number" then
                    return a < b
                else
                    return tostring(a) < tostring(b)
                end
            end)
            for i, k in ipairs(keys) do
                _vardump(values[k], k, indent2, nest + 1)
            end
            result[#result +1] = string.format("%s}%s", indent, postfix)
        end
    end
    _vardump(object, label, "", 1)

    if returnTable then return result end
    return table.concat(result, "\n")
end

local u  = nil
local f = cc.FileUtils:getInstance()
-- The res index file in original package.
local lresinfo = "res/resinfo.txt"
local uroot = f:getWritablePath()
-- The directory for save updated files.
local ures = uroot.."res/"
-- The package zip file what download from server.
local uzip = uroot.."res.zip"
-- The directory for uncompress res.zip.
local utmp = uroot.."utmp/"
-- The res index file in zip package for update.
local zresinfo = utmp.."res/resinfo.txt"

-- The res index file for final game.
-- It combiled original lresinfo and zresinfo.
local uresinfo = ures .. "resinfo.txt"

local localResInfo = nil
local remoteResInfo = nil
local finalResInfo = nil

local function _initUpdater()
    print("initUpdater, ", u)
    if not u then 
        u = Updater:create() 
        u:retain()
    end
    print("after initUpdater:", u)
end

function updater.writeFile(path, content, mode)
    mode = mode or "w+b"
    local file = io.open(path, mode)
    if file then
        if file:write(content) == nil then return false end
        io.close(file)
        return true
    else
        return false
    end
end

function updater.readFile(path)
    return cc.HelperFunc:getFileData(path)
end

function updater.exists(filePath)
    return f:isFileExist(filePath)
end

function updater.existDir(dirPath)
    return f:isDirectoryExist(dirPath)
end
--[[
-- Departed, uses lfs instead.
function updater._mkdir(path)
    _initUpdater()
    return u:createDirectory(path)
end

-- Departed, get a warning in ios simulator
function updater._rmdir(path)
    _initUpdater()
    return u:removeDirectory(path)
end
--]]

function updater.mkdir(path)
    if not updater.existDir(path) then
        return lfs.mkdir(path)
    end
    return true
end

function updater.rmdir(path)
    print("updater.rmdir:", path)
    if updater.existDir(path) then
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

function updater.copydir(srcPath,desPath)
    print("updater.copydir:", srcPath,desPath)
    local _dirList = {}
    local function _copydir(srcPath,desPath)
        local iter, dir_obj = lfs.dir(srcPath)
        while true do
            local dir = iter(dir_obj)
            if dir == nil then break end
            if dir ~= "." and dir ~= ".." then
                local curSrcDir = srcPath..dir
                local curDesDir = desPath..dir
                local mode = lfs.attributes(curSrcDir, "mode") 
                if mode == "directory" then
                    _copydir(curSrcDir.."/",curDesDir.."/")
                elseif mode == "file" then
                    -- 生成文件
                    -- 排除uresinfo
                    if uresinfo ~= curDesDir then
                        -- Create nonexistent directory in update res.
                        local i,j = 1,1
                        while true do
                            j = string.find(curDesDir, "/", i)
                            if j == nil then break end
                            local dirTemp = string.sub(curDesDir, 1,j)
                            -- Save created directory flag to a table because
                            -- the io operation is too slow.
                            if not _dirList[dirTemp] then
                                _dirList[dirTemp] = true
                                updater.mkdir(dirTemp)
                            end
                            i = j+1
                        end
                        print(string.format('copy %s to %s', curSrcDir, curDesDir))
                        local fileContent = updater.readFile(curSrcDir)
                        if fileContent then
                            updater.writeFile(curDesDir, fileContent)
                        end
                    end
                end
            end
        end
    end
    _copydir(srcPath,desPath)
end

-- Is there a update.zip package in ures directory?
-- If it is true, return its abstract path.
function updater.hasNewUpdatePackage()
    local newUpdater = ures.."lib/update.zip"
    if updater.exists(newUpdater) then
        return newUpdater
    end
    return nil
end

-- Check local resinfo and remote resinfo, compare their version value.
function updater.checkUpdate()
    localResInfo = updater.getLocalResInfo()
    -- 判断是否发生升级或重新安装
    local orginalResInfo = updater.getOriginalResInfo()
    if orginalResInfo and orginalResInfo.orginalVersion ~= localResInfo.orginalVersion then
        updater.cleanDownedRes()
    end
    local localVer = localResInfo.version
    print("localVer:", localVer)
    remoteResInfo = updater.getRemoteResInfo(localResInfo.update_url)
    -- 获取远程版本信息失败，不进行升级
    if not remoteResInfo.version then
        print("get remoteVer failed")
        return false
    end
    if remoteResInfo.url_downloadClient then
        localResInfo.url_downloadClient = remoteResInfo.url_downloadClient
    end
    -- 获取成功，更新登陆点
    if remoteResInfo.url_logon_list then
        localResInfo.url_logon_list = updater.clone(remoteResInfo.url_logon_list)
    end
    -- 获取显示的游戏种类
    if remoteResInfo.game_list then
        localResInfo.game_list = updater.clone(remoteResInfo.game_list)
    end
    -- 判断是否是IOS审核版本
    if remoteResInfo.reviewVersion then
        if remoteResInfo.reviewVersion == localVer then
            localResInfo.isInReview = 1
        else
            localResInfo.isInReview = 0
        end
    else
        localResInfo.isInReview = 0
    end
    -- 获取终端号
    if remoteResInfo.dwTerminal then
        localResInfo.dwTerminal = remoteResInfo.dwTerminal
    end
    -- 保存文件
    local dumpTable = updater.vardump(localResInfo, "local data", true)
    dumpTable[#dumpTable+1] = "return data"
    if not updater.writeFile(uresinfo, table.concat(dumpTable, "\n")) then
        print("update logon_list failed!")
    end
    -- IOS审核版本不进行升级
    if localResInfo.isInReview == 1 then
        return false,false
    end

    local remoteVer = remoteResInfo.version
    print("remoteVer:", remoteVer)
    if remoteVer ~= localVer then
        local localVerSub = string.split(localVer,".")
        local remoteVerSub = string.split(remoteVer,".")
        if #localVerSub == #remoteVerSub and #localVerSub == 3 then
            remoteResInfo.bForceUpdate = (localVerSub[1]~=remoteVerSub[1] or localVerSub[2]~=remoteVerSub[2])
            return true,remoteResInfo.bForceUpdate,remoteResInfo.updateContent
        end
        return true,true,remoteResInfo.updateContent
    end
    return false,false
end

-- Copy resinfo.lua from original package to update directory(ures) 
-- when it is not in ures.
function updater.getLocalResInfo()
    print(string.format("updater.getLocalResInfo, lresinfo:%s, uresinfo:%s", 
        lresinfo,uresinfo))
    local resInfoTxt = nil
    if updater.exists(uresinfo) then
        resInfoTxt = updater.readFile(uresinfo)
    else
        print(ures)        
        if not updater.mkdir(ures) then
            print(ures.. "create error!")
        end
        local info = updater.readFile(lresinfo)
        print("localResInfo:", info)
        assert(info, string.format("Can not get the constent from %s!", lresinfo))
        updater.writeFile(uresinfo, info)
        resInfoTxt = info
    end
    return assert(loadstring(resInfoTxt))()
end

function updater.getOriginalResInfo()
    local info = updater.readFile(lresinfo)
    return assert(loadstring(info))()
end

function updater.getRemoteResInfo(path)
    _initUpdater()
    print("updater.getRemoteResInfo:", path)
    u:setConnectionTimeout(10)
    local resInfoTxt = u:getUpdateInfo(path)
    print("resInfoTxt:", resInfoTxt)
    if string.len(resInfoTxt) < 1 then
        return {}
    end
    return assert(loadstring(resInfoTxt))()
end

cc.PLATFORM_OS_WINDOWS = 0
cc.PLATFORM_OS_LINUX   = 1
cc.PLATFORM_OS_MAC     = 2
cc.PLATFORM_OS_ANDROID = 3
cc.PLATFORM_OS_IPHONE  = 4
cc.PLATFORM_OS_IPAD    = 5
cc.PLATFORM_OS_BLACKBERRY = 6
cc.PLATFORM_OS_NACL    = 7
cc.PLATFORM_OS_EMSCRIPTEN = 8
cc.PLATFORM_OS_TIZEN   = 9
cc.PLATFORM_OS_WINRT   = 10
cc.PLATFORM_OS_WP8     = 11

function updater.update(handler)
    assert(remoteResInfo and remoteResInfo.url_android and remoteResInfo.url_iphone, "Can not get remoteResInfo!")
    print("updater.update:", remoteResInfo.url_android,remoteResInfo.url_iphone)
    if handler then
        print("updater.update handler:", handler)
        u:registerScriptHandler(handler)
    end
    updater.rmdir(utmp)
    -- 判断平台
    local sharedApplication = cc.Application:getInstance()
    local target = sharedApplication:getTargetPlatform()
    if target == cc.PLATFORM_OS_WINDOWS or target == cc.PLATFORM_OS_ANDROID then
        -- 大版本不同，需要强制更新
        if remoteResInfo.bForceUpdate then
            print("bForceUpdate强制升级，清空res ")
            -- 强制升级，清空相关下载res
            updater.cleanDownedRes()
            local luaj = require("update.luaj")
            luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "downLoadApk", {remoteResInfo.url_android_base}, "(Ljava/lang/String;)V")
            return
        end
        if remoteResInfo.androidAction == "update" then            
            u:update(remoteResInfo.url_android, uzip, utmp, false)
            return
        elseif remoteResInfo.androidAction == "toUrl" then
            print("强制升级，清空res",uresinfo)
            -- 强制升级，清空相关下载res
            updater.cleanDownedRes()
            local luaj = require("update.luaj")
            luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "downLoadApk", {remoteResInfo.url_android}, "(Ljava/lang/String;)V")
            return
        end
    elseif target == cc.PLATFORM_OS_IPHONE or target == cc.PLATFORM_OS_IPAD then
        -- 大版本不同，需要强制更新
        if remoteResInfo.bForceUpdate then
            print("bForceUpdate强制升级，清空res")
            -- 强制升级，清空相关下载res
            updater.cleanDownedRes()
            cc.Native:openURL(remoteResInfo.url_iphone_base)
            --return 退出游戏
            os.exit()
            return
        end
        if remoteResInfo.iosAction == "update" then
            u:update(remoteResInfo.url_iphone, uzip, utmp, false)
            return
        elseif remoteResInfo.iosAction == "toUrl" then
            print("强制升级，清空res",uresinfo)
            -- 强制升级，清空相关下载res
            updater.cleanDownedRes()
            cc.Native:openURL(remoteResInfo.url_iphone)
            --return 退出游戏
        end
    elseif target == cc.PLATFORM_OS_WP8 then
        
    end

    os.exit()
end

function updater.cleanDownedRes()
    -- 清空下载的lib文件
    local libList = localResInfo["lib"]
    if libList then
        for k,v in pairs(libList) do
            if f:isAbsolutePath(v) then
                os.remove(v)
            end
        end        
    end
    -- 清空其他文件
    --[[local othList = localResInfo["oth"]
    if othList then
        for k,v in pairs(othList) do
            if f:isAbsolutePath(v) then
                os.remove(v)
            end
        end        
    end]]
        -- 大厅相关文件夹
    local dirRemove = {
        uroot.."res/Common/",
        uroot.."res/pic/",
        uroot.."res/plist/",
        uroot.."res/exportjson/",
    }
    for i,v in ipairs(dirRemove) do
        updater.rmdir(v)
    end
        -- 大厅相关文件
    local filRemove = {
        uroot.."res/GameServer.conf",
        uroot.."res/LobbyServer.conf",
        uroot.."res/LogonServer.conf"
    }
    for i,v in ipairs(filRemove) do
        os.remove(v)
    end
    -- 清空更新模块
    os.remove(uroot.."res/lib/update.zip")
    -- 清空ures文件
    os.remove(uresinfo)
end

function updater._copyNewFile(resInZip)
    -- Create nonexistent directory in update res.
    local i,j = 1,1
    while true do
        j = string.find(resInZip, "/", i)
        if j == nil then break end
        local dir = string.sub(resInZip, 1,j)
        -- Save created directory flag to a table because
        -- the io operation is too slow.
        if not updater._dirList[dir] then
            updater._dirList[dir] = true
            local fullUDir = uroot..dir
            updater.mkdir(fullUDir)
        end
        i = j+1
    end
    local fullFileInURes = uroot..resInZip
    local fullFileInUTmp = utmp..resInZip
    print(string.format('copy %s to %s', fullFileInUTmp, fullFileInURes))
    local zipFileContent = updater.readFile(fullFileInUTmp)
    if zipFileContent then
        updater.writeFile(fullFileInURes, zipFileContent)
        return fullFileInURes
    end
    return nil
end

function updater._copyNewFilesBatch(resType, resInfoInZip)
    local resList = resInfoInZip[resType]
    if not resList then return end
    local finalRes = finalResInfo[resType]
    for __,v in ipairs(resList) do
        local fullFileInURes = updater._copyNewFile(v)
        if fullFileInURes then
            -- Update key and file in the finalResInfo
            -- Ignores the update package because it has been in memory.
            if v ~= "res/lib/update.zip" then
                finalRes[v] = fullFileInURes
            end
        else
            print(string.format("updater ERROR, copy file %s.", v))
        end
    end
end

function updater.updateFinalResInfo()
    assert(localResInfo and remoteResInfo,
        "Perform updater.checkUpdate() first!")
    if not finalResInfo then
        finalResInfo = updater.clone(localResInfo)
    end
    --do return end
    local resInfoTxt = updater.readFile(zresinfo)
    local zipResInfo = assert(loadstring(resInfoTxt))()
    if zipResInfo["version"] then
        finalResInfo.version = zipResInfo["version"]
    end
    if zipResInfo["update_url"] then
        finalResInfo.update_url = zipResInfo["update_url"]
    end
    if zipResInfo["url_downloadClient"] then
        finalResInfo.url_downloadClient = zipResInfo["url_downloadClient"]
    end
    if zipResInfo["url_logon_list"] then
        finalResInfo.url_logon_list = updater.clone(zipResInfo["url_logon_list"])
    end
    -- Save a dir list maked.
    updater._dirList = {}
    updater.copydir(utmp,uroot)
    -- 覆盖lib路径
    updater._copyNewFilesBatch("lib", zipResInfo)
    --updater._copyNewFilesBatch("oth", zipResInfo)
    -- Clean dir list.
    updater._dirList = nil
    updater.rmdir(utmp)
    -- 删除下载文件
    os.remove(uzip)
    local dumpTable = updater.vardump(finalResInfo, "local data", true)
    dumpTable[#dumpTable+1] = "return data"
    if updater.writeFile(uresinfo, table.concat(dumpTable, "\n")) then
        return true
    end
    print(string.format("updater ERROR, write file %s.", uresinfo))
    return false
end

function updater.getResCopy()
    if finalResInfo then return updater.clone(finalResInfo) end
    return updater.clone(localResInfo)
end

function updater.clean()
    if u then
        u:unregisterScriptHandler()
        u:release()
        u = nil
    end
    updater.rmdir(utmp)
    -- 删除下载文件
    os.remove(uzip)

    localResInfo = nil
    remoteResInfo = nil
    finalResInfo = nil
end

return updater