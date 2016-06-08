oxui = {}

oxui.getUIByName = function(name)
	if name then
		return cc.uiloader:load(name)
	else
		print("name is nil")
	end 
end 

oxui.getNodeByName = function(node,name)
	if node and name then
		return cc.uiloader:seekNodeByName(node,name)
	else
		print("node or name is nil")
	end
	
end

oxui.addArmatureFileByName = function(name)
	if name then
		return ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(name)
	else
		print("name is nil")
	end
	
end
 ---增加一个定时器
 ---方法
 ---时间
 ---是否暂停
oxui.TimerHandlerCache = oxui.TimerHandlerCache or {}

oxui.schedule = function(listener, interval, times)
    if listener == nil or type(listener) ~= "function" then
       --print("Error : fftimer schedule error: listener == nil or not a function")
        return
    end

    interval = interval or 1
    times = times or 0

    local current = 0
    local handle
    local state

    local function timerHandler()
        state = listener(current, times, handle)
    end

    local function callback()

        if times == 0 or current < times then
            current = current + 1

            local state2,error = pcall(timerHandler)
            if error then
                --print("Error : fftimer error : " .. error)
            end
            if (times > 0 and current >= times) or state == false or state2 == false then
                oxui.stop(handle)
            end
        else
            oxui.stop(handle)
        end

    end

    handle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, interval, false)
    oxui.TimerHandlerCache[handle] = true
    return handle
end 

oxui.stop = function(handle)
    if handle then
        if type(handle) == "number" then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(handle)
        else
            local node = oxui.TimerHandlerCache[handle]
            if node then
                node:stopAction(handle)
            else 
            end
        end
        oxui.TimerHandlerCache[handle] = nil
    end
end 

oxui.soundPath = "sound/"
oxui.soundPathOther = oxui.soundPath .. "otherOx/"
oxui.musicPath = "music/"
oxui.ogg = "oxtbnew/ogg/"
oxui.pauseMusicBackground = function()
    SoundManager:pauseMusicBackground()
end

-- 音效的名字，是否循环
oxui.playSound = function(name,isLoop,t)
    local n = name
    if not n then
    	return
    end
    
    local loop = isLoop
    if not isLoop then
    	isLoop = false
    end
    
    local type = t
    local str = ".mp3" 
    if type == OxtbNewDefine.wav then
        type = ".wav"
    elseif type == OxtbNewDefine.m4a then
        type = ".m4a"
    else
        type = ".mp3"
    end
    local n = "oxtbnew/ogg/" .. name .. type
    
    SoundManager:playMusicEffect(n,loop,false)    
end
 
oxui.cacheAnimationList = oxui.cacheAnimationList or {}
oxui.animPath = "oxtbnew/animation/"
oxui.playAnimation = function(parent, z, filename, animationIndexOrName, isLoop, speedScale, isAutoRemoveOrCallback, prePath)
    prePath = prePath or oxui.animPath
    local path = prePath .. filename ..  ".ExportJson"
    oxui.loadAnimationData(path, filename)
    local armature = ccs.Armature:create(filename)
    if parent then
        if z then
            parent:addChild(armature, z)
        else
            parent:addChild(armature)
        end
    end

    local animation = armature:getAnimation()
    if speedScale then
        animation:setSpeedScale(speedScale)
    end

    if isAutoRemoveOrCallback then
        local handler
        if type(isAutoRemoveOrCallback) == "function" then
            handler = isAutoRemoveOrCallback
        elseif type(isAutoRemoveOrCallback) == "boolean" then
            if isAutoRemoveOrCallback then
                handler = function(s, e, movementID)
                    if ccs.MovementEventType.complete == e or ccs.MovementEventType.loopComplete == e then
                        s:removeFromParent()
                        oxui.removeArmatureFileInfo()
                    end
                end
            end
        end
        if handler then
            animation:setMovementEventCallFunc(handler)
        end
    end

    if animationIndexOrName then
        --播放动画
        local durationTo = -1

        local loop = -1
        if isLoop == true then
            loop = 1
        elseif isLoop == false then
            loop = 0
        end

        if type(animationIndexOrName) == "number" then
            animation:playWithIndex(animationIndexOrName, durationTo, loop)
        else
            animation:play(animationIndexOrName, durationTo, loop)
        end
    end

    local arr = oxui.cacheAnimationList[path]
    if not arr then
        arr = {}
        oxui.cacheAnimationList[path] = arr
    end
    table.insert(arr, armature)

    return armature
end

oxui.removeAll = function ()  
   
    --cc.SpriteFrameCache:getInstance():removeSpriteFramesFromTexture("oxtbnew/u_game_table.jpg")

end

--删除动画
oxui.removeArmatureFileInfo = function(filename, isFullPath)

    --清理缓存的动画，不使用的都删除
     for path, arr in pairs(oxui.cacheAnimationList) do
         local isClear = true
         for key, armature in pairs(arr) do
             if armature then
                 isClear = false
                 break
             end
         end
         if isClear then
             oxui.cacheAnimationList[path] = nil
             ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(path)
         end
     end


    --清理指定文件
    if filename then
         local path
         if isFullPath then
             path = filename
         else
             path = oxui.animPath .. filename ..  ".ExportJson"
         end
         --dump(path)
         ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(path)
         
        display.removeSpriteFramesWithFile(oxui.animPath .. filename .. ".plist",oxui.animPath .. filename .. ".png")
        
    end
end


oxui.loadAnimationData = function (path, action)

    if not cc.FileUtils:getInstance():isFileExist(path) then
        print("动画文件:   " .. path .. "  不存在")
        return false
    end

    --加载动画
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(path)
    local animationData = ccs.ArmatureDataManager:getInstance():getAnimationData(action)
    local armatureData =  ccs.ArmatureDataManager:getInstance():getArmatureData(action)


    if not animationData or not armatureData then
        --释放以前的错误动画,
        oxui.removeArmatureFileInfo(path, true)

        --重新加载动画
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(path)
        animationData = ccs.ArmatureDataManager:getInstance():getAnimationData(action)
        armatureData =  ccs.ArmatureDataManager:getInstance():getArmatureData(action)

        if not animationData or not armatureData then
            print("动画文件:   " .. path .. " 内容不存在 重新加载失败")
            return false
        end

        print("动画文件:   " .. path .. " 内容不存在, 重新加载成功")
    end

    return true
end
 
 oxui.string= function(num)
    local n = num
    if num > 10000 and num < 10000000 then
        n = string.format("%.2f",num /10000) .. "万"
    elseif  num >= 10000000  then
        n = string.format("%.2f",num /100000000) .. "亿"
    end
    return n 
 end

oxui.tableshift = function(array)
    local ret = table.remove(array, 1)
    return ret
end

oxui.BMString= function(num)
    local n = num
    if num > 10000 and num < 10000000 then
        n = "+" .. string.format("%.2f",num /10000) .. ":"
    elseif  num >= 10000000  then
        n = "+" .. string.format("%.2f",num /100000000) .. ";"
    elseif num > 0 then
        n = "+" .. num
    elseif num < -10000  and num > -10000000 then
        n =  string.format("%.2f",num /10000) .. ":"
    elseif num <= -10000000 then
        n =  string.format("%.2f",num /100000000) .. ";"
    end
    return n 
end

return oxui