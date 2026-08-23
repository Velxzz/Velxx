-------------------------------------------------------------------------------
--! json & cryptography library (Platoboost Internal)
-------------------------------------------------------------------------------
local a=2^32;local b=a-1;local function c(d,e)local f,g=0,1;while d~=0 or e~=0 do local h,i=d%2,e%2;local j=(h+i)%2;f=f+j*g;d=math.floor(d/2)e=math.floor(e/2)g=g*2 end;return f%a end;local function k(d,e,l,...)local m;if e then d=d%a;e=e%a;m=c(d,e)if l then m=k(m,l,...)end;return m elseif d then return d%a else return 0 end end;local function n(d,e,l,...)local m;if e then d=d%a;e=e%a;m=(d+e-c(d,e))/2;if l then m=n(m,l,...)end;return m elseif d then return d%a else return b end end;local function o(p)return b-p end;local function q(d,r)if r<0 then return lshift(d,-r)end;return math.floor(d%2^32/2^r)end;local function s(p,r)if r>31 or r<-31 then return 0 end;return q(p%a,r)end;local function lshift(d,r)if r<0 then return s(d,-r)end;return d*2^r%2^32 end;local function t(p,r)p=p%a;r=r%32;local u=n(p,2^r-1)return s(p,r)+lshift(u,32-r)end;local v={0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2}local function w(x)return string.gsub(x,".",function(l)return string.format("%02x",string.byte(l))end)end;local function y(z,A)local x=""for B=1,A do local C=z%256;x=string.char(C)..x;z=(z-C)/256 end;return x end;local function D(x,B)local A=0;for B=B,B+3 do A=A*256+string.byte(x,B)end;return A end;local function E(F,G)local H=64-(G+9)%64;G=y(8*G,8)F=F.."\128"..string.rep("\0",H)..G;assert(#F%64==0)return F end;local function I(J)J[1]=0x6a09e667;J[2]=0xbb67ae85;J[3]=0x3c6ef372;J[4]=0xa54ff53a;J[5]=0x510e527f;J[6]=0x9b05688c;J[7]=0x1f83d9ab;J[8]=0x5be0cd19;return J end;local function K(F,B,J)local L={}for M=1,16 do L[M]=D(F,B+(M-1)*4)end;for M=17,64 do local N=L[M-15]local O=k(t(N,7),t(N,18),s(N,3))N=L[M-2]L[M]=(L[M-16]+O+L[M-7]+k(t(N,17),t(N,19),s(N,10)))%a end;local d,e,l,P,Q,R,S,T=J[1],J[2],J[3],J[4],J[5],J[6],J[7],J[8]for B=1,64 do local O=k(t(d,2),t(d,13),t(d,22))local U=k(n(d,e),n(d,l),n(e,l))local V=(O+U)%a;local W=k(t(Q,6),t(Q,11),t(Q,25))local X=k(n(Q,R),n(o(Q),S))local Y=(T+W+X+v[B]+L[B])%a;T=S;S=R;R=Q;Q=(P+Y)%a;P=l;l=e;e=d;d=(Y+V)%a end;J[1]=(J[1]+d)%a;J[2]=(J[2]+e)%a;J[3]=(J[3]+l)%a;J[4]=(J[4]+P)%a;J[5]=(J[5]+Q)%a;J[6]=(J[6]+R)%a;J[7]=(J[7]+S)%a;J[8]=(J[8]+T)%a end;local function Z(F)F=E(F,#F)local J=I({})for B=1,#F,64 do K(F,B,J)end;return w(y(J[1],4)..y(J[2],4)..y(J[3],4)..y(J[4],4)..y(J[5],4)..y(J[6],4)..y(J[7],4)..y(J[8],4))end;local e;local l={["\\"]="\\",["\""]="\"",["\b"]="b",["\f"]="f",["\n"]="n",["\r"]="r",["\t"]="t"}local P={["/"]="/"}for Q,R in pairs(l)do P[R]=Q end;local S=function(T)return"\\"..(l[T]or string.format("u%04x",T:byte()))end;local B=function(M)return"null"end;local v=function(M,z)local _={}z=z or{}if z[M]then error("circular reference")end;z[M]=true;if rawget(M,1)~=nil or next(M)==nil then local A=0;for Q in pairs(M)do if type(Q)~="number"then error("invalid table: mixed or invalid key types")end;A=A+1 end;if A~=#M then error("invalid table: sparse array")end;for a0,R in ipairs(M)do table.insert(_,e(R,z))end;z[M]=nil;return"["..table.concat(_,",").."]"else for Q,R in pairs(M)do if type(Q)~="string"then error("invalid table: mixed or invalid key types")end;table.insert(_,e(Q,z)..":"..e(R,z))end;z[M]=nil;return"{"..table.concat(_,",").."}"end end;local g=function(M)return'"'..M:gsub('[%z\1-\31\\"]',S)..'"'end;local a1=function(M)if M~=M or M<=-math.huge or M>=math.huge then error("unexpected number value '"..tostring(M).."'")end;return string.format("%.14g",M)end;local j={["nil"]=B,["table"]=v,["string"]=g,["number"]=a1,["boolean"]=tostring}e=function(M,z)local x=type(M)local a2=j[x]if a2 then return a2(M,z)end;error("unexpected type '"..x.."'")end;local a3=function(M)return e(M)end;local a4;local N=function(...)local _={}for a0=1,select("#",...)do _[select(a0,...)]=true end;return _ end;local L=N(" ","\t","\r","\n")local p=N(" ","\t","\r","\n","]","}",",")local a5=N("\\","/",'"',"b","f","n","r","t","u")local m=N("true","false","null")local a6={["true"]=true,["false"]=false,["null"]=nil}local a7=function(a8,a9,aa,ab)for a0=a9,#a8 do if aa[a8:sub(a0,a0)]~=ab then return a0 end end;return#a8+1 end;local ac=function(a8,a9,J)local ad=1;local ae=1;for a0=1,a9-1 do ae=ae+1;if a8:sub(a0,a0)=="\n"then ad=ad+1;ae=1 end end;error(string.format("%s at line %d col %d",J,ad,ae))end;local af=function(A)local a2=math.floor;if A<=0x7f then return string.char(A)elseif A<=0x7ff then return string.char(a2(A/64)+192,A%64+128)elseif A<=0xffff then return string.char(a2(A/4096)+224,a2(A%4096/64)+128,A%64+128)elseif A<=0x10ffff then return string.char(a2(A/262144)+240,a2(A%262144/4096)+128,a2(A%4096/64)+128,A%64+128)end;error(string.format("invalid unicode codepoint '%x'",A))end;local ag=function(ah)local ai=tonumber(ah:sub(1,4),16)local aj=tonumber(ah:sub(7,10),16)if aj then return af((ai-0xd800)*0x400+aj-0xdc00+0x10000)else return af(ai)end end;local ak=function(a8,a0)local _=""local al=a0+1;local Q=al;while al<=#a8 do local am=a8:byte(al)if am<32 then ac(a8,al,"control character in string")elseif am==92 then _=_..a8:sub(Q,al-1)al=al+1;local T=a8:sub(al,al)if T=="u"then local an=a8:match("^[dD][89aAbB]%x%x\\u%x%x%x%x",al+1)or a8:match("^%x%x%x%x",al+1)or ac(a8,al-1,"invalid unicode escape in string")_=_..ag(an)al=al+#an else if not a5[T]then ac(a8,al-1,"invalid escape char '"..T.."' in string")end;_=_..P[T]end;Q=al+1 elseif am==34 then _=_..a8:sub(Q,al-1)return _,al+1 end;al=al+1 end;ac(a8,a0,"expected closing quote for string")end;local ao=function(a8,a0)local am=a7(a8,a0,p)local ah=a8:sub(a0,am-1)local A=tonumber(ah)if not A then ac(a8,a0,"invalid number '"..ah.."'")end;return A,am end;local ap=function(a8,a0)local am=a7(a8,a0,p)local aq=a8:sub(a0,am-1)if not m[aq]then ac(a8,a0,"invalid literal '"..aq.."'")end;return a6[aq],am end;local ar=function(a8,a0)local _={}local A=1;a0=a0+1;while 1 do local am;a0=a7(a8,a0,L,true)if a8:sub(a0,a0)=="]"then a0=a0+1;break end;am,a0=a4(a8,a0)_[A]=am;A=A+1;a0=a7(a8,a0,L,true)local as=a8:sub(a0,a0)a0=a0+1;if as=="]"then break end;if as~=","then ac(a8,a0,"expected ']' or ','")end end;return _,a0 end;local at=function(a8,a0)local _={}a0=a0+1;while 1 do local au,M;a0=a7(a8,a0,L,true)if a8:sub(a0,a0)=="}"then a0=a0+1;break end;if a8:sub(a0,a0)~='"'then ac(a8,a0,"expected string for key")end;au,a0=a4(a8,a0)a0=a7(a8,a0,L,true)if a8:sub(a0,a0)~=":"then ac(a8,a0,"expected ':' after key")end;a0=a7(a8,a0+1,L,true)M,a0=a4(a8,a0)_[au]=M;a0=a7(a8,a0,L,true)local as=a8:sub(a0,a0)a0=a0+1;if as=="}"then break end;if as~=","then ac(a8,a0,"expected '}' or ','")end end;return _,a0 end;local av={['"']=ak,["0"]=ao,["1"]=ao,["2"]=ao,["3"]=ao,["4"]=ao,["5"]=ao,["6"]=ao,["7"]=ao,["8"]=ao,["9"]=ao,["-"]=ao,["t"]=ap,["f"]=ap,["n"]=ap,["["]=ar,["{"]=at}a4=function(a8,a9)local as=a8:sub(a9,a9)local a2=av[as]if a2 then return a2(a8,a9)end;ac(a8,a9,"unexpected character '"..as.."'")end;local aw=function(a8)if type(a8)~="string"then error("expected argument of type string, got "..type(a8))end;local _,a9=a4(a8,a7(a8,1,L,true))a9=a7(a8,a9,L,true)if a9<=#a8 then ac(a8,a9,"trailing garbage")end;return _ end;
local lEncode, lDecode, lDigest = a3, aw, Z;

-------------------------------------------------------------------------------
--! Platoboost Module Setup
-------------------------------------------------------------------------------
local service = 30134;
local secret = "7f0bc597-f40c-4952-93be-8003d9abdd3b";
local useNonce = true;

local keyStatusMessage = ""
local onMessage = function(message) 
    keyStatusMessage = message 
end;

repeat task.wait(1) until game:IsLoaded();

local requestSending = false;
local fSetClipboard, fRequest, fStringChar, fToString, fStringSub, fOsTime, fMathRandom, fMathFloor, fGetHwid = setclipboard or toclipboard, request or http_request or syn_request, string.char, tostring, string.sub, os.time, math.random, math.floor, gethwid or function() return game:GetService("Players").LocalPlayer.UserId end
local cachedLink, cachedTime = "", 0;

local host = "https://api.platoboost.com";
local hostResponse = fRequest({ Url = host .. "/public/connectivity", Method = "GET" });
if hostResponse and (hostResponse.StatusCode ~= 200 or hostResponse.StatusCode ~= 429) then
    host = "https://api.platoboost.net";
end

function cacheLink()
    if cachedTime + (10*60) < fOsTime() then
        local response = fRequest({
            Url = host .. "/public/start",
            Method = "POST",
            Body = lEncode({ service = service, identifier = lDigest(fGetHwid()) }),
            Headers = { ["Content-Type"] = "application/json" }
        });
        if response and response.StatusCode == 200 then
            local decoded = lDecode(response.Body);
            if decoded.success == true then
                cachedLink = decoded.data.url;
                cachedTime = fOsTime();
                return true, cachedLink;
            else
                onMessage(decoded.message);
                return false, decoded.message;
            end
        elseif response and response.StatusCode == 429 then
            local msg = "Rate limited, please wait 20s.";
            onMessage(msg);
            return false, msg;
        end
        local msg = "Failed to cache link.";
        onMessage(msg);
        return false, msg;
    else
        return true, cachedLink;
    end
end

local generateNonce = function()
    local str = ""
    for _ = 1, 16 do str = str .. fStringChar(fMathFloor(fMathRandom() * (122 - 97 + 1)) + 97) end
    return str
end

local copyLink = function()
    local success, link = cacheLink();
    if success and fSetClipboard then fSetClipboard(link); end
end

local verifyKey = function(key)
    if requestSending then onMessage("Request pending..."); return false; else requestSending = true; end
    local nonce = generateNonce();
    local endpoint = host .. "/public/whitelist/" .. fToString(service) .. "?identifier=" .. lDigest(fGetHwid()) .. "&key=" .. key .. (useNonce and ("&nonce=" .. nonce) or "");
    local response = fRequest({ Url = endpoint, Method = "GET" });
    requestSending = false;

    if response and response.StatusCode == 200 then
        local decoded = lDecode(response.Body);
        if decoded.success then
            if decoded.data.valid then
                return true;
            else
                onMessage("Invalid Key!");
                return false;
            end
        else
            onMessage(decoded.message);
            return false;
        end
    end
    onMessage("Error connecting to server.");
    return false;
end

-------------------------------------------------------------------------------
--! UI Init & Setup
-------------------------------------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local parentContainer
if gethui then parentContainer = gethui() else
    local success, core = pcall(function() return game:GetService("CoreGui") end)
    parentContainer = (success and core) or LocalPlayer:WaitForChild("PlayerGui")
end

local oldGui = parentContainer:FindFirstChild("ModifierGui")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModifierGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 9
ScreenGui.Parent = parentContainer

-------------------------------------------------------------------------------
--! Key System UI Frame
-------------------------------------------------------------------------------
local KeyFrame = Instance.new("Frame", ScreenGui)
KeyFrame.Size = UDim2.new(0, 240, 0, 180)
KeyFrame.Position = UDim2.new(0.4, 0, 0.35, 0)
KeyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
KeyFrame.BorderSizePixel = 0
KeyFrame.Active = true
KeyFrame.Draggable = true
Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 10)

local KeyTitle = Instance.new("TextLabel", KeyFrame)
KeyTitle.Size = UDim2.new(1, 0, 0, 30)
KeyTitle.Text = "KEY SYSTEM"
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.TextSize = 12
KeyTitle.BackgroundTransparency = 1

local KeyTextBox = Instance.new("TextBox", KeyFrame)
KeyTextBox.Size = UDim2.new(0.9, 0, 0, 30)
KeyTextBox.Position = UDim2.new(0.05, 0, 0.25, 0)
KeyTextBox.PlaceholderText = "Enter Key Here..."
KeyTextBox.Text = ""
KeyTextBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
KeyTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTextBox.Font = Enum.Font.Gotham
KeyTextBox.TextSize = 10
Instance.new("UICorner", KeyTextBox).CornerRadius = UDim.new(0, 5)

local GetKeyBtn = Instance.new("TextButton", KeyFrame)
GetKeyBtn.Size = UDim2.new(0.42, 0, 0, 28)
GetKeyBtn.Position = UDim2.new(0.05, 0, 0.5, 0)
GetKeyBtn.Text = "Get Key"
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.TextSize = 10
Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 5)

local VerifyBtn = Instance.new("TextButton", KeyFrame)
VerifyBtn.Size = UDim2.new(0.42, 0, 0, 28)
VerifyBtn.Position = UDim2.new(0.53, 0, 0.5, 0)
VerifyBtn.Text = "Verify Key"
VerifyBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.TextSize = 10
Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 5)

local KeyStatusLabel = Instance.new("TextLabel", KeyFrame)
KeyStatusLabel.Size = UDim2.new(0.9, 0, 0, 20)
KeyStatusLabel.Position = UDim2.new(0.05, 0, 0.72, 0)
KeyStatusLabel.Text = ""
KeyStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
KeyStatusLabel.Font = Enum.Font.GothamSemibold
KeyStatusLabel.TextSize = 9
KeyStatusLabel.BackgroundTransparency = 1

-------------------------------------------------------------------------------
--! Main UI (Modifier Frame)
-------------------------------------------------------------------------------
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 330)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local HeaderBar = Instance.new("Frame", MainFrame)
HeaderBar.Size = UDim2.new(1, 0, 0, 35)
HeaderBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
HeaderBar.BorderSizePixel = 0
Instance.new("UICorner", HeaderBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", HeaderBar)
Title.Size = UDim2.new(1, -10, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "MODIFIER V1.0 PRO"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

RunService.RenderStepped:Connect(function()
    local hue = (tick() % 5) / 5
    Title.TextColor3 = Color3.fromHSV(hue, 1, 1)
end)

local ContentScroll = Instance.new("ScrollingFrame", MainFrame)
ContentScroll.Size = UDim2.new(1, -10, 1, -45)
ContentScroll.Position = UDim2.new(0, 5, 0, 40)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 4
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 450)

local UIListLayout = Instance.new("UIListLayout", ContentScroll)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)

local function createToggleRow(parent, labelText, order)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -6, 0, 28)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order
    
    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Text = labelText .. " :"
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    
    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(0, 75, 0, 22)
    btn.Position = UDim2.new(1, -75, 0.5, -11)
    btn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    btn.BorderSizePixel = 0
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 4)
    
    return row, btn
end

local activeFeatures = true
local isRunning = false
local floatFunctionActive = true
local isLocked = false

local _, ActiveFeaturesBtn = createToggleRow(ContentScroll, "Active Features", 1)
ActiveFeaturesBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
ActiveFeaturesBtn.Text = "ON"

local _, StartToggleBtn = createToggleRow(ContentScroll, "Start Modifier", 2)

local speedRow = Instance.new("Frame", ContentScroll)
speedRow.Size = UDim2.new(1, -6, 0, 28)
speedRow.BackgroundTransparency = 1
speedRow.LayoutOrder = 3

local speedLabel = Instance.new("TextLabel", speedRow)
speedLabel.Size = UDim2.new(0.6, 0, 1, 0)
speedLabel.Text = "Modifier Speed :"
speedLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 10
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.BackgroundTransparency = 1

local SpeedBtn = Instance.new("TextButton", speedRow)
SpeedBtn.Size = UDim2.new(0, 75, 0, 22)
SpeedBtn.Position = UDim2.new(1, -75, 0.5, -11)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
SpeedBtn.BorderSizePixel = 0
SpeedBtn.Text = "1"
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.Font = Enum.Font.GothamBold
SpeedBtn.TextSize = 10
Instance.new("UICorner", SpeedBtn).CornerRadius = UDim.new(0, 4)

local spawnRow = Instance.new("Frame", ContentScroll)
spawnRow.Size = UDim2.new(1, -6, 0, 28)
spawnRow.BackgroundTransparency = 1
spawnRow.LayoutOrder = 4

local spawnLabel = Instance.new("TextLabel", spawnRow)
spawnLabel.Size = UDim2.new(0.6, 0, 1, 0)
spawnLabel.Text = "Spawn Block :"
spawnLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
spawnLabel.Font = Enum.Font.GothamBold
spawnLabel.TextSize = 10
spawnLabel.TextXAlignment = Enum.TextXAlignment.Left
spawnLabel.BackgroundTransparency = 1

local SpawnBtn = Instance.new("TextButton", spawnRow)
SpawnBtn.Size = UDim2.new(0, 75, 0, 22)
SpawnBtn.Position = UDim2.new(1, -75, 0.5, -11)
SpawnBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
SpawnBtn.BorderSizePixel = 0
SpawnBtn.Text = "SPAWN"
SpawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpawnBtn.Font = Enum.Font.GothamBold
SpawnBtn.TextSize = 9
Instance.new("UICorner", SpawnBtn).CornerRadius = UDim.new(0, 4)

local undoRow = Instance.new("Frame", ContentScroll)
undoRow.Size = UDim2.new(1, -6, 0, 28)
undoRow.BackgroundTransparency = 1
undoRow.LayoutOrder = 5

local undoLabel = Instance.new("TextLabel", undoRow)
undoLabel.Size = UDim2.new(0.6, 0, 1, 0)
undoLabel.Text = "Undo Last Block :"
undoLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
undoLabel.Font = Enum.Font.GothamBold
undoLabel.TextSize = 10
undoLabel.TextXAlignment = Enum.TextXAlignment.Left
undoLabel.BackgroundTransparency = 1

local UndoBtn = Instance.new("TextButton", undoRow)
UndoBtn.Size = UDim2.new(0, 75, 0, 22)
UndoBtn.Position = UDim2.new(1, -75, 0.5, -11)
UndoBtn.BackgroundColor3 = Color3.fromRGB(230, 140, 0)
UndoBtn.BorderSizePixel = 0
UndoBtn.Text = "UNDO"
UndoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UndoBtn.Font = Enum.Font.GothamBold
UndoBtn.TextSize = 9
Instance.new("UICorner", UndoBtn).CornerRadius = UDim.new(0, 4)

local resetRow = Instance.new("Frame", ContentScroll)
resetRow.Size = UDim2.new(1, -6, 0, 28)
resetRow.BackgroundTransparency = 1
resetRow.LayoutOrder = 6

local resetLabel = Instance.new("TextLabel", resetRow)
resetLabel.Size = UDim2.new(0.6, 0, 1, 0)
resetLabel.Text = "Reset Modifier :"
resetLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
resetLabel.Font = Enum.Font.GothamBold
resetLabel.TextSize = 10
resetLabel.TextXAlignment = Enum.TextXAlignment.Left
resetLabel.BackgroundTransparency = 1

local ResetBtn = Instance.new("TextButton", resetRow)
ResetBtn.Size = UDim2.new(0, 75, 0, 22)
ResetBtn.Position = UDim2.new(1, -75, 0.5, -11)
ResetBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
ResetBtn.BorderSizePixel = 0
ResetBtn.Text = "RESET"
ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.TextSize = 9
Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, 4)

local _, LockButtonToggle = createToggleRow(ContentScroll, "Lock Button", 7)

local configRow = Instance.new("Frame", ContentScroll)
configRow.Size = UDim2.new(1, -6, 0, 32)
configRow.BackgroundTransparency = 1
configRow.LayoutOrder = 8

local SaveConfigBtn = Instance.new("TextButton", configRow)
SaveConfigBtn.Size = UDim2.new(0.48, 0, 1, 0)
SaveConfigBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
SaveConfigBtn.BorderSizePixel = 0
SaveConfigBtn.Text = "Save New"
SaveConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveConfigBtn.Font = Enum.Font.GothamBold
SaveConfigBtn.TextSize = 10
Instance.new("UICorner", SaveConfigBtn).CornerRadius = UDim.new(0, 4)

local LoadConfigBtn = Instance.new("TextButton", configRow)
LoadConfigBtn.Size = UDim2.new(0.48, 0, 1, 0)
LoadConfigBtn.Position = UDim2.new(0.52, 0, 0, 0)
LoadConfigBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
LoadConfigBtn.BorderSizePixel = 0
LoadConfigBtn.Text = "Load Config"
LoadConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadConfigBtn.Font = Enum.Font.GothamBold
LoadConfigBtn.TextSize = 10
Instance.new("UICorner", LoadConfigBtn).CornerRadius = UDim.new(0, 4)

local updateRow = Instance.new("Frame", ContentScroll)
updateRow.Size = UDim2.new(1, -6, 0, 28)
updateRow.BackgroundTransparency = 1
updateRow.LayoutOrder = 9

local UpdateConfigBtn = Instance.new("TextButton", updateRow)
UpdateConfigBtn.Size = UDim2.new(1, 0, 1, 0)
UpdateConfigBtn.BackgroundColor3 = Color3.fromRGB(130, 60, 200)
UpdateConfigBtn.BorderSizePixel = 0
UpdateConfigBtn.Text = "Update Config (Overwrite Code)"
UpdateConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UpdateConfigBtn.Font = Enum.Font.GothamBold
UpdateConfigBtn.TextSize = 10
Instance.new("UICorner", UpdateConfigBtn).CornerRadius = UDim.new(0, 4)

local loadBoxRow = Instance.new("Frame", ContentScroll)
loadBoxRow.Size = UDim2.new(1, -6, 0, 28)
loadBoxRow.BackgroundTransparency = 1
loadBoxRow.LayoutOrder = 10

local LoadBox = Instance.new("TextBox", loadBoxRow)
LoadBox.Size = UDim2.new(1, 0, 1, 0)
LoadBox.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
LoadBox.BorderSizePixel = 0
LoadBox.PlaceholderText = "Paste Code Config Here..."
LoadBox.Text = ""
LoadBox.TextColor3 = Color3.fromRGB(30, 30, 30)
LoadBox.Font = Enum.Font.Gotham
LoadBox.TextSize = 10
Instance.new("UICorner", LoadBox).CornerRadius = UDim.new(0, 4)

-- Destroy UI Button Row
local destroyRow = Instance.new("Frame", ContentScroll)
destroyRow.Size = UDim2.new(1, -6, 0, 28)
destroyRow.BackgroundTransparency = 1
destroyRow.LayoutOrder = 11

local DestroyBtn = Instance.new("TextButton", destroyRow)
DestroyBtn.Size = UDim2.new(1, 0, 1, 0)
DestroyBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
DestroyBtn.BorderSizePixel = 0
DestroyBtn.Text = "Destroy UI"
DestroyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DestroyBtn.Font = Enum.Font.GothamBold
DestroyBtn.TextSize = 10
Instance.new("UICorner", DestroyBtn).CornerRadius = UDim.new(0, 4)

local statusRow = Instance.new("Frame", ContentScroll)
statusRow.Size = UDim2.new(1, -6, 0, 20)
statusRow.BackgroundTransparency = 1
statusRow.LayoutOrder = 12

local StatusLabel = Instance.new("TextLabel", statusRow)
StatusLabel.Size = UDim2.new(1, 0, 1, 0)
StatusLabel.Text = ""
StatusLabel.TextColor3 = Color3.fromRGB(0, 150, 0)
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.TextSize = 10
StatusLabel.BackgroundTransparency = 1

local MainFloatBtn = Instance.new("TextButton", ScreenGui)
MainFloatBtn.Size = UDim2.new(0, 45, 0, 45)
MainFloatBtn.Position = UDim2.new(0.02, 0, 0.2, 0)
MainFloatBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFloatBtn.BackgroundTransparency = 0.2
MainFloatBtn.Text = "M"
MainFloatBtn.TextColor3 = Color3.fromRGB(0, 150, 255)
MainFloatBtn.Font = Enum.Font.GothamBold
MainFloatBtn.TextSize = 18
MainFloatBtn.BorderSizePixel = 0
MainFloatBtn.Active = true
MainFloatBtn.Draggable = true
MainFloatBtn.Visible = false
Instance.new("UICorner", MainFloatBtn).CornerRadius = UDim.new(1, 0)

MainFloatBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local createdFloatBtns = {}
local function createCircularFloat(name, text, customPos, callback)
    local btn = Instance.new("TextButton", ScreenGui)
    btn.Size = UDim2.new(0, 50, 0, 50)
    btn.Position = customPos
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.BackgroundTransparency = 0.4
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = name == "Speed" and 12 or 10
    btn.BorderSizePixel = 0
    btn.Active = true
    btn.Visible = false
    
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    
    btn.MouseButton1Click:Connect(function()
        if activeFeatures and floatFunctionActive then
            callback()
        end
    end)
    
    local dragging = false
    local dragInput, dragStart, startPos
    
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    
    btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging and not isLocked then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    table.insert(createdFloatBtns, btn)
    return btn
end

-------------------------------------------------------------------------------
--! Modifier Logic & Functions
-------------------------------------------------------------------------------
local spawnedBlocks = {}
local currentIndex = 1
local currentSpeedIndex = 11
local lastPos = nil
local startingCFrame = nil
local currentTransitionTime = 0

local speedValues = { 0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }

local function getSpeedValue() return speedValues[currentSpeedIndex] end

local FastSteerFloatBtn
local function updateSpeedUI()
    local val = getSpeedValue()
    SpeedBtn.Text = tostring(val)
    if FastSteerFloatBtn then FastSteerFloatBtn.Text = tostring(val) end
end

local function cycleSpeed()
    currentSpeedIndex = currentSpeedIndex - 1
    if currentSpeedIndex < 1 then currentSpeedIndex = #speedValues end
    updateSpeedUI()
end

SpeedBtn.MouseButton1Click:Connect(cycleSpeed)

local function createVisualBlock(cf)
    local block = Instance.new("Part")
    block.Size = Vector3.new(1, 10, 1)
    block.CFrame = cf
    block.Anchored = true
    block.CanCollide = false
    block.Transparency = 0.5
    block.Material = Enum.Material.SmoothPlastic
    block.Color = Color3.fromRGB(255, 255, 255)
    
    local texture = Instance.new("Texture")
    texture.Face = Enum.NormalId.Top
    texture.Texture = "rbxassetid://620583021"
    texture.Parent = block
    
    block.Parent = workspace
    table.insert(spawnedBlocks, block)
    return block
end

local function spawnBlockAtPlayer()
    if not activeFeatures then return end
    local char = LocalPlayer.Character
    if not char then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local targetPart = (humanoid and humanoid.SeatPart) or rootPart
    
    if targetPart then
        local currentPos = targetPart.Position
        local finalCFrame
        if lastPos then
            local moveDir = currentPos - lastPos
            if moveDir.Magnitude > 0.01 then
                local forwardVector = moveDir.Unit
                local upVector = targetPart.CFrame.UpVector
                local rightVector = forwardVector:Cross(upVector).Unit
                upVector = rightVector:Cross(forwardVector).Unit
                finalCFrame = CFrame.fromMatrix(currentPos, rightVector, upVector, -forwardVector)
            else
                finalCFrame = targetPart.CFrame
            end
        else
            finalCFrame = targetPart.CFrame
        end
        lastPos = currentPos
        createVisualBlock(finalCFrame)
        StatusLabel.Text = "Block Spawned!"
    end
end

local function undoLastBlock()
    if not activeFeatures then return end
    if #spawnedBlocks > 0 then
        local lastBlock = table.remove(spawnedBlocks, #spawnedBlocks)
        if lastBlock then lastBlock:Destroy() end
        if currentIndex > #spawnedBlocks then currentIndex = math.max(1, #spawnedBlocks) end
        lastPos = #spawnedBlocks > 0 and spawnedBlocks[#spawnedBlocks].Position or nil
        StatusLabel.Text = "Last Block Removed!"
    else
        StatusLabel.Text = "No blocks to undo!"
    end
end

local FloatStart
local function toggleStart()
    if not activeFeatures or #spawnedBlocks == 0 then return end
    isRunning = not isRunning
    if isRunning then
        StartToggleBtn.Text = "ON"
        StartToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        if FloatStart then FloatStart.Text = "Pause" end
        startingCFrame = nil
        currentTransitionTime = 0
    else
        StartToggleBtn.Text = "OFF"
        StartToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        if FloatStart then FloatStart.Text = "Start" end
    end
end

local function resetAll()
    if not activeFeatures then return end
    isRunning = false
    StartToggleBtn.Text = "OFF"
    StartToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    if FloatStart then FloatStart.Text = "Start" end
    currentIndex = 1
    lastPos = nil
    startingCFrame = nil
    currentTransitionTime = 0
    for _, block in ipairs(spawnedBlocks) do if block then block:Destroy() end end
    spawnedBlocks = {}
    StatusLabel.Text = "Reseted!"
end

FloatStart = createCircularFloat("Start", "Start", UDim2.new(1, -245, 1, -270), toggleStart)
local FloatSpawn = createCircularFloat("Spawn", "Spawn", UDim2.new(1, -220, 1, -195), spawnBlockAtPlayer)
local FloatUndo = createCircularFloat("Undo", "Undo", UDim2.new(1, -220, 1, -120), undoLastBlock)
local FloatReset = createCircularFloat("Reset", "Reset", UDim2.new(1, -125, 1, -345), resetAll)
FastSteerFloatBtn = createCircularFloat("Speed", "1", UDim2.new(1, -220, 1, -345), cycleSpeed)

StartToggleBtn.MouseButton1Click:Connect(toggleStart)
SpawnBtn.MouseButton1Click:Connect(spawnBlockAtPlayer)
UndoBtn.MouseButton1Click:Connect(undoLastBlock)
ResetBtn.MouseButton1Click:Connect(resetAll)

ActiveFeaturesBtn.MouseButton1Click:Connect(function()
    activeFeatures = not activeFeatures
    ActiveFeaturesBtn.Text = activeFeatures and "ON" or "OFF"
    ActiveFeaturesBtn.BackgroundColor3 = activeFeatures and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(220, 50, 50)
    if not activeFeatures and isRunning then toggleStart() end
end)

LockButtonToggle.MouseButton1Click:Connect(function()
    isLocked = not isLocked
    LockButtonToggle.Text = isLocked and "ON" or "OFF"
    LockButtonToggle.BackgroundColor3 = isLocked and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(220, 50, 50)
end)

SaveConfigBtn.MouseButton1Click:Connect(function()
    if #spawnedBlocks == 0 then StatusLabel.Text = "Spawn blocks first!"; return end
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local randomCode = "C_"
    local rng = Random.new()
    for i = 1, 13 do
        local randIndex = rng:NextInteger(1, #chars)
        randomCode = randomCode .. chars:sub(randIndex, randIndex)
    end
    local dataToSave = {}
    for _, block in ipairs(spawnedBlocks) do table.insert(dataToSave, {block.CFrame:GetComponents()}) end
    if writefile then writefile("ModifierConfigs/" .. randomCode .. ".json", HttpService:JSONEncode(dataToSave)) end
    if setclipboard then setclipboard(randomCode); StatusLabel.Text = "Saved & Copied!" else StatusLabel.Text = "Saved: " .. randomCode end
end)

UpdateConfigBtn.MouseButton1Click:Connect(function()
    if #spawnedBlocks == 0 then StatusLabel.Text = "Spawn blocks first!"; return end
    local codeToUpdate = LoadBox.Text:gsub("%s+", "")
    if codeToUpdate == "" then StatusLabel.Text = "Enter code to update!"; return end
    local fileName = "ModifierConfigs/" .. codeToUpdate .. ".json"
    if isfile and not isfile(fileName) then StatusLabel.Text = "Code file not found!"; return end
    local dataToSave = {}
    for _, block in ipairs(spawnedBlocks) do table.insert(dataToSave, {block.CFrame:GetComponents()}) end
    if writefile then writefile(fileName, HttpService:JSONEncode(dataToSave)); StatusLabel.Text = "Updated: " .. codeToUpdate end
end)

LoadConfigBtn.MouseButton1Click:Connect(function()
    local codeToLoad = LoadBox.Text:gsub("%s+", "")
    if codeToLoad == "" then StatusLabel.Text = "Enter code first!"; return end
    local fileName = "ModifierConfigs/" .. codeToLoad .. ".json"
    if readfile and pcall(readfile, fileName) then
        for _, block in ipairs(spawnedBlocks) do if block then block:Destroy() end end
        spawnedBlocks = {}
        isRunning = false
        StartToggleBtn.Text = "OFF"
        StartToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        if FloatStart then FloatStart.Text = "Start" end
        currentIndex = 1; lastPos = nil; startingCFrame = nil; currentTransitionTime = 0
        
        local success, decodedData = pcall(function() return HttpService:JSONDecode(readfile(fileName)) end)
        if success and type(decodedData) == "table" then
            for _, comps in ipairs(decodedData) do createVisualBlock(CFrame.new(table.unpack(comps))) end
            if #spawnedBlocks > 0 then lastPos = spawnedBlocks[#spawnedBlocks].Position end
            StatusLabel.Text = "Loaded Successfully!"
        else StatusLabel.Text = "Invalid Config Format!" end
    else StatusLabel.Text = "Code not found!" end
end)

-- Functional Destroy UI Button
DestroyBtn.MouseButton1Click:Connect(function()
    resetAll()
    ScreenGui:Destroy()
end)

-------------------------------------------------------------------------------
--! Key System Actions & Connections
-------------------------------------------------------------------------------
GetKeyBtn.MouseButton1Click:Connect(function()
    copyLink()
    KeyStatusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    KeyStatusLabel.Text = "Key link copied to clipboard!"
end)

VerifyBtn.MouseButton1Click:Connect(function()
    local userKey = KeyTextBox.Text:gsub("%s+", "")
    if userKey == "" then
        KeyStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        KeyStatusLabel.Text = "Please enter key first!"
        return
    end

    KeyStatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    KeyStatusLabel.Text = "Verifying..."

    task.spawn(function()
        local success = verifyKey(userKey)
        if success then
            KeyStatusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
            KeyStatusLabel.Text = "Key Verified! Loading..."
            task.wait(1)
            
            KeyFrame:Destroy()
            MainFrame.Visible = true
            MainFloatBtn.Visible = true
            for _, floatBtn in ipairs(createdFloatBtns) do
                floatBtn.Visible = true
            end
        else
            KeyStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            KeyStatusLabel.Text = keyStatusMessage ~= "" and keyStatusMessage or "Key Invalid!"
        end
    end)
end)

-------------------------------------------------------------------------------
--! Loop Heartbeat Teleport
-------------------------------------------------------------------------------
RunService.Heartbeat:Connect(function(dt)
    if not activeFeatures or not isRunning or #spawnedBlocks == 0 then return end
    local speedVal = getSpeedValue()
    local char = LocalPlayer.Character
    if not char then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local targetPart = (humanoid and humanoid.SeatPart) or rootPart
    
    if targetPart then
        if targetPart:IsA("BasePart") then
            targetPart.AssemblyLinearVelocity = Vector3.zero
            targetPart.AssemblyAngularVelocity = Vector3.zero
        end
        local targetBlock = spawnedBlocks[currentIndex]
        if targetBlock then
            local targetCFrame = targetBlock.CFrame
            if speedVal == 0 then
                targetPart.CFrame = targetCFrame
                currentIndex = currentIndex + 1
                if currentIndex > #spawnedBlocks then currentIndex = 1 end
                startingCFrame = nil
            else
                if not startingCFrame then
                    startingCFrame = targetPart.CFrame
                    currentTransitionTime = 0
                end
                currentTransitionTime = currentTransitionTime + dt
                local alpha = currentTransitionTime / speedVal
                if alpha >= 1 then
                    targetPart.CFrame = targetCFrame
                    currentIndex = currentIndex + 1
                    if currentIndex > #spawnedBlocks then currentIndex = 1 end
                    startingCFrame = nil
                else
                    targetPart.CFrame = startingCFrame:Lerp(targetCFrame, alpha)
                end
            end
        end
    end
end)