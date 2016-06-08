require("common.BitMethodEx")
-- return level,leftExp,percent
function G_GetUserLevel(experience)
    local levelExperGroup={
        0,
        500,1500,3500,6500,11500,
        17500,24500,34500,45500,57500,
        68000,98000,138000,188000,248000,
        318000,428000,578000,768000,998000,
        1298000,1648000,2048000,2498000,2998000,
        3798000,4898000,6298000,7998000,9998000,
        12998000,16498000,19998000,23998000,29998000,
        39998000,54998000,69998000,84998000,99998000,
        129998000,179998000,249998000,349998000,499998000
    }

    for i,v in ipairs(levelExperGroup) do
        if experience < v then
            return i-2,v-experience,(experience-levelExperGroup[i-1])/(v-levelExperGroup[i-1])
        end
    end
    
    return (#levelExperGroup-1),0,0
end

local nVipExperGroup={
        10,100,500,2000,5000,20000,50000
    }
-- return level,leftMoney,nextLv
function G_GetUserVipLevel(nMoney)
    for i,v in ipairs(nVipExperGroup) do
        if nMoney < v then
            return i-1,v-nMoney,v
        end
    end
    
    return (#nVipExperGroup),0,0
end
-- return percent
function G_GetUserVipLevelPercent(nMoney)  
    nMoney = nMoney or 0
    for i,v in ipairs(nVipExperGroup) do
        if nMoney < v then
            if i<2 then
                return nMoney/v
            end
            return (nMoney-nVipExperGroup[i-1])/(v-nVipExperGroup[i-1])
        end
    end
    
    return 0
end
-- return leftmoney
function G_GetUserVipLevelLeft(nMoney,level)  
    nMoney = nMoney or 0
    if level > 0 and level < 8 then
        local leftMoney = nVipExperGroup[level] - nMoney
        if leftMoney > 0 then
            return leftMoney
        end
    end
    
    return 0
end
--add widget to quick button(touch bug) 
function G_uiWidgetVirtualBtn(btnOrg,size)
    if btnOrg then
        size = size or cc.size(0,0)
        local btnVirtual = ccui.Widget:create()
        btnVirtual:setContentSize(size)
        btnVirtual:setPosition(0, 0)
        btnVirtual:setTouchEnabled(true)
        btnVirtual:addTouchEventListener(function (pSender,eventType)
            if eventType == 0 then
                btnOrg.fsm_:doEvent("press")
                btnOrg:dispatchEvent({name = btnOrg.PRESSED_EVENT, x = 0, y = 0, touchInTarget = true})
            elseif eventType == 2 or eventType == 3 then
                btnOrg.fsm_:doEvent("release")
                btnOrg:dispatchEvent({name = btnOrg.RELEASE_EVENT, x = 0, y = 0, touchInTarget = true})
                if eventType == 2 then
                    btnOrg:dispatchEvent({name = btnOrg.CLICKED_EVENT, x = 0, y = 0, touchInTarget = true})
                end
            end
        end)
        btnOrg:addChild(btnVirtual,100)
    end
end
-- calc maxlength string
function G_TruncationString(strOrg, maxLength)
    local strRet = strOrg
    if string.len(strRet) > maxLength then
        local len = maxLength
        local cByte = string.byte(strRet,len)
        if bitEx:_rshift(cByte,7) ~= 0 and len > 1 then
            while len > 1 do
                len = len - 1
                cByte = string.byte(strRet,len)
                if bitEx:_rshift(cByte,7) == 0 then
                    break
                end
                if bitEx:_rshift(cByte,6) ~= 2 then
                    if len > 0 then
                        len = len - 1
                    end
                    break
                end
            end
        end
        return string.sub(strRet,1,len).."..."
    end
    return strRet
end

-- calc maxlength string
function G_ShowNodeWithBackout(node)
    if node then
        if node.setScale then
            node:setScale(0.5)
        end
        if node.performWithDelay then
            node:performWithDelay(function ()
                transition.execute(node,cc.ScaleTo:create(0.2, 1),{easing="backout",time="0.2"})
            end,0)
        end
    end
end

function G_EfficacyPassPortID(strNumber)
    strNumber = string.upper(strNumber)

    local nCharLength = string.len(strNumber)
    if nCharLength ~= 18 then
        return false,"身份证号码必须为 18 位数字或字符x！"
    end

    -- 校验前17位是否为数字
    local strNumber1_9 = string.sub(strNumber,1,9)
    local strNumber10_17 = string.sub(strNumber,10,17)
    if not tonumber(strNumber1_9) or not tonumber(strNumber10_17) then
        return false,"身份证号码必须为 18 位数字或字符x！"
    end
    -- 校验18位是否为数字或X
    if not tonumber(string.sub(strNumber,18)) and not string.find(strNumber,"X") then
        return false,"身份证号码必须为 18 位数字或字符x！"
    end
    -- 校验年月日
    local nYear = tonumber(string.sub(strNumber,7,10))
    local nMonth = tonumber(string.sub(strNumber,11,12))
    local nDay = tonumber(string.sub(strNumber,13,14))
    if not nYear or nYear<1900 or nYear > 2100
     or not nMonth or nMonth<1 or nMonth > 12
     or not nDay or nDay<1 or nDay > 31 then
        return false,"您输入的身份证号码不正确，请重新输入！"
    end
    -- 校验码校验
    local nSum = 0
    local nWi = {7,9,10,5,8,4,2,1,6,3,7,9,10,5,8,4,2,1}
    local cCheckArry = {string.byte("1"),string.byte("0"),
            string.byte("X"),string.byte("9"),string.byte("8"),
            string.byte("7"),string.byte("6"),string.byte("5"),
            string.byte("4"),string.byte("3"),string.byte("2")}
    for i=1,17 do
        nSum = nSum + nWi[i]*tonumber(string.sub(strNumber,i,i))
    end
    local cCheck=cCheckArry[nSum%11+1]
    local cCheck2=string.byte(strNumber,18)
    if cCheck ~= cCheck2 then
        return false,"您输入的身份证号码不正确，请重新输入！"
    end

    return true
end

function G_RequireFile(filePath)
    local fileTxt = cc.FileUtils:getInstance():getStringFromFile(filePath)
    if string.len(fileTxt) > 1 then
        local f = loadstring(fileTxt)
        if f then
            return f()
        end
    end
    return nil
end

function G_showFloatTips(tipsTxt,x,y,parentNode)
    if tipsTxt and string.len(tipsTxt)>0 then
        x = x or display.cx
        y = y or display.cy
        parentNode = parentNode or display.getRunningScene()
        local label = display.newTTFLabel({
            text = tipsTxt,
            font = "微软雅黑",
            size = 25,
            color = cc.c3b(255, 255, 255),
            align = cc.TEXT_ALIGNMENT_LEFT,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        })
        label:enableShadow(cc.c4b(120, 16, 0, 255))
        local size = label:getContentSize()
        size.width = size.width + 20*2
        size.height = size.height + 5*2
        local bg = cc.LayerColor:create(cc.c4b(0, 0, 0, 150))
        bg:size(size)
        bg:addChild(label)
        label:align(display.CENTER, size.width/2, size.height/2)
        bg:align(display.CENTER, x, y)
        bg:ignoreAnchorPointForPosition(false)
        parentNode:addChild(bg, 1000)

        bg:setScale(0)
        local sequence = transition.sequence({
            cc.ScaleTo:create(0.2, 1),
            cc.DelayTime:create(2),
            cc.FadeOut:create(0.5),
            cc.CallFunc:create(function ()
                bg:removeFromParent()
                dump("floatTips remove")
            end)
        })
        bg:runAction(sequence)
    end
end

