--
-- Author: SuperM
-- Date: 2016-01-18 18:03:10
--
local XWWidgetBase = require("plazacenter.widgets.XWWidgetBase")
local HallTaskWidget = class("HallTaskWidget", XWWidgetBase)

function HallTaskWidget:ctor(parentNode,callBack)
	HallTaskWidget.super.ctor(self)

	self.callBack = callBack
	self.widgetType = "HallTaskWidget"
    self.missionMatch = parentNode.MissionMatch
    self.taskInfoList = {}

	self:addTo(parentNode)
end

function HallTaskWidget:onEnter()
    if not self.bFirstEnter then
        return
    end
	HallTaskWidget.super.onEnter(self)

    local node, width, height = cc.uiloader:load(WIDGET_HALL_TASK_CSB_FILE)
    if not node then
        return
    end

    node:setTouchEnabled(false)

    local bgnode = cc.uiloader:seekNodeByName(node, "Image_Animation")
    local closeBtn = cc.uiloader:seekNodeByName(node, "Button_Close")
    self.taskListView = cc.uiloader:seekNodeByName(node, "ListView_Tasks")
    if closeBtn then
        AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(closeBtn)
        closeBtn:onButtonClicked(function ()
            self.callBack()
            self:removeFromParent()
        end)            
    end

    self:addChild(node)

    G_ShowNodeWithBackout(bgnode)

    self:registerEvents()
    -- 请求任务列表
    local CMD_GL_GetTask = {
        dwOpTerminal=GlobalPlatInfo.dwTerminal,
    }
    self:requestCommand(MDM_GL_C_DATA,SUB_GL_C_TASK_LOAD,CMD_GL_GetTask,"CMD_GL_GetTask")
end

function HallTaskWidget:onCleanup()
	HallTaskWidget.super.onCleanup(self)
    self:unregisterEvents()
end

function HallTaskWidget:cleanPlistRes()
	print("HallTaskWidget:cleanPlistRes")
    display.removeSpriteFramesWithFile("UIHallTask.plist", "UIHallTask.png")
end

function HallTaskWidget:registerEvents()
    local eventListeners = eventListeners or {}
    local appBase = AppBaseInstanse.PLAZACENTER_APP
    eventListeners[appBase.Message.LS_TaskLoaded] = handler(self, self.receiveTaskLoadedMessage)
    eventListeners[appBase.Message.LS_TaskReward] = handler(self, self.receiveTaskRewardMessage)
    
    self.eventHandles = appBase.notificationCenter:addAllEventListenerByTable( eventListeners )
end

function HallTaskWidget:unregisterEvents()
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:removeAllListenerByTable(self.eventHandles) 
    self.eventHandles = {}
end

G_tryCatch=function(fun)
  local ret,errMessage=pcall(fun);
  --print("ret:" .. (ret and "true" or "false" )  .. " \nerrMessage:" .. (errMessage or "null"));
end

function G_SetTexture(imgCtrl,strPicName)
    local fun = function () 
        imgCtrl:setTexture("download/"..strPicName..".png")
    end
    G_tryCatch(fun)
end

function HallTaskWidget:setNetworkPic(imgCtrl,strPicName)
    if string.len(strPicName) < 1 then
        return
    end
    if cc.FileUtils:getInstance():isFileExist("download/"..strPicName..".png") then
        --imgCtrl:setTexture("download/"..strPicName..".png")
        G_SetTexture(imgCtrl,strPicName)
    else
        local updater = require("common.UpdaterModule").new()
        if updater then
            updater:updateFile(string.format("%s/image/TaskIcon/%s.png",GlobalWebIPs.szMallWebIP,strPicName)
                    ,strPicName..".png",function (event,value)
                        if event == "success" then
                            --imgCtrl:setTexture("download/"..strPicName..".png")
                            G_SetTexture(imgCtrl,strPicName)
                        end
                    end,false)
            updater:addTo(imgCtrl)
        end
        imgCtrl:setSpriteFrame("pic/plazacenter/Sundry/u_null.png")
    end
end

