--- The entry of Game
-- @author zrong(zengrong.net)
-- Creation 2014-07-03

local UpdateApp = {}

cc.FileUtils:getInstance():setPopupNotify(false)

res = {}

function io.getres(path)
    if cc.FileUtils:getInstance():isAbsolutePath(path) then
        return path
    end
    if res[path] then return res[path] end
    --[[for key, value in pairs(finalRes.oth) do
        local pathInIndex = string.find(key, path)
        if pathInIndex and pathInIndex >= 1 then
            print("io.getres getvalue:", path)
            res[path] = value
            return value
        end
    end]]
    return path
end

UpdateApp.__cname = "UpdateApp"
UpdateApp.__index = UpdateApp
UpdateApp.__ctype = 2

local sharedDirector = cc.Director:getInstance()
local sharedFileUtils = cc.FileUtils:getInstance()
local updater = require("update.updater")

local Alert = {}
function Alert.map(t, fn)
    for k, v in pairs(t) do
        t[k] = fn(v, k)
    end
end
function Alert:showAlert(title, message, buttonLabels, listener)
    if type(buttonLabels) ~= "table" then
        buttonLabels = {tostring(buttonLabels)}
    else
        Alert.map(buttonLabels, function(v) return tostring(v) end)
    end

    local sharedApplication = cc.Application:getInstance()
    local target = sharedApplication:getTargetPlatform()
    if 3 == target then -- 3 android
        local tempListner = function(event)
            if type(event) == "string" then
                event = require("update.json").decode(event)
                event.buttonIndex = tonumber(event.buttonIndex)
            end
            if listener then listener(event) end
        end
        local luaj = require("update.luaj")
        luaj.callStaticMethod("org/cocos2dx/utils/PSNative", "createAlert", {title, message, buttonLabels, tempListner}, "(Ljava/lang/String;Ljava/lang/String;Ljava/util/Vector;I)V");
    else
        local defaultLabel = ""
        if #buttonLabels > 0 then
            defaultLabel = buttonLabels[1]
            table.remove(buttonLabels, 1)
        end

        cc.Native:createAlert(title, message, defaultLabel)
        for i, label in ipairs(buttonLabels) do
            cc.Native:addAlertButton(label)
        end

        if type(listener) ~= "function" then
            listener = function() end
        end

        cc.Native:showAlert(listener)
    end
end

function UpdateApp.new(...)
    local instance = setmetatable({}, UpdateApp)
    instance.class = UpdateApp
    instance:ctor(...)
    return instance
end

function UpdateApp:ctor(appName, packageRoot)
    self.name = appName
    self.packageRoot = packageRoot or appName
    -- set global app
    _G[self.name] = self
end

function UpdateApp:run(checkNewUpdatePackage)
    --print("I am new update package")
    local newUpdatePackage = updater.hasNewUpdatePackage()
    if  checkNewUpdatePackage and newUpdatePackage then
        self:updateSelf(newUpdatePackage)
        return
    end
    local bNeedUpdate,bForceUpdate,content = updater.checkUpdate()
    if bNeedUpdate then
        Alert:showAlert("719游戏提醒",content or "游戏大厅已经升级，即将进行升级，请确认！",
            {"确定","取消"},function(event)
                if event.action and event.action == "clicked" then
                    if event.buttonIndex == 1 then
                        self:runUpdateScene(function()
                            _G["finalRes"] = updater.getResCopy()
                            self:runRootScene()
                        end)
                    else
                        if bForceUpdate then
                            self:exit()
                        end
                        _G["finalRes"] = updater.getResCopy()
                        self:runRootScene()
                    end
                end
            end)        
    else
        _G["finalRes"] = updater.getResCopy()
        self:runRootScene()
    end
end

-- Remove update package, load new update package and run it.
function UpdateApp:updateSelf(newUpdatePackage)
    print("UpdateApp.updateSelf ", newUpdatePackage)
    local updatePackage = {
        "update.UpdateApp",
        "update.updater",
        "update.updateScene",
        "update.luaj",
        "update.json",
    }
    --self:_printPackages("--before clean")
    for __,v in ipairs(updatePackage) do
        package.preload[v] = nil
        package.loaded[v] = nil
    end
    --self:_printPackages("--after clean")
    _G["update"] = nil
    cc.LuaLoadChunksFromZIP(newUpdatePackage)
    --self:_printPackages("--after CCLuaLoadChunksForZIP")
    require("update.UpdateApp").new("update"):run(false)
    --self:_printPackages("--after require and run")
end

-- Show a scene for update.
function UpdateApp:runUpdateScene(handler)
    self:enterScene(require("update.updateScene").addListener(handler))
end

-- Load all of packages(except update package, it is not in finalRes.lib)
-- and run root app.
function UpdateApp:runRootScene()
    for __, v in pairs(finalRes.lib) do
        print("runRootScene:cc.LuaLoadChunksFromZIP",__, v)
        cc.LuaLoadChunksFromZIP(v)
    end

    require("plazacenter.main")
end

function UpdateApp:_printPackages(label)
    label = label or ""
    print("\npring packages "..label.."------------------")
    for __k, __v in pairs(package.preload) do
        print("package.preload:", __k, __v)
    end
    for __k, __v in pairs(package.loaded) do
        print("package.loaded:", __k, __v)
    end
    print("print packages "..label.."------------------\n")
end


function UpdateApp:exit()
    sharedDirector:endToLua()
    os.exit()
end

function UpdateApp:enterScene(__scene)
    if sharedDirector:getRunningScene() then
        sharedDirector:replaceScene(__scene)
    else
        sharedDirector:runWithScene(__scene)
    end
end

return UpdateApp