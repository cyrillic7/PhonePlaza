local GameLogic = class("GameLogic")

local aceType = 4
--构造本类
function GameLogic:ctor()
    self.cardData = {}
end

function GameLogic:GetCardType(cbCardData,cbCardCount,CadData)

    if cbCardCount ~= 5 then
        return 0
    end
    self.cardData = cbCardData
    local cbCardDataSort = cbCardData
    local bcOutCadData = CadData
    local iSingleA = {}
    local iGetTenCount = 0
    local iBigValue = 0
    local bcMakeMax = {}
    dump(cbCardData)
    dump(CadData)
    bcOutCadData = self:SortCardList(cbCardDataSort,cbCardCount)
    cbCardDataSort = self:SortCardList(cbCardDataSort,cbCardCount)
    dump(bcOutCadData)
    for  iten = 1,cbCardCount do
        if(self:GetCardLogicValue(cbCardDataSort[iten])==10 or self:GetCardLogicValue(cbCardDataSort[iten]) ==11) then
            iGetTenCount = iGetTenCount + 1
        end
    end
    dump(bcOutCadData)
    print("iGetTenCount = " .. iGetTenCount)
    if iGetTenCount>=3 then
        if self:GetCardColor(cbCardDataSort[1])==aceType and self:GetCardColor(cbCardDataSort[2])== aceType then
            if bcOutCadData then
                bcOutCadData[1] = cbCardDataSort[1]
                bcOutCadData[2] = cbCardDataSort[4]
                bcOutCadData[3] = cbCardDataSort[5]
                bcOutCadData[4] = cbCardDataSort[2]
                bcOutCadData[5] = cbCardDataSort[3]
                return 10
            end

            if(self:GetCardColor(cbCardDataSort[1]) == aceType) then
                --大小王与最小的组合成牛
                if bcOutCadData then
                    bcOutCadData[1] = cbCardDataSort[1]
                    bcOutCadData[2] = cbCardDataSort[4]
                    bcOutCadData[3] = cbCardDataSort[5]
                    bcOutCadData[4] = cbCardDataSort[2]
                    bcOutCadData[5] = cbCardDataSort[3]
                end
                return 10
            else
                iBigValue=self:GetCardLogicValue(cbCardDataSort[4])+self:GetCardLogicValue(cbCardDataSort[5])
                if iBigValue % 10 == 0 then
                    return 10
                else
                    return iBigValue%10
                end
            end
        end
    end
    if iGetTenCount==2 or (iGetTenCount==1 and self:GetCardColor(cbCardDataSort[0]) == aceType) then
        if(self:GetCardColor(cbCardDataSort[1]) ==aceType and self:GetCardColor(cbCardDataSort[2]) == aceType) then
            if bcOutCadData then
                bcOutCadData[1] = cbCardDataSort[1]
                bcOutCadData[2] = cbCardDataSort[4]
                bcOutCadData[3] = cbCardDataSort[5]
                bcOutCadData[4] = cbCardDataSort[2]
                bcOutCadData[5] = cbCardDataSort[3]
            end
            return 10
        else 
            --如果有一张王 其他任意三张组合为10则是牛牛
            if self:GetCardColor(cbCardDataSort[1])==aceType then
                for n=2,cbCardCount do
                    for j = 2,cbCardCount do
                        if j ~= n then
                            for w = 2,cbCardCount do
                                if w ~= n and w ~= j then
                                    --如果剩余的四张中任意三张能组合位10的整数倍
                                    if((self:GetCardLogicValue(cbCardDataSort[n])+self:GetCardLogicValue(cbCardDataSort[j])+self:GetCardLogicValue(cbCardDataSort[w]))%10==0) then
                                        local add = 0
                                        for y = 2,cbCardCount do
                                            if y ~= n and y ~= j and y ~= w then
                                                iSingleA[add] =cbCardDataSort[y]
                                                add = add + 1
                                            end
                                        end
                                        if bcOutCadData then
                                            bcOutCadData[1] = cbCardDataSort[n]
                                            bcOutCadData[2] = cbCardDataSort[j]
                                            bcOutCadData[3] = cbCardDataSort[w]
                                            bcOutCadData[4] = cbCardDataSort[0]
                                            bcOutCadData[5] = iSingleA[0]
                                        end
                                        return 10
                                    end
                                end
                            end
                        end
                    end
                end
                --如果有一张王 其他任意三张组合不为10则 取两张点数最大的组合
                local bcTmp = {}
                local iBig = 1
                for  ini = 2 , cbCardCount do
                    for j = 2, cbCardCount do
                        if ini ~= j then
                            local bclogic = (self:GetCardLogicValue(cbCardDataSort[ini])+self:GetCardLogicValue(cbCardDataSort[j]))%10
                            if bclogic>iBig then
                                iBig = bclogic
                                local add = 1
                                bcTmp[1]=cbCardDataSort[ini]
                                bcTmp[2]=cbCardDataSort[j]
                                for y = 2, cbCardCount do
                                    if y ~= ini and y~=j then
                                        iSingleA[add] =cbCardDataSort[y]
                                        add = add + 1
                                    end
                                end
                                bcTmp[3]=iSingleA[1]
                                bcTmp[4]=iSingleA[2]
                            end
                        end
                    end
                end

                if bcOutCadData then
                    bcOutCadData[1] = cbCardDataSort[1]
                    bcOutCadData[2] = bcTmp[3]
                    bcOutCadData[3] = bcTmp[4]
                    bcOutCadData[4] = bcTmp[1]
                    bcOutCadData[5] = bcTmp[2]
                end
                if iGetTenCount==1 and self:GetCardColor(cbCardDataSort[1])==aceType then
                --下面还能组合 有两张为 10 也可以组合成牛牛
                else
                    --如果没有则比较 完与最小组合最大点数和组合
                    iBigValue=self:GetCardLogicValue(bcTmp[1])+self:GetCardLogicValue(bcTmp[2])
                    print("iBigValue = " .. iBigValue)
                    if iBigValue%10==0 then
                        return 10
                    else
                        return iBigValue%10
                    end
                end
            else
                if((self:GetCardLogicValue(cbCardDataSort[4])+self:GetCardLogicValue(cbCardDataSort[5])+self:GetCardLogicValue(cbCardDataSort[5]))%10==0) then
                    if bcOutCadData then
                        bcOutCadData[1] = cbCardDataSort[3]
                        bcOutCadData[2] = cbCardDataSort[4]
                        bcOutCadData[3] = cbCardDataSort[5]
                        bcOutCadData[4] = cbCardDataSort[1]
                        bcOutCadData[5] = cbCardDataSort[2]
                    end
                    return 10
                else
                    for n= 3,cbCardCount do
                        for j = 3,cbCardCount do
                            if j ~= n then
                                if((self:GetCardLogicValue(cbCardDataSort[n])+self:GetCardLogicValue(cbCardDataSort[j]))%10==0) then
                                    local add = 1
                                    for y = 4,cbCardCount do
                                        if y ~= n and y ~= j then
                                            iSingleA[add] =cbCardDataSort[y]
                                            add = add + 1
                                        end
                                    end
                                    if iBigValue <= iSingleA[1]%10 then
                                        iBigValue = self:GetCardLogicValue(iSingleA[1])%10
                                        if bcOutCadData then
                                            bcOutCadData[1]= cbCardDataSort[1]
                                            bcOutCadData[2]= cbCardDataSort[n]
                                            bcOutCadData[3]= cbCardDataSort[j]
                                            bcOutCadData[4]= cbCardDataSort[2]
                                            bcOutCadData[5]= iSingleA[1]
                                        end
                                        if iBigValue==0 then
                                            return 10
                                        end
                                    end
                                end
                            end
                        end
                    end 
                    if(iBigValue ~= 0) then
                        if iBigValue%10 == 0 then
                            return 10
                        else
                            return iBigValue%10
                        end
                    end
                end
            end
        end
        iGetTenCount = 1
    end 
    if iGetTenCount==1 then
        if self:GetCardColor(cbCardDataSort[1]) == aceType then
            for n= 2,cbCardCount do
                for j = 2 , cbCardCount do
                    if j ~= n then
                        --任意两张组合成牛
                        if (self:GetCardLogicValue(cbCardDataSort[n])+self:GetCardLogicValue(cbCardDataSort[j]))%10 == 0 then
                            local add = 1
                            for y = 2, cbCardCount do
                                if(y ~= n and y ~= j) then
                                    iSingleA[add] =cbCardDataSort[y]
                                    add = add + 1
                                end
                            end
                            if bcOutCadData then
                                bcOutCadData[1] = cbCardDataSort[1]
                                bcOutCadData[2] = iSingleA[1]
                                bcOutCadData[3] = iSingleA[2]
                                bcOutCadData[4] = cbCardDataSort[n]
                                bcOutCadData[5] = cbCardDataSort[j]
                            end
                            return 10
                        end
                    end
                end
            end
            --取4张中组合最大的点数
            local bcTmp = {}
            local iBig = 0
            --local ini = 0
            for ini = 2 ,cbCardCount do
                for j = 2,cbCardCount do
                    if ini ~= j then
                        local bclogic = (self:GetCardLogicValue(cbCardDataSort[ini])+self:GetCardLogicValue(cbCardDataSort[j]))%10
                        if bclogic > iBig then
                            iBig = bclogic
                            local add = 0
                            bcTmp[1]=cbCardDataSort[ini]
                            bcTmp[2]=cbCardDataSort[j]
                            for y = 2,cbCardCount do
                                if y ~= ini and y ~= j then
                                    iSingleA[add] =cbCardDataSort[y]
                                    add = add + 1
                                end
                            end
                            bcTmp[3]=iSingleA[1]
                            bcTmp[4]=iSingleA[2]
                        end
                    end
                end
            end

            if bcOutCadData then
                bcOutCadData[1] = cbCardDataSort[1]
                bcOutCadData[2] = bcTmp[3]
                bcOutCadData[3] = bcTmp[4]
                bcOutCadData[4] = bcTmp[1]
                bcOutCadData[5] = bcTmp[2]
            end

            iBigValue=self:GetCardLogicValue(bcTmp[1])+self:GetCardLogicValue(bcTmp[2])
            if iBigValue%10==0 then
                return 10
            else
                return iBigValue%10==0
            end
        end
        --取4张中任两张组合为10 然后求另外两张的组合看是否是组合中最大
        for n= 2,cbCardCount do
            for j = 2,cbCardCount do
                if j ~= n then
                    if(self:GetCardLogicValue(cbCardDataSort[n])+self:GetCardLogicValue(cbCardDataSort[j]))%10==0 then
                        local add = 1
                        for y = 2,cbCardCount do
                            if y ~= n and y ~= j then
                                iSingleA[add] =cbCardDataSort[y]
                                add = add + 1
                            end
                        end
                        if(iBigValue<=(self:GetCardLogicValue(iSingleA[1])+self:GetCardLogicValue(iSingleA[2]))%10) then
                            iBigValue = self:GetCardLogicValue(iSingleA[1])+self:GetCardLogicValue(iSingleA[2])%10
                            bcMakeMax[1]= cbCardDataSort[1]
                            bcMakeMax[2]= cbCardDataSort[j]
                            bcMakeMax[3]= cbCardDataSort[n]
                            bcMakeMax[4]= iSingleA[1]
                            bcMakeMax[5]= iSingleA[2]
                            if bcOutCadData then
                                bcOutCadData = bcMakeMax
                            end
                            if iBigValue==0 then
                                return 10
                            end
                        end
                    end
                end
            end
        end
        if iBigValue ~= 0 then
            if iBigValue%10==0 then
                return 10
            else
                return iBigValue%10
            end

        else
            --如果组合不成功
            iGetTenCount = 0
        end

    end
    if iGetTenCount==0 then
        --5个组合
        for n= 1,cbCardCount do
            for j = 1,cbCardCount do
                if j ~= n then
                    for w = 1, cbCardCount do
                        if w ~= n and w ~= j then
                            local valueAdd = self:GetCardLogicValue(cbCardDataSort[n])
                            valueAdd = valueAdd + self:GetCardLogicValue(cbCardDataSort[j])
                            valueAdd = valueAdd + self:GetCardLogicValue(cbCardDataSort[w])
                            if valueAdd%10==0 then
                                local add = 1
                                for y = 1,cbCardCount do
                                    if y ~= n and y ~= j and y ~=w then
                                        iSingleA[add] =cbCardDataSort[y]
                                        add = add + 1
                                    end
                                end
                                if iBigValue<=(self:GetCardLogicValue(iSingleA[1])+self:GetCardLogicValue(iSingleA[2]))%10 then
                                    iBigValue = self:GetCardLogicValue(iSingleA[1])+self:GetCardLogicValue(iSingleA[2])%10
                                    bcMakeMax[1]= cbCardDataSort[n]
                                    bcMakeMax[2]= cbCardDataSort[j]
                                    bcMakeMax[3]= cbCardDataSort[w]
                                    bcMakeMax[4]= iSingleA[1]
                                    bcMakeMax[5]= iSingleA[2]

                                    if bcOutCadData then
                                        bcOutCadData = bcMakeMax
                                    end
                                    if iBigValue==0 then
                                        return 10
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        if iBigValue ~=0 then
            if iBigValue%10 == 0 then
                return 10
            else
                return iBigValue%10
            end
        else
            return 0
        end

        return 0
    end
end

function GameLogic:GetCardLogicValue(cbData)
    --扑克属性
    if cbData then
        local cbCardColor,cbCardValue = GameUtil:GetCardForPc(cbData)
 
        if(cbCardColor == aceType) then
            return 11
        end
        --转换数值
        if tonumber(cbCardValue) > 10 then
            return 10
        else
            return cbCardValue
        end
    else
        return 0
    end
end

--function GameLogic:GetCardForPc( index )
--    local startIndex = 0
--    local endIndex = 100
--    if "number" == type(index) and index >= startIndex and index <= endIndex then
--        local typeIndex = math.floor(index / 13)
--        local number = index % 13
--        --print("index" .. index .. "typeIndex = " .. typeIndex .. "number" .. number)
--        return typeIndex, number
--
--    end
--end

function GameLogic:GetCardNewValue(cbData)
    --扑克属性
    local cbCardColor,cbCardValue = GameUtil:GetCardForPc(cbData)

    --转换数值
    if cbCardColor == aceType then
        return  cbCardValue+13+2
    end
    return cbCardValue
end

function GameLogic:GetCardColor(cbData)
    local cbCardColor,cbCardValue = GameUtil:GetCardForPc(cbData)
    return cbCardColor
end

function GameLogic:GetTimes(cbCardData, cbCardCount)

    if  cbCardCount~=OxNewDefine.MAXCOUNT then
        return 0
    end

    local bTimes= self:GetCardType(cbCardData,cbCardCount)
    print("bTimes=" .. bTimes)
    if bTimes < 10 then
        return 1
    elseif bTimes==10 then
        return 2
    else
        return 0
    end 
end

function GameLogic:SortCard()
--    dump(self.cardData)
--    table.sort(self.cardData,function(a,b)return a > b end) --
--    dump(self.cardData)
end


function GameLogic:Compara(a,b)
    if a>b then
        return true
    else
        return false
    end

    --    if a==b then
    --        if a.ctype>b.ctype then
    --            return true
    --        end
    --    end

end

--获取牛牛
function GameLogic:GetOxCard(cbCardData,cbCardCount)
    --设置变量
    local bTemp= {}
    local bTempData = clone(cbCardData)
    local cbCard = clone(cbCardData)
    local bSum=0
    for i=1 ,cbCardCount do
        bTemp[i]=self:GetCardLogicValue(cbCard[i])
        bSum =bTemp[i] +bSum
    end
    --查找牛牛
    for i=1,cbCardCount do
        for j=i+1 ,cbCardCount do
            print("i = " ..  i .. " j = ".. j)
            if((bSum-bTemp[i]-bTemp[j])%10==0) then
                local bCount = 1
                for k =1, cbCardCount do
                    if k~=i and k ~= j then
                        bCount = bCount +1
                        cbCard[bCount] = bTempData[k]
                    end
                end
                bCount = bCount + 1
                cbCard[bCount] = bTempData[i]
                bCount = bCount + 1
                cbCard[bCount] = bTempData[j]

                return true
            end
        end
    end
    return false
end

--function GameLogic:getOXNum()
--    local bTemp= {}
--    local bSum=0
--    for i=1 ,5 do
--        bTemp[i]=self:GetCardLogicValue(self.cbCardData[i])
--        bSum =bTemp[i] +bSum
--    end
--    return bSum % 10
--end

function GameLogic:sortCardRes(cbCardData,cbCardCount)
    local bTemp= {}
    local bTempData = cbCardData
    local newData = {}
    local bSum=0
    --    print("bTempData------------" )
    --    dump(bTempData)
    for i=1 ,5 do
        bTemp[i]=self:GetCardLogicValue(bTempData[i])
        bSum =bTemp[i] +bSum
    end
    --    print("bTemp------------" )
    --    dump(bTemp)
    local tmp1 = false
    local tmp2 = false
    --tmp1记录是否有3张组成10
    --tmp2记录是否是“牛牛”
    local index1,index2,index3
    for a=1, 3 do
        for b=a+1,4 do
            for c=b+1 ,5 do
                if((bTemp[a]+bTemp[b]+bTemp[c])%10 == 0) then
                    index1 = bTempData[a]
                    index2 = bTempData[b]
                    index3 = bTempData[c]
                end
            end
        end
    end
    local count = 3
    for key, var in pairs(bTempData) do
        if var == index1 then
            --table.insert(newData,1,var)
            newData[1] = var
        elseif var == index2 then
            --table.insert(newData,2,var)
            newData[2] = var
        elseif var == index3 then
            --table.insert(newData,3,var)
            newData[3] = var
        else
            count = count + 1
            newData[count] = var
        end
        --print( "var == ".. var .. " index1 ==".. index1 )
    end
    --dump(newData)
    --print("newData------------" )
    return newData,{index1,index2,index3}
end

--获取整数
function GameLogic:IsIntValue(cbCardData,cbCardCount)
    local sum=0
    for i=1,cbCardCount do
        sum= sum+self:GetCardLogicValue(cbCardData[i])
        if self:GetCardLogicValue(cbCardData[i])==11 then
            return true
        end
    end
    return (sum%10==0)
end

--//排列扑克
function GameLogic:SortCardList(cbCardData , cbCardCount)
    --数目过虑
    local data = cbCardData
    if (cbCardCount==0) then
        return;
    end
    table.sort(data,function(a,b) return a > b end)
--    --转换数值
--    local cbSortValue= {}
--    for i=1,cbCardCount do
--        cbSortValue[i]=self:GetCardLogicValue(cbCardData[i])
--    end
--    --排序操作
--    local bSorted=false;
--    local cbThreeCount = cbCardCount - 1
--    local cbLast=cbCardCount -1
--
--    while (bSorted==false) do
--        bSorted = true
--        for  i=1 , cbLast  do
--            if (( cbSortValue[i] < cbSortValue[i+1]) or
--                ((cbSortValue[i]==cbSortValue[i+1]) and (cbCardData[i]<cbCardData[i+1]))) then
--                --交换位置
--                cbThreeCount=cbCardData[i]
--                cbCardData[i]=cbCardData[i+1]
--                cbCardData[i+1]=cbThreeCount
--                cbThreeCount=cbSortValue[i]
--                cbSortValue[i]=cbSortValue[i+1]
--                cbSortValue[i+1]=cbThreeCount
--                bSorted = false
--            end
--        end
--        cbLast = cbLast - 1
--    end
--    print("---------------------------")
--    dump(data)
    return data
end

function GameLogic:GetCardType2(cbCardData , cbCardCount)
    --数目过虑
    if (cbCardCount==0) then
        return;
    end
    print("获得牌型")
    dump(cbCardData)
    --转换数值
    local cbSortValue= {}
    local num = 0
    for i=1,cbCardCount do
        cbSortValue[i]=self:GetCardLogicValue(cbCardData[i])
        num = num + cbSortValue[i]
    end
    dump(cbSortValue)
    print("num===" .. num)
    local tmp1 = false
    local tmp2 = false
    --tmp1记录是否有3张组成10
    --tmp2记录是否是“牛牛”
    for a=1,3 do
        for b=a+1,4 do
            for c=b+1,5 do
                if (cbSortValue[a]+cbSortValue[b]+cbSortValue[c])%10 == 0 then
                    tmp1 = true
                    print("tmp1")
                    local tmp3 = 0
                    --tmp3是暂时保存数据用的
                    for j=1, 5 do
                        if j ~= a and j ~= b and j ~= c then
                            tmp3 = tmp3 + cbSortValue[j]
                        end
                    end
                    print("tmp3= " .. tmp3 )
                    if(tmp3%10 == 0)then
                        tmp2 = true
                        print("tmp2")
                    end
                end
            end
        end
    end

    if tmp1 or tmp2 then
        if num % 10 == 0 then
            return 10
        else
            return  num % 10
        end
    else
        return 0
    end

end


--对比扑克
function GameLogic:CompareCard(cbFirstData,cbNextData,cbCardCount, FirstOX,NextOX)
    if FirstOX~=NextOX then
        return FirstOX>NextOX
    end
    --比较牛大小
    if FirstOX then
        --获取点数
        local cbNextType=self:GetCardType(cbNextData,cbCardCount)
        local cbFirstType=self:GetCardType(cbFirstData,cbCardCount)

        --点数判断
        if cbFirstType ~=cbNextType then
            return cbFirstType>cbNextType
        end
    end

    --排序大小
    local bFirstTemp = {}
    local bNextTemp = {}
    bFirstTemp = cbFirstData
    bNextTemp = cbNextData

    self:SortCardList(bFirstTemp,cbCardCount)
    self:SortCardList(bNextTemp,cbCardCount)

    --比较数值
    local cbNextMaxValue=self:GetCardNewValue(bNextTemp[1])
    local cbFirstMaxValue=self:GetCardNewValue(bFirstTemp[1])
    if(cbNextMaxValue~=cbFirstMaxValue) then
        if(self:GetCardColor(bFirstTemp[1])==aceType and self:GetCardColor(bNextTemp[1])==aceType) then
            return cbFirstMaxValue>cbNextMaxValue
        elseif(self:GetCardColor(bFirstTemp[1])==aceType or self:GetCardColor(bNextTemp[1])==aceType) then
            return cbFirstMaxValue<cbNextMaxValue
        end
        return cbFirstMaxValue>cbNextMaxValue
    end

    --比较颜色
    return self:GetCardColor(bFirstTemp[1]) > self:GetCardColor(bNextTemp[1])

end

return GameLogic
