_G.HubVisualCarregada = false
_G.HubLogicaPronta = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Limpeza agressiva para evitar vazamento de memória (Anti-Lag)
if _G.SecureSpeedLoop then _G.SecureSpeedLoop = false task.wait(0.05) end
if _G.SecureRenderLoop then _G.SecureRenderLoop = false task.wait(0.05) end
if _G.MainHubInterface then _G.MainHubInterface:Destroy() task.wait(0.05) end

pcall(function() RunService:UnbindFromRenderStep("GodzESP_Render") end)
pcall(function() RunService:UnbindFromRenderStep("AimbotMobileLock") end)
pcall(function() RunService:UnbindFromRenderStep("GodzSpeed_Render") end)

-- PATCH DE CORREÇÃO: Limpeza dos eventos de Input
if _G.MainDragGlobal then pcall(function() _G.MainDragGlobal:Disconnect() end) _G.MainDragGlobal = nil end
if _G.NoclipGlobalDrag then pcall(function() _G.NoclipGlobalDrag:Disconnect() end) _G.NoclipGlobalDrag = nil end
if _G.FlyGlobalDrag then pcall(function() _G.FlyGlobalDrag:Disconnect() end) _G.FlyGlobalDrag = nil end

if _G.ViewCamConnection then pcall(function() _G.ViewCamConnection:Disconnect() end) _G.ViewCamConnection = nil end
if _G.FlyConnectionGodz then pcall(function() _G.FlyConnectionGodz:Disconnect() end) _G.FlyConnectionGodz = nil end
if _G.FlyPlatformGodz then pcall(function() _G.FlyPlatformGodz:Destroy() end) _G.FlyPlatformGodz = nil end
if _G.FlyRoundBtn then pcall(function() _G.FlyRoundBtn:Destroy() end) _G.FlyRoundBtn = nil end
if _G.NoclipRoundBtn then pcall(function() _G.NoclipRoundBtn:Destroy() end) _G.NoclipRoundBtn = nil end

pcall(function()
    Camera.CameraType = Enum.CameraType.Custom
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        Camera.CameraSubject = player.Character.Humanoid
    end
end)

for _, v in ipairs(game:GetService("CoreGui"):GetChildren()) do
    if v:IsA("ScreenGui") and v:FindFirstChildOfClass("Frame") and not v:FindFirstChild("titleFrame") then
        if #v:GetChildren() == 1 or v:FindFirstChild("EspPlayerGroup") then
            v:Destroy()
        end
    end
end

setgarbagecollection = setgarbagecollection or function() end
pcall(function() gcinfo() end)

local minimizado, paginaAtual = false, 2
_G.SecureRenderLoop = false
_G.SecureSpeedLoop = false
_G.CameraViewActive = false
_G.NoclipActiveGodz = false
_G.FlyActiveGodz = false
_G.FlyingStateGodz = false

_G.AimbotActiveGodz = false
_G.AimTargetPart = "Head" 
_G.AimFovValue = 100
_G.AimTeamCheck = false
_G.AimKillCheck = false
_G.AimWallCheck = false

_G.SpeedBypassValue = 50 
_G.EspBoxTrack = true
_G.EspSkeletonTrack = true
_G.EspNameTrack = true
_G.EspHealthTrack = true

local atualizarInterface
local resetarCoresAbas

local function getRandomName()
    local str = ""
    for i = 1, math.random(8, 12) do
        str = str .. string.char(math.random(97, 122))
    end
    return str
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = getRandomName()
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui
_G.MainHubInterface = screenGui

if syn and syn.protect_gui then syn.protect_gui(screenGui) end

local EspContainer = Instance.new("ScreenGui")
EspContainer.Name = getRandomName()
EspContainer.ResetOnSpawn = false
EspContainer.IgnoreGuiInset = true
EspContainer.Parent = CoreGui

if syn and syn.protect_gui then syn.protect_gui(EspContainer) end

local fovCircle = Instance.new("Frame")
fovCircle.Name = "FOVCircle"
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.Size = UDim2.new(0, _G.AimFovValue, 0, _G.AimFovValue)
fovCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false 
fovCircle.Parent = EspContainer

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Color3.fromRGB(255, 255, 255)
fovStroke.Thickness = 1.5
fovStroke.Parent = fovCircle

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovCircle

local aimTracer = Instance.new("Frame")
aimTracer.Name = "AimTracer"
aimTracer.AnchorPoint = Vector2.new(0.5, 0.5)
aimTracer.BorderSizePixel = 0
aimTracer.Visible = false
aimTracer.Parent = EspContainer

_G.MainFrameGodz = Instance.new("Frame")
_G.MainFrameGodz.Size = UDim2.new(0, 260, 0, 240)
_G.MainFrameGodz.Position = UDim2.new(0.05, 0, 0.4, 0)
_G.MainFrameGodz.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
_G.MainFrameGodz.BorderSizePixel = 0
_G.MainFrameGodz.Active = true
_G.MainFrameGodz.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = _G.MainFrameGodz

local dragging, dragInput, dragStart, startPos
local titleFrame = Instance.new("Frame")
titleFrame.Size = UDim2.new(1, 0, 0, 30)
titleFrame.BackgroundTransparency = 1
titleFrame.Parent = _G.MainFrameGodz

titleFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = _G.MainFrameGodz.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

titleFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)

_G.MainDragGlobal = UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        _G.MainFrameGodz.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
titleLabel.Position = UDim2.new(0.05, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Godz.NK painel - SINTONIA RP"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.Code
titleLabel.TextSize = 13
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleFrame

_G.BtnMinimizarGodz = Instance.new("TextButton")
_G.BtnMinimizarGodz.Size = UDim2.new(0, 24, 0, 24)
_G.BtnMinimizarGodz.Position = UDim2.new(1, -29, 0, 3)
_G.BtnMinimizarGodz.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
_G.BtnMinimizarGodz.Text = "−"
_G.BtnMinimizarGodz.TextColor3 = Color3.fromRGB(200, 200, 200)
_G.BtnMinimizarGodz.Font = Enum.Font.Code
_G.BtnMinimizarGodz.TextSize = 14
_G.BtnMinimizarGodz.BorderSizePixel = 0
_G.BtnMinimizarGodz.Parent = titleFrame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = _G.BtnMinimizarGodz

_G.ContainerFrameGodz = Instance.new("Frame")
_G.ContainerFrameGodz.Size = UDim2.new(1, 0, 1, -30)
_G.ContainerFrameGodz.Position = UDim2.new(0, 0, 0, 30)
_G.ContainerFrameGodz.BackgroundTransparency = 1
_G.ContainerFrameGodz.Parent = _G.MainFrameGodz

_G.HubVisualCarregada = true

local tabsScroll = Instance.new("ScrollingFrame")
tabsScroll.Size = UDim2.new(0.9, 0, 0, 30)
tabsScroll.Position = UDim2.new(0.05, 0, 0, 0)
tabsScroll.BackgroundTransparency = 1
tabsScroll.BorderSizePixel = 0
tabsScroll.CanvasSize = UDim2.new(3.2, 0, 0, 0) -- Tamanho aumentado para comportar a 9ª aba
tabsScroll.ScrollBarThickness = 0
tabsScroll.ScrollingDirection = Enum.ScrollingDirection.X
tabsScroll.Parent = _G.ContainerFrameGodz

local tabsLayout = Instance.new("UIListLayout")
tabsLayout.FillDirection = Enum.FillDirection.Horizontal
tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabsLayout.Padding = UDim.new(0, 6)
tabsLayout.Parent = tabsScroll

local function criarBotaoAba(texto, order, tamanhoX)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, tamanhoX or 55, 1, -4)
    btn.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
    btn.Text = texto
    btn.TextColor3 = Color3.fromRGB(160, 160, 170)
    btn.Font = Enum.Font.Code
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.LayoutOrder = order
    btn.Parent = tabsScroll
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    return btn
end

_G.BtnAba1Godz = criarBotaoAba("MAIN", 1, 50)
_G.BtnAba2Godz = criarBotaoAba("ESP", 2, 50)
_G.BtnAba3Godz = criarBotaoAba("TP", 3, 45)
_G.BtnAba4Godz = criarBotaoAba("CLASS", 4, 55)
_G.BtnAba5Godz = criarBotaoAba("VIEW", 5, 45)
_G.BtnAba6Godz = criarBotaoAba("NOCLIP", 6, 55)
_G.BtnAba7Godz = criarBotaoAba("AIM", 7, 45)
_G.BtnAba8Godz = criarBotaoAba("FLY", 8, 45) 
_G.BtnAba9Godz = criarBotaoAba("TP PLY", 9, 55) -- NOVA ABA ADICIONADA AQUI

_G.StatusLabelGodz = Instance.new("TextLabel")
_G.StatusLabelGodz.Size = UDim2.new(0.9, 0, 0, 25)
_G.StatusLabelGodz.Position = UDim2.new(0.05, 0, 0, 32)
_G.StatusLabelGodz.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
_G.StatusLabelGodz.Text = "Status: Iniciando..."
_G.StatusLabelGodz.TextColor3 = Color3.fromRGB(180, 180, 190)
_G.StatusLabelGodz.Font = Enum.Font.Code
_G.StatusLabelGodz.TextSize = 12
_G.StatusLabelGodz.Parent = _G.ContainerFrameGodz

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = _G.StatusLabelGodz

_G.ContentFrameGodz = Instance.new("Frame")
_G.ContentFrameGodz.Size = UDim2.new(0.9, 0, 1, -65)
_G.ContentFrameGodz.Position = UDim2.new(0.05, 0, 0, 62)
_G.ContentFrameGodz.BackgroundTransparency = 1
_G.ContentFrameGodz.Parent = _G.ContainerFrameGodz

_G.EspScrollFrameGodz = Instance.new("ScrollingFrame")
_G.EspScrollFrameGodz.Size = UDim2.new(1, 0, 1, -5)
_G.EspScrollFrameGodz.BackgroundTransparency = 1
_G.EspScrollFrameGodz.BorderSizePixel = 0
_G.EspScrollFrameGodz.CanvasSize = UDim2.new(0, 0, 1.8, 0)
_G.EspScrollFrameGodz.ScrollBarThickness = 2
_G.EspScrollFrameGodz.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
_G.EspScrollFrameGodz.Visible = false
_G.EspScrollFrameGodz.Parent = _G.ContentFrameGodz

local espLayout = Instance.new("UIListLayout")
espLayout.FillDirection = Enum.FillDirection.Vertical
espLayout.SortOrder = Enum.SortOrder.LayoutOrder
espLayout.Padding = UDim.new(0, 6)
espLayout.Parent = _G.EspScrollFrameGodz

_G.TpScrollFrameGodz = Instance.new("ScrollingFrame")
_G.TpScrollFrameGodz.Size = UDim2.new(1, 0, 1, -5)
_G.TpScrollFrameGodz.BackgroundTransparency = 1
_G.TpScrollFrameGodz.BorderSizePixel = 0
_G.TpScrollFrameGodz.CanvasSize = UDim2.new(0, 0, 1.0, 0)
_G.TpScrollFrameGodz.ScrollBarThickness = 0
_G.TpScrollFrameGodz.Visible = false
_G.TpScrollFrameGodz.Parent = _G.ContentFrameGodz

local pLayout = Instance.new("UIListLayout")
pLayout.FillDirection = Enum.FillDirection.Vertical
pLayout.SortOrder = Enum.SortOrder.LayoutOrder
pLayout.Padding = UDim.new(0, 8)
pLayout.Parent = _G.TpScrollFrameGodz

_G.ClassScrollFrameGodz = Instance.new("ScrollingFrame")
_G.ClassScrollFrameGodz.Size = UDim2.new(1, 0, 1, -5)
_G.ClassScrollFrameGodz.BackgroundTransparency = 1
_G.ClassScrollFrameGodz.BorderSizePixel = 0
_G.ClassScrollFrameGodz.CanvasSize = UDim2.new(0, 0, 2.2, 0)
_G.ClassScrollFrameGodz.ScrollBarThickness = 3
_G.ClassScrollFrameGodz.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
_G.ClassScrollFrameGodz.ScrollingDirection = Enum.ScrollingDirection.Y
_G.ClassScrollFrameGodz.Visible = false
_G.ClassScrollFrameGodz.Parent = _G.ContentFrameGodz

local classLayout = Instance.new("UIListLayout")
classLayout.FillDirection = Enum.FillDirection.Vertical
classLayout.SortOrder = Enum.SortOrder.LayoutOrder
classLayout.Padding = UDim.new(0, 6)
classLayout.Parent = _G.ClassScrollFrameGodz

_G.ViewScrollFrameGodz = Instance.new("ScrollingFrame")
_G.ViewScrollFrameGodz.Size = UDim2.new(1, 0, 1, -5)
_G.ViewScrollFrameGodz.BackgroundTransparency = 1
_G.ViewScrollFrameGodz.BorderSizePixel = 0
_G.ViewScrollFrameGodz.CanvasSize = UDim2.new(0, 0, 1.2, 0)
_G.ViewScrollFrameGodz.ScrollBarThickness = 0
_G.ViewScrollFrameGodz.Visible = false
_G.ViewScrollFrameGodz.Parent = _G.ContentFrameGodz

local viewLayout = Instance.new("UIListLayout")
viewLayout.FillDirection = Enum.FillDirection.Vertical
viewLayout.SortOrder = Enum.SortOrder.LayoutOrder
viewLayout.Padding = UDim.new(0, 8)
viewLayout.Parent = _G.ViewScrollFrameGodz

_G.NoclipScrollFrameGodz = Instance.new("ScrollingFrame")
_G.NoclipScrollFrameGodz.Size = UDim2.new(1, 0, 1, -5)
_G.NoclipScrollFrameGodz.BackgroundTransparency = 1
_G.NoclipScrollFrameGodz.BorderSizePixel = 0
_G.NoclipScrollFrameGodz.CanvasSize = UDim2.new(0, 0, 1.0, 0)
_G.NoclipScrollFrameGodz.ScrollBarThickness = 0
_G.NoclipScrollFrameGodz.Visible = false
_G.NoclipScrollFrameGodz.Parent = _G.ContentFrameGodz

local noclipLayout = Instance.new("UIListLayout")
noclipLayout.FillDirection = Enum.FillDirection.Vertical
noclipLayout.SortOrder = Enum.SortOrder.LayoutOrder
noclipLayout.Padding = UDim.new(0, 8)
noclipLayout.Parent = _G.NoclipScrollFrameGodz

_G.AimScrollFrameGodz = Instance.new("ScrollingFrame")
_G.AimScrollFrameGodz.Size = UDim2.new(1, 0, 1, -5)
_G.AimScrollFrameGodz.BackgroundTransparency = 1
_G.AimScrollFrameGodz.BorderSizePixel = 0
_G.AimScrollFrameGodz.CanvasSize = UDim2.new(0, 0, 2.2, 0) 
_G.AimScrollFrameGodz.ScrollBarThickness = 2
_G.AimScrollFrameGodz.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
_G.AimScrollFrameGodz.Visible = false
_G.AimScrollFrameGodz.Parent = _G.ContentFrameGodz

local aimLayout = Instance.new("UIListLayout")
aimLayout.FillDirection = Enum.FillDirection.Vertical
aimLayout.SortOrder = Enum.SortOrder.LayoutOrder
aimLayout.Padding = UDim.new(0, 6)
aimLayout.Parent = _G.AimScrollFrameGodz

_G.FlyScrollFrameGodz = Instance.new("ScrollingFrame")
_G.FlyScrollFrameGodz.Size = UDim2.new(1, 0, 1, -5)
_G.FlyScrollFrameGodz.BackgroundTransparency = 1
_G.FlyScrollFrameGodz.BorderSizePixel = 0
_G.FlyScrollFrameGodz.CanvasSize = UDim2.new(0, 0, 1.0, 0)
_G.FlyScrollFrameGodz.ScrollBarThickness = 0
_G.FlyScrollFrameGodz.Visible = false
_G.FlyScrollFrameGodz.Parent = _G.ContentFrameGodz

local flyLayout = Instance.new("UIListLayout")
flyLayout.FillDirection = Enum.FillDirection.Vertical
flyLayout.SortOrder = Enum.SortOrder.LayoutOrder
flyLayout.Padding = UDim.new(0, 8)
flyLayout.Parent = _G.FlyScrollFrameGodz

-- SCROLL DA NOVA ABA 9 (TP PLY)
_G.TpPlyScrollFrameGodz = Instance.new("ScrollingFrame")
_G.TpPlyScrollFrameGodz.Size = UDim2.new(1, 0, 1, -5)
_G.TpPlyScrollFrameGodz.BackgroundTransparency = 1
_G.TpPlyScrollFrameGodz.BorderSizePixel = 0
_G.TpPlyScrollFrameGodz.CanvasSize = UDim2.new(0, 0, 1.2, 0)
_G.TpPlyScrollFrameGodz.ScrollBarThickness = 0
_G.TpPlyScrollFrameGodz.Visible = false
_G.TpPlyScrollFrameGodz.Parent = _G.ContentFrameGodz

local tpPlyLayout = Instance.new("UIListLayout")
tpPlyLayout.FillDirection = Enum.FillDirection.Vertical
tpPlyLayout.SortOrder = Enum.SortOrder.LayoutOrder
tpPlyLayout.Padding = UDim.new(0, 8)
tpPlyLayout.Parent = _G.TpPlyScrollFrameGodz

local function criarBotaoAcao(nome, texto, cor, pai)
    local btn = Instance.new("TextButton")
    btn.Name = nome; btn.Size = UDim2.new(1, 0, 0, 26); btn.BackgroundColor3 = cor
    btn.Text = texto; btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Code; btn.TextSize = 12; btn.BorderSizePixel = 0
    btn.Parent = pai
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6); btnCorner.Parent = btn
    return btn
end

local SpeedTextBox = Instance.new("TextBox")
SpeedTextBox.Name = getRandomName()
SpeedTextBox.Size = UDim2.new(1, 0, 0, 32)
SpeedTextBox.Position = UDim2.new(0, 0, 0, 0)
SpeedTextBox.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
SpeedTextBox.BorderSizePixel = 0
SpeedTextBox.Text = "50"
SpeedTextBox.PlaceholderText = "Definir Velocidade (Max 60)..."
SpeedTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedTextBox.TextSize = 12
SpeedTextBox.Font = Enum.Font.Code
SpeedTextBox.Parent = _G.ContentFrameGodz

local stc = Instance.new("UICorner")
stc.CornerRadius = UDim.new(0, 6)
stc.Parent = SpeedTextBox

_G.BtnToggleSpeedGodz = criarBotaoAcao("BtnToggleSpeed", "SPEED AMORTECIDO: DESATIVADO", Color3.fromRGB(231, 76, 60), _G.ContentFrameGodz)
_G.BtnToggleSpeedGodz.Position = UDim2.new(0, 0, 0, 38)

_G.BtnToggleESPGodz = criarBotaoAcao("BtnToggleESP", "LIGAR ESP MASTER: DESATIVADO", Color3.fromRGB(231, 76, 60), _G.EspScrollFrameGodz)
_G.BtnToggleBoxGodz = criarBotaoAcao("BtnToggleBox", "ESP QUADRO 2D: ATIVADO", Color3.fromRGB(46, 204, 113), _G.EspScrollFrameGodz)
_G.BtnToggleSkeletonGodz = criarBotaoAcao("BtnToggleSkeleton", "ESP SKELETO + HEAD: ATIVADO", Color3.fromRGB(46, 204, 113), _G.EspScrollFrameGodz)
_G.BtnToggleNameGodz = criarBotaoAcao("BtnToggleName", "ESP NOME DO PLAYER: ATIVADO", Color3.fromRGB(46, 204, 113), _G.EspScrollFrameGodz)
_G.BtnToggleHealthGodz = criarBotaoAcao("BtnToggleHealth", "ESP BARRA DE VIDA: ATIVADO", Color3.fromRGB(46, 204, 113), _G.EspScrollFrameGodz)

_G.BtnTpGaragem = criarBotaoAcao("BtnTpGaragem", "TELEPORTAR P/ GARAGEM", Color3.fromRGB(230, 126, 34), _G.TpScrollFrameGodz)

_G.BtnClassGcm = criarBotaoAcao("BtnClassGcm", "VIRAR GCM", Color3.fromRGB(41, 128, 185), _G.ClassScrollFrameGodz)
_G.BtnClassCaminhoneiro = criarBotaoAcao("BtnClassCaminhoneiro", "VIRAR CAMINHONEIRO", Color3.fromRGB(39, 174, 96), _G.ClassScrollFrameGodz)
_G.BtnClassCivil = criarBotaoAcao("BtnClassCivil", "VIRAR CIVIL", Color3.fromRGB(142, 68, 173), _G.ClassScrollFrameGodz)
_G.BtnClassLixeiro = criarBotaoAcao("BtnClassLixeiro", "VIRAR LIXEIRO", Color3.fromRGB(241, 196, 15), _G.ClassScrollFrameGodz)
_G.BtnClassFood = criarBotaoAcao("BtnClassFood", "VIRAR SINTONIA FOOD", Color3.fromRGB(211, 84, 0), _G.ClassScrollFrameGodz)

local ViewTextBox = Instance.new("TextBox")
ViewTextBox.Size = UDim2.new(1, 0, 0, 32)
ViewTextBox.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
ViewTextBox.BorderSizePixel = 0
ViewTextBox.Text = ""
ViewTextBox.PlaceholderText = "Nome ou Display do Alvo..."
ViewTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
ViewTextBox.TextSize = 12
ViewTextBox.Font = Enum.Font.Code
ViewTextBox.Parent = _G.ViewScrollFrameGodz

local vtc = Instance.new("UICorner")
vtc.CornerRadius = UDim.new(0, 6)
vtc.Parent = ViewTextBox

_G.BtnToggleViewGodz = criarBotaoAcao("BtnToggleView", "ASSISTIR JOGADOR", Color3.fromRGB(180, 40, 40), _G.ViewScrollFrameGodz)
_G.BtnToggleNoclipGodz = criarBotaoAcao("BtnToggleNoclip", "BOTÃO FLUTUANTE NOCLIP: OFF", Color3.fromRGB(231, 76, 60), _G.NoclipScrollFrameGodz)

_G.BtnToggleAimGodz = criarBotaoAcao("BtnToggleAim", "SISTEMA AIMBOT: OFF", Color3.fromRGB(231, 76, 60), _G.AimScrollFrameGodz)
_G.BtnToggleAimPartGodz = criarBotaoAcao("BtnToggleAimPart", "MIRA FOCADA: CABEÇA", Color3.fromRGB(155, 89, 182), _G.AimScrollFrameGodz) 

local AimFovTextBox = Instance.new("TextBox")
AimFovTextBox.Size = UDim2.new(1, 0, 0, 32)
AimFovTextBox.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
AimFovTextBox.BorderSizePixel = 0
AimFovTextBox.Text = "100"
AimFovTextBox.PlaceholderText = "Definir Área do FOV (Padrão 100)..."
AimFovTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
AimFovTextBox.TextSize = 12
AimFovTextBox.Font = Enum.Font.Code
AimFovTextBox.Parent = _G.AimScrollFrameGodz

local afc = Instance.new("UICorner")
afc.CornerRadius = UDim.new(0, 6)
afc.Parent = AimFovTextBox

_G.BtnToggleAimTeamGodz = criarBotaoAcao("BtnToggleAimTeam", "TEAM CHECK: OFF", Color3.fromRGB(231, 76, 60), _G.AimScrollFrameGodz)
_G.BtnToggleAimKillGodz = criarBotaoAcao("BtnToggleAimKill", "KILL CHECK: OFF", Color3.fromRGB(231, 76, 60), _G.AimScrollFrameGodz)
_G.BtnToggleAimWallGodz = criarBotaoAcao("BtnToggleAimWall", "WALL CHECK: OFF", Color3.fromRGB(231, 76, 60), _G.AimScrollFrameGodz)

_G.BtnToggleFlyGodz = criarBotaoAcao("BtnToggleFly", "BOTÃO FLUTUANTE FLY: OFF", Color3.fromRGB(231, 76, 60), _G.FlyScrollFrameGodz)

-- UI DA ABA 9 (TP PLY)
local TpPlayerTextBox = Instance.new("TextBox")
TpPlayerTextBox.Size = UDim2.new(1, 0, 0, 32)
TpPlayerTextBox.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
TpPlayerTextBox.BorderSizePixel = 0
TpPlayerTextBox.Text = ""
TpPlayerTextBox.PlaceholderText = "Nome do Alvo..."
TpPlayerTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TpPlayerTextBox.TextSize = 12
TpPlayerTextBox.Font = Enum.Font.Code
TpPlayerTextBox.Parent = _G.TpPlyScrollFrameGodz

local tptc = Instance.new("UICorner")
tptc.CornerRadius = UDim.new(0, 6)
tptc.Parent = TpPlayerTextBox

_G.BtnTpPlayerGodz = criarBotaoAcao("BtnTpPlayer", "TELEPORTAR (Freeze)", Color3.fromRGB(39, 174, 96), _G.TpPlyScrollFrameGodz)

_G.HubLogicaPronta = true

local cacheESP = {}

local function removerESP(anyPlayerName)
    if cacheESP[anyPlayerName] then
        if cacheESP[anyPlayerName].Group then
            pcall(function() cacheESP[anyPlayerName].Group:Destroy() end)
        end
        cacheESP[anyPlayerName] = nil
    end
end

local function clearAllESP()
    for playerName, _ in pairs(cacheESP) do
        removerESP(playerName)
    end
end

local function criarLine(parent)
    local line = Instance.new("Frame")
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BorderSizePixel = 0
    line.Visible = false
    line.Parent = parent
    return line
end

local function atualizarLineFrame(frame, p1, p2, corDinamica)
    local dist = (p1 - p2).Magnitude
    frame.Size = UDim2.new(0, dist, 0, 2)
    frame.Position = UDim2.new(0, (p1.X + p2.X) / 2, 0, (p1.Y + p2.Y) / 2)
    frame.Rotation = math.deg(math.atan2(p2.Y - p1.Y, p2.X - p1.X))
    frame.BackgroundColor3 = corDinamica
    frame.Visible = true
end

local function criarVinculoESP(p)
    if p == player then return end
    removerESP(p.Name)
    
    local playerGroup = Instance.new("Frame")
    playerGroup.Name = "EspPlayerGroup"
    playerGroup.Size = UDim2.new(1, 0, 1, 0)
    playerGroup.BackgroundTransparency = 1
    playerGroup.Visible = false
    playerGroup.Parent = EspContainer
    
    local boxFrame = Instance.new("Frame")
    boxFrame.BackgroundTransparency = 1
    boxFrame.BorderSizePixel = 0
    boxFrame.Parent = playerGroup
    
    local boxStroke = Instance.new("UIStroke")
    boxStroke.Thickness = 1.5
    boxStroke.LineJoinMode = Enum.LineJoinMode.Miter
    boxStroke.Color = Color3.fromRGB(0, 255, 0)
    boxStroke.Parent = boxFrame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 11
    textLabel.Font = Enum.Font.Code
    textLabel.TextStrokeTransparency = 0.3
    textLabel.TextXAlignment = Enum.TextXAlignment.Center
    textLabel.Text = p.DisplayName or p.Name
    textLabel.Parent = playerGroup
    
    local circleFrame = Instance.new("Frame")
    circleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    circleFrame.BackgroundTransparency = 1
    circleFrame.BorderSizePixel = 0
    circleFrame.Parent = playerGroup
    
    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(1, 0)
    cc.Parent = circleFrame
    
    local circleStroke = Instance.new("UIStroke")
    circleStroke.Thickness = 1.5
    circleStroke.Color = Color3.fromRGB(0, 255, 0)
    circleStroke.Parent = circleFrame
    
    local healthBG = Instance.new("Frame")
    healthBG.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    healthBG.BorderSizePixel = 0
    healthBG.Size = UDim2.new(0, 100, 0, 4)
    healthBG.Parent = playerGroup
    
    local healthFill = Instance.new("Frame")
    healthFill.BorderSizePixel = 0
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.Parent = healthBG
    
    local healthLabel = Instance.new("TextLabel")
    healthLabel.BackgroundTransparency = 1
    healthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    healthLabel.TextSize = 10
    healthLabel.Font = Enum.Font.Code
    healthLabel.TextStrokeTransparency = 0.3
    healthLabel.TextXAlignment = Enum.TextXAlignment.Center
    healthLabel.Parent = playerGroup
    
    local skeleton = {
        H_T  = criarLine(playerGroup),
        T_LA = criarLine(playerGroup),
        T_RA = criarLine(playerGroup),
        T_LL = criarLine(playerGroup),
        T_RL = criarLine(playerGroup)
    }
    
    local centerLineObj = criarLine(playerGroup)
    
    cacheESP[p.Name] = {
        Group = playerGroup,
        Box = boxFrame,
        BoxStroke = boxStroke,
        Circle = circleFrame,
        CircleStroke = circleStroke,
        NameTag = textLabel,
        HealthBG = healthBG,
        HealthFill = healthFill,
        HealthLabel = healthLabel,
        Skeleton = skeleton,
        CenterLine = centerLineObj, 
        PlayerObj = p
    }
end

Players.PlayerAdded:Connect(function(p)
    criarVinculoESP(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.2)
        if _G.SecureRenderLoop then criarVinculoESP(p) end
    end)
end)

Players.PlayerRemoving:Connect(removerESP)

for _, p in ipairs(Players:GetPlayers()) do 
    criarVinculoESP(p) 
    p.CharacterAdded:Connect(function()
        task.wait(0.2)
        if _G.SecureRenderLoop then criarVinculoESP(p) end
    end)
end

local parametrosRay = RaycastParams.new()
parametrosRay.FilterType = Enum.RaycastFilterType.Exclude

RunService.Heartbeat:Connect(function()
    if not _G.SecureRenderLoop then
        for _, data in pairs(cacheESP) do
            if data.Group and data.Group.Visible then data.Group.Visible = false end
        end
        return
    end
    
    local charMeu = player.Character
    if not charMeu then return end
    
    local origemRay = Camera.CFrame.Position
    parametrosRay.FilterDescendantsInstances = {charMeu, Workspace:FindFirstChild("CarrosSpawnados")}
    
    for _, data in pairs(cacheESP) do
        local p = data.PlayerObj
        local char = p and p.Character
        if char and char.Parent then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            local hum = char:FindFirstChildOfClass("Humanoid")
            
            if hrp and head and hum then
                local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local topPos = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3.3, 0))
                    local bottomPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 4.3, 0))
                    local headPos = Camera:WorldToViewportPoint(head.Position)
                    
                    local resultadoRay = Workspace:Raycast(origemRay, head.Position - origemRay, parametrosRay)
                    local estaVisivel = (resultadoRay == nil or resultadoRay.Instance:IsDescendantOf(char))
                    
                    local corAtual = estaVisivel and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                    local boxSizeY = math.abs(topPos.Y - bottomPos.Y)
                    local boxSizeX = boxSizeY * 0.55
                    
                    local meuHrp = charMeu:FindFirstChild("HumanoidRootPart")
                    if meuHrp then
                        if (meuHrp.Position - hrp.Position).Magnitude <= 20 then
                            atualizarLineFrame(data.CenterLine, Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2), Vector2.new(headPos.X, headPos.Y), corAtual)
                        else
                            data.CenterLine.Visible = false
                        end
                    else
                        data.CenterLine.Visible = false
                    end
                    
                    if _G.EspBoxTrack then
                        data.Box.Size = UDim2.new(0, boxSizeX, 0, boxSizeY)
                        data.Box.Position = UDim2.new(0, topPos.X - (boxSizeX / 2), 0, topPos.Y)
                        data.BoxStroke.Color = corAtual
                        data.Box.Visible = true
                    else
                        data.Box.Visible = false
                    end
                    
                    if _G.EspNameTrack then
                        data.NameTag.Text = hum.Health <= 0 and (p.DisplayName or p.Name) .. " [MORTO]" or p.DisplayName or p.Name
                        data.NameTag.Position = UDim2.new(0, topPos.X - 100, 0, topPos.Y - 16)
                        data.NameTag.Size = UDim2.new(0, 200, 0, 15)
                        data.NameTag.Visible = true
                        data.NameTag.TextColor3 = corAtual
                    else
                        data.NameTag.Visible = false
                    end
                    
                    if _G.EspSkeletonTrack then
                        local circleSize = boxSizeY * 0.25 
                        data.Circle.Size = UDim2.new(0, circleSize, 0, circleSize)
                        data.Circle.Position = UDim2.new(0, headPos.X, 0, headPos.Y)
                        data.CircleStroke.Color = corAtual
                        data.Circle.Visible = true
                    else
                        data.Circle.Visible = false
                    end
                    
                    if _G.EspHealthTrack then
                        data.HealthBG.Size = UDim2.new(0, boxSizeX, 0, 4)
                        data.HealthBG.Position = UDim2.new(0, topPos.X - (boxSizeX / 2), 0, bottomPos.Y + 5)
                        data.HealthBG.Visible = true
                        
                        local maxHealth = hum.MaxHealth > 0 and hum.MaxHealth or 100
                        local vidaPct = (hum.Health / maxHealth) * 100
                        data.HealthFill.Size = UDim2.new(math.clamp(hum.Health / maxHealth, 0, 1), 0, 1, 0)
                        
                        if vidaPct > 70 then data.HealthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                        elseif vidaPct < 20 then data.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                        elseif vidaPct < 40 then data.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 235, 0)
                        else data.HealthFill.BackgroundColor3 = Color3.fromRGB(230, 126, 34) end
                        
                        data.HealthLabel.Text = math.floor(hum.Health) .. " / " .. math.floor(maxHealth)
                        data.HealthLabel.Position = UDim2.new(0, topPos.X - 100, 0, bottomPos.Y + 11)
                        data.HealthLabel.Size = UDim2.new(0, 200, 0, 12)
                        data.HealthLabel.Visible = true
                    else
                        data.HealthBG.Visible = false
                        data.HealthLabel.Visible = false
                    end
                    
                    if _G.EspSkeletonTrack and hum.Health > 0 then
                        local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or hrp
                        local lArm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm")
                        local rArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
                        local lLeg = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg")
                        local rLeg = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Arm")
                        
                        local function getScreenV2(part)
                            if part then
                                local pos2d, on = Camera:WorldToViewportPoint(part.Position)
                                if on then return Vector2.new(pos2d.X, pos2d.Y) end
                            end
                            return nil
                        end
                        
                        local scrTorso = getScreenV2(torso)
                        local scrLArm = getScreenV2(lArm)
                        local scrRArm = getScreenV2(rArm)
                        local scrLLeg = getScreenV2(lLeg)
                        local scrRLeg = getScreenV2(rLeg)
                        
                        if headPos and scrTorso then atualizarLineFrame(data.Skeleton.H_T, Vector2.new(headPos.X, headPos.Y), scrTorso, corAtual) else data.Skeleton.H_T.Visible = false end
                        if scrTorso and scrLArm then atualizarLineFrame(data.Skeleton.T_LA, scrTorso, scrLArm, corAtual) else data.Skeleton.T_LA.Visible = false end
                        if scrTorso and scrRArm then atualizarLineFrame(data.Skeleton.T_RA, scrTorso, scrRArm, corAtual) else data.Skeleton.T_RA.Visible = false end
                        if scrTorso and scrLLeg then atualizarLineFrame(data.Skeleton.T_LL, scrTorso, scrLLeg, corAtual) else data.Skeleton.T_LL.Visible = false end
                        if scrTorso and scrRLeg then atualizarLineFrame(data.Skeleton.T_RL, scrTorso, scrRLeg, corAtual) else data.Skeleton.T_RL.Visible = false end
                    else
                        data.Skeleton.H_T.Visible = false
                        data.Skeleton.T_LA.Visible = false
                        data.Skeleton.T_RA.Visible = false
                        data.Skeleton.T_LL.Visible = false
                        data.Skeleton.T_RL.Visible = false
                    end
                    data.Group.Visible = true
                else
                    data.Group.Visible = false
                    data.CenterLine.Visible = false
                end
            else
                data.Group.Visible = false
                data.CenterLine.Visible = false
            end
        else
            if data.Group then data.Group.Visible = false end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(2)
        if _G.SecureRenderLoop then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and (not cacheESP[p.Name] or not cacheESP[p.Name].Group or not cacheESP[p.Name].Group.Parent) then 
                    criarVinculoESP(p) 
                end
            end
        end
    end
end)

local function buscarJogador(texto)
    texto = texto:lower()
    for _, j in ipairs(Players:GetPlayers()) do
        if j ~= player and (string.find(j.Name:lower(), texto) or string.find(j.DisplayName:lower(), texto)) then
            return j
        end
    end
end

_G.BtnToggleViewGodz.MouseButton1Click:Connect(function()
    _G.CameraViewActive = not _G.CameraViewActive
    _G.BtnToggleViewGodz.Text = _G.CameraViewActive and "ESPIANDO..." or "ASSISTIR JOGADOR"
    _G.BtnToggleViewGodz.BackgroundColor3 = _G.CameraViewActive and Color3.fromRGB(40, 180, 40) or Color3.fromRGB(180, 40, 40)
    
    if not _G.CameraViewActive then
        Camera.CameraType = Enum.CameraType.Custom
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = player.Character.Humanoid
        end
    end
    if paginaAtual == 5 then
        _G.StatusLabelGodz.Text = _G.CameraViewActive and "Espiando Alvo..." or "Aba de Monitoramento"
        _G.StatusLabelGodz.TextColor3 = _G.CameraViewActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(255, 255, 255)
    end
end)

_G.ViewCamConnection = RunService.Heartbeat:Connect(function()
    if _G.CameraViewActive then
        local Alvo = buscarJogador(ViewTextBox.Text)
        if Alvo and Alvo.Character and Alvo.Character:FindFirstChild("HumanoidRootPart") then
            Camera.CameraType = Enum.CameraType.Scriptable
            local alvoPos = Alvo.Character.HumanoidRootPart.Position
            Camera.CFrame = CFrame.new(alvoPos + Vector3.new(0, 20, 0.1), alvoPos)
        else
            _G.BtnToggleViewGodz.Text = "ALVO PERDIDO / CAÍDO"
            _G.BtnToggleViewGodz.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
            _G.CameraViewActive = false
            Camera.CameraType = Enum.CameraType.Custom
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                Camera.CameraSubject = player.Character.Humanoid
            end
            if paginaAtual == 5 then
                _G.StatusLabelGodz.Text = "Alvo perdido ou offline"
                _G.StatusLabelGodz.TextColor3 = Color3.fromRGB(231, 76, 60)
            end
        end
    end
end)

local function alternarBotaoFlutuanteNoclip(ligar)
    if ligar then
        if _G.NoclipRoundBtn then pcall(function() _G.NoclipRoundBtn:Destroy() end) end
        local roundBtn = Instance.new("TextButton")
        roundBtn.Size = UDim2.new(0, 50, 0, 50)
        roundBtn.Position = UDim2.new(0.1, 0, 0.5, 0)
        roundBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        roundBtn.Text = "👻"
        roundBtn.TextSize = 24
        roundBtn.Font = Enum.Font.Code
        roundBtn.Active = true
        roundBtn.Parent = screenGui
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(1, 0)
        btnCorner.Parent = roundBtn
        
        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = Color3.fromRGB(0, 255, 120)
        btnStroke.Thickness = 2
        btnStroke.Parent = roundBtn
        
        local nDrag, nDragInput, nDragStart, nStartPos
        roundBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                nDrag = true
                nDragStart = input.Position
                nStartPos = roundBtn.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then nDrag = false end
                end)
            end
        end)
        
        roundBtn.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then nDragInput = input end
        end)
        
        if _G.NoclipGlobalDrag then _G.NoclipGlobalDrag:Disconnect() end
        _G.NoclipGlobalDrag = UserInputService.InputChanged:Connect(function(input)
            if input == nDragInput and nDrag then
                local delta = input.Position - nDragStart
                roundBtn.Position = UDim2.new(nStartPos.X.Scale, nStartPos.X.Offset + delta.X, nStartPos.Y.Scale, nStartPos.Y.Offset + delta.Y)
            end
        end)
        
        roundBtn.MouseButton1Click:Connect(function()
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hrp and hum then
                    local direcao = hum.MoveDirection.Magnitude > 0 and hum.MoveDirection or hrp.CFrame.LookVector
                    hrp.CFrame = hrp.CFrame + (direcao * 3.0)
                    roundBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
                    task.wait(0.05)
                    roundBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                end
            end
        end)
        _G.NoclipRoundBtn = roundBtn
    else
        if _G.NoclipGlobalDrag then _G.NoclipGlobalDrag:Disconnect() _G.NoclipGlobalDrag = nil end
        if _G.NoclipRoundBtn then pcall(function() _G.NoclipRoundBtn:Destroy() end) _G.NoclipRoundBtn = nil end
    end
end

_G.BtnToggleNoclipGodz.MouseButton1Click:Connect(function()
    _G.NoclipActiveGodz = not _G.NoclipActiveGodz
    _G.BtnToggleNoclipGodz.BackgroundColor3 = _G.NoclipActiveGodz and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    _G.BtnToggleNoclipGodz.Text = _G.NoclipActiveGodz and "BOTÃO FLUTUANTE NOCLIP: ON" or "BOTÃO FLUTUANTE NOCLIP: OFF"
    alternarBotaoFlutuanteNoclip(_G.NoclipActiveGodz)
end)

local function alternarBotaoFlutuanteFly(ligar)
    if ligar then
        if _G.FlyRoundBtn then pcall(function() _G.FlyRoundBtn:Destroy() end) end
        
        local roundBtn = Instance.new("TextButton")
        roundBtn.Size = UDim2.new(0, 50, 0, 50)
        roundBtn.Position = UDim2.new(0.1, 0, 0.62, 0) 
        roundBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        roundBtn.Text = "🦅"
        roundBtn.TextSize = 24
        roundBtn.Font = Enum.Font.Roboto 
        roundBtn.RichText = true
        roundBtn.Active = true
        roundBtn.Parent = screenGui
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(1, 0)
        btnCorner.Parent = roundBtn
        
        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = Color3.fromRGB(52, 152, 219)
        btnStroke.Thickness = 2
        btnStroke.Parent = roundBtn
        
        local fDrag, fDragInput, fDragStart, fStartPos
        roundBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                fDrag = true
                fDragStart = input.Position
                fStartPos = roundBtn.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then fDrag = false end
                end)
            end
        end)
        
        roundBtn.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then fDragInput = input end
        end)
        
        if _G.FlyGlobalDrag then _G.FlyGlobalDrag:Disconnect() end
        _G.FlyGlobalDrag = UserInputService.InputChanged:Connect(function(input)
            if input == fDragInput and fDrag then
                local delta = input.Position - fDragStart
                roundBtn.Position = UDim2.new(fStartPos.X.Scale, fStartPos.X.Offset + delta.X, fStartPos.Y.Scale, fStartPos.Y.Offset + delta.Y)
            end
        end)
        
        local function startFly()
            local char = player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            
            local hrp = char.HumanoidRootPart
            _G.FlyingStateGodz = true
            roundBtn.Text = "🦅"
            roundBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            
            if _G.FlyPlatformGodz then pcall(function() _G.FlyPlatformGodz:Destroy() end) end
            
            local platform = Instance.new("Part")
            platform.Size = Vector3.new(4, 1, 4)
            platform.Transparency = 1 
            platform.Anchored = true
            platform.CanCollide = true
            platform.Parent = workspace
            _G.FlyPlatformGodz = platform
            
            if _G.FlyConnectionGodz then pcall(function() _G.FlyConnectionGodz:Disconnect() end) end
            _G.FlyConnectionGodz = RunService.Heartbeat:Connect(function(dt)
                if not _G.FlyingStateGodz or not char or not char:FindFirstChild("HumanoidRootPart") then return end
                
                platform.CFrame = hrp.CFrame * CFrame.new(0, -3.1, 0)
                hrp.Velocity = Vector3.new(0, 0, 0)
                
                local moveVector = Vector3.new(0, 0, 0)
                pcall(function()
                    moveVector = require(player.PlayerScripts.PlayerModule):GetControls():GetMoveVector()
                end)
                
                local camCFrame = workspace.CurrentCamera.CFrame
                if moveVector.Magnitude > 0 then
                    local direction = (camCFrame.LookVector * -moveVector.Z + camCFrame.RightVector * moveVector.X)
                    hrp.CFrame = hrp.CFrame + (direction * 40 * dt)
                end
            end)
        end
        
        local function stopFly()
            _G.FlyingStateGodz = false
            roundBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            if _G.FlyConnectionGodz then pcall(function() _G.FlyConnectionGodz:Disconnect() end) _G.FlyConnectionGodz = nil end
            if _G.FlyPlatformGodz then pcall(function() _G.FlyPlatformGodz:Destroy() end) _G.FlyPlatformGodz = nil end
        end
        
        roundBtn.MouseButton1Click:Connect(function()
            if _G.FlyingStateGodz then stopFly() else startFly() end
        end)
        
        _G.FlyRoundBtn = roundBtn
    else
        _G.FlyingStateGodz = false
        if _G.FlyGlobalDrag then _G.FlyGlobalDrag:Disconnect() _G.FlyGlobalDrag = nil end
        if _G.FlyConnectionGodz then pcall(function() _G.FlyConnectionGodz:Disconnect() end) _G.FlyConnectionGodz = nil end
        if _G.FlyPlatformGodz then pcall(function() _G.FlyPlatformGodz:Destroy() end) _G.FlyPlatformGodz = nil end
        if _G.FlyRoundBtn then pcall(function() _G.FlyRoundBtn:Destroy() end) _G.FlyRoundBtn = nil end
    end
end

_G.BtnToggleFlyGodz.MouseButton1Click:Connect(function()
    _G.FlyActiveGodz = not _G.FlyActiveGodz
    _G.BtnToggleFlyGodz.BackgroundColor3 = _G.FlyActiveGodz and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    _G.BtnToggleFlyGodz.Text = _G.FlyActiveGodz and "BOTÃO FLUTUANTE FLY: ON" or "BOTÃO FLUTUANTE FLY: OFF"
    alternarBotaoFlutuanteFly(_G.FlyActiveGodz)
end)

local function encontrarAlvoMaisProximo()
    local alvoMaisProximo = nil
    local menorDistanciaNaTela = _G.AimFovValue / 2
    local centroDaTela = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local estaVisivelAlvo = false
    
    local carrosFolder = Workspace:FindFirstChild("CarrosSpawnados")
    local meuChar = player.Character
    if not meuChar then return nil, false end
    
    local paramsAimbot = RaycastParams.new()
    paramsAimbot.FilterType = Enum.RaycastFilterType.Exclude
    
    for _, outroPlayer in ipairs(Players:GetPlayers()) do
        if outroPlayer ~= player and outroPlayer.Character then
            local char = outroPlayer.Character
            local alvoPart = _G.AimTargetPart == "Head" and char:FindFirstChild("Head") or (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
            if not alvoPart then alvoPart = char:FindFirstChild("HumanoidRootPart") end
            
            local humanoid = char:FindFirstChild("Humanoid")
            if alvoPart and humanoid then
                if _G.AimKillCheck and humanoid.Health <= 0 then continue end
                if _G.AimTeamCheck and outroPlayer.Team == player.Team then continue end
                
                local posicaoNaTela, visivelNaTela = Camera:WorldToViewportPoint(alvoPart.Position)
                if visivelNaTela then
                    local distanciaDoCentro = (Vector2.new(posicaoNaTela.X, posicaoNaTela.Y) - centroDaTela).Magnitude
                    if distanciaDoCentro < menorDistanciaNaTela then
                        local listaExclusao = {meuChar, char}
                        if carrosFolder then table.insert(listaExclusao, carrosFolder) end
                        paramsAimbot.FilterDescendantsInstances = listaExclusao
                        
                        local resultadoRaycast = Workspace:Raycast(Camera.CFrame.Position, alvoPart.Position - Camera.CFrame.Position, paramsAimbot)
                        local visivel = (resultadoRaycast == nil or resultadoRaycast.Instance:IsDescendantOf(char))
                        
                        menorDistanciaNaTela = distanciaDoCentro
                        alvoMaisProximo = alvoPart
                        estaVisivelAlvo = visivel
                    end
                end
            end
        end
    end
    return alvoMaisProximo, estaVisivelAlvo
end

RunService:BindToRenderStep("AimbotMobileLock", Enum.RenderPriority.Camera.Value + 1, function()
    if _G.AimbotActiveGodz then
        fovCircle.Visible = true 
        local centroDaTela = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local alvo, visivel = encontrarAlvoMaisProximo()
        
        if alvo then
            local corDinamica = visivel and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            local pos2d, onScreen = Camera:WorldToViewportPoint(alvo.Position)
            
            if onScreen then
                atualizarLineFrame(aimTracer, centroDaTela, Vector2.new(pos2d.X, pos2d.Y), corDinamica)
                aimTracer.Visible = true
            else
                aimTracer.Visible = false
            end
            
            fovStroke.Color = corDinamica
            if not _G.AimWallCheck or (_G.AimWallCheck and visivel) then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, alvo.Position)
            end
        else
            aimTracer.Visible = false
            fovStroke.Color = Color3.fromRGB(255, 255, 255)
        end
    else
        aimTracer.Visible = false
        fovCircle.Visible = false 
    end
end)

_G.BtnToggleAimGodz.MouseButton1Click:Connect(function() _G.AimbotActiveGodz = not _G.AimbotActiveGodz atualizarInterface() end)
_G.BtnToggleAimPartGodz.MouseButton1Click:Connect(function() _G.AimTargetPart = _G.AimTargetPart == "Head" and "Torso" or "Head" atualizarInterface() end)
_G.BtnToggleAimTeamGodz.MouseButton1Click:Connect(function() _G.AimTeamCheck = not _G.AimTeamCheck atualizarInterface() end)
_G.BtnToggleAimKillGodz.MouseButton1Click:Connect(function() _G.AimKillCheck = not _G.AimKillCheck atualizarInterface() end)
_G.BtnToggleAimWallGodz.MouseButton1Click:Connect(function() _G.AimWallCheck = not _G.AimWallCheck atualizarInterface() end)

AimFovTextBox.FocusLost:Connect(function()
    local val = tonumber(AimFovTextBox.Text)
    if val then _G.AimFovValue = math.clamp(val, 10, 600) else AimFovTextBox.Text = tostring(_G.AimFovValue) end
    fovCircle.Size = UDim2.new(0, _G.AimFovValue, 0, _G.AimFovValue)
end)

-- NOVA LÓGICA DE TP PLAYER ACOPLADA AO BOTÃO DA ABA 9
_G.BtnTpPlayerGodz.MouseButton1Click:Connect(function()
    local targetName = TpPlayerTextBox.Text
    local targetPlayer = nil
    
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #targetName) == targetName:lower() or (p.DisplayName and p.DisplayName:lower():sub(1, #targetName) == targetName:lower()) then
            targetPlayer = p
            break
        end
    end
    
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local myRoot = char.HumanoidRootPart
            local targetRoot = targetPlayer.Character.HumanoidRootPart
            
            _G.BtnTpPlayerGodz.Text = "TELEPORTANDO..."
            _G.BtnTpPlayerGodz.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
            
            task.spawn(function()
                -- Em vez de instanciar uma Part, deixamos o personagem ancorado no ar enquanto movemos.
                -- Isso previne quedas sem precisar instanciar blocos que podem ser bloqueados pela engine em scripts locais.
                myRoot.Anchored = true
                
                while targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and (myRoot.Position - targetRoot.Position).Magnitude > 4 do
                    local direction = (targetRoot.Position - myRoot.Position).Unit
                    myRoot.CFrame = myRoot.CFrame + (direction * 4) 
                    task.wait(0.05)
                end
                
                myRoot.Anchored = false
                _G.BtnTpPlayerGodz.Text = "TELEPORTAR (Freeze)"
                _G.BtnTpPlayerGodz.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
                _G.StatusLabelGodz.Text = "Teleporte concluído!"
                _G.StatusLabelGodz.TextColor3 = Color3.fromRGB(46, 204, 113)
            end)
        end
    else
        _G.BtnTpPlayerGodz.Text = "JOGADOR NÃO ENCONTRADO"
        _G.BtnTpPlayerGodz.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        task.wait(1.5)
        _G.BtnTpPlayerGodz.Text = "TELEPORTAR (Freeze)"
        _G.BtnTpPlayerGodz.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
    end
end)


resetarCoresAbas = function()
    local c = Color3.fromRGB(36, 36, 42) local tc = Color3.fromRGB(160, 160, 170)
    _G.BtnAba1Godz.BackgroundColor3 = c; _G.BtnAba1Godz.TextColor3 = tc
    _G.BtnAba2Godz.BackgroundColor3 = c; _G.BtnAba2Godz.TextColor3 = tc
    _G.BtnAba3Godz.BackgroundColor3 = c; _G.BtnAba3Godz.TextColor3 = tc
    _G.BtnAba4Godz.BackgroundColor3 = c; _G.BtnAba4Godz.TextColor3 = tc
    _G.BtnAba5Godz.BackgroundColor3 = c; _G.BtnAba5Godz.TextColor3 = tc
    _G.BtnAba6Godz.BackgroundColor3 = c; _G.BtnAba6Godz.TextColor3 = tc
    _G.BtnAba7Godz.BackgroundColor3 = c; _G.BtnAba7Godz.TextColor3 = tc
    _G.BtnAba8Godz.BackgroundColor3 = c; _G.BtnAba8Godz.TextColor3 = tc 
    _G.BtnAba9Godz.BackgroundColor3 = c; _G.BtnAba9Godz.TextColor3 = tc 
end

atualizarInterface = function()
    resetarCoresAbas()
    
    SpeedTextBox.Visible = false
    _G.BtnToggleSpeedGodz.Visible = false
    _G.EspScrollFrameGodz.Visible = false
    _G.TpScrollFrameGodz.Visible = false
    _G.ClassScrollFrameGodz.Visible = false
    _G.ViewScrollFrameGodz.Visible = false
    _G.NoclipScrollFrameGodz.Visible = false
    _G.AimScrollFrameGodz.Visible = false
    _G.FlyScrollFrameGodz.Visible = false 
    _G.TpPlyScrollFrameGodz.Visible = false 
    
    _G.BtnToggleESPGodz.BackgroundColor3 = _G.SecureRenderLoop and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    _G.BtnToggleESPGodz.Text = _G.SecureRenderLoop and "LIGAR ESP MASTER: ATIVADO" or "LIGAR ESP MASTER: DESATIVADO"
    
    _G.BtnToggleBoxGodz.BackgroundColor3 = _G.EspBoxTrack and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    _G.BtnToggleBoxGodz.Text = _G.EspBoxTrack and "ESP QUADRO 2D: ATIVADO" or "ESP QUADRO 2D: DESATIVADO"
    
    _G.BtnToggleSkeletonGodz.BackgroundColor3 = _G.EspSkeletonTrack and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    _G.BtnToggleSkeletonGodz.Text = _G.EspSkeletonTrack and "ESP SKELETO + HEAD: ATIVADO" or "ESP SKELETO + HEAD: DESATIVADO"
    
    _G.BtnToggleNameGodz.BackgroundColor3 = _G.EspNameTrack and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    _G.BtnToggleNameGodz.Text = _G.EspNameTrack and "ESP NOME DO PLAYER: ATIVADO" or "ESP NOME DO PLAYER: DESATIVADO"
    
    _G.BtnToggleHealthGodz.BackgroundColor3 = _G.EspHealthTrack and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    _G.BtnToggleHealthGodz.Text = _G.EspHealthTrack and "ESP BARRA DE VIDA: ATIVADO" or "ESP BARRA DE VIDA: DESATIVADO"
    
    _G.BtnToggleViewGodz.Text = _G.CameraViewActive and "ESPIANDO..." or "ASSISTIR JOGADOR"
    _G.BtnToggleViewGodz.BackgroundColor3 = _G.CameraViewActive and Color3.fromRGB(40, 180, 40) or Color3.fromRGB(180, 40, 40)
    
    _G.BtnToggleAimGodz.BackgroundColor3 = _G.AimbotActiveGodz and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    _G.BtnToggleAimGodz.Text = _G.AimbotActiveGodz and "SISTEMA AIMBOT: ON" or "SISTEMA AIMBOT: OFF"

    _G.BtnToggleAimPartGodz.Text = _G.AimTargetPart == "Head" and "MIRA FOCADA: CABEÇA" or "MIRA FOCADA: TORSO"
    _G.BtnToggleAimPartGodz.BackgroundColor3 = _G.AimTargetPart == "Head" and Color3.fromRGB(155, 89, 182) or Color3.fromRGB(230, 126, 34)
    
    _G.BtnToggleAimTeamGodz.BackgroundColor3 = _G.AimTeamCheck and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    _G.BtnToggleAimTeamGodz.Text = _G.AimTeamCheck and "TEAM CHECK: ON" or "TEAM CHECK: OFF"
    
    _G.BtnToggleAimKillGodz.BackgroundColor3 = _G.AimKillCheck and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    _G.BtnToggleAimKillGodz.Text = _G.AimKillCheck and "KILL CHECK: ON" or "KILL CHECK: OFF"
    
    _G.BtnToggleAimWallGodz.BackgroundColor3 = _G.AimWallCheck and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    _G.BtnToggleAimWallGodz.Text = _G.AimWallCheck and "WALL CHECK: ON" or "WALL CHECK: OFF"
    
    _G.BtnToggleFlyGodz.BackgroundColor3 = _G.FlyActiveGodz and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    _G.BtnToggleFlyGodz.Text = _G.FlyActiveGodz and "BOTÃO FLUTUANTE FLY: ON" or "BOTÃO FLUTUANTE FLY: OFF"
    
    if paginaAtual == 1 then
        _G.BtnAba1Godz.BackgroundColor3 = Color3.fromRGB(231, 76, 60); _G.BtnAba1Godz.TextColor3 = Color3.fromRGB(255, 255, 255)
        SpeedTextBox.Visible = true
        _G.BtnToggleSpeedGodz.Visible = true
        _G.StatusLabelGodz.Text = _G.SecureSpeedLoop and "Speed: ATIVO AMORTECEDOR (" .. _G.SpeedBypassValue .. ")" or "Speed: DESATIVADO"
        _G.StatusLabelGodz.TextColor3 = _G.SecureSpeedLoop and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(255, 255, 255)
    elseif paginaAtual == 2 then
        _G.BtnAba2Godz.BackgroundColor3 = Color3.fromRGB(231, 76, 60); _G.BtnAba2Godz.TextColor3 = Color3.fromRGB(255, 255, 255)
        _G.EspScrollFrameGodz.Visible = true
        _G.StatusLabelGodz.Text = _G.SecureRenderLoop and "ESP Ativo: on" or "ESP desativo: off"
        _G.StatusLabelGodz.TextColor3 = _G.SecureRenderLoop and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(255, 255, 255)
    elseif paginaAtual == 3 then
        _G.BtnAba3Godz.BackgroundColor3 = Color3.fromRGB(231, 76, 60); _G.BtnAba3Godz.TextColor3 = Color3.fromRGB(255, 255, 255)
        _G.TpScrollFrameGodz.Visible = true
        _G.StatusLabelGodz.Text = "Menu de Posicionamento"
        _G.StatusLabelGodz.TextColor3 = Color3.fromRGB(255, 255, 255)
    elseif paginaAtual == 4 then
        _G.BtnAba4Godz.BackgroundColor3 = Color3.fromRGB(231, 76, 60); _G.BtnAba4Godz.TextColor3 = Color3.fromRGB(255, 255, 255)
        _G.ClassScrollFrameGodz.Visible = true
        _G.StatusLabelGodz.Text = "Selecione uma Profissão"
        _G.StatusLabelGodz.TextColor3 = Color3.fromRGB(255, 255, 255)
    elseif paginaAtual == 5 then
        _G.BtnAba5Godz.BackgroundColor3 = Color3.fromRGB(231, 76, 60); _G.BtnAba5Godz.TextColor3 = Color3.fromRGB(255, 255, 255)
        _G.ViewScrollFrameGodz.Visible = true
        _G.StatusLabelGodz.Text = _G.CameraViewActive and "Espiando Alvo..." or "Aba de Monitoramento"
        _G.StatusLabelGodz.TextColor3 = _G.CameraViewActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(255, 255, 255)
    elseif paginaAtual == 6 then
        _G.BtnAba6Godz.BackgroundColor3 = Color3.fromRGB(231, 76, 60); _G.BtnAba6Godz.TextColor3 = Color3.fromRGB(255, 255, 255)
        _G.NoclipScrollFrameGodz.Visible = true
        _G.StatusLabelGodz.Text = "Configurações do Botão Fantasma"
        _G.StatusLabelGodz.TextColor3 = Color3.fromRGB(255, 255, 255)
    elseif paginaAtual == 7 then
        _G.BtnAba7Godz.BackgroundColor3 = Color3.fromRGB(231, 76, 60); _G.BtnAba7Godz.TextColor3 = Color3.fromRGB(255, 255, 255)
        _G.AimScrollFrameGodz.Visible = true
        _G.StatusLabelGodz.Text = _G.AimbotActiveGodz and "Aimbot Ativo: Travando Alvos" or "Configurações de Auxílio de Mira"
        _G.StatusLabelGodz.TextColor3 = _G.AimbotActiveGodz and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(255, 255, 255)
    elseif paginaAtual == 8 then 
        _G.BtnAba8Godz.BackgroundColor3 = Color3.fromRGB(231, 76, 60); _G.BtnAba8Godz.TextColor3 = Color3.fromRGB(255, 255, 255)
        _G.FlyScrollFrameGodz.Visible = true
        _G.StatusLabelGodz.Text = "Bypass Fly: " .. (_G.FlyActiveGodz and "Botão Criado" or "Botão Oculto")
        _G.StatusLabelGodz.TextColor3 = _G.FlyActiveGodz and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(255, 255, 255)
    elseif paginaAtual == 9 then
        _G.BtnAba9Godz.BackgroundColor3 = Color3.fromRGB(231, 76, 60); _G.BtnAba9Godz.TextColor3 = Color3.fromRGB(255, 255, 255)
        _G.TpPlyScrollFrameGodz.Visible = true
        _G.StatusLabelGodz.Text = "Teleporte até Jogadores"
        _G.StatusLabelGodz.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    
    if _G.AimbotActiveGodz then fovCircle.Visible = true else fovCircle.Visible = false end
end

_G.BtnAba1Godz.MouseButton1Click:Connect(function() paginaAtual = 1 atualizarInterface() end)
_G.BtnAba2Godz.MouseButton1Click:Connect(function() paginaAtual = 2 atualizarInterface() end)
_G.BtnAba3Godz.MouseButton1Click:Connect(function() paginaAtual = 3 atualizarInterface() end)
_G.BtnAba4Godz.MouseButton1Click:Connect(function() paginaAtual = 4 atualizarInterface() end)
_G.BtnAba5Godz.MouseButton1Click:Connect(function() paginaAtual = 5 atualizarInterface() end)
_G.BtnAba6Godz.MouseButton1Click:Connect(function() paginaAtual = 6 atualizarInterface() end)
_G.BtnAba7Godz.MouseButton1Click:Connect(function() paginaAtual = 7 atualizarInterface() end)
_G.BtnAba8Godz.MouseButton1Click:Connect(function() paginaAtual = 8 atualizarInterface() end)
_G.BtnAba9Godz.MouseButton1Click:Connect(function() paginaAtual = 9 atualizarInterface() end)

SpeedTextBox.FocusLost:Connect(function()
    local val = tonumber(SpeedTextBox.Text)
    if val then _G.SpeedBypassValue = math.clamp(val, 16, 60) else SpeedTextBox.Text = tostring(_G.SpeedBypassValue) end
    atualizarInterface()
end)

_G.BtnToggleSpeedGodz.MouseButton1Click:Connect(function()
    _G.SecureSpeedLoop = not _G.SecureSpeedLoop
    _G.BtnToggleSpeedGodz.BackgroundColor3 = _G.SecureSpeedLoop and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    _G.BtnToggleSpeedGodz.Text = _G.SecureSpeedLoop and "SPEED AMORTECIDO: ATIVADO" or "SPEED AMORTECIDO: DESATIVADO"
    atualizarInterface()
end)

_G.BtnToggleESPGodz.MouseButton1Click:Connect(function()
    _G.SecureRenderLoop = not _G.SecureRenderLoop
    if _G.SecureRenderLoop then
        for _, p in ipairs(Players:GetPlayers()) do criarVinculoESP(p) end
    else
        clearAllESP()
    end
    atualizarInterface()
end)

_G.BtnToggleBoxGodz.MouseButton1Click:Connect(function() _G.EspBoxTrack = not _G.EspBoxTrack atualizarInterface() end)
_G.BtnToggleSkeletonGodz.MouseButton1Click:Connect(function() _G.EspSkeletonTrack = not _G.EspSkeletonTrack atualizarInterface() end)
_G.BtnToggleNameGodz.MouseButton1Click:Connect(function() _G.EspNameTrack = not _G.EspNameTrack atualizarInterface() end)
_G.BtnToggleHealthGodz.MouseButton1Click:Connect(function() _G.EspHealthTrack = not _G.EspHealthTrack atualizarInterface() end)

_G.BtnTpGaragem.MouseButton1Click:Connect(function()
    pcall(function()
        local Event = ReplicatedStorage:FindFirstChild("InGameRemotes") and ReplicatedStorage.InGameRemotes:FindFirstChild("SpawnaTeleporte")
        if Event and Event:IsA("RemoteEvent") then
            Event:FireServer("Garagem")
            _G.StatusLabelGodz.Text = "Teleporte Enviado: Garagem!"
            _G.StatusLabelGodz.TextColor3 = Color3.fromRGB(46, 204, 113)
        end
    end)
end)

local function dispararTrocaClasse(cargo, id)
    pcall(function()
        local remote = ReplicatedStorage:FindFirstChild("Mercadinho") and ReplicatedStorage.Mercadinho:FindFirstChild("PrefRemote")
        if remote and remote:IsA("RemoteEvent") then
            remote:FireServer(cargo, id)
            _G.StatusLabelGodz.Text = "Classe alterada: " .. cargo .. "!"
            _G.StatusLabelGodz.TextColor3 = Color3.fromRGB(46, 204, 113)
        else
            _G.StatusLabelGodz.Text = "Erro: Remote PrefRemote ausente!"
            _G.StatusLabelGodz.TextColor3 = Color3.fromRGB(231, 76, 60)
        end
    end)
end

_G.BtnClassGcm.MouseButton1Click:Connect(function() dispararTrocaClasse("GCM", 3) end)
_G.BtnClassCaminhoneiro.MouseButton1Click:Connect(function() dispararTrocaClasse("Caminhoneiro", 10) end)
_G.BtnClassCivil.MouseButton1Click:Connect(function() dispararTrocaClasse("Civil", 1) end)
_G.BtnClassLixeiro.MouseButton1Click:Connect(function() dispararTrocaClasse("Lixeiro", 1) end)
_G.BtnClassFood.MouseButton1Click:Connect(function() dispararTrocaClasse("SintoniaFood", 3) end)

_G.BtnMinimizarGodz.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    _G.ContainerFrameGodz.Visible = not minimizado
    _G.MainFrameGodz.Size = minimizado and UDim2.new(0, 260, 0, 30) or UDim2.new(0, 260, 0, 240)
    _G.BtnMinimizarGodz.Text = minimizado and "+" or "−"
    if not minimizado then atualizarInterface() end
end)

local SpeedConnectionName = getRandomName()
_G[SpeedConnectionName] = RunService.RenderStepped:Connect(function(deltaTime)
    if not screenGui or not screenGui.Parent then
        _G.SecureSpeedLoop = false; _G.SecureRenderLoop = false; _G.CameraViewActive = false; _G.AimbotActiveGodz = false; _G.FlyingStateGodz = false
        pcall(function() RunService:UnbindFromRenderStep("AimbotMobileLock") end)
        if _G.ViewCamConnection then pcall(function() _G.ViewCamConnection:Disconnect() end) end
        if _G.NoclipRoundBtn then pcall(function() _G.NoclipRoundBtn:Destroy() end) end
        if _G.FlyRoundBtn then pcall(function() _G.FlyRoundBtn:Destroy() end) end
        if _G.FlyConnectionGodz then pcall(function() _G.FlyConnectionGodz:Disconnect() end) end
        if _G.FlyPlatformGodz then pcall(function() _G.FlyPlatformGodz:Destroy() end) end
        if fovCircle then pcall(function() fovCircle:Destroy() end) end
        if aimTracer then pcall(function() aimTracer:Destroy() end) end
        clearAllESP()
        EspContainer:Destroy()
        if _G[SpeedConnectionName] then _G[SpeedConnectionName]:Disconnect() end
        return
    end
    
    if _G.SecureSpeedLoop then
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hrp and hum and hum.MoveDirection.Magnitude > 0 and hum.Health > 0 then
            local clampedSpeed = math.clamp(_G.SpeedBypassValue, 16, 60)
            local targetVelocity = hum.MoveDirection * clampedSpeed
            hrp.AssemblyLinearVelocity = Vector3.new(targetVelocity.X, hrp.AssemblyLinearVelocity.Y, targetVelocity.Z)
            local nextPosition = hrp.Position + (hum.MoveDirection * (clampedSpeed * 0.50 * deltaTime))
            hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(nextPosition) * hrp.CFrame.Rotation, 0.8)
        end
    end
end)

atualizarInterface()