function HallTaskWidget:addTaskItem(taskInfo)
    local taskListView = self.taskListView
    if taskListView and taskInfo then
        local item = taskListView:newItem()
        local content= cc.uiloader:load(WIDGET_TASK_ITEM_CSB_FILE)
        if not content then
            return
        end
        local title = cc.uiloader:seekNodeByName(content, "Label_Title")
        local desc = cc.uiloader:seekNodeByName(content, "Label_Desc")
        local reward = cc.uiloader:seekNodeByName(content, "Label_Rewards")
        local imgIcon = cc.uiloader:seekNodeByName(content, "Image_Icon")
        local imgProgressBg = cc.uiloader:seekNodeByName(content, "Image_ProgressBg")
        local btnAward = cc.uiloader:seekNodeByName(content, "Button_GetReward")
        if title then
            title:setString(G_TruncationString(taskInfo.szTitle,27))
        end
        if desc then
            desc:setString(taskInfo.szRemarks)
        end
        if reward then
            local strAward = ""
            local awards = taskInfo.Award 
            if awards.dwAward1 ~= 0 then
                strAward = strAward..awards.szAward1.."×"..awards.dwAward1
            end
            if awards.dwAward2 ~= 0 then
                if strAward ~= "" then
                    strAward = strAward..","
                end
                strAward = strAward..awards.szAward2.."×"..awards.dwAward2
            end
            if awards.dwAward3 ~= 0 then
                if strAward ~= "" then
                    strAward = strAward..","
                end
                strAward = strAward..awards.szAward3.."×"..awards.dwAward3
            end
            reward:setString(strAward)
        end
        if imgIcon then
            self:setNetworkPic(imgIcon, taskInfo.szImgName)
        end
        -- 判断任务是否完成
        if imgProgressBg and btnAward then
            if taskInfo.dwCurProgress > 0 and taskInfo.dwCurProgress >= taskInfo.dwProgress then
                imgProgressBg:setVisible(false)
                btnAward:setVisible(true)
                AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(btnAward)
                btnAward:onButtonClicked(function ()
                    self:onOkBtnClicked(item)
                end)
            else
                imgProgressBg:setVisible(true)
                btnAward:setVisible(false)
                -- 创建进度
                local bgSize = imgProgressBg:getContentSize()
                if taskInfo.dwCurProgress > 0 and taskInfo.dwProgress > 0 then
                    local imgProgress = display.newScale9Sprite("#pic/plazacenter/Sundry/u_lv_bar.png", 0, 0, bgSize)
                    imgProgress.maxWidth = bgSize.width
                    imgProgress.height = bgSize.height
                    imgProgress:align(display.LEFT_BOTTOM, 0, 0)
                    imgProgress:addTo(imgProgressBg)
                    while true do
                        local newWidth = imgProgress.maxWidth*taskInfo.dwCurProgress/taskInfo.dwProgress
                        if newWidth >= 1 and newWidth < 20  then
                            newWidth = 20
                        elseif newWidth < 1 then
                            imgProgress:setVisible(false)
                            break
                        end
                        imgProgress:setVisible(true)
                        imgProgress:setContentSize(newWidth,imgProgress.height)
                        break
                    end
                end
                -- 创建文字
                cc.ui.UILabel.new({text = tostring(taskInfo.dwCurProgress).."/"..tostring(taskInfo.dwProgress),
                        font = "微软雅黑",
                        size = 22,
                        align = cc.ui.TEXT_ALIGNMENT_CENTER,
                        valign = cc.ui.VERTICAL_TEXT_ALIGNMENT_CENTER,
                        color = cc.c3b(255, 255, 255),})
                    :align(display.CENTER, bgSize.width/2, bgSize.height/2)
                    :addTo(imgProgressBg)
            end
        end
        item:addContent(content)
        item:setItemSize(content:getContentSize().width,content:getContentSize().height)
        item.taskInfo = taskInfo
        taskListView:addItem(item)
    end
end

function HallTaskWidget:updateTaskList()
    self.taskListView:removeAllItems()
    for k,v in pairs(self.taskInfoList) do
        self:addTaskItem(v)
    end
    self.taskListView:reload()
end

function HallTaskWidget:onOkBtnClicked(taskItem)
    if taskItem and taskItem.taskInfo then
        self.lastRewardItem = taskItem
        local CMD_GL_TaskID = {
            dwTaskID=taskItem.taskInfo.dwTaskID,
            dwUserID=GlobalUserInfo.dwUserID,
            szPassword=GlobalUserInfo.szPassword,
        }
        self:requestCommand(MDM_GL_C_DATA, SUB_GL_C_TASK_REWARD, CMD_GL_TaskID, "CMD_GL_TaskID")
    end
end

function HallTaskWidget:requestCommand(mainID, subID, request,structName)
    if self.missionMatch then
        self:hideLoadingWidget()
        self:showLoadingWidget()
        self:updateStatusLabel("发送请求中，请稍后")
        self.missionMatch:requestCommand(mainID, subID, request,structName)
        self.hideLoadingAction = self:performWithDelay(function ()
            self:hideLoadingWidget()
            local dataMsgBox = {
                nodeParent=self,
                msgboxType=MSGBOX_TYPE_OK,
                msgInfo="发送数据请求失败，请稍后重试！"
            }
            require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        end, 10)
    end
end

function HallTaskWidget:receiveTaskLoadedMessage(event)
    local Params = event.para
    -- CMD_GL_TaskInfo
    self.taskInfoList = {}
    if Params.unResolvedData then
        self.taskInfoList = self.missionMatch:ParseStructGroup(Params.unResolvedData,"CMD_GL_TaskInfo")
    end
    -- 判断是否有任务
    if Params.dwTaskID then
        table.insert(self.taskInfoList,1,Params)
    else
        self.taskInfoList = {}
        local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="您的当天任务已全部完成！",
            callBack=function ()
                self.callBack()
                self:removeFromParent()
            end
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
    end
    self:updateTaskList()

    self:hideLoadingWidget()
end

function HallTaskWidget:receiveTaskRewardMessage(event)
    local CMD_GL_TaskIDLog = event.para
    --CMD_GL_TaskIDLog 
    if CMD_GL_TaskIDLog.lResultCode == 0 then
        if self.lastRewardItem and self.taskListView then
            self.taskListView:removeItem(self.lastRewardItem, true)
            self.lastRewardItem = nil
        end
    end
    local dataMsgBox = {
        nodeParent=self,
        msgboxType=MSGBOX_TYPE_OK,
        msgInfo=CMD_GL_TaskIDLog.szDescribeString
    }
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
    
    self:hideLoadingWidget()
end

function HallTaskWidget:hideLoadingWidget()
    HallTaskWidget.super.hideLoadingWidget(self)
    if self.hideLoadingAction then
        self:stopAction(self.hideLoadingAction)
        self.hideLoadingAction = nil
    end
end

return HallTaskWidget