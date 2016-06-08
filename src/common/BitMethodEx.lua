--[[
Description:
    FileName:bitEx.lua
    This module provides a selection of bitwise operations.
History:
    Initial version created by  阵雨 2005-11-10.
Notes:
  ....
]]
--[[{2147483648,1073741824,536870912,268435456,134217728,67108864,33554432,16777216,
        8388608,4194304,2097152,1048576,524288,262144,131072,65536,
        32768,16384,8192,4096,2048,1024,512,256,128,64,32,16,8,4,2,1}
        ]]


bitEx={data32={}}
for i=1,32 do
    bitEx.data32[i]=2^(32-i)
end

function bitEx:d2b(arg)
    local   tr={}
    for i=1,32 do
        if arg >= self.data32[i] then
        tr[i]=1
        arg=arg-self.data32[i]
        else
        tr[i]=0
        end
    end
    return   tr
end   --bitEx:d2b

function    bitEx:b2d(arg)
    local   nr=0
    for i=1,32 do
        if arg[i] ==1 then
        nr=nr+2^(32-i)
        end
    end
    return  nr
end   --bitEx:b2d

function    bitEx:_xor(a,b)
    local   op1=self:d2b(a)
    local   op2=self:d2b(b)
    local   r={}

    for i=1,32 do
        if op1[i]==op2[i] then
            r[i]=0
        else
            r[i]=1
        end
    end
    return  self:b2d(r)
end --bitEx:xor

function    bitEx:_and(a,b)
    local   op1=self:d2b(a)
    local   op2=self:d2b(b)
    local   r={}
    
    for i=1,32 do
        if op1[i]==1 and op2[i]==1  then
            r[i]=1
        else
            r[i]=0
        end
    end
    return  self:b2d(r)
    
end --bitEx:_and

function    bitEx:_or(a,b)
    local   op1=self:d2b(a)
    local   op2=self:d2b(b)
    local   r={}
    
    for i=1,32 do
        if  op1[i]==1 or   op2[i]==1   then
            r[i]=1
        else
            r[i]=0
        end
    end
    return  self:b2d(r)
end --bitEx:_or

function    bitEx:_not(a)
    local   op1=self:d2b(a)
    local   r={}

    for i=1,32 do
        if  op1[i]==1   then
            r[i]=0
        else
            r[i]=1
        end
    end
    return  self:b2d(r)
end --bitEx:_not

function    bitEx:_rshift(a,n)
    local   op1=self:d2b(a)
    local   r=self:d2b(0)
    
    if n < 32 and n > 0 then
        for i=1,n do
            for i=31,1,-1 do
                op1[i+1]=op1[i]
            end
            op1[1]=0
        end
    r=op1
    end
    return  self:b2d(r)
end --bitEx:_rshift

function    bitEx:_lshift(a,n)
    local   op1=self:d2b(a)
    local   r=self:d2b(0)
    
    if n < 32 and n > 0 then
        for i=1,n   do
            for i=1,31 do
                op1[i]=op1[i+1]
            end
            op1[32]=0
        end
    r=op1
    end
    return  self:b2d(r)
end --bitEx:_lshift


function    bitEx:print(ta)
    local   sr=""
    for i=1,32 do
        sr=sr..ta[i]
    end
    print(sr)
end

--[[bs=bitEx:d2b(7)
bitEx:print(bs)                          
-->00000000000000000000000000000111
bitEx:print(bitEx:d2b(bitEx:_not(7)))         
-->11111111111111111111111111111000
bitEx:print(bitEx:d2b(bitEx:_rshift(7,2)))    
-->00000000000000000000000000000001
bitEx:print(bitEx:d2b(bitEx:_lshift(7,2)))    
-->00000000000000000000000000011100
print(bitEx:b2d(bs))                      -->     7
print(bitEx:_xor(7,2))                    -->     5
print(bitEx:_and(7,4))                    -->     4
print(bitEx:_or(5,2))                     -->     7
]]

--end of bitEx.lua