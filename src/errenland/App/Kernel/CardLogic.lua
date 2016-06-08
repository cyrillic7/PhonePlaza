--处理牌数据逻辑
local CardLogic =class("CardLogic")

--逻辑构造
function CardLogic:ctor()
   self.CardNum=
   {
   "ONE_SAME",
   "TWO_SAME",
   "THREE_SAME",
   "FOUR_SAME",
   }
end


-----------------------------------------------------------------
--//同牌搜索
function CardLogic:SearchSameCard(cbHandCardData, cbHandCardCount,cbReferCard,cbSameCardCount)

	--//设置结果
	local cbResultCount = 0
	local SecrchResult={}

--print("相同张"..cbSameCardCount)
	if cbHandCardCount<cbSameCardCount then
		return cbResultCount,SecrchResult
	end
    table.sort(cbHandCardData, handler(self,self.ComparaBtoS))
--print("相同张sss"..cbSameCardCount)
	--//分析扑克
	local AnalyseResult=self:AnalysebCardData(cbHandCardData,cbHandCardCount)
	local cbReferLogicValue = 0
	if cbReferCard~=0 then
		cbReferLogicValue=self:GetCardLogicValue(cbReferCard)
	end

	local cbBlockIndex = cbSameCardCount
	while cbBlockIndex <= 4  do
		for i = 1, AnalyseResult.cbBlockCount[self.CardNum[cbBlockIndex]] do
	
		    local cbIndex = (AnalyseResult.cbBlockCount[self.CardNum[cbBlockIndex]]-i)*(cbBlockIndex)+cbBlockIndex
			if self:GetCardLogicValue(AnalyseResult.cbCardData[self.CardNum[cbBlockIndex]][cbIndex]) > cbReferLogicValue then
				
				local carddata={}
				for i=1,cbSameCardCount do
					local  j=cbIndex-cbSameCardCount+i
					local  card=AnalyseResult.cbCardData[self.CardNum[cbBlockIndex]][j]
					table.insert(carddata,card)
				end
				if table.getn(carddata)>0 then
					--todo
					cbResultCount=cbResultCount+1
				    SecrchResult[cbResultCount]=carddata
				end
				
			end
	    end

	    cbBlockIndex=cbBlockIndex+1
	end
	

	--print("查找到张数为"..cbBlockIndex.."的牌")
    --dump(SecrchResult)
	return cbResultCount,SecrchResult
end
--带牌类型搜索(三带）
function CardLogic:SearchThreeTakeCardType( cbHandCardData,cbHandCardCount,cbReferCard,cbSameCount,cbTakeCardCount )
	--设置结果
	local cbResultCount=0
	local SecrchResult={}

	if cbSameCount ~= 3 and cbSameCount ~= 4 then
		return cbResultCount , SecrchResult
	end
	if cbTakeCardCount ~= 1 and cbTakeCardCount ~= 2 then
		return cbResultCount, SecrchResult 
	end
	--长度判断
	if  (cbSameCount == 4 and cbHandCardCount<cbSameCount+cbTakeCardCount*2) or
		(cbHandCardCount < cbSameCount+cbTakeCardCount) then
		return cbResultCount, SecrchResult 
	end

	--搜索主要同张
	local cbSameCardResultCount ,SameCardResult= self:SearchSameCard( cbHandCardData,cbHandCardCount,cbReferCard,cbSameCount )
    --搜索带牌同张
    local cbTakeCardResultCount ,TakeCardResult= self:SearchSameCard( cbHandCardData,cbHandCardCount,0,cbTakeCardCount )

	if cbSameCardResultCount > 0 and cbTakeCardResultCount>0 then
		--需要牌数
		local cbNeedCount = cbSameCount+cbTakeCardCount
		for i=1,cbSameCardResultCount do
			local SameData=SameCardResult[i]
			local SameCardValue=self:GetCardLogicValue(SameData[1])
			for j=1,cbTakeCardResultCount do
				
				local takeData=TakeCardResult[j]
				local takeCardValue=self:GetCardLogicValue(takeData[1])
				if SameCardValue~=takeCardValue then
					local findCard={}
					for z=1,cbSameCount do
						findCard[z]=SameData[z]
					end
					for k=1,cbTakeCardCount do
						findCard[k+cbSameCount]=takeData[k]
					end

					cbResultCount=cbResultCount+1
					--print("找到一组 cbResultCount="..cbResultCount)
                   -- dump(findCard)
					SecrchResult[cbResultCount]=findCard
				end
            end	
		end	
	end
	return cbResultCount ,SecrchResult
end



function CardLogic:InserTabelToTable(table1,table2)

    local m_table = table1
	for k,v in pairs(table2) do
		table.insert(m_table,v)
	end
	return m_table
end
--单顺搜索
function CardLogic:SearchSingleLineCardType( cbHandCardData, cbHandCardCount,  cbReferCard, cbLineCount )

	--设置结果

	local cbResultCount = 0
	local SecrchResult={}

	local cbBlockCount=1

	--定义变量
	local cbLessLineCount = cbLineCount
	if cbReferCard == 0  then
		cbLessLineCount = 5
	end

	if cbLessLineCount<cbLineCount then
		return cbResultCount,SecrchResult
	end

	--搜索主要同张
	local cbSameCardResultCount ,SameCardResult= self:SearchSameCard( cbHandCardData,cbHandCardCount,cbReferCard,cbBlockCount )
   -- dump(SameCardResult)
    local Alldata={}
    local Allcount=0
	for i=1,cbSameCardResultCount do
	  local carddata=SameCardResult[i]
	  --不能有2或以上的牌
	  if self:GetCardLogicValue(carddata[1])<15 then
	  	for j=1,cbBlockCount do
	  	  Allcount=Allcount+1
	  	  Alldata[Allcount]=carddata[j]
	    end
	  end
	  
	end

	table.sort(Alldata, handler(self,self.ComparaStoB))
    --从中Alldata找出符合条件的顺子

    while cbLessLineCount<=14  do

	    for i=1,Allcount do
	    	local data={}
	    	local linecount=1
	    	local  firstcard = Alldata[i]
	    	data[linecount]=firstcard
	    	
	    	for j=i+1,Allcount do
	    		local firstValue=self:GetCardLogicValue(firstcard)
	    		local NextValue=self:GetCardLogicValue(Alldata[j])
	    		
	    		if firstValue+1==NextValue then
	    			firstcard=Alldata[j]
	    			linecount=linecount+1
	    			data[linecount]=Alldata[j]
	    			if linecount==cbLessLineCount then
	    				cbResultCount=cbResultCount+1
		                SecrchResult[cbResultCount]=data
		                break
	    			end
	    		else
	    			break
	    		end
	    	
	        end

	    end
	    if  cbReferCard~=0 then
	    	break
	    end

    	cbLessLineCount=cbLessLineCount+1
    end
    


   -- dump(SecrchResult)
	--cbResultCount=cbResultCount+1
	--SecrchResult[cbResultCount]=Alldata
	return cbResultCount,SecrchResult
end

--双顺搜索
function CardLogic:SearchDoubleLineCardType( cbHandCardData, cbHandCardCount,  cbReferCard, cbLineCount )

	--设置结果
	local cbResultCount = 0
	local SecrchResult={}

	local cbBlockCount=2

	if cbHandCardCount<cbLineCount*2 then
		return cbResultCount,SecrchResult
	end

	--定义变量
	local cbLessLineCount = cbLineCount
	if cbReferCard == 0  then
		cbLessLineCount = 3
	end

	if cbLessLineCount<3 then
		return cbResultCount,SecrchResult
	end
	--搜索主要同张
	local cbSameCardResultCount ,SameCardResult= self:SearchSameCard( cbHandCardData,cbHandCardCount,cbReferCard,cbBlockCount )
   -- print("先搜索出对子")
   -- dump(SameCardResult)
    local Alldata={}
    local Allcount=0
	for i=1,cbSameCardResultCount do
	  local carddata=SameCardResult[i]
	  --不能有2或以上的牌
	  if self:GetCardLogicValue(carddata[1])<15 then
	  	for j=1,cbBlockCount do
	  	  Allcount=Allcount+1
	  	  Alldata[Allcount]=carddata[j]
	    end
	  end
	end
    table.sort(Alldata, handler(self,self.ComparaStoB))
    --print("连对数组"..cbLessLineCount)
    --dump(Alldata)
	cbSameCardResultCount ,SameCardResult= self:SearchSameCard( Alldata,Allcount,cbReferCard,cbBlockCount )
   -- print("重新整理后")
   -- dump(SameCardResult)
    while cbLessLineCount<=10  do
	    for i=1,cbSameCardResultCount do

	    	local data={}
	    	local index=1
	    	local findcount=1
	    	local fristCard=SameCardResult[i]
	    	
			for k=1,cbBlockCount do
				data[index]=fristCard[k]
				index=index+1
			end
	    	for j=i+1,cbSameCardResultCount do
	    		local NextCard=SameCardResult[j]
	    		local firstValue=self:GetCardLogicValue(fristCard[1])
	    		local NextValue=self:GetCardLogicValue(NextCard[1])
	    		if firstValue+1==NextValue then
	    			fristCard=NextCard
	    			for z=1,cbBlockCount do
		    		    data[index]=NextCard[z]
						index=index+1
		    	    end
		    	    findcount=findcount+1
		    	    if findcount==cbLessLineCount then
		    	    	cbResultCount=cbResultCount+1
			            SecrchResult[cbResultCount]=data
			            break
		    	    end
		    	else
		    		break
	    		end
	    	end
	    end
	    if  cbReferCard~=0 then
	    	break
	    end

    	cbLessLineCount=cbLessLineCount+1
    end

   -- print("查找结果")
   -- dump(SecrchResult)
	return cbResultCount,SecrchResult
end

--三顺搜索
function CardLogic:SearchThreeLineCardType( cbHandCardData, cbHandCardCount,  cbReferCard, cbLineCount )

	--设置结果
	local cbResultCount = 0
	local SecrchResult={}

	local cbBlockCount=3

	if cbHandCardCount<cbLineCount*3 then
		return cbResultCount,SecrchResult
	end

	--定义变量
	local cbLessLineCount = cbLineCount

	--搜索主要同张
	local cbSameCardResultCount ,SameCardResult= self:SearchSameCard( cbHandCardData,cbHandCardCount,cbReferCard,cbBlockCount )
   -- print("先搜索出三张")
   -- dump(SameCardResult)
    local Alldata={}
    local Allcount=0
	for i=1,cbSameCardResultCount do
	  local carddata=SameCardResult[i]
	  --不能有2或以上的牌
	  if self:GetCardLogicValue(carddata[1])<15 then
	  	for j=1,cbBlockCount do
	  	  Allcount=Allcount+1
	  	  Alldata[Allcount]=carddata[j]
	    end
	  end
	end
    table.sort(Alldata, handler(self,self.ComparaStoB))
    --print("三张数组"..cbLessLineCount)
    --dump(Alldata)
	cbSameCardResultCount ,SameCardResult= self:SearchSameCard( Alldata,Allcount,cbReferCard,cbBlockCount )
    --print("重新整理后")
    --dump(SameCardResult)
    while cbLessLineCount<=6  do
	    for i=1,cbSameCardResultCount do

	    	local data={}
	    	local index=1
	    	local findcount=1
	    	local fristCard=SameCardResult[i]
	    	
			for k=1,cbBlockCount do
				data[index]=fristCard[k]
				index=index+1
			end
	    	for j=i+1,cbSameCardResultCount do
	    		local NextCard=SameCardResult[j]
	    		local firstValue=self:GetCardLogicValue(fristCard[1])
	    		local NextValue=self:GetCardLogicValue(NextCard[1])

	    		if firstValue+1==NextValue then
	    			fristCard=NextCard
	    			for z=1,cbBlockCount do
		    		    data[index]=NextCard[z]
						index=index+1
		    	    end
		    	    findcount=findcount+1

		    	    if findcount==cbLessLineCount then
		    	    	cbResultCount=cbResultCount+1
			            SecrchResult[cbResultCount]=data
			            break
		    	    end
		    	else
		    		break
	    		end
	    	end

	    end
	    if  cbReferCard~=0 then
	    	break
	    end
	    cbLessLineCount=cbLessLineCount+1
    end


    --print("查找结果")
    --dump(SecrchResult)
	return cbResultCount,SecrchResult
end
--带牌类型搜索(四带）
function CardLogic:SearchFourTakeCardType( cbHandCardData,cbHandCardCount,cbReferCard,cbSameCount,cbTakeCardCount )
	--设置结果
	local cbResultCount=0
	local SecrchResult={}

	if  cbSameCount ~= 4 then
		return cbResultCount , SecrchResult
	end
	if cbTakeCardCount ~= 1 and cbTakeCardCount ~= 2 then
		return cbResultCount, SecrchResult 
	end

	--长度判断
	if  (cbSameCount == 4 and cbHandCardCount<cbSameCount+cbTakeCardCount*2) or
		(cbHandCardCount < cbSameCount+cbTakeCardCount*2) then
		return cbResultCount, SecrchResult 
	end

	--搜索主要同张
	local cbSameCardResultCount ,SameCardResult= self:SearchSameCard( cbHandCardData,cbHandCardCount,cbReferCard,cbSameCount )
    

    

    if cbSameCardResultCount > 0  then
    	for i=1,cbSameCardResultCount do
    		local tempHandData=clone(cbHandCardData)
	        local tempHandCount=cbHandCardCount
	        local sameCarddata=clone(SameCardResult[i])
    		local newhangcount,newHandData=self:RemoveCardList(sameCarddata, #sameCarddata, tempHandData, tempHandCount)
    	
            --搜索带牌同张
            local cbTakeCardResultCount ,TakeCardResult= self:SearchSameCard( newHandData,newhangcount,0,cbTakeCardCount )

			if cbTakeCardResultCount>1 then
				for j=1,cbTakeCardResultCount do
					sameCarddata=clone(SameCardResult[i])
					local insercount=1
					local data1=TakeCardResult[j]
					sameCarddata=self:InserTabelToTable(sameCarddata,data1)
					for k=j+1,cbTakeCardResultCount do
						local data2=TakeCardResult[k]
						sameCarddata=self:InserTabelToTable(sameCarddata,data2)
						insercount=insercount+1
						if insercount==2 then
							cbResultCount=cbResultCount+1
							--print("找到一组 cbResultCount="..cbResultCount)
		                   -- dump(sameCarddata)
							SecrchResult[cbResultCount]=sameCarddata
							sameCarddata={}
							break
						end
				    end
				end
	            
			end


    	end
    end
	return cbResultCount ,SecrchResult
end
--飞机搜索
function CardLogic:SearchPlanCardType( cbHandCardData, cbHandCardCount,  cbReferCard, cbLineCount,takeCount )

	--设置结果
	local cbResultCount = 0
	local SecrchResult={}


	if cbHandCardCount <cbLineCount*3+takeCount*cbLineCount then
		return cbResultCount, SecrchResult 
	end

   --先搜索出三张的对子
   local cbthreeLineCardResultCount ,threeLineCardResult =self:SearchThreeLineCardType( cbHandCardData, cbHandCardCount,  cbReferCard, cbLineCount )
    if cbthreeLineCardResultCount > 0  then
    	for i=1,cbthreeLineCardResultCount do
    		local tempHandData=clone(cbHandCardData)
	        local tempHandCount=cbHandCardCount
	        local sameCarddata=clone(threeLineCardResult[i])

    		local newhangcount,newHandData=self:RemoveCardList(sameCarddata, #sameCarddata, tempHandData, tempHandCount)
    	
            local cbtakeCardResultCount ,takeCardResult= self:SearchSameCard( newHandData,newhangcount,0,takeCount )
            if cbtakeCardResultCount>=cbLineCount then
            	for j=1,cbtakeCardResultCount do
            		sameCarddata=clone(threeLineCardResult[i])
					local insercount=1
					local data1=takeCardResult[j]
					sameCarddata=self:InserTabelToTable(sameCarddata,data1)
            		for k=j+1,cbtakeCardResultCount do
            			local data2=takeCardResult[k]
						sameCarddata=self:InserTabelToTable(sameCarddata,data2)
						insercount=insercount+1
						if insercount==cbLineCount then
							cbResultCount=cbResultCount+1
							--print("找到一组 cbResultCount="..cbResultCount)
		                   -- dump(sameCarddata)
							SecrchResult[cbResultCount]=sameCarddata
							sameCarddata={}
							break
						end
            	    end
            	end
            	--todo
            end
    	end
    end
    print("查找飞机结果"..cbResultCount)
   -- dump(SecrchResult)
	return cbResultCount ,SecrchResult
end

--炸弹类型搜索
function CardLogic:SearchBombType( cbHandCardData,cbHandCardCount,cbReferCard)
	--设置结果
	local cbResultCount=0
	local SecrchResult={}

	if cbHandCardCount<4 then
		return cbResultCount,SecrchResult
	end

	--搜索主要同张
	local cbSameCardResultCount ,SameCardResult= self:SearchSameCard( cbHandCardData,cbHandCardCount,cbReferCard,4 )

	if cbSameCardResultCount>0 then
		for i=1,cbSameCardResultCount do
			local carddata=SameCardResult[i]
			cbResultCount=cbResultCount+1
			SecrchResult[cbResultCount]=carddata
		end
		--todo
	end
	print("查找炸弹结果"..cbResultCount)
    --dump(SecrchResult)
	return cbResultCount ,SecrchResult
end

--火箭类型搜索
function CardLogic:SearchHuojianType( cbHandCardData,cbHandCardCount)

		--设置结果
	local cbResultCount=0
	local SecrchResult={}

	local findcount=0
	for i=1,cbHandCardCount do
		if cbHandCardData[i]==78 or cbHandCardData[i]==79 then
			findcount=findcount+1
		end
	end
	if findcount==2 then
		local data={78,79}
		--设置结果
		cbResultCount=cbResultCount+1
		SecrchResult[cbResultCount]=data
	end

	print("查找火箭结果"..cbResultCount)
   -- dump(SecrchResult)
	return cbResultCount ,SecrchResult

end
--排列扑克
function CardLogic:SortOutCardList( cbCardData,  cbCardCount)

	--获取牌型
	local cbCardDataout={}
	local cbCardType = self:GetCardType(cbCardData,cbCardCount);

	if cbCardType == ErRenLandDefine.CT_SINGLE_LINE then
	
		--分析牌
		local AnalyseResult=self:AnalysebCardData(cbCardData,cbCardCount)
		cbCardDataout=AnalyseResult.cbCardData[self.CardNum[1]]
		table.sort(cbCardDataout, handler(self,self.ComparaStoB))

		--print("单顺中取比较牌 决定")
		--dump(cbCardDataout[1])
	end

	if cbCardType == ErRenLandDefine.CT_DOUBLE_LINE then
	
		--分析牌
		local AnalyseResult=self:AnalysebCardData(cbCardData,cbCardCount)
		cbCardDataout=AnalyseResult.cbCardData[self.CardNum[2]]
		table.sort(cbCardDataout, handler(self,self.ComparaStoB))

		--print("双顺中取比较牌 决定")
		--dump(cbCardDataout[1])
	end

	if cbCardType == ErRenLandDefine.CT_THREE_LINE then
	
		--分析牌
		local AnalyseResult=self:AnalysebCardData(cbCardData,cbCardCount)
		cbCardDataout=AnalyseResult.cbCardData[self.CardNum[3]]
		table.sort(cbCardDataout, handler(self,self.ComparaStoB))

		--print("三张连对中取比较牌 决定")
		--dump(cbCardDataout[1])
	end

	if cbCardType == ErRenLandDefine.CT_THREE_TAKE_ONE or cbCardType ==  ErRenLandDefine.CT_THREE_TAKE_TWO then
	
		--分析牌
		local AnalyseResult=self:AnalysebCardData(cbCardData,cbCardCount)
		cbCardDataout=AnalyseResult.cbCardData[self.CardNum[3]]
		table.sort(cbCardDataout, handler(self,self.ComparaStoB))

		--print("三带牌中取比较牌 决定")
		--dump(cbCardDataout[1])
	end

	if cbCardType == ErRenLandDefine.CT_FOUR_TAKE_ONE or cbCardType ==  ErRenLandDefine.CT_FOUR_TAKE_TWO then
	
		--分析牌
		local AnalyseResult=self:AnalysebCardData(cbCardData,cbCardCount)
		cbCardDataout=AnalyseResult.cbCardData[self.CardNum[4]]
		table.sort(cbCardDataout, handler(self,self.ComparaStoB))

		--print("四带牌中取比较牌 决定")
		--dump(cbCardDataout[1])
	end
	
	return cbCardDataout[1]

end

--出牌搜索
function CardLogic:SearchslectoutCard(cbHandCardData, cbHandCardCount)
	table.sort(cbHandCardData, handler(self,self.ComparaBtoS))

	local cbResultCount=0
	local SecrchResult={}


	if cbHandCardCount<=3 then
		return cbResultCount,SecrchResult
	end

	
	--是否一手出完
    local lasttype=self:GetCardType(cbHandCardData, cbHandCardCount)
	

	if  lasttype~= ErRenLandDefine.CT_ERROR  then
	   return cbResultCount,SecrchResult
	else
	   	----查找对子
		--local samecount, finddata=self:SearchSameCard(cbHandCardData, cbHandCardCount,0,2)
		--for i=1,samecount do
		--	cbResultCount=cbResultCount+1
		--	SecrchResult[cbResultCount] = finddata[i]
		--end

		--查找三张
		--local samecount, finddata=self:SearchSameCard(cbHandCardData, cbHandCardCount,0,3)
		--for i=1,samecount do
		--	cbResultCount=cbResultCount+1
		--	SecrchResult[cbResultCount] = finddata[i]
		--end

		
		local samecount=0
		local finddata
		if cbHandCardCount>15 then
			samecount, finddata=self:SearchPlanCardType(cbHandCardData, cbHandCardCount,0,3,2)
			if samecount>0 then
				cbResultCount=cbResultCount+1
				SecrchResult[cbResultCount] = finddata[1]
			end
		end
		if cbHandCardCount>12 and samecount==0 then
			samecount, finddata=self:SearchPlanCardType(cbHandCardData, cbHandCardCount,0,3,1)
			if samecount>0 then
				cbResultCount=cbResultCount+1
				SecrchResult[cbResultCount] = finddata[1]
			end
		end
		if cbHandCardCount>10 and samecount==0  then
			samecount, finddata=self:SearchPlanCardType(cbHandCardData, cbHandCardCount,0,2,2)
			if samecount>0 then
				cbResultCount=cbResultCount+1
				SecrchResult[cbResultCount] = finddata[1]
			end
		end

		if cbHandCardCount>8 and samecount==0  then
			samecount, finddata=self:SearchPlanCardType(cbHandCardData, cbHandCardCount,0,2,1)
			if samecount>0 then
				cbResultCount=cbResultCount+1
				SecrchResult[cbResultCount] = finddata[1]
			end
		end
		samecount=0
        

		--查找单顺
		samecount, finddata=self:SearchSingleLineCardType(cbHandCardData, cbHandCardCount,0,5)

		if samecount>0 then
			cbResultCount=cbResultCount+1
			SecrchResult[cbResultCount] = finddata[samecount]
		end
		samecount=0

		--查找双顺
		samecount, finddata=self:SearchDoubleLineCardType(cbHandCardData, cbHandCardCount,0,3)
		if samecount>0 then
			cbResultCount=cbResultCount+1
			SecrchResult[cbResultCount] = finddata[samecount]
		end
		samecount=0
		--查找三顺
		samecount, finddata=self:SearchThreeLineCardType(cbHandCardData, cbHandCardCount,0,3)
		if samecount>0 then
			cbResultCount=cbResultCount+1
			SecrchResult[cbResultCount] = finddata[samecount]
		end
		samecount=0

		--查找三带二
		samecount, finddata=self:SearchThreeTakeCardType(cbHandCardData, cbHandCardCount,0,3,2)
		if samecount>0 then
			cbResultCount=cbResultCount+1
			SecrchResult[cbResultCount] = finddata[samecount]
		end

		if samecount==0 then
			--查找三带一
			samecount, finddata=self:SearchThreeTakeCardType(cbHandCardData, cbHandCardCount,0,3,1)
			if samecount>0 then
				cbResultCount=cbResultCount+1
				SecrchResult[cbResultCount] = finddata[1]
			end
		end
		samecount=0
		--查找四带两对
		samecount, finddata=self:SearchFourTakeCardType(cbHandCardData, cbHandCardCount,0,4,2)
		if samecount>0 then
			cbResultCount=cbResultCount+1
			SecrchResult[cbResultCount] = finddata[1]
		end
		if samecount==0 then
			--查找四带两单
			samecount, finddata=self:SearchFourTakeCardType(cbHandCardData, cbHandCardCount,0,4,1)
			if samecount>0 then
				cbResultCount=cbResultCount+1
				SecrchResult[cbResultCount] = finddata[1]
			end
		end

	end

	

	--print("提示出的牌")
	--dump(SecrchResult)

	return cbResultCount,SecrchResult
	
end
--出牌搜索
function CardLogic:SearchOutCard(cbHandCardData, cbHandCardCount,cbTurnCardData,  cbTurnCardCount )

    table.sort(cbHandCardData, handler(self,self.ComparaBtoS))

	local cbResultCount=0
	local SecrchResult={}

	--//获取类型
	local cbTurnOutType=self:GetCardType(cbTurnCardData,cbTurnCardCount)
	print("传入牌类型"..cbTurnOutType)
	if cbTurnOutType==ErRenLandDefine.CT_ERROR then
		--todo
		--是否一手出完
	    local lasttype=self:GetCardType(cbHandCardData, cbHandCardCount)
		print("最后一手牌类型"..lasttype)

		if  lasttype~= ErRenLandDefine.CT_ERROR  then
			if not SecrchResult[cbResultCount] then
			 cbResultCount=cbResultCount+1
			 SecrchResult[cbResultCount] = cbHandCardData
	        end
		end
		--最小的牌有两张或以上
		if cbHandCardCount > 1 then
            local card1=cbHandCardData[cbHandCardCount]
            local cardvalue1=self:GetCardLogicValue(card1)
            local findcard={}
            findcard[1]=card1
            for i=1,cbHandCardCount-1 do
            	local card2=cbHandCardData[cbHandCardCount-i]
            	local cardvalue2=self:GetCardLogicValue(card2)
            	if cardvalue1~= cardvalue2 then
            		break
            	end
            	findcard[i+1]=card2
            end
            cbResultCount=cbResultCount+1
            SecrchResult[cbResultCount] = findcard
		end

		--查找单张
		local samecount, finddata=self:SearchSameCard(cbHandCardData, cbHandCardCount,0,1)
		if samecount>0 then
			cbResultCount=cbResultCount+1
			SecrchResult[cbResultCount] = finddata[1]
			
		end

		--查找对子
		local samecount, finddata=self:SearchSameCard(cbHandCardData, cbHandCardCount,0,2)
		if samecount>0 then
			cbResultCount=cbResultCount+1
			SecrchResult[cbResultCount] = finddata[1]
			
		end

		--查找三张
		local samecount, finddata=self:SearchSameCard(cbHandCardData, cbHandCardCount,0,3)
		if samecount>0 then
			cbResultCount=cbResultCount+1
			SecrchResult[cbResultCount] = finddata[1]
			
		end

		--查找三带一
		local samecount, finddata=self:SearchThreeTakeCardType(cbHandCardData, cbHandCardCount,0,3,1)
		if samecount>0 then
			cbResultCount=cbResultCount+1
			SecrchResult[cbResultCount] = finddata[1]
		end

		--查找三带二
		local samecount, finddata=self:SearchThreeTakeCardType(cbHandCardData, cbHandCardCount,0,3,2)
		if samecount>0 then
			cbResultCount=cbResultCount+1
			SecrchResult[cbResultCount] = finddata[1]
		end

		--查找四带两单
		local samecount, finddata=self:SearchFourTakeCardType(cbHandCardData, cbHandCardCount,0,4,1)
		if samecount>0 then
			cbResultCount=cbResultCount+1
			SecrchResult[cbResultCount] = finddata[1]
		end

		--查找四带两对
		local samecount, finddata=self:SearchFourTakeCardType(cbHandCardData, cbHandCardCount,0,4,2)
		if samecount>0 then
			cbResultCount=cbResultCount+1
			SecrchResult[cbResultCount] = finddata[1]
		end


		--查找单顺
		local samecount, finddata=self:SearchSingleLineCardType(cbHandCardData, cbHandCardCount,0,5)
		if samecount>0 then
			cbResultCount=cbResultCount+1
			SecrchResult[cbResultCount] = finddata[1]
		end

		--查找双顺
		local samecount, finddata=self:SearchDoubleLineCardType(cbHandCardData, cbHandCardCount,0,3)
		if samecount>0 then
			cbResultCount=cbResultCount+1
			SecrchResult[cbResultCount] = finddata[1]
		end
		--查找三顺
		local samecount, finddata=self:SearchThreeLineCardType(cbHandCardData, cbHandCardCount,0,3)
		if samecount>0 then
			cbResultCount=cbResultCount+1
			SecrchResult[cbResultCount] = finddata[1]
		end
        --炸弹
		local samecount, finddata=self:SearchBombType( cbHandCardData,cbHandCardCount,0)
		if samecount>0 then
			cbResultCount=cbResultCount+1
			SecrchResult[cbResultCount] = finddata[1]
		end
        --火箭
		local samecount, finddata=self:SearchHuojianType( cbHandCardData,cbHandCardCount)
		if samecount>0 then
			cbResultCount=cbResultCount+1
			SecrchResult[cbResultCount] = finddata[1]
		end

		--print("提示出的牌")
		--dump(SecrchResult)
	else
        --单牌，对子，三张
		if cbTurnOutType==ErRenLandDefine.CT_SINGLE or cbTurnOutType==ErRenLandDefine.CT_DOUBLE or cbTurnOutType==ErRenLandDefine.CT_THREE then
			--变量定义
			local cbReferCard=cbTurnCardData[1]
			local cbSameCount = 1
			if cbTurnOutType == ErRenLandDefine.CT_DOUBLE then
			   cbSameCount = 2
			end
			if cbTurnOutType == ErRenLandDefine.CT_THREE then
			   cbSameCount = 3
			end
			--查找相同张数
			local samecount, finddata=self:SearchSameCard(cbHandCardData, cbHandCardCount,cbReferCard,cbSameCount)
			for i=1,samecount do
				cbResultCount=cbResultCount+1
				SecrchResult[cbResultCount] = finddata[i]
			end
		end
		--单顺
		if cbTurnOutType==ErRenLandDefine.CT_SINGLE_LINE then
			--变量定义

			local cbReferCard=self:SortOutCardList( cbTurnCardData,  cbTurnCardCount)
			local Linecount=cbTurnCardCount
			--print("danshun---------------->"..Linecount)

			--查找单顺
			local samecount, finddata=self:SearchSingleLineCardType(cbHandCardData, cbHandCardCount,cbReferCard,Linecount)
			for i=1,samecount do
				cbResultCount=cbResultCount+1
				SecrchResult[cbResultCount] = finddata[i]
			end
		end
		--双顺
		if cbTurnOutType==ErRenLandDefine.CT_DOUBLE_LINE then
			--变量定义
			local cbReferCard=self:SortOutCardList( cbTurnCardData,  cbTurnCardCount)
			local Linecount=cbTurnCardCount/2

			--查找单顺
			local samecount, finddata=self:SearchDoubleLineCardType(cbHandCardData, cbHandCardCount,cbReferCard,Linecount)
			for i=1,samecount do
				cbResultCount=cbResultCount+1
				SecrchResult[cbResultCount] = finddata[i]
			end
		end
		--三连对
		if cbTurnOutType==ErRenLandDefine.CT_THREE_LINE then
			--变量定义
			local cbReferCard=self:SortOutCardList( cbTurnCardData,  cbTurnCardCount)
			local Linecount=cbTurnCardCount/3

            
			--查找三连对
			local samecount, finddata=self:SearchThreeLineCardType(cbHandCardData, cbHandCardCount,cbReferCard,Linecount)
			for i=1,samecount do
				cbResultCount=cbResultCount+1
				SecrchResult[cbResultCount] = finddata[i]
			end
		end

		--三带1
		if cbTurnOutType==ErRenLandDefine.CT_THREE_TAKE_ONE then
			--变量定义
			local cbReferCard=self:SortOutCardList( cbTurnCardData,  cbTurnCardCount)
			local Linecount=cbTurnCardCount/4
			if Linecount>1 then
				local samecount, finddata=self:SearchPlanCardType(cbHandCardData, cbHandCardCount,cbReferCard,Linecount,1)
				for i=1,samecount do
					cbResultCount=cbResultCount+1
					SecrchResult[cbResultCount] = finddata[i]
				end
			else
				dump(cbHandCardData)
				--查找三带1
				local samecount, finddata=self:SearchThreeTakeCardType(cbHandCardData, cbHandCardCount,cbReferCard,3,1)
				for i=1,samecount do
					cbResultCount=cbResultCount+1
					SecrchResult[cbResultCount] = finddata[i]
				end
			end

			
		end
		--三带2
		if cbTurnOutType==ErRenLandDefine.CT_THREE_TAKE_TWO then
			--变量定义
			local cbReferCard=self:SortOutCardList( cbTurnCardData,  cbTurnCardCount)
			local Linecount=cbTurnCardCount/5
			if Linecount>1 then
				local samecount, finddata=self:SearchPlanCardType(cbHandCardData, cbHandCardCount,cbReferCard,Linecount,2)
				for i=1,samecount do
					cbResultCount=cbResultCount+1
					SecrchResult[cbResultCount] = finddata[i]
				end
			else
				--查找三带2
				local samecount, finddata=self:SearchThreeTakeCardType(cbHandCardData, cbHandCardCount,cbReferCard,3,2)
				for i=1,samecount do
					cbResultCount=cbResultCount+1
					SecrchResult[cbResultCount] = finddata[i]
				end
			end


		end

		--查找四带两单
		if cbTurnOutType==ErRenLandDefine.CT_FOUR_TAKE_ONE then
			--变量定义
			local cbReferCard=self:SortOutCardList( cbTurnCardData,  cbTurnCardCount)
			local samecount, finddata=self:SearchFourTakeCardType(cbHandCardData, cbHandCardCount,cbReferCard,4,1)
			for i=1,samecount do
				cbResultCount=cbResultCount+1
				SecrchResult[cbResultCount] = finddata[i]
			end
		end
		
		--查找四带两对
		if cbTurnOutType==ErRenLandDefine.CT_FOUR_TAKE_TWO then
			--变量定义
			local cbReferCard=self:SortOutCardList( cbTurnCardData,  cbTurnCardCount)
			local samecount, finddata=self:SearchFourTakeCardType(cbHandCardData, cbHandCardCount,cbReferCard,4,2)
			for i=1,samecount do
				cbResultCount=cbResultCount+1
				SecrchResult[cbResultCount] = finddata[i]
			end
		end
        --炸弹
		if  cbTurnOutType~=ErRenLandDefine.CT_MISSILE_CARD then
			local cbReferCard = 0
		    if cbTurnOutType==CT_BOMB_CARD then
		       cbReferCard=cbTurnCardData[0]
		    end
			--炸弹
			local samecount, finddata=self:SearchBombType( cbHandCardData,cbHandCardCount,cbReferCard)
			if samecount>0 then
				cbResultCount=cbResultCount+1
				SecrchResult[cbResultCount] = finddata[1]
			end
		end
		
        --火箭
        if cbTurnOutType~=ErRenLandDefine.CT_MISSILE_CARD  then
			local samecount, finddata=self:SearchHuojianType( cbHandCardData,cbHandCardCount)
			if samecount>0 then
				cbResultCount=cbResultCount+1
				SecrchResult[cbResultCount] = finddata[1]
			end
	    end

	end


	--cbResultCount=cbResultCount

	--print("搜索结果"..cbResultCount)
	--dump(SecrchResult)
	return cbResultCount ,SecrchResult
end


--删除扑克
function CardLogic:RemoveCardList(cbRemoveCard, cbRemoveCount, cbCardData, cbCardCount)

	--//检验数据
	--ASSERT(cbRemoveCount<=cbCardCount);
print("要删除的牌"..cbRemoveCount.."张")
	dump(cbRemoveCard)
	print("原始手牌"..cbCardCount.."张")
	dump(cbCardData)

	--//定义变量
	local cbDeleteCount=0
	local cbTempCardData=cbCardData

	for i=1,cbRemoveCount do
	
		for j=1,cbCardCount do
		
			if cbRemoveCard[i]==cbTempCardData[j] then
			
				cbDeleteCount=cbDeleteCount+1
				cbTempCardData[j]=0

				break
			end
			
		end
	end
	print("执行结束")
	dump(cbTempCardData)


    local OutCarddata={}

	--//清理扑克
	local cbCardPos=1
	for i=1,cbCardCount do
	
		if cbTempCardData[i]~=0 then
			OutCarddata[cbCardPos]=cbTempCardData[i]
			cbCardPos=cbCardPos+1
		end
	end
	print("结果")
	dump(OutCarddata)
	local  leftCount=cbCardCount-cbRemoveCount
	return leftCount, OutCarddata
end
--获取类型
function CardLogic:GetCardType(cbCardData,cbCardCount)

	local CardData=cbCardData
	cbCardData={}
	for i=1,cbCardCount do
		cbCardData[i]=CardData[i]
	end
print("张数"..cbCardCount)
dump(cbCardData)
	--简单牌型
	if cbCardCount==0 then
	    return ErRenLandDefine.CT_ERROR  --错误
	end
	if cbCardCount==1 then
	    return ErRenLandDefine.CT_SINGLE --单牌
	end
	if cbCardCount==2 then
		--//牌型判断
		if cbCardData[1]==79 and cbCardData[2]==78 then 
		 return ErRenLandDefine.CT_MISSILE_CARD  --火箭
		end
		if self:GetCardLogicValue(cbCardData[1])==self:GetCardLogicValue(cbCardData[2])then 
		 return ErRenLandDefine.CT_DOUBLE  --对子
		end
	end
    --分析
	local AnalyseResult=self:AnalysebCardData(cbCardData,cbCardCount)
	--dump(AnalyseResult)
	--四牌判断
	if AnalyseResult.cbBlockCount[self.CardNum[4]]>0 then
		--牌型判断
		if AnalyseResult.cbBlockCount[self.CardNum[4]]==1 and AnalyseResult.cbBlockCount[self.CardNum[3]]==1 then 
			local cbFirstLogicValue1=self:GetCardLogicValue(AnalyseResult.cbCardData[self.CardNum[3]][1])
			local cbFirstLogicValue2=self:GetCardLogicValue(AnalyseResult.cbCardData[self.CardNum[4]][1])
			if cbFirstLogicValue1-cbFirstLogicValue2==1 or cbFirstLogicValue2-cbFirstLogicValue1==1 then 
			
				if cbCardCount==8 then 
					return ErRenLandDefine.CT_THREE_TAKE_ONE
				end
				--[[if cbCardCount==10 then 
					return ErRenLandDefine.CT_THREE_TAKE_TWO
				end]]
			end
		end
		if AnalyseResult.cbBlockCount[self.CardNum[4]]==1 and cbCardCount==4 then 
			return ErRenLandDefine.CT_BOMB_CARD 
		end
		if AnalyseResult.cbBlockCount[self.CardNum[4]]==1 and cbCardCount==6 then  
			return ErRenLandDefine.CT_FOUR_TAKE_ONE 
		end
		if AnalyseResult.cbBlockCount[self.CardNum[4]]==1 and cbCardCount==8 and AnalyseResult.cbBlockCount[self.CardNum[2]]==2 then
		 return ErRenLandDefine.CT_FOUR_TAKE_TWO
		end
		return ErRenLandDefine.CT_ERROR
	end

	--三牌判断
	if AnalyseResult.cbBlockCount[self.CardNum[3]]>0 then
		--连牌判断
		if AnalyseResult.cbBlockCount[self.CardNum[3]]>1 then
			--变量定义
			local cbCardData=AnalyseResult.cbCardData[self.CardNum[3]][1]
			local cbFirstLogicValue=self:GetCardLogicValue(cbCardData)
			--错误过虑
			if cbFirstLogicValue>=15 then 
				return ErRenLandDefine.CT_ERROR 
			end
			--连牌判断
			for  i=1,AnalyseResult.cbBlockCount[self.CardNum[3]]-1 do
			
				local cbCardData=AnalyseResult.cbCardData[self.CardNum[3]][i*3+1]
				--print("第"..i.."张牌"..cbCardData) 
				if cbFirstLogicValue~=self:GetCardLogicValue(cbCardData)+i then		
	               return ErRenLandDefine.CT_ERROR
	            end
			end
		else
		    if cbCardCount == 3 then 
		       return ErRenLandDefine.CT_THREE
		    end
		end
		--牌形判断
		if AnalyseResult.cbBlockCount[self.CardNum[3]]*3==cbCardCount then 
			return ErRenLandDefine.CT_THREE_LINE 
		end
		if AnalyseResult.cbBlockCount[self.CardNum[3]]*4==cbCardCount then 
		 return ErRenLandDefine.CT_THREE_TAKE_ONE
		end
		if AnalyseResult.cbBlockCount[self.CardNum[3]]*5==cbCardCount and AnalyseResult.cbBlockCount[self.CardNum[2]]==AnalyseResult.cbBlockCount[self.CardNum[3]] then 
		 return ErRenLandDefine.CT_THREE_TAKE_TWO
		end
		return ErRenLandDefine.CT_ERROR
	end

	--两张类型
	if AnalyseResult.cbBlockCount[self.CardNum[2]]>=3 then
		--变量定义
		local cbCardData=AnalyseResult.cbCardData[self.CardNum[2]][1]
		local cbFirstLogicValue=self:GetCardLogicValue(cbCardData)
		--错误过虑
		if cbFirstLogicValue>=15 then 
			return ErRenLandDefine.CT_ERROR
		end
		--连牌判断
		for i=1,AnalyseResult.cbBlockCount[self.CardNum[2]]-1 do
			local cbCardData=AnalyseResult.cbCardData[self.CardNum[2]][i*2+1]
			if cbFirstLogicValue~=self:GetCardLogicValue(cbCardData)+i then
			 return ErRenLandDefine.CT_ERROR
			end
		end
		--二连判断
		if AnalyseResult.cbBlockCount[self.CardNum[2]]*2==cbCardCount  then 
			return ErRenLandDefine.CT_DOUBLE_LINE
		end
		return ErRenLandDefine.CT_ERROR
	end

	--单张判断
	if AnalyseResult.cbBlockCount[self.CardNum[1]]>=5 and AnalyseResult.cbBlockCount[self.CardNum[1]]==cbCardCount then 
		--变量定义
		local cbCardData=AnalyseResult.cbCardData[self.CardNum[1]][1]
		local cbFirstLogicValue=self:GetCardLogicValue(cbCardData)

		--错误过虑
		if cbFirstLogicValue>=15 then
		 return ErRenLandDefine.CT_ERROR
		end
		--连牌判断
		for i=1,AnalyseResult.cbBlockCount[self.CardNum[1]]-1 do
			local cbCardData=AnalyseResult.cbCardData[self.CardNum[1]][i+1]
			if cbFirstLogicValue~=self:GetCardLogicValue(cbCardData)+i then 
				return ErRenLandDefine.CT_ERROR
			end
		end
		return ErRenLandDefine.CT_SINGLE_LINE
	end
	return ErRenLandDefine.CT_ERROR
end


function CardLogic:GetCardLogicValue(card)
	-- body
    local cardType, cardNumber = GameUtil:GetCardForPc(card)
    if cardNumber<=2 then
    	cardNumber=cardNumber+13
    end

    if cardType ==4 then
		cardNumber =cardNumber+2
	end
    return cardNumber
end
function CardLogic:GetCardValue(card)
	-- body
    local cardType, cardNumber = GameUtil:GetCardForPc(card)

    return cardNumber
end
function CardLogic:GetCardcorlor(card)
	-- body
    local cardType, cardNumber = GameUtil:GetCardForPc(card)

    return cardType
end

--对比扑克
function CardLogic:CompareCard(cbFirstCard,cbNextCard,cbFirstCount,cbNextCount)

	--获取类型
	local cbNextType=self:GetCardType(cbNextCard,cbNextCount)
	--print("cbNextType"..cbNextType)
	local cbFirstType=self:GetCardType(cbFirstCard,cbFirstCount)

--print("cbFirstType"..cbFirstType)
	--类型判断
	if cbNextType==ErRenLandDefine.CT_ERROR then 
		return false 
	end
	if cbNextType==ErRenLandDefine.CT_MISSILE_CARD then
	 return true 
	end

	--炸弹判断
	if cbFirstType~=ErRenLandDefine.CT_BOMB_CARD and cbNextType==ErRenLandDefine.CT_BOMB_CARD then
	 return true
	end
	if cbFirstType==ErRenLandDefine.CT_BOMB_CARD and cbNextType~=ErRenLandDefine.CT_BOMB_CARD then
	 return false
	end

	--规则判断
	if cbFirstType~=cbNextType or cbFirstCount~=cbNextCount then 
	 return false
	end

	--开始对比
	if cbNextType==ErRenLandDefine.CT_SINGLE or cbNextType==ErRenLandDefine.CT_DOUBLE or 
		cbNextType==ErRenLandDefine.CT_THREE or cbNextType==ErRenLandDefine.CT_SINGLE_LINE or
		cbNextType==ErRenLandDefine.CT_DOUBLE_LINE or cbNextType==ErRenLandDefine.CT_THREE_LINE or
		cbNextType==ErRenLandDefine.CT_BOMB_CARD  then
		--获取数值
			local cbNextLogicValue=self:GetCardLogicValue(cbNextCard[1])
			local cbFirstLogicValue=self:GetCardLogicValue(cbFirstCard[1])

			--对比扑克
			return cbNextLogicValue>cbFirstLogicValue
	end

	if cbNextType==ErRenLandDefine.CT_THREE_TAKE_ONE or cbNextType==ErRenLandDefine.CT_THREE_TAKE_TWO  then
		--分析扑克

			local NextResult=self:AnalysebCardData(cbNextCard,cbNextCount)
			local FirstResult=self:AnalysebCardData(cbFirstCard,cbFirstCount)

			--获取数值
			local cbNextLogicValue=self:GetCardLogicValue(NextResult.cbCardData[self.CardNum[3]][1])
			local cbFirstLogicValue=self:GetCardLogicValue(FirstResult.cbCardData[self.CardNum[3]][1])

			--对比扑克
			return cbNextLogicValue>cbFirstLogicValue
	end

	if cbNextType==ErRenLandDefine.CT_FOUR_TAKE_ONE or cbNextType==ErRenLandDefine.CT_FOUR_TAKE_TWO  then
		--分析扑克

			local NextResult=self:AnalysebCardData(cbNextCard,cbNextCount)
			local FirstResult=self:AnalysebCardData(cbFirstCard,cbFirstCount)

			--获取数值
			local cbNextLogicValue=self:GetCardLogicValue(NextResult.cbCardData[self.CardNum[4]][1])
			local cbFirstLogicValue=self:GetCardLogicValue(FirstResult.cbCardData[self.CardNum[4]][1])

			--对比扑克
			return cbNextLogicValue>cbFirstLogicValue
	end

	return false
end


--分析扑克
function CardLogic:AnalysebCardData(cbCardData,cbCardCount)
	local CardData=cbCardData
	cbCardData={}
	for i=1,cbCardCount do
		cbCardData[i]=CardData[i]
	end
	table.sort(CardData, handler(self,self.ComparaBtoS))
	--设置结果
	local AnalyseResult=
	{
		cbBlockCount={},
		cbCardData={}
	}
    for i=1,4 do
		if not AnalyseResult.cbCardData[self.CardNum[i]] then
			AnalyseResult.cbCardData[self.CardNum[i]] = {}
			AnalyseResult.cbBlockCount[self.CardNum[i]] = 0
		end
    end
	self.allCard={}
	for k,v in pairs(cbCardData) do
		local cbLogicValue=self:GetCardValue(v)
		local cardType =self:GetCardcorlor(v)
		self:calCardCount({ctype =cardType,number =cbLogicValue})
	end

	for k ,v in pairs(self.allCard) do
		for i=1,#v do
			local pccard=self:MakePcCard(v[i])
			table.insert(AnalyseResult.cbCardData[self.CardNum[#v]],pccard)
		end
		AnalyseResult.cbBlockCount[self.CardNum[#v]]=AnalyseResult.cbBlockCount[self.CardNum[#v]]+1
	end
	--dump(AnalyseResult)
	return AnalyseResult
end


----------------以下为单元算法，无需改动---------------

function CardLogic:SortCardData(card)
	local data=card
	table.sort(data, handler(self,self.ComparaBtoS))
	return data
end
--分析扑克算法
function CardLogic:calCardCount(card)
	local hasIn = false
	for k ,v in pairs(self.allCard) do
		if type(v) == "table" then
			if  v[1].number == card.number then
				hasIn = true
				table.insert(self.allCard[k], card)
			end
		end
	end
	--不在的话 加入数组
	if not hasIn then
		table.insert(self.allCard,{card})
	end
end
--比较单牌
function CardLogic:ComparaBtoS(a,b)
	local num1=self:GetCardLogicValue(a)
	local num2=self:GetCardLogicValue(b)



	local corlor1=self:GetCardcorlor(a)
	local corlor2=self:GetCardcorlor(b)

	if corlor1 ==4 then
		num1 =num1+2
	end

	if corlor2 ==4 then
        num2 =num2+2
	end

	if num1>num2 then
		return true
	end
	if num1==num2 then
		if corlor1>corlor2 then
			return true
		end
	end
	return false
end
--比较单牌
function CardLogic:ComparaStoB(a,b)
	local num1=self:GetCardLogicValue(a)
	local num2=self:GetCardLogicValue(b)



	local corlor1=self:GetCardcorlor(a)
	local corlor2=self:GetCardcorlor(b)

	if corlor1 ==4 then
		num1 =num1+2
	end

	if corlor2 ==4 then
        num2 =num2+2
	end

	if num1<num2 then
		return true
	end
	if num1==num2 then
		if corlor1<corlor2 then
			return true
		end
	end
	return false
end
function CardLogic:MakePcCard(card)
	-- body
    --local cardType, cardNumber = GameUtil:GetCardForPc(card)
    local Pccard=card.number+card.ctype*16
    return Pccard
end

return CardLogic