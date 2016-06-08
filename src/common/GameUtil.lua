--[[
	工具类 
]]--
GameUtil = class("GameUtil").new()

function GameUtil:ctor()
	
end


-- 扑克牌牌型对应的中文名称
local PrefixCardTypeChineseNames = {
	"方块",		
	"梅花", 		
	"红桃",		
	"黑桃", 		
}

--扑克牌序号列表
local PokerCardNumber = {
	"A",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"10",
	"J",
	"Q",
	"K",
}

-- push scene
function GameUtil:replaceScene( sceneName, args, transitionType, time, more )
	local scenePackageName = "ninePieces.App.Scene." .. sceneName
	local sceneClass = require(scenePackageName)
	local scene = sceneClass.new(unpack(checktable(args)))
	if transitionType then
		scene = display.wrapSceneWithTransition(scene, transitionType, time, more)
	end
	cc.Director:getInstance():replaceScene(scene)
end

-- push scene
function GameUtil:pushScene( sceneName, args, transitionType, time, more )
	local scenePackageName = "ninePieces.App.Scene." .. sceneName
	local sceneClass = require(scenePackageName)
	local scene = sceneClass.new(unpack(checktable(args)))
	if transitionType then
		scene = display.wrapSceneWithTransition(scene, transitionType, time, more)
	end
	cc.Director:getInstance():pushScene(scene)
end

-- push test scene
function GameUtil:pushTestScene( sceneName, args, transitionType, time, more )
	local scenePackageName = "ninePieces.App.Test." .. sceneName
	local sceneClass = require(scenePackageName)
	local scene = sceneClass.new(unpack(checktable(args)))
	if transitionType then
		scene = display.wrapSceneWithTransition(scene, transitionType, time, more)
	end
	cc.Director:getInstance():pushScene(scene)
end

-- 读取cocostudio json
-- fileName  需包含文件路径和文件名, 不需包含后缀名
function GameUtil:widgetFromCocostudioFile( fileName )
	if fileName then
		local mainWidget = nil
		local name = fileName .. ".json"
		if false == cc.FileUtils:getInstance():isFileExist(cc.FileUtils:getInstance():fullPathForFilename(tostring(name))) then
			mainWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile(string.format("%s.csb", fileName))
		else
			mainWidget = ccs.GUIReader:getInstance():widgetFromJsonFile(name);
		end
		-- 适应分辨率策略
		if mainWidget then
			local visiblePanel = mainWidget:getChildByName("VisiblePanel")
			if visiblePanel then
				visiblePanel:setContentSize(cc.size(display.width, display.height))
				visiblePanel:ignoreContentAdaptWithSize(false)
			end
		end
		return mainWidget
	end
end

function print_table(lua_table, indent)
	indent = indent or 0
	for k, v in pairs(lua_table) do
		if type(k) == "string" then
			k = string.format("%q", k)
		end
		local szSuffix = ""
		if type(v) == "table" then
			szSuffix = "{"
		end
		local szPrefix = string.rep("    ", indent)
		formatting = szPrefix.."["..k.."]".." = "..szSuffix
		if type(v) == "table" then
			print(formatting)
			print_table(v, indent + 1)
			print(szPrefix.."},")
		else
			local szValue = ""
			if type(v) == "string" then
				szValue = string.format("%q", v)
			else
				szValue = tostring(v)
			end
			print(formatting..szValue..",")
		end
	end
end

--筹码数字转字符
function GameUtil:getFormatChips( num ,digitNum)
	if nil == num then
		return nil
	end
	local formatUnits = {"K", "M", "B", "T"}
	local formatString = ""
	if num >= 1000 then
		local d = num
		local index = 0
		while d >= 1000 and index < (#formatUnits - 1) do
			d = d / 1000
			index = index + 1
		end
		local temp = math.floor(d)
		if temp == d then
			formatString = string.format("%.f%s", d, formatUnits[index])
		else
			d = (math.floor(d * 100)) / 100
			formatString = string.format("%.2f%s", d, formatUnits[index])
			if digitNum then
				formatString = string.format("%." .. digitNum .. "f%s", d, formatUnits[index])
			end
		end
	else 
		formatString = tostring(num)
	end

	return formatString
end

--args
--pointTable {{x = 171,y= 490},{x = 171,y = 193},{x = 206,y = 213},{x = 206, y =517}},
--winpos cc.p(0,0)
function GameUtil:InsidePolygon(pointTable,winPos)
	local ptCount = #pointTable
	--printInfo("ptCount"..ptCount)
	local px = winPos.x 
	local py = winPos.y
	local count1 = 0
	local count2 = 0

	local  j  = ptCount
	for i,pt in pairs(pointTable) do
		if i ~= 1 then
			j = i -1
		end
		if type(pt) == "table" and pt.x and pt.y then
			local value = (px - pointTable[j].x) * (pointTable[i].y - pointTable[j].y) -
				(py - pointTable[j].y) * (pointTable[i].x - pointTable[j].x);
			if value > 0 then
				count1 = count1 + 1
			elseif value < 0 then
				count2 = count2 + 1
			end
		end

	end

	if 0 == count1 or  0 == count2 then
		return true
	end

	return false
end

function GameUtil:GetCard( index )
	local startIndex = 0
	local endIndex = 51
	if "number" == type(index) and index >= startIndex and index <= endIndex then
		local typeIndex = index % 4 + 1
		local number = math.floor(index / 4) + 1
		return typeIndex, number
	end
end

function GameUtil:GetCardForPc( index )
	local startIndex = 0
	local endIndex = 100
	if "number" == type(index) and index >= startIndex and index <= endIndex then
		local typeIndex = math.floor(index / 16)
		local number = index % 16
		return typeIndex, number
	end
end

function GameUtil:GetCardLogicValue( index )
	local number = index % 16
	if number == 2 or number == 1 then
		return number + 9
	else
		return number
	end
end

function GameUtil:GetCardType( index )
	return math.floor(index / 16)
end

--通过POKERCARD 对象还原牌的初值
function GameUtil:GetCardValueByPokerCard(card)
	return card.ctype*16 + card.number
end


function GameUtil:SwitchViewChairID(mechairId,chairId)
	print("mechairId = "..mechairId)
	if mechairId ~=2 then
		return (chairId+2-mechairId)%4
	else
		return chairId
	end
end

function GameUtil:playScaleAnimation(less, pSender)
	local  scale = less and 0.9 or 1
	pSender:runAction(cc.ScaleTo:create(0.2,scale))
end

function GameUtil:compByIndex(item1,item2)
    if GameUtil:GetCardLogicValue(item1) > GameUtil:GetCardLogicValue(item2) then
        return true
    else
        --相同牌值比花色
        if GameUtil:GetCardLogicValue(item1) == GameUtil:GetCardLogicValue(item2) then
            if  GameUtil:GetCardType(item1)  > GameUtil:GetCardType(item2)then
                return true
            end
        end
        return false
    end
end

