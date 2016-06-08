------
-- updateScene for update package.
-- This is a object, not a class.
-- In this scene, it will show download progress bar 
-- and state for uncompress.
-- @author zrong(zengrong.net)
-- Creation: 2014-07-03

local updater = require("update.updater")
local sharedDirector         = cc.Director:getInstance()
local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance()

-- check device screen size
local glview = sharedDirector:getOpenGLView()
local size = glview:getFrameSize()
local display = {}
display.sizeInPixels = {width = size.width, height = size.height}

local w = display.sizeInPixels.width
local h = display.sizeInPixels.height

CONFIG_SCREEN_WIDTH = 1136 
CONFIG_SCREEN_HEIGHT = 640
CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"

local scale, scaleX, scaleY

scaleX, scaleY = w / CONFIG_SCREEN_WIDTH, h / CONFIG_SCREEN_HEIGHT
scale = scaleY
CONFIG_SCREEN_WIDTH = w / scale

glview:setDesignResolutionSize(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT, 1)

local winSize = sharedDirector:getWinSize()
display.contentScaleFactor = scale
display.size               = {width = winSize.width, height = winSize.height}
display.width              = display.size.width
display.height             = display.size.height
display.cx                 = display.width / 2
display.cy                 = display.height / 2
display.c_left             = -display.width / 2
display.c_right            = display.width / 2
display.c_top              = display.height / 2
display.c_bottom           = -display.height / 2
display.left               = 0
display.right              = display.width
display.top                = display.height
display.bottom             = 0
display.widthInPixels      = display.sizeInPixels.width
display.heightInPixels     = display.sizeInPixels.height

print("# display in updateScene start")
print(string.format("# us.CONFIG_SCREEN_AUTOSCALE      = %s", CONFIG_SCREEN_AUTOSCALE))
print(string.format("# us.CONFIG_SCREEN_WIDTH          = %0.2f", CONFIG_SCREEN_WIDTH))
print(string.format("# us.CONFIG_SCREEN_HEIGHT         = %0.2f", CONFIG_SCREEN_HEIGHT))
print(string.format("# us.display.widthInPixels        = %0.2f", display.widthInPixels))
print(string.format("# us.display.heightInPixels       = %0.2f", display.heightInPixels))
print(string.format("# us.display.contentScaleFactor   = %0.2f", display.contentScaleFactor))
print(string.format("# us.display.width                = %0.2f", display.width))
print(string.format("# us.display.height               = %0.2f", display.height))
print(string.format("# us.display.cx                   = %0.2f", display.cx))
print(string.format("# us.display.cy                   = %0.2f", display.cy))
print(string.format("# us.display.left                 = %0.2f", display.left))
print(string.format("# us.display.right                = %0.2f", display.right))
print(string.format("# us.display.top                  = %0.2f", display.top))
print(string.format("# us.display.bottom               = %0.2f", display.bottom))
print(string.format("# us.display.c_left               = %0.2f", display.c_left))
print(string.format("# us.display.c_right              = %0.2f", display.c_right))
print(string.format("# us.display.c_top                = %0.2f", display.c_top))
print(string.format("# us.display.c_bottom             = %0.2f", display.c_bottom))
print("# display in updateScene done")

display.ANCHOR_POINTS = {
    {x=0.5, y=0.5},  -- CENTER
    {x=0, y=1},      -- TOP_LEFT
    {x=0.5, y=1},    -- TOP_CENTER
    {x=1, y=1},      -- TOP_RIGHT
    {x=0, y=0.5},    -- CENTER_LEFT
    {x=1, y=0.5},    -- CENTER_RIGHT
    {x=0, y=0},      -- BOTTOM_LEFT
    {x=1, y=0},      -- BOTTOM_RIGHT
    {x=0.5, y=0},    -- BOTTOM_CENTER
}

display.CENTER        = 1
display.LEFT_TOP      = 2; display.TOP_LEFT      = 2
display.CENTER_TOP    = 3; display.TOP_CENTER    = 3
display.RIGHT_TOP     = 4; display.TOP_RIGHT     = 4
display.CENTER_LEFT   = 5; display.LEFT_CENTER   = 5
display.CENTER_RIGHT  = 6; display.RIGHT_CENTER  = 6
display.BOTTOM_LEFT   = 7; display.LEFT_BOTTOM   = 7
display.BOTTOM_RIGHT  = 8; display.RIGHT_BOTTOM  = 8
display.BOTTOM_CENTER = 9; display.CENTER_BOTTOM = 9

function display.align(target, anchorPoint, x, y)
    target:setAnchorPoint(display.ANCHOR_POINTS[anchorPoint])
    if x and y then target:setPosition(x, y) end
end

function display.newSpriteFrame(frameName)
    local frame = sharedSpriteFrameCache:getSpriteFrame(frameName)
    if not frame then
        print("display.newSpriteFrame() - invalid frameName %s", tostring(frameName))
    end
    return frame
end

function display.newFrames(pattern, begin, length, isReversed)
    local frames = {}
    local step = 1
    local last = begin + length - 1
    if isReversed then
        last, begin = begin, last
        step = -1
    end

    for index = begin, last, step do
        local frameName = string.format(pattern, index)
        local frame = sharedSpriteFrameCache:getSpriteFrame(frameName)
        if not frame then
            print("display.newFrames() - invalid frame, name %s", tostring(frameName))
            return
        end

        frames[#frames + 1] = frame
    end
    return frames
end

function display.newAnimation(frames, time)
    local count = #frames
    -- local array = Array:create()
    -- for i = 1, count do
    --     array:addObject(frames[i])
    -- end
    time = time or 1.0 / count
    return cc.Animation:createWithSpriteFrames(frames, time)
end

local us = cc.Scene:create()
us.name = "updateScene"

local localResInfo = nil

function us._addUI()
    -- Get the newest resinfo in ures.
    local localResInfo = updater.getResCopy()
    -- 添加图片资源
    sharedSpriteFrameCache:addSpriteFrames(us._getres("res/plist/UpdateScenePics.plist"),us._getres("res/plist/UpdateScenePics.png"))

    --local __bg = cc.Sprite:create(us._getres("res/pic/init_bg.png"))
    --display.align(__bg, display.CENTER, display.cx, display.cy)
    --us:addChild(__bg, 0)

    -- 背景色
    local __bgColor = cc.LayerColor:create({ r =0, g =0, b =0, a =0 })
    us:addChild(__bgColor, 0)
    -- ICON
    local frame = display.newSpriteFrame("logo.png")
    if frame then
        local icon = cc.Sprite:createWithSpriteFrame(frame)
        display.align(icon, display.CENTER, display.left+100, display.top-100)
        us:addChild(icon, 0)
    end
    
    -- 动画
    local frames = display.newFrames("donghua/%d.png", 1, 9)
    local animation = display.newAnimation(frames, 2 / 9) -- 0.5 秒播放 8 桢
    local action = cc.RepeatForever:create(cc.Animate:create(animation))
    local animationSprite = cc.Sprite:create()
    display.align(animationSprite, display.CENTER, display.cx, display.cy)
    us:addChild(animationSprite, 0)
    animationSprite:runAction(action)

    -- 进度条
        -- 背景
    frame = display.newSpriteFrame("progress_Bg.png")
    if frame then
        local progressBg = ccui.Scale9Sprite:createWithSpriteFrame(frame,{x=18,y=17,width=2,height=1})
        progressBg:setContentSize(display.width-346,35)
        display.align(progressBg, display.CENTER, display.cx, display.cy-75)
        us:addChild(progressBg, 0)
        -- 前景
        frame = display.newSpriteFrame("progress_Fore.png")
        if frame then
            local progressSprite = cc.Sprite:createWithSpriteFrame(frame)
            local progress = cc.ProgressTimer:create(progressSprite)
            progress:setType(1)
            progress:setMidpoint({x=0, y=0.5})
            progress:setBarChangeRate({x=1.0, y=0})
            progress:setPosition(progressBg:getContentSize().width/2, progressBg:getContentSize().height/2)
            progressBg:addChild(progress)
            us.progress = progress
        end
    end

    local __label = cc.LabelTTF:create("正在进行更新，已完成0%！", "微软雅黑", 24)
    __label:setColor({r=137,g=251,b=114})
    us._label = __label
    display.align(__label, display.CENTER, display.cx, display.cy-110)
    us:addChild(__label, 10)
end

function us._getres(path)
    if not localResInfo then
        localResInfo = updater.getResCopy()
    end
    --[[for key, value in pairs(localResInfo.oth) do
        print("us._getres:", key, value)
        local pathInIndex = string.find(key, path)
        if pathInIndex and pathInIndex >= 1 then
            print("us._getres getvalue:", path)
            res[path] = value
            return value
        end
    end]]
    return path
end

function us._sceneHandler(event)
    if event == "enter" then
        print(string.format("updateScene \"%s:onEnter()\"", us.name))
        us.onEnter()
    elseif event == "cleanup" then
        print(string.format("updateScene \"%s:onCleanup()\"", us.name))
        us.onCleanup()
    elseif event == "exit" then
        print(string.format("updateScene \"%s:onExit()\"", us.name))
        us.onExit()

        if DEBUG_MEM then
            print("----------------------------------------")
            print(string.format("LUA VM MEMORY USED: %0.2f KB", collectgarbage("count")))
            cc.TextureCache:sharedTextureCache():dumpCachedTextureInfo()
            print("----------------------------------------")
        end
    end
end

function us._updateHandler(event, value)
    updater.state = event
    if event == "success" then
        updater.stateValue = value
        updater.updateFinalResInfo()
        if us._succHandler then
            us._succHandler()
        end
    elseif event == "error" then
        updater.stateValue = value
    elseif event == "progress" then
        updater.stateValue = tostring(value)
        if us.progress then
            us.progress:setPercentage(value)
        end
        if us._label then
            us._label:setString("正在进行更新，已完成"..value.."%！")
        end
    elseif event == "state" then
        updater.stateValue = value
    end
    --us._label:setString(updater.stateValue)
    if event == "error" then
        print(string.format("Update error: %s ", updater.stateValue))
        -- 更新失败，直接进入
        if us._succHandler then
            us._succHandler()
        end
    end
end

function us.addListener(handler)
    us._succHandler = handler
    return us
end

function us.onEnter()
    print("us.onEnter")
    updater.update(us._updateHandler)
end

function us.onExit()    
    print("us.onExit")
    updater.clean()
    us:unregisterScriptHandler()
    -- 释放图片资源
    sharedSpriteFrameCache:removeSpriteFramesFromFile(us._getres("res/plist/UpdateScenePics.plist"))
    sharedSpriteFrameCache:removeSpriteFrameByName(us._getres("res/plist/UpdateScenePics.png"))
    cc.Director:getInstance():getTextureCache():removeTextureForKey(us._getres("res/plist/UpdateScenePics.png"))
end

function us.onCleanup()
end

us:registerScriptHandler(us._sceneHandler)
us._addUI()
return us