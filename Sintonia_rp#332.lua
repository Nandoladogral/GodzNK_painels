task.spawn(function()
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
    if _G.EspCarTrack then _G.EspCarTrack = false task.wait(0.05) end 
    if _G.MainHubInterface then _G.MainHubInterface:Destroy() task.wait(0.05) end

    pcall(function() RunService:UnbindFromRenderStep("GodzESP_Render") end)
    pcall(function() RunService:UnbindFromRenderStep("AimbotMobileLock") end)
    pcall(function() RunService:UnbindFromRenderStep("GodzSpeed_Render") end)

    -- PATCH DE CORREÇÃO: Limpeza dos eventos de Input
    if _G.MainDragGlobal then pcall(function() _G.MainDragGlobal:Disconnect() end) _G.MainDragGlobal = nil end
    if _G.NoclipGlobalDrag then pcall(function() _G.NoclipGlobalDrag:Disconnect() end) _G.NoclipGlobalDrag = nil end
    if _G.FlyGlobalDrag then pcall(function() _G.FlyGlobalDrag:Disconnect() end) _G.FlyGlobalDrag = nil end
    if _G.AimGlobalDrag then pcall(function() _G.AimGlobalDrag:Disconnect() end) _G.AimGlobalDrag = nil end
    if _G.MagGlobalDrag then pcall(function() _G.MagGlobalDrag:Disconnect() end) _G.MagGlobalDrag = nil end

    if _G.FlyConnectionGodz then pcall(function() _G.FlyConnectionGodz:Disconnect() end) _G.FlyConnectionGodz = nil end
    if _G.FlyAdvancedConnectionGodz then pcall(function() _G.FlyAdvancedConnectionGodz:Disconnect() end) _G.FlyAdvancedConnectionGodz = nil end
    if _G.FlyPlatformGodz then pcall(function() _G.FlyPlatformGodz:Destroy() end) _G.FlyPlatformGodz = nil end
    if _G.FlyRoundBtn then pcall(function() _G.FlyRoundBtn:Destroy() end) _G.FlyRoundBtn = nil end
    if _G.NoclipRoundBtn then pcall(function() _G.NoclipRoundBtn:Destroy() end) _G.NoclipRoundBtn = nil end
    if _G.AimRoundBtn then pcall(function() _G.AimRoundBtn:Destroy() end) _G.AimRoundBtn = nil end
    if _G.MagRoundBtn then pcall(function() _G.MagRoundBtn:Destroy() end) _G.MagRoundBtn = nil end

    pcall(function()
        Camera.CameraType = Enum.CameraType.Custom
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = player.Character.Humanoid
        end
    end)

    -- Removida limpeza automática agressiva que poderia causar conflitos com a própria interface

    setgarbagecollection = setgarbagecollection or function() end
    pcall(function() gcinfo() end)

    local minimizado, paginaAtual = false, 1
    _G.SecureRenderLoop = false
    _G.SecureSpeedLoop = false
    _G.NoclipActiveGodz = false
    _G.FlyActiveGodz = false
    _G.FlyPlatformActiveGodz = false -- Estado do fly plataforma
    _G.FlyAdvancedActiveGodz = false -- Estado do fly avançado

    -- Estados Aim Magnetic
    _G.MagActiveGodz = false
    _G.MagFloatActive = false
    _G.StreamerModeActiveGodz = false
    local playerSendoPuxado = nil
    local alvoAtual = nil
    local isPulling = false

    -- Elemento Drawing da linha Roxa
    local linhaESP = Drawing.new("Line")
    linhaESP.Color = Color3.fromRGB(140, 0, 210) 
    linhaESP.Thickness = 2.5
    linhaESP.Transparency = 1
    linhaESP.Visible = false

    _G.AimbotActiveGodz = false
    _G.AimFloatActive = false 
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
    _G.EspCarTrack = false 
    _G.EspMoneyTrack = false
    _G.EspNomesOcultos = {} -- Tabela global para armazenar os nomes ocultados

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
    tabsScroll.CanvasSize = UDim2.new(2.5, 0, 0, 0) 
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
    _G.BtnAba6Godz = criarBotaoAba("AIM", 5, 45)
    _G.BtnAba7Godz = criarBotaoAba("TP PLY", 6, 55)
    _G.BtnAba8Godz = criarBotaoAba("OPEN", 7, 50)
    _G.BtnAba9Godz = criarBotaoAba("SYSTEM", 8, 90)

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

    _G.MainScrollFrameGodz = Instance.new("ScrollingFrame")
    _G.MainScrollFrameGodz.Size = UDim2.new(1, 0, 1, -5)
    _G.MainScrollFrameGodz.BackgroundTransparency = 1
    _G.MainScrollFrameGodz.BorderSizePixel = 0
    _G.MainScrollFrameGodz.CanvasSize = UDim2.new(0, 0, 1.8, 0)
    _G.MainScrollFrameGodz.ScrollBarThickness = 2
    _G.MainScrollFrameGodz.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
    _G.MainScrollFrameGodz.Visible = false
    _G.MainScrollFrameGodz.Parent = _G.ContentFrameGodz

    local mainLayout = Instance.new("UIListLayout")
    mainLayout.FillDirection = Enum.FillDirection.Vertical
    mainLayout.SortOrder = Enum.SortOrder.LayoutOrder
    mainLayout.Padding = UDim.new(0, 6)
    mainLayout.Parent = _G.MainScrollFrameGodz

    local function criarSeparador(texto, pai)
        local sep = Instance.new("TextLabel")
        sep.Size = UDim2.new(1, 0, 0, 20)
        sep.BackgroundTransparency = 1
        sep.Text = "- - - - " .. texto .. " - - - -"
        sep.TextColor3 = Color3.fromRGB(150, 150, 160)
        sep.Font = Enum.Font.Code
        sep.TextSize = 12
        sep.Parent = pai
    end

    _G.EspScrollFrameGodz = Instance.new("ScrollingFrame")
    _G.EspScrollFrameGodz.Size = UDim2.new(1, 0, 1, -5)
    _G.EspScrollFrameGodz.BackgroundTransparency = 1
    _G.EspScrollFrameGodz.BorderSizePixel = 0
    _G.EspScrollFrameGodz.CanvasSize = UDim2.new(0, 0, 2.5, 0) 
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

    -- Aba MAG removida e conteúdo movido para AIM

    _G.AimScrollFrameGodz = Instance.new("ScrollingFrame")
    _G.AimScrollFrameGodz.Size = UDim2.new(1, 0, 1, -5)
    _G.AimScrollFrameGodz.BackgroundTransparency = 1
    _G.AimScrollFrameGodz.BorderSizePixel = 0
    _G.AimScrollFrameGodz.CanvasSize = UDim2.new(0, 0, 2.5, 0) 
    _G.AimScrollFrameGodz.ScrollBarThickness = 2
    _G.AimScrollFrameGodz.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
    _G.AimScrollFrameGodz.Visible = false
    _G.AimScrollFrameGodz.Parent = _G.ContentFrameGodz

    local aimLayout = Instance.new("UIListLayout")
    aimLayout.FillDirection = Enum.FillDirection.Vertical
    aimLayout.SortOrder = Enum.SortOrder.LayoutOrder
    aimLayout.Padding = UDim.new(0, 6)
    aimLayout.Parent = _G.AimScrollFrameGodz

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

    _G.OpenScrollFrameGodz = Instance.new("ScrollingFrame")
    _G.OpenScrollFrameGodz.Size = UDim2.new(1, 0, 1, -5)
    _G.OpenScrollFrameGodz.BackgroundTransparency = 1
    _G.OpenScrollFrameGodz.BorderSizePixel = 0
    _G.OpenScrollFrameGodz.CanvasSize = UDim2.new(0, 0, 1.2, 0)
    _G.OpenScrollFrameGodz.ScrollBarThickness = 2
    _G.OpenScrollFrameGodz.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
    _G.OpenScrollFrameGodz.Visible = false
    _G.OpenScrollFrameGodz.Parent = _G.ContentFrameGodz

    _G.SystemScrollFrameGodz = Instance.new("ScrollingFrame")
    _G.SystemScrollFrameGodz.Size = UDim2.new(1, 0, 1, -5)
    _G.SystemScrollFrameGodz.BackgroundTransparency = 1
    _G.SystemScrollFrameGodz.BorderSizePixel = 0
    _G.SystemScrollFrameGodz.CanvasSize = UDim2.new(0, 0, 1.2, 0)
    _G.SystemScrollFrameGodz.ScrollBarThickness = 2
    _G.SystemScrollFrameGodz.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
    _G.SystemScrollFrameGodz.Visible = false
    _G.SystemScrollFrameGodz.Parent = _G.ContentFrameGodz

    local systemLayout = Instance.new("UIListLayout")
    systemLayout.FillDirection = Enum.FillDirection.Vertical
    systemLayout.SortOrder = Enum.SortOrder.LayoutOrder
    systemLayout.Padding = UDim.new(0, 6)
    systemLayout.Parent = _G.SystemScrollFrameGodz

    -- Removida duplicação do botão Streamer Mode aqui

    local openLayout = Instance.new("UIListLayout")
    openLayout.FillDirection = Enum.FillDirection.Vertical
    openLayout.SortOrder = Enum.SortOrder.LayoutOrder
    openLayout.Padding = UDim.new(0, 6)
    openLayout.Parent = _G.OpenScrollFrameGodz

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

    local function criarBotaoCompacto(nome, descricao, cor, pai)
        -- Container para o layout horizontal
        local container = Instance.new("Frame")
        container.Name = "Container_" .. nome
        container.Size = UDim2.new(1, 0, 0, 28)
        container.BackgroundTransparency = 1
        container.BorderSizePixel = 0
        container.Parent = pai

        -- Label com descrição (70% da largura)
        local label = Instance.new("TextLabel")
        label.Name = "Label_" .. nome
        label.Size = UDim2.new(0.70, -4, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
        label.Text = descricao
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.Font = Enum.Font.Code
        label.TextSize = 11
        label.BorderSizePixel = 0
        label.Parent = container

        local labelCorner = Instance.new("UICorner")
        labelCorner.CornerRadius = UDim.new(0, 6)
        labelCorner.Parent = label

        -- Botão pequeno (28% da largura)
        local btn = Instance.new("TextButton")
        btn.Name = nome
        btn.Size = UDim2.new(0.28, 0, 1, 0)
        btn.Position = UDim2.new(0.72, 0, 0, 0)
        btn.BackgroundColor3 = cor
        btn.Text = "LIGAR"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Code
        btn.TextSize = 10
        btn.BorderSizePixel = 0
        btn.Parent = container

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn

        return btn, label, container
    end
    
    local function criarBotaoCompactoTp(nome, descricao, cor, pai)
        -- Container para o layout horizontal
        local container = Instance.new("Frame")
        container.Name = "Container_" .. nome
        container.Size = UDim2.new(1, 0, 0, 28)
        container.BackgroundTransparency = 1
        container.BorderSizePixel = 0
        container.Parent = pai

        -- Label com descrição (70% da largura)
        local label = Instance.new("TextLabel")
        label.Name = "Label_" .. nome
        label.Size = UDim2.new(0.70, -4, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
        label.Text = descricao
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.Font = Enum.Font.Code
        label.TextSize = 11
        label.BorderSizePixel = 0
        label.Parent = container

        local labelCorner = Instance.new("UICorner")
        labelCorner.CornerRadius = UDim.new(0, 6)
        labelCorner.Parent = label

        -- Botão pequeno (28% da largura)
        local btn = Instance.new("TextButton")
        btn.Name = nome
        btn.Size = UDim2.new(0.28, 0, 1, 0)
        btn.Position = UDim2.new(0.72, 0, 0, 0)
        btn.BackgroundColor3 = cor
        btn.Text = "TP"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Code
        btn.TextSize = 10
        btn.BorderSizePixel = 0
        btn.Parent = container

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn

        return btn, label, container
    end

    -- ORGANIZAÇÃO DA ABA MAIN
    criarSeparador("SPEED", _G.MainScrollFrameGodz)

    local SpeedTextBox = Instance.new("TextBox")
    SpeedTextBox.Name = getRandomName()
    SpeedTextBox.Size = UDim2.new(1, 0, 0, 32)
    SpeedTextBox.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
    SpeedTextBox.BorderSizePixel = 0
    SpeedTextBox.Text = "50"
    SpeedTextBox.PlaceholderText = "Definir Velocidade (Max 60)..."
    SpeedTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedTextBox.TextSize = 12
    SpeedTextBox.Font = Enum.Font.Code
    SpeedTextBox.Parent = _G.MainScrollFrameGodz

    local stc = Instance.new("UICorner")
    stc.CornerRadius = UDim.new(0, 6)
    stc.Parent = SpeedTextBox

    _G.BtnToggleSpeedGodz, _G.SpeedLabel = criarBotaoCompacto("BtnToggleSpeed", "SPEED BYPESS", Color3.fromRGB(231, 76, 60), _G.MainScrollFrameGodz)

    criarSeparador("FLY", _G.MainScrollFrameGodz)
    _G.BtnToggleFlyGodz, _G.FlyLabel = criarBotaoCompacto("BtnToggleFly", "FLY PLATAFORM", Color3.fromRGB(231, 76, 60), _G.MainScrollFrameGodz)
    _G.BtnToggleFlyAdvancedGodz, _G.FlyAdvancedLabel = criarBotaoCompacto("BtnToggleFlyAdvanced", "FLY AVANÇADO", Color3.fromRGB(231, 76, 60), _G.MainScrollFrameGodz)

    criarSeparador("NOCLIP", _G.MainScrollFrameGodz)
    _G.BtnToggleNoclipGodz, _G.NoclipLabel = criarBotaoCompacto("BtnToggleNoclip", "BOTÃO FLUTUANTE NOCLIP", Color3.fromRGB(231, 76, 60), _G.MainScrollFrameGodz)

    -- OUTRAS ABAS
    _G.BtnToggleESPGodz, _G.ESPLabel = criarBotaoCompacto("BtnToggleESP", "LIGAR ESP", Color3.fromRGB(231, 76, 60), _G.EspScrollFrameGodz)
    _G.BtnToggleBoxGodz, _G.BoxLabel = criarBotaoCompacto("BtnToggleBox", "ESP QUADRO 2D", Color3.fromRGB(46, 204, 113), _G.EspScrollFrameGodz)
    _G.BtnToggleSkeletonGodz, _G.SkeletonLabel = criarBotaoCompacto("BtnToggleSkeleton", "ESP SKELETO + HEAD", Color3.fromRGB(46, 204, 113), _G.EspScrollFrameGodz)
    _G.BtnToggleNameGodz, _G.NameLabel = criarBotaoCompacto("BtnToggleName", "ESP NOME DO PLAYER", Color3.fromRGB(46, 204, 113), _G.EspScrollFrameGodz)
    _G.BtnToggleHealthGodz, _G.HealthLabel = criarBotaoCompacto("BtnToggleHealth", "ESP BARRA DE VIDA", Color3.fromRGB(46, 204, 113), _G.EspScrollFrameGodz)
    _G.BtnToggleCarGodz, _G.CarLabel = criarBotaoCompacto("BtnToggleCar", "ESP CARROS", Color3.fromRGB(231, 76, 60), _G.EspScrollFrameGodz) 
    _G.BtnToggleMoneyGodz, _G.MoneyLabel = criarBotaoCompacto("BtnToggleMoney", "ESP DINHEIRO", Color3.fromRGB(231, 76, 60), _G.EspScrollFrameGodz)

    -- ADICIONADO: Elementos visuais para Ocultar ESP Nome
    criarSeparador("OCULTAR ESP NOME", _G.EspScrollFrameGodz)
    local OcultarNameTextBox = Instance.new("TextBox")
    OcultarNameTextBox.Size = UDim2.new(1, 0, 0, 32)
    OcultarNameTextBox.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
    OcultarNameTextBox.BorderSizePixel = 0
    OcultarNameTextBox.Text = ""
    OcultarNameTextBox.PlaceholderText = "Nome do jogador para ocultar..."
    OcultarNameTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    OcultarNameTextBox.TextSize = 12
    OcultarNameTextBox.Font = Enum.Font.Code
    OcultarNameTextBox.Parent = _G.EspScrollFrameGodz

    local ontc = Instance.new("UICorner")
    ontc.CornerRadius = UDim.new(0, 6)
    ontc.Parent = OcultarNameTextBox

    local BtnOcultarNameGodz = criarBotaoAcao("BtnOcultarName", "OCULTAR JOGADOR", Color3.fromRGB(192, 57, 43), _G.EspScrollFrameGodz)

    _G.BtnTpGaragem, _G.TpGaragemLabel = criarBotaoCompactoTp("BtnTpGaragem", "TP GARAGEM", Color3.fromRGB(231, 76, 60), _G.TpScrollFrameGodz)
    _G.BtnTpOrg, _G.TpOrgLabel = criarBotaoCompactoTp("BtnTpOrg", "TP ORGANIZAÇÃO", Color3.fromRGB(231, 76, 60), _G.TpScrollFrameGodz)

    _G.BtnClassGcm, _G.ClassGcmLabel = criarBotaoCompacto("BtnClassGcm", "VIRAR GCM", Color3.fromRGB(231, 76, 60), _G.ClassScrollFrameGodz)
    _G.BtnClassCaminhoneiro, _G.ClassCaminheiroLabel = criarBotaoCompacto("BtnClassCaminhoneiro", "VIRAR CAMINHONEIRO", Color3.fromRGB(231, 76, 60), _G.ClassScrollFrameGodz)
    _G.BtnClassCivil, _G.ClassCivilLabel = criarBotaoCompacto("BtnClassCivil", "VIRAR CIVIL", Color3.fromRGB(231, 76, 60), _G.ClassScrollFrameGodz)
    _G.BtnClassLixeiro, _G.ClassLixeiroLabel = criarBotaoCompacto("BtnClassLixeiro", "VIRAR LIXEIRO", Color3.fromRGB(231, 76, 60), _G.ClassScrollFrameGodz)
    _G.BtnClassFood, _G.ClassFoodLabel = criarBotaoCompacto("BtnClassFood", "VIRAR SINTONIA FOOD", Color3.fromRGB(231, 76, 60), _G.ClassScrollFrameGodz)

    criarSeparador("AIMBOT", _G.AimScrollFrameGodz)
    _G.BtnToggleAimGodz, _G.AimbotLabel = criarBotaoCompacto("BtnToggleAim", "SISTEMA AIMBOT", Color3.fromRGB(231, 76, 60), _G.AimScrollFrameGodz)
    _G.BtnToggleAimFloatGodz, _G.AimFloatLabel = criarBotaoCompacto("BtnToggleAimFloat", "BOTÃO FLUTUANTE AIM", Color3.fromRGB(231, 76, 60), _G.AimScrollFrameGodz)
    
    -- FOV ABAIXO DE AIMBOT
    local FovContainer = Instance.new("Frame")
    FovContainer.Name = "FovContainer"
    FovContainer.Size = UDim2.new(1, 0, 0, 28)
    FovContainer.BackgroundTransparency = 1
    FovContainer.BorderSizePixel = 0
    FovContainer.Parent = _G.AimScrollFrameGodz

    local FovLabel = Instance.new("TextLabel")
    FovLabel.Name = "FovLabel"
    FovLabel.Size = UDim2.new(0.30, -2, 1, 0)
    FovLabel.Position = UDim2.new(0, 0, 0, 0)
    FovLabel.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
    FovLabel.Text = "FOV AIMBOT"
    FovLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    FovLabel.Font = Enum.Font.Code
    FovLabel.TextSize = 11
    FovLabel.BorderSizePixel = 0
    FovLabel.Parent = FovContainer

    local fovCorner = Instance.new("UICorner")
    fovCorner.CornerRadius = UDim.new(0, 6)
    fovCorner.Parent = FovLabel

    local AimFovTextBox = Instance.new("TextBox")
    AimFovTextBox.Size = UDim2.new(0.68, -2, 1, 0)
    AimFovTextBox.Position = UDim2.new(0.32, 0, 0, 0)
    AimFovTextBox.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
    AimFovTextBox.BorderSizePixel = 0
    AimFovTextBox.Text = "100"
    AimFovTextBox.PlaceholderText = "Definir FOV..."
    AimFovTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    AimFovTextBox.TextSize = 12
    AimFovTextBox.Font = Enum.Font.Code
    AimFovTextBox.Parent = FovContainer

    local afc = Instance.new("UICorner")
    afc.CornerRadius = UDim.new(0, 6)
    afc.Parent = AimFovTextBox
    
    _G.BtnToggleAimPartGodz, _G.AimPartLabel = criarBotaoCompacto("BtnToggleAimPart", "MIRA FOCADA", Color3.fromRGB(155, 89, 182), _G.AimScrollFrameGodz)
    _G.BtnToggleAimTeamGodz, _G.AimTeamLabel = criarBotaoCompacto("BtnToggleAimTeam", "TEAM CHECK", Color3.fromRGB(231, 76, 60), _G.AimScrollFrameGodz)
    _G.BtnToggleAimKillGodz, _G.AimKillLabel = criarBotaoCompacto("BtnToggleAimKill", "KILL CHECK", Color3.fromRGB(231, 76, 60), _G.AimScrollFrameGodz)
    _G.BtnToggleAimWallGodz, _G.AimWallLabel = criarBotaoCompacto("BtnToggleAimWall", "WALL CHECK", Color3.fromRGB(231, 76, 60), _G.AimScrollFrameGodz)

    criarSeparador("MAGNETIC PULL", _G.AimScrollFrameGodz)
    _G.BtnToggleMagGodz, _G.MagLabel = criarBotaoCompacto("BtnToggleMag", "SISTEMA MAGNETICO", Color3.fromRGB(231, 76, 60), _G.AimScrollFrameGodz)
    _G.BtnToggleMagFloatGodz, _G.MagFloatLabel = criarBotaoCompacto("BtnToggleMagFloat", "BOTÃO FLUTUANTE PULL", Color3.fromRGB(231, 76, 60), _G.AimScrollFrameGodz)

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

    _G.BtnTpPlayerGodz, _G.TpPlayerLabel = criarBotaoCompacto("BtnTpPlayer", "TELEPORTAR (Freeze)", Color3.fromRGB(39, 174, 96), _G.TpPlyScrollFrameGodz)

    criarSeparador("ABRIR LOCAIS", _G.OpenScrollFrameGodz)
    _G.BtnOpenFabrica, _G.OpenFabricaLabel = criarBotaoCompacto("BtnOpenFabrica", "ABRIR FÁBRICA DE ARMA", Color3.fromRGB(231, 76, 60), _G.OpenScrollFrameGodz)
    _G.BtnOpenMercadoNegro, _G.OpenMercadoNegroLabel = criarBotaoCompacto("BtnOpenMercadoNegro", "ABRIR MERCADO NEGRO", Color3.fromRGB(231, 76, 60), _G.OpenScrollFrameGodz)
    _G.BtnOpenMercadinho, _G.OpenMercadinhoLabel = criarBotaoCompacto("BtnOpenMercadinho", "ABRIR MERCADINHO", Color3.fromRGB(231, 76, 60), _G.OpenScrollFrameGodz)

    -- ABA SYSTEM
    criarSeparador("SYSTEM", _G.SystemScrollFrameGodz)
    local futuramenteLabel = Instance.new("TextLabel")
    futuramenteLabel.Size = UDim2.new(1, 0, 0, 50)
    futuramenteLabel.BackgroundTransparency = 1
    futuramenteLabel.Text = "FUTURAMENTE"
    futuramenteLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    futuramenteLabel.Font = Enum.Font.Code
    futuramenteLabel.TextSize = 18
    futuramenteLabel.Parent = _G.SystemScrollFrameGodz

    _G.HubLogicaPronta = true

    -- LÓGICA ESP MASTER
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
        textLabel.Text = "" 
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
                        
                        -- ALTERADO: Agora mantém a tag e formata com "nao definido" caso o player esteja na lista
                        if _G.EspNameTrack then
                            if _G.EspNomesOcultos[p.Name:lower()] then
                                data.NameTag.Text = "Apelido: nao definido\nNome: nao definido"
                            else
                                local textoMorto = hum.Health <= 0 and " [MORTO]" or ""
                                data.NameTag.Text = "Apelido: " .. (p.DisplayName or p.Name) .. textoMorto .. "\nNome: " .. p.Name
                            end
                            data.NameTag.Position = UDim2.new(0, topPos.X - 100, 0, topPos.Y - 26) 
                            data.NameTag.Size = UDim2.new(0, 200, 0, 25) 
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

    local function estaPertoDeCarroSpawnado(targetRoot)
        local carrosFolder = workspace:FindFirstChild("CarrosSpawnados")
        if not carrosFolder then return false end
        for _, objeto in ipairs(carrosFolder:GetChildren()) do
            local posicaoObjeto = nil
            if objeto:IsA("BasePart") then
                posicaoObjeto = objeto.Position
            elseif objeto:IsA("Model") then
                posicaoObjeto = objeto:GetPivot().Position
            end
            if posicaoObjeto then
                local distancia = (targetRoot.Position - posicaoObjeto).Magnitude
                if distancia < 5 then return true end
            end
        end
        return false
    end

    local function obterJogadorNaMira()
        local maisProximo = nil
        local menorDistanciaDaMira = math.huge
        local centroTela = Camera.ViewportSize / 2

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local humanoid = p.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local targetRoot = p.Character.HumanoidRootPart
                    if not estaPertoDeCarroSpawnado(targetRoot) then
                        local pos, naTela = Camera:WorldToViewportPoint(targetRoot.Position)
                        if naTela then
                            local distDaMira = (Vector2.new(pos.X, pos.Y) - centroTela).Magnitude
                            if distDaMira < menorDistanciaDaMira then
                                menorDistanciaDaMira = distDaMira
                                maisProximo = p
                            end
                        end
                    end
                end
            end
        end
        return maisProximo
    end

    RunService.Heartbeat:Connect(function()
        if not _G.MagActiveGodz then
            linhaESP.Visible = false
            if isPulling then
                isPulling = false
                playerSendoPuxado = nil
                if _G.MagRoundBtn then _G.MagRoundBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35) end
            end
            return
        end

        local centroTela = Camera.ViewportSize / 2
        
        if isPulling and playerSendoPuxado and playerSendoPuxado.Character then
            local hum = playerSendoPuxado.Character:FindFirstChildOfClass("Humanoid")
            local targetRoot = playerSendoPuxado.Character:FindFirstChild("HumanoidRootPart")
            
            if not hum or hum.Health <= 0 or (targetRoot and estaPertoDeCarroSpawnado(targetRoot)) then
                isPulling = false
                playerSendoPuxado = nil
                if _G.MagRoundBtn then
                    _G.MagRoundBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                    _G.MagRoundBtn.UIStroke.Color = Color3.fromRGB(200, 0, 0)
                end
            end
        end

        if not isPulling then
            alvoAtual = obterJogadorNaMira()
        else
            alvoAtual = playerSendoPuxado
        end
        
        if alvoAtual and alvoAtual.Character and alvoAtual.Character:FindFirstChild("HumanoidRootPart") then
            local headPart = alvoAtual.Character:FindFirstChild("Head")
            local alvoPosicaoVisivel = headPart and headPart.Position or alvoAtual.Character.HumanoidRootPart.Position
            
            local pos, naTela = Camera:WorldToViewportPoint(alvoPosicaoVisivel)
            if naTela then
                linhaESP.Visible = true
                linhaESP.From = centroTela
                linhaESP.To = Vector2.new(pos.X, pos.Y)
            else
                linhaESP.Visible = false
            end
            
            if isPulling and playerSendoPuxado and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local meuRoot = player.Character.HumanoidRootPart
                local targetRoot = playerSendoPuxado.Character.HumanoidRootPart
                local targetHead = playerSendoPuxado.Character:FindFirstChild("Head")
                local camCFrame = Camera.CFrame
                
                local distanciaAteMim = (meuRoot.Position - camCFrame.Position):Dot(camCFrame.LookVector)
                local posicaoFinal = camCFrame.Position + (camCFrame.LookVector * (distanciaAteMim + 5))
                
                if targetHead then
                    local offsetY = targetHead.Position.Y - targetRoot.Position.Y
                    local posicaoAjustada = posicaoFinal - Vector3.new(0, offsetY, 0)
                    targetRoot.CFrame = CFrame.new(posicaoAjustada, posicaoAjustada + camCFrame.LookVector)
                else
                    targetRoot.CFrame = CFrame.new(posicaoFinal, posicaoFinal + camCFrame.LookVector)
                end
                
                targetRoot.AssemblyLinearVelocity = Vector3.new(0,0,0)
                targetRoot.AssemblyAngularVelocity = Vector3.new(0,0,0)
            end
        else
            linhaESP.Visible = false
            if isPulling then 
                isPulling = false
                playerSendoPuxado = nil
                if _G.MagRoundBtn then _G.MagRoundBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35) end
            end
        end
    end)

    local function alternarBotaoFlutuanteMag(ligar)
        if ligar then
            if _G.MagRoundBtn then pcall(function() _G.MagRoundBtn:Destroy() end) end
            local roundBtn = Instance.new("TextButton")
            roundBtn.Size = UDim2.new(0, 50, 0, 50)
            roundBtn.Position = UDim2.new(0.1, 0, 0.74, 0) 
            roundBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            roundBtn.Text = "🏌️"
            roundBtn.TextSize = 24
            roundBtn.Font = Enum.Font.Code
            roundBtn.Active = true
            roundBtn.Parent = screenGui
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(1, 0)
            btnCorner.Parent = roundBtn
            
            local btnStroke = Instance.new("UIStroke")
            btnStroke.Color = Color3.fromRGB(200, 0, 0)
            btnStroke.Thickness = 2
            btnStroke.Parent = roundBtn
            
            local mDrag, mDragInput, mDragStart, mStartPos
            local mudouDeLugar = false
            
            roundBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    mDrag = true
                    mDragStart = input.Position
                    mStartPos = roundBtn.Position
                    mudouDeLugar = false
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then mDrag = false end
                    end)
                end
            end)
            
            roundBtn.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then mDragInput = input end
            end)
            
            if _G.MagGlobalDrag then _G.MagGlobalDrag:Disconnect() end
            _G.MagGlobalDrag = UserInputService.InputChanged:Connect(function(input)
                if input == mDragInput and mDrag then
                    local delta = input.Position - mDragStart
                    if delta.Magnitude > 5 then mudouDeLugar = true end
                    roundBtn.Position = UDim2.new(mStartPos.X.Scale, mStartPos.X.Offset + delta.X, mStartPos.Y.Scale, mStartPos.Y.Offset + delta.Y)
                end
            end)
            
            roundBtn.MouseButton1Click:Connect(function()
                if mudouDeLugar then return end
                if not _G.MagActiveGodz then return end
                
                if isPulling then
                    isPulling = false
                    playerSendoPuxado = nil
                    roundBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                    btnStroke.Color = Color3.fromRGB(200, 0, 0)
                else
                    if alvoAtual then
                        isPulling = true
                        playerSendoPuxado = alvoAtual
                        roundBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
                        btnStroke.Color = Color3.fromRGB(140, 0, 210)
                    end
                end
            end)
            _G.MagRoundBtn = roundBtn
        else
            isPulling = false
            playerSendoPuxado = nil
            if _G.MagGlobalDrag then _G.MagGlobalDrag:Disconnect() _G.MagGlobalDrag = nil end
            if _G.MagRoundBtn then pcall(function() _G.MagRoundBtn:Destroy() end) _G.MagRoundBtn = nil end
        end
    end

    _G.BtnToggleMagGodz.MouseButton1Click:Connect(function()
        _G.MagActiveGodz = not _G.MagActiveGodz
        atualizarInterface()
    end)

    _G.BtnToggleMagFloatGodz.MouseButton1Click:Connect(function()
        _G.MagFloatActive = not _G.MagFloatActive
        alternarBotaoFlutuanteMag(_G.MagFloatActive)
        atualizarInterface()
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
        alternarBotaoFlutuanteNoclip(_G.NoclipActiveGodz)
        atualizarInterface()
    end)

    -- Conexão do Modo Streamer removida pois o botão foi retirado da interface visual

        local function alternarBotaoFlutuanteFly(ligar)
        if ligar then
            if _G.FlyRoundBtn then pcall(function() _G.FlyRoundBtn:Destroy() end) end
            
            local roundBtn = Instance.new("TextButton")
            roundBtn.Size = UDim2.new(0, 50, 0, 50)
            roundBtn.Position = UDim2.new(0.1, 0, 0.62, 0) 
            roundBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            roundBtn.Text = "🏃‍♂️"
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
                _G.FlyPlatformActiveGodz = true
                roundBtn.Text = "🏃‍♂️"
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
                    if not _G.FlyPlatformActiveGodz or not char or not char.Parent or not char:FindFirstChild("HumanoidRootPart") then return end
                    
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end
                    
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
                _G.FlyPlatformActiveGodz = false
                roundBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                if _G.FlyConnectionGodz then pcall(function() _G.FlyConnectionGodz:Disconnect() end) _G.FlyConnectionGodz = nil end
                if _G.FlyPlatformGodz then pcall(function() _G.FlyPlatformGodz:Destroy() end) _G.FlyPlatformGodz = nil end
            end
            
            roundBtn.MouseButton1Click:Connect(function()
                if _G.FlyPlatformActiveGodz then stopFly() else startFly() end
                atualizarInterface()
            end)
            
            _G.FlyRoundBtn = roundBtn
        else
            _G.FlyPlatformActiveGodz = false
            if _G.FlyConnectionGodz then pcall(function() _G.FlyConnectionGodz:Disconnect() end) _G.FlyConnectionGodz = nil end
            if _G.FlyPlatformGodz then pcall(function() _G.FlyPlatformGodz:Destroy() end) _G.FlyPlatformGodz = nil end
            if _G.FlyGlobalDrag then _G.FlyGlobalDrag:Disconnect() _G.FlyGlobalDrag = nil end
            if _G.FlyRoundBtn then pcall(function() _G.FlyRoundBtn:Destroy() end) _G.FlyRoundBtn = nil end
        end
    end

    local function alternarBotaoFlutuanteFlyAdvanced(ligar)
        if ligar then
            if _G.FlyAdvancedRoundBtn then pcall(function() _G.FlyAdvancedRoundBtn:Destroy() end) end
            
            local roundBtn = Instance.new("TextButton")
            roundBtn.Size = UDim2.new(0, 50, 0, 50)
            roundBtn.Position = UDim2.new(0.1, 0, 0.50, 0) 
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
            btnStroke.Color = Color3.fromRGB(231, 76, 60)
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
            
            if _G.FlyAdvancedGlobalDrag then _G.FlyAdvancedGlobalDrag:Disconnect() end
            _G.FlyAdvancedGlobalDrag = UserInputService.InputChanged:Connect(function(input)
                if input == fDragInput and fDrag then
                    local delta = input.Position - fDragStart
                    roundBtn.Position = UDim2.new(fStartPos.X.Scale, fStartPos.X.Offset + delta.X, fStartPos.Y.Scale, fStartPos.Y.Offset + delta.Y)
                end
            end)
            
            local Players = game:GetService("Players")
            local RunService = game:GetService("RunService")
            local UserInputService = game:GetService("UserInputService")
            local player = Players.LocalPlayer
            local camera = workspace.CurrentCamera
            local PlayerModule = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
            local Controls = PlayerModule:GetControls()
            local FlySpeed = 58

            local function startAdvancedFly()
                local char = player.Character
                if not char then return end
                local root = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not root or not hum then return end

                local oldSpeed = hum.WalkSpeed
                local oldJump = hum.JumpPower
                hum.WalkSpeed = 0
                hum.JumpPower = 0
                local animate = char:FindFirstChild("Animate")
                if animate then animate.Disabled = true end
                for _, track in ipairs(hum:GetPlayingAnimationTracks()) do track:Stop() end

                local movingDown = false
                local inputConnections = {}
                inputConnections.inputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
                    if gpe then return end
                    if input.KeyCode == Enum.KeyCode.LeftShift then movingDown = true end
                end)
                inputConnections.inputEnded = UserInputService.InputEnded:Connect(function(input)
                    if input.KeyCode == Enum.KeyCode.LeftShift then movingDown = false end
                end)

                local flyLoop
                flyLoop = RunService.Heartbeat:Connect(function(dt)
                    if not _G.FlyAdvancedActiveGodz or not char or not char.Parent or not root or not hum then
                        pcall(function()
                            if hum then hum.WalkSpeed = oldSpeed or 16 hum.JumpPower = oldJump or 50 hum:ChangeState(Enum.HumanoidStateType.Landed) end
                            if animate then animate.Disabled = false end
                            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                        end)
                        pcall(function() if inputConnections.inputBegan then inputConnections.inputBegan:Disconnect() end if inputConnections.inputEnded then inputConnections.inputEnded:Disconnect() end end)
                        if flyLoop then flyLoop:Disconnect() end
                        return
                    end
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                    local moveVector = Controls:GetMoveVector()
                    local moveDir = Vector3.new(0, 0, 0)
                    if moveVector.Magnitude > 0 then moveDir = (camera.CFrame.RightVector * moveVector.X) + (camera.CFrame.LookVector * -moveVector.Z) end
                    if hum.Jump or UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                    if movingDown then moveDir = moveDir - Vector3.new(0, 1, 0) end
                    if moveDir.Magnitude > 0 then root.CFrame = root.CFrame + (moveDir.Unit * FlySpeed * dt) end
                    root.CFrame = CFrame.lookAt(root.Position, root.Position + camera.CFrame.LookVector)
                    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end)
                _G.FlyAdvancedConnectionGodz = flyLoop
            end

            roundBtn.MouseButton1Click:Connect(function()
                _G.FlyAdvancedActiveGodz = not _G.FlyAdvancedActiveGodz
                if _G.FlyAdvancedActiveGodz then
                    roundBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                    task.spawn(startAdvancedFly)
                else
                    roundBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                    -- O loop do Heartbeat já cuida da restauração quando _G.FlyAdvancedActiveGodz vira false
                    -- Mas vamos forçar aqui também para garantir
                    pcall(function()
                        local char = player.Character
                        if char then
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if hum then
                                hum.WalkSpeed = 16
                                hum.JumpPower = 50
                                hum:ChangeState(Enum.HumanoidStateType.Landed)
                            end
                            local animate = char:FindFirstChild("Animate")
                            if animate then animate.Disabled = false end
                        end
                    end)
                    if _G.FlyAdvancedConnectionGodz then pcall(function() _G.FlyAdvancedConnectionGodz:Disconnect() end) _G.FlyAdvancedConnectionGodz = nil end
                end
                atualizarInterface()
            end)
            
            _G.FlyAdvancedRoundBtn = roundBtn
        else
            _G.FlyAdvancedActiveGodz = false
            if _G.FlyAdvancedConnectionGodz then pcall(function() _G.FlyAdvancedConnectionGodz:Disconnect() end) _G.FlyAdvancedConnectionGodz = nil end
            if _G.FlyAdvancedGlobalDrag then _G.FlyAdvancedGlobalDrag:Disconnect() _G.FlyAdvancedGlobalDrag = nil end
            if _G.FlyAdvancedRoundBtn then pcall(function() _G.FlyAdvancedRoundBtn:Destroy() end) _G.FlyAdvancedRoundBtn = nil end
        end
    end

    _G.BtnToggleFlyGodz.MouseButton1Click:Connect(function()
        _G.FlyActiveGodz = not _G.FlyActiveGodz
        
        if _G.FlyActiveGodz then
            _G.StatusLabelGodz.Text = "FLY PLATAFORM: ATIVADO"
            _G.StatusLabelGodz.TextColor3 = Color3.fromRGB(46, 204, 113)
            alternarBotaoFlutuanteFly(true)
        else
            _G.StatusLabelGodz.Text = "FLY PLATAFORM: DESATIVADO"
            _G.StatusLabelGodz.TextColor3 = Color3.fromRGB(231, 76, 60)
            alternarBotaoFlutuanteFly(false)
        end
        atualizarInterface()
    end)

    _G.BtnToggleFlyAdvancedGodz.MouseButton1Click:Connect(function()
        _G.FlyAdvancedBtnActiveGodz = not _G.FlyAdvancedBtnActiveGodz
        
        if _G.FlyAdvancedBtnActiveGodz then
            _G.StatusLabelGodz.Text = "FLY AVANÇADO: BOTÃO ATIVADO"
            _G.StatusLabelGodz.TextColor3 = Color3.fromRGB(46, 204, 113)
            alternarBotaoFlutuanteFlyAdvanced(true)
        else
            _G.StatusLabelGodz.Text = "FLY AVANÇADO: BOTÃO DESATIVADO"
            _G.StatusLabelGodz.TextColor3 = Color3.fromRGB(231, 76, 60)
            
            -- Forçar restauração do movimento ao remover o botão
            _G.FlyAdvancedActiveGodz = false
            pcall(function()
                local char = player.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.WalkSpeed = 16
                        hum.JumpPower = 50
                        hum:ChangeState(Enum.HumanoidStateType.Landed)
                    end
                    local animate = char:FindFirstChild("Animate")
                    if animate then animate.Disabled = false end
                end
            end)
            
            alternarBotaoFlutuanteFlyAdvanced(false)
        end
        atualizarInterface()
    end)

    local function alternarBotaoFlutuanteAim(ligar)
        if ligar then
            if _G.AimRoundBtn then pcall(function() _G.AimRoundBtn:Destroy() end) end
            
            local roundBtn = Instance.new("TextButton")
            roundBtn.Size = UDim2.new(0, 50, 0, 50)
            roundBtn.Position = UDim2.new(0.1, 0, 0.38, 0) 
            roundBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            roundBtn.Text = "🎯"
            roundBtn.TextSize = 24
            roundBtn.Font = Enum.Font.Roboto 
            roundBtn.Active = true
            roundBtn.Parent = screenGui
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(1, 0)
            btnCorner.Parent = roundBtn
            
            local btnStroke = Instance.new("UIStroke")
            btnStroke.Color = Color3.fromRGB(155, 89, 182)
            btnStroke.Thickness = 2
            btnStroke.Parent = roundBtn
            
            local aDrag, aDragInput, aDragStart, aStartPos
            roundBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    aDrag = true
                    aDragStart = input.Position
                    aStartPos = roundBtn.Position
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then aDrag = false end
                    end)
                end
            end)
            
            roundBtn.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then aDragInput = input end
            end)
            
            if _G.AimGlobalDrag then _G.AimGlobalDrag:Disconnect() end
            _G.AimGlobalDrag = UserInputService.InputChanged:Connect(function(input)
                if input == aDragInput and aDrag then
                    local delta = input.Position - aDragStart
                    roundBtn.Position = UDim2.new(aStartPos.X.Scale, aStartPos.X.Offset + delta.X, aStartPos.Y.Scale, aStartPos.Y.Offset + delta.Y)
                end
            end)
            
            roundBtn.MouseButton1Click:Connect(function()
                _G.AimbotActiveGodz = not _G.AimbotActiveGodz
                roundBtn.BackgroundColor3 = _G.AimbotActiveGodz and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(35, 35, 35)
                atualizarInterface()
            end)
            
            roundBtn.BackgroundColor3 = _G.AimbotActiveGodz and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(35, 35, 35)
            _G.AimRoundBtn = roundBtn
        else
            if _G.AimGlobalDrag then _G.AimGlobalDrag:Disconnect() _G.AimGlobalDrag = nil end
            if _G.AimRoundBtn then pcall(function() _G.AimRoundBtn:Destroy() end) _G.AimRoundBtn = nil end
        end
    end

    _G.BtnToggleAimFloatGodz.MouseButton1Click:Connect(function()
        _G.AimFloatActive = not _G.AimFloatActive
        alternarBotaoFlutuanteAim(_G.AimFloatActive)
        atualizarInterface()
    end)


    local function encontrarAlvoMaisProximoAimbot()
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

    RunService.Heartbeat:Connect(function()
        if _G.AimbotActiveGodz then
            fovCircle.Visible = true 
            local centroDaTela = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local alvo, visivel = encontrarAlvoMaisProximoAimbot()
            
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

    _G.BtnToggleAimGodz.MouseButton1Click:Connect(function() 
        _G.AimbotActiveGodz = not _G.AimbotActiveGodz 
        atualizarInterface() 
        if _G.AimRoundBtn then 
            _G.AimRoundBtn.BackgroundColor3 = _G.AimbotActiveGodz and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(35, 35, 35)
        end
    end)
    _G.BtnToggleAimPartGodz.MouseButton1Click:Connect(function() _G.AimTargetPart = _G.AimTargetPart == "Head" and "Torso" or "Head" atualizarInterface() end)
    _G.BtnToggleAimTeamGodz.MouseButton1Click:Connect(function() _G.AimTeamCheck = not _G.AimTeamCheck atualizarInterface() end)
    _G.BtnToggleAimKillGodz.MouseButton1Click:Connect(function() _G.AimKillCheck = not _G.AimKillCheck atualizarInterface() end)
    _G.BtnToggleAimWallGodz.MouseButton1Click:Connect(function() _G.AimWallCheck = not _G.AimWallCheck atualizarInterface() end)

    AimFovTextBox.FocusLost:Connect(function()
        local val = tonumber(AimFovTextBox.Text)
        if val then _G.AimFovValue = math.clamp(val, 10, 600) else AimFovTextBox.Text = tostring(_G.AimFovValue) end
        fovCircle.Size = UDim2.new(0, _G.AimFovValue, 0, _G.AimFovValue)
    end)

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
                
                _G.StatusLabelGodz.Text = "Teleportando..."
                _G.StatusLabelGodz.TextColor3 = Color3.fromRGB(230, 126, 34)
                
                task.spawn(function()
                    myRoot.Anchored = true
                    
                    while targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and (myRoot.Position - targetRoot.Position).Magnitude > 4 do
                        local direction = (targetRoot.Position - myRoot.Position).Unit
                        myRoot.CFrame = myRoot.CFrame + (direction * 4) 
                        task.wait(0.05)
                    end
                    
                    myRoot.Anchored = false
                    _G.StatusLabelGodz.Text = "Teleporte concluído!"
                    _G.StatusLabelGodz.TextColor3 = Color3.fromRGB(46, 204, 113)
                end)
            end
        else
            _G.StatusLabelGodz.Text = "Jogador não encontrado!"
            _G.StatusLabelGodz.TextColor3 = Color3.fromRGB(231, 76, 60)
        end
    end)

    local espObjectsCarros = {}
    local renderConnectionsCarros = {}
    local carAddedConnection, carRemovedConnection

    local function limparESPCarro(carro)
        if espObjectsCarros[carro] then
            pcall(function() espObjectsCarros[carro]:Destroy() end)
            espObjectsCarros[carro] = nil
        end
        if renderConnectionsCarros[carro] then
            pcall(function() renderConnectionsCarros[carro]:Disconnect() end)
            renderConnectionsCarros[carro] = nil
        end
    end

    local function criarESPCarro(carro)
        if not _G.EspCarTrack then return end
        if not carro:IsA("Model") and not carro:IsA("BasePart") then return end
        if espObjectsCarros[carro] then return end

        local rootPart = carro.PrimaryPart or carro:FindFirstChild("HumanoidRootPart") or carro:FindFirstChildWhichIsA("BasePart")
        if not rootPart then return end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "CarESP_" .. carro.Name
        billboard.Adornee = rootPart
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true

        local textLabel = Instance.new("TextLabel")
        textLabel.Parent = billboard
        textLabel.BackgroundTransparency = 1
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.Text = carro.Name
        textLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
        textLabel.TextStrokeTransparency = 0
        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.TextScaled = false
        textLabel.TextSize = 14
        textLabel.Font = Enum.Font.Code

        pcall(function() billboard.Parent = EspContainer end)
        espObjectsCarros[carro] = billboard

        renderConnectionsCarros[carro] = RunService.RenderStepped:Connect(function()
            if not carro or not carro.Parent or not rootPart or not rootPart.Parent or not _G.EspCarTrack then
                limparESPCarro(carro)
                return
            end
            
            local myChar = player.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                local distance = math.floor((myChar.HumanoidRootPart.Position - rootPart.Position).Magnitude)
                textLabel.Text = string.format("%s\n[%d m]", carro.Name, distance)
            end
        end)
    end

    local function gerenciarCarESP()
        if _G.EspCarTrack then
            -- Função para verificar se um objeto é um carro
            local function isCarro(obj)
                if obj:IsA("Model") and (obj:FindFirstChild("DriveSeat") or obj:FindFirstChild("VehicleSeat")) then
                    return true
                end
                return false
            end

            -- Rastrear carros existentes em todo o Workspace
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if isCarro(obj) then
                    criarESPCarro(obj)
                end
            end

            -- Conexão para novos carros
            if carAddedConnection then carAddedConnection:Disconnect() end
            carAddedConnection = Workspace.DescendantAdded:Connect(function(obj)
                task.wait(1) -- Esperar carregar componentes
                if isCarro(obj) then
                    criarESPCarro(obj)
                end
            end)

            -- Conexão para remoção
            if carRemovedConnection then carRemovedConnection:Disconnect() end
            carRemovedConnection = Workspace.DescendantRemoving:Connect(function(obj)
                limparESPCarro(obj)
            end)
        else
            if carAddedConnection then carAddedConnection:Disconnect(); carAddedConnection = nil end
            if carRemovedConnection then carRemovedConnection:Disconnect(); carRemovedConnection = nil end
            for carro, _ in pairs(espObjectsCarros) do
                limparESPCarro(carro)
            end
        end
    end

    local espObjectsMoney = {}
    local renderConnectionsMoney = {}
    local moneyAddedConnection, moneyRemovedConnection

    local function limparESPMoney(obj)
        if espObjectsMoney[obj] then
            pcall(function() espObjectsMoney[obj]:Destroy() end)
            espObjectsMoney[obj] = nil
        end
        if renderConnectionsMoney[obj] then
            pcall(function() renderConnectionsMoney[obj]:Disconnect() end)
            renderConnectionsMoney[obj] = nil
        end
    end

    local function criarESPMoney(obj)
        if not _G.EspMoneyTrack then return end
        if espObjectsMoney[obj] then return end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "MoneyESP_" .. obj.Name
        billboard.Adornee = obj
        billboard.Size = UDim2.new(0, 200, 0, 60)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true

        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1
        container.Parent = billboard

        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Parent = container

        local function criarLabel(texto, tamanho, cor)
            local label = Instance.new("TextLabel")
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 0, 15)
            label.Text = texto
            label.TextColor3 = cor
            label.TextStrokeTransparency = 0
            label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            label.TextSize = tamanho
            label.Font = Enum.Font.Code
            label.Parent = container
            return label
        end

        local nomeLabel = criarLabel("Maleta de Dinheiro", 13, Color3.fromRGB(160, 32, 240))
        local localLabel = criarLabel("", 11, Color3.fromRGB(200, 200, 200))
        local distLabel = criarLabel("", 10, Color3.fromRGB(255, 255, 255))

        local localName = "[ DESCONHECIDO ]"
        if obj:IsDescendantOf(Workspace:FindFirstChild("Cassino")) then
            localName = "[ CASSINO ]"
        elseif obj:IsDescendantOf(Workspace:FindFirstChild("Banco")) then
            localName = "[ BANCO ]"
        end
        localLabel.Text = localName

        pcall(function() billboard.Parent = EspContainer end)
        espObjectsMoney[obj] = billboard

        renderConnectionsMoney[obj] = RunService.RenderStepped:Connect(function()
            if not obj or not obj.Parent or not _G.EspMoneyTrack then
                limparESPMoney(obj)
                return
            end
            
            local myChar = player.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                local distance = math.floor((myChar.HumanoidRootPart.Position - obj.Position).Magnitude)
                distLabel.Text = string.format("{ %d studs }", distance)
            end
        end)
    end

    local function gerenciarMoneyESP()
        if _G.EspMoneyTrack then
            local function isMoney(obj)
                return obj.Name == "duffelbagmeshzinha" and (obj:IsDescendantOf(Workspace:FindFirstChild("Cassino")) or obj:IsDescendantOf(Workspace:FindFirstChild("Banco")))
            end

            for _, obj in ipairs(Workspace:GetDescendants()) do
                if isMoney(obj) then criarESPMoney(obj) end
            end

            if moneyAddedConnection then moneyAddedConnection:Disconnect() end
            moneyAddedConnection = Workspace.DescendantAdded:Connect(function(obj)
                task.wait(0.5)
                if isMoney(obj) then criarESPMoney(obj) end
            end)

            if moneyRemovedConnection then moneyRemovedConnection:Disconnect() end
            moneyRemovedConnection = Workspace.DescendantRemoving:Connect(function(obj)
                limparESPMoney(obj)
            end)
        else
            if moneyAddedConnection then moneyAddedConnection:Disconnect(); moneyAddedConnection = nil end
            if moneyRemovedConnection then moneyRemovedConnection:Disconnect(); moneyRemovedConnection = nil end
            for obj, _ in pairs(espObjectsMoney) do limparESPMoney(obj) end
        end
    end

    resetarCoresAbas = function()
        local c = Color3.fromRGB(36, 36, 42) local tc = Color3.fromRGB(160, 160, 170)
        _G.BtnAba1Godz.BackgroundColor3 = c; _G.BtnAba1Godz.TextColor3 = tc
        _G.BtnAba2Godz.BackgroundColor3 = c; _G.BtnAba2Godz.TextColor3 = tc
        _G.BtnAba3Godz.BackgroundColor3 = c; _G.BtnAba3Godz.TextColor3 = tc
        _G.BtnAba4Godz.BackgroundColor3 = c; _G.BtnAba4Godz.TextColor3 = tc
        _G.BtnAba6Godz.BackgroundColor3 = c; _G.BtnAba6Godz.TextColor3 = tc
        _G.BtnAba7Godz.BackgroundColor3 = c; _G.BtnAba7Godz.TextColor3 = tc
        _G.BtnAba8Godz.BackgroundColor3 = c; _G.BtnAba8Godz.TextColor3 = tc
        _G.BtnAba9Godz.BackgroundColor3 = c; _G.BtnAba9Godz.TextColor3 = tc
    end

    atualizarInterface = function()
        resetarCoresAbas()
        
        _G.MainScrollFrameGodz.Visible = false
        _G.EspScrollFrameGodz.Visible = false
        _G.TpScrollFrameGodz.Visible = false
        _G.ClassScrollFrameGodz.Visible = false
        _G.AimScrollFrameGodz.Visible = false
        _G.TpPlyScrollFrameGodz.Visible = false
        _G.OpenScrollFrameGodz.Visible = false
        _G.SystemScrollFrameGodz.Visible = false
        
        _G.BtnToggleESPGodz.BackgroundColor3 = _G.SecureRenderLoop and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        _G.BtnToggleESPGodz.Text = _G.SecureRenderLoop and "DESLIGAR" or "LIGAR"
        _G.ESPLabel.Text = _G.SecureRenderLoop and "LIGAR ESP ✓" or "LIGAR ESP"
        
        _G.BtnToggleBoxGodz.BackgroundColor3 = _G.EspBoxTrack and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        _G.BtnToggleBoxGodz.Text = _G.EspBoxTrack and "DESLIGAR" or "LIGAR"
        _G.BoxLabel.Text = _G.EspBoxTrack and "ESP QUADRO 2D ✓" or "ESP QUADRO 2D"
        
        _G.BtnToggleSkeletonGodz.BackgroundColor3 = _G.EspSkeletonTrack and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        _G.BtnToggleSkeletonGodz.Text = _G.EspSkeletonTrack and "DESLIGAR" or "LIGAR"
        _G.SkeletonLabel.Text = _G.EspSkeletonTrack and "ESP SKELETO + HEAD ✓" or "ESP SKELETO + HEAD"
        
        _G.BtnToggleNameGodz.BackgroundColor3 = _G.EspNameTrack and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        _G.BtnToggleNameGodz.Text = _G.EspNameTrack and "DESLIGAR" or "LIGAR"
        _G.NameLabel.Text = _G.EspNameTrack and "ESP NOME DO PLAYER ✓" or "ESP NOME DO PLAYER"
        
        _G.BtnToggleHealthGodz.BackgroundColor3 = _G.EspHealthTrack and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        _G.BtnToggleHealthGodz.Text = _G.EspHealthTrack and "DESLIGAR" or "LIGAR"
        _G.HealthLabel.Text = _G.EspHealthTrack and "ESP BARRA DE VIDA ✓" or "ESP BARRA DE VIDA"
        
        _G.BtnToggleCarGodz.BackgroundColor3 = _G.EspCarTrack and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        _G.BtnToggleCarGodz.Text = _G.EspCarTrack and "DESLIGAR" or "LIGAR"
        _G.CarLabel.Text = _G.EspCarTrack and "ESP CARROS ✓" or "ESP CARROS"

        _G.BtnToggleMoneyGodz.BackgroundColor3 = _G.EspMoneyTrack and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        _G.BtnToggleMoneyGodz.Text = _G.EspMoneyTrack and "DESLIGAR" or "LIGAR"
        _G.MoneyLabel.Text = _G.EspMoneyTrack and "ESP DINHEIRO ✓" or "ESP DINHEIRO"

        _G.BtnToggleMagGodz.BackgroundColor3 = _G.MagActiveGodz and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        _G.BtnToggleMagGodz.Text = _G.MagActiveGodz and "DESLIGAR" or "LIGAR"
        _G.MagLabel.Text = _G.MagActiveGodz and "SISTEMA MAGNETICO ✓" or "SISTEMA MAGNETICO"

        _G.BtnToggleMagFloatGodz.BackgroundColor3 = _G.MagFloatActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        _G.BtnToggleMagFloatGodz.Text = _G.MagFloatActive and "DESLIGAR" or "LIGAR"
        _G.MagFloatLabel.Text = _G.MagFloatActive and "BOTÃO FLUTUANTE PULL ✓" or "BOTÃO FLUTUANTE PULL"
        
        _G.BtnToggleAimGodz.BackgroundColor3 = _G.AimbotActiveGodz and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        _G.BtnToggleAimGodz.Text = _G.AimbotActiveGodz and "DESLIGAR" or "LIGAR"
        _G.AimbotLabel.Text = _G.AimbotActiveGodz and "SISTEMA AIMBOT ✓" or "SISTEMA AIMBOT"

        _G.BtnToggleAimFloatGodz.BackgroundColor3 = _G.AimFloatActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        _G.BtnToggleAimFloatGodz.Text = _G.AimFloatActive and "DESLIGAR" or "LIGAR"
        _G.AimFloatLabel.Text = _G.AimFloatActive and "BOTÃO FLUTUANTE AIM ✓" or "BOTÃO FLUTUANTE AIM"

        _G.BtnToggleAimPartGodz.Text = _G.AimTargetPart == "Head" and "CABEÇA" or "TORSO"
        _G.BtnToggleAimPartGodz.BackgroundColor3 = _G.AimTargetPart == "Head" and Color3.fromRGB(155, 89, 182) or Color3.fromRGB(230, 126, 34)
        
        _G.BtnToggleAimTeamGodz.BackgroundColor3 = _G.AimTeamCheck and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        _G.BtnToggleAimTeamGodz.Text = _G.AimTeamCheck and "DESLIGAR" or "LIGAR"
        _G.AimTeamLabel.Text = _G.AimTeamCheck and "TEAM CHECK ✓" or "TEAM CHECK"
        
        _G.BtnToggleAimKillGodz.BackgroundColor3 = _G.AimKillCheck and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        _G.BtnToggleAimKillGodz.Text = _G.AimKillCheck and "DESLIGAR" or "LIGAR"
        _G.AimKillLabel.Text = _G.AimKillCheck and "KILL CHECK ✓" or "KILL CHECK"
        
        _G.BtnToggleAimWallGodz.BackgroundColor3 = _G.AimWallCheck and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        _G.BtnToggleAimWallGodz.Text = _G.AimWallCheck and "DESLIGAR" or "LIGAR"
        _G.AimWallLabel.Text = _G.AimWallCheck and "WALL CHECK ✓" or "WALL CHECK"
        
        _G.BtnToggleFlyGodz.BackgroundColor3 = _G.FlyActiveGodz and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        _G.BtnToggleFlyGodz.Text = _G.FlyActiveGodz and "BOTÃO ON" or "BOTÃO OFF"
        _G.FlyLabel.Text = _G.FlyActiveGodz and "FLY PLATAFORM ✓" or "FLY PLATAFORM"
        
        if _G.FlyRoundBtn then
            _G.FlyRoundBtn.BackgroundColor3 = _G.FlyPlatformActiveGodz and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(35, 35, 35)
        end

        _G.BtnToggleFlyAdvancedGodz.BackgroundColor3 = _G.FlyAdvancedBtnActiveGodz and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        _G.BtnToggleFlyAdvancedGodz.Text = _G.FlyAdvancedBtnActiveGodz and "BOTÃO ON" or "BOTÃO OFF"
        _G.FlyAdvancedLabel.Text = _G.FlyAdvancedBtnActiveGodz and "FLY AVANÇADO ✓" or "FLY AVANÇADO"
        
        if _G.FlyAdvancedRoundBtn then
            _G.FlyAdvancedRoundBtn.BackgroundColor3 = _G.FlyAdvancedActiveGodz and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(35, 35, 35)
        end

        _G.BtnToggleNoclipGodz.BackgroundColor3 = _G.NoclipActiveGodz and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        _G.BtnToggleNoclipGodz.Text = _G.NoclipActiveGodz and "DESLIGAR" or "LIGAR"
        _G.NoclipLabel.Text = _G.NoclipActiveGodz and "BOTÃO FLUTUANTE NOCLIP ✓" or "BOTÃO FLUTUANTE NOCLIP"
        
        -- Atualizar botões de TP e Open
        _G.BtnTpPlayerGodz.Text = "TP"
        _G.BtnOpenFabrica.Text = "OPEN"
        _G.BtnOpenMercadoNegro.Text = "OPEN"
        _G.BtnOpenMercadinho.Text = "OPEN"
        
        -- Atualizar botões de Classe
        _G.BtnClassGcm.Text = "SET"
        _G.BtnClassCaminhoneiro.Text = "SET"
        _G.BtnClassCivil.Text = "SET"
        _G.BtnClassLixeiro.Text = "SET"
        _G.BtnClassFood.Text = "SET"
        
        -- Modo Streamer removido da interface visual
        
        if paginaAtual == 1 then
            _G.BtnAba1Godz.BackgroundColor3 = Color3.fromRGB(231, 76, 60); _G.BtnAba1Godz.TextColor3 = Color3.fromRGB(255, 255, 255)
            _G.MainScrollFrameGodz.Visible = true
            _G.StatusLabelGodz.Text = "Menu Principal Combinado"
            _G.StatusLabelGodz.TextColor3 = Color3.fromRGB(255, 255, 255)
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
            _G.BtnAba6Godz.BackgroundColor3 = Color3.fromRGB(231, 76, 60); _G.BtnAba6Godz.TextColor3 = Color3.fromRGB(255, 255, 255)
            _G.AimScrollFrameGodz.Visible = true
            _G.StatusLabelGodz.Text = _G.AimbotActiveGodz and "Aimbot Ativo: Travando Alvos" or "Configurações de Auxílio de Mira"
            _G.StatusLabelGodz.TextColor3 = _G.AimbotActiveGodz and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(255, 255, 255)
        elseif paginaAtual == 6 then
            _G.BtnAba7Godz.BackgroundColor3 = Color3.fromRGB(231, 76, 60); _G.BtnAba7Godz.TextColor3 = Color3.fromRGB(255, 255, 255)
            _G.TpPlyScrollFrameGodz.Visible = true
            _G.StatusLabelGodz.Text = "Teleporte até Jogadores"
            _G.StatusLabelGodz.TextColor3 = Color3.fromRGB(255, 255, 255)
        elseif paginaAtual == 7 then
            _G.BtnAba8Godz.BackgroundColor3 = Color3.fromRGB(231, 76, 60); _G.BtnAba8Godz.TextColor3 = Color3.fromRGB(255, 255, 255)
            _G.OpenScrollFrameGodz.Visible = true
            _G.StatusLabelGodz.Text = "Abrir Locais do Server"
            _G.StatusLabelGodz.TextColor3 = Color3.fromRGB(255, 255, 255)
        elseif paginaAtual == 8 then
            _G.BtnAba9Godz.BackgroundColor3 = Color3.fromRGB(231, 76, 60); _G.BtnAba9Godz.TextColor3 = Color3.fromRGB(255, 255, 255)
            _G.SystemScrollFrameGodz.Visible = true
            _G.StatusLabelGodz.Text = _G.StreamerModeActiveGodz and "Modo Streamer: ATIVADO" or "Configurações do Sistema"
            _G.StatusLabelGodz.TextColor3 = _G.StreamerModeActiveGodz and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(255, 255, 255)
        end
        
        if _G.AimbotActiveGodz then fovCircle.Visible = true else fovCircle.Visible = false end
    end

    _G.BtnAba1Godz.MouseButton1Click:Connect(function() paginaAtual = 1 atualizarInterface() end)
    _G.BtnAba2Godz.MouseButton1Click:Connect(function() paginaAtual = 2 atualizarInterface() end)
    _G.BtnAba3Godz.MouseButton1Click:Connect(function() paginaAtual = 3 atualizarInterface() end)
    _G.BtnAba4Godz.MouseButton1Click:Connect(function() paginaAtual = 4 atualizarInterface() end)
    _G.BtnAba6Godz.MouseButton1Click:Connect(function() paginaAtual = 5 atualizarInterface() end)
    _G.BtnAba7Godz.MouseButton1Click:Connect(function() paginaAtual = 6 atualizarInterface() end)
    _G.BtnAba8Godz.MouseButton1Click:Connect(function() paginaAtual = 7 atualizarInterface() end)
    _G.BtnAba9Godz.MouseButton1Click:Connect(function() paginaAtual = 8 atualizarInterface() end)

    SpeedTextBox.FocusLost:Connect(function()
        local val = tonumber(SpeedTextBox.Text)
        if val then _G.SpeedBypassValue = math.clamp(val, 16, 60) else SpeedTextBox.Text = tostring(_G.SpeedBypassValue) end
        atualizarInterface()
    end)

    _G.BtnToggleSpeedGodz.MouseButton1Click:Connect(function()
        _G.SecureSpeedLoop = not _G.SecureSpeedLoop
        _G.BtnToggleSpeedGodz.BackgroundColor3 = _G.SecureSpeedLoop and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        _G.BtnToggleSpeedGodz.Text = _G.SecureSpeedLoop and "DESLIGAR" or "LIGAR"
        _G.SpeedLabel.Text = _G.SecureSpeedLoop and "SPEED BYPESS ✓" or "SPEED BYPESS"
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

    _G.BtnToggleCarGodz.MouseButton1Click:Connect(function()
        _G.EspCarTrack = not _G.EspCarTrack
        atualizarInterface()
        gerenciarCarESP()
    end)

    _G.BtnToggleMoneyGodz.MouseButton1Click:Connect(function()
        _G.EspMoneyTrack = not _G.EspMoneyTrack
        atualizarInterface()
        gerenciarMoneyESP()
    end)

    -- ADICIONADO: Nova função "ocultar" posicionada conforme solicitado
    local function ocultar(targetName)
        if targetName ~= "" then
            local encontrado = false
            for _, p in pairs(Players:GetPlayers()) do
                if p.Name:lower():sub(1, #targetName) == targetName:lower() or (p.DisplayName and p.DisplayName:lower():sub(1, #targetName) == targetName:lower()) then
                    _G.EspNomesOcultos[p.Name:lower()] = true
                    _G.StatusLabelGodz.Text = "Nome modificado: " .. p.Name
                    _G.StatusLabelGodz.TextColor3 = Color3.fromRGB(46, 204, 113)
                    OcultarNameTextBox.Text = ""
                    encontrado = true
                    break
                end
            end
            if not encontrado then
                _G.StatusLabelGodz.Text = "Jogador não encontrado!"
                _G.StatusLabelGodz.TextColor3 = Color3.fromRGB(231, 76, 60)
            end
        end
    end

    -- ADICIONADO: Lógica do clique do botão ocultar nome refatorada para chamar a nova função
    BtnOcultarNameGodz.MouseButton1Click:Connect(function()
        ocultar(OcultarNameTextBox.Text)
    end)

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

    _G.BtnTpOrg.MouseButton1Click:Connect(function()
        pcall(function()
            local Event = ReplicatedStorage:FindFirstChild("InGameRemotes") and ReplicatedStorage.InGameRemotes:FindFirstChild("SpawnaTeleporte")
            if Event and Event:IsA("RemoteEvent") then
                Event:FireServer("Org")
                _G.StatusLabelGodz.Text = "Teleporte Enviado: Organização!"
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
            _G.SecureSpeedLoop = false; _G.SecureRenderLoop = false; _G.AimbotActiveGodz = false; _G.FlyAdvancedActiveGodz = false; _G.FlyPlatformActiveGodz = false
            _G.EspCarTrack = false 
            _G.MagActiveGodz = false
            _G.MagFloatActive = false
            
            pcall(function() RunService:UnbindFromRenderStep("AimbotMobileLock") end)
            if _G.NoclipRoundBtn then pcall(function() _G.NoclipRoundBtn:Destroy() end) end
            if _G.FlyRoundBtn then pcall(function() _G.FlyRoundBtn:Destroy() end) end
            if _G.FlyAdvancedRoundBtn then pcall(function() _G.FlyAdvancedRoundBtn:Destroy() end) end
            if _G.AimRoundBtn then pcall(function() _G.AimRoundBtn:Destroy() end) end
            if _G.MagRoundBtn then pcall(function() _G.MagRoundBtn:Destroy() end) end
            
            if _G.FlyConnectionGodz then pcall(function() _G.FlyConnectionGodz:Disconnect() end) end
            if _G.FlyAdvancedConnectionGodz then 
                pcall(function() _G.FlyAdvancedConnectionGodz:Disconnect() end)
                -- Restaurar estado ao destruir
                pcall(function()
                    local char = player.Character
                    if char then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            hum.WalkSpeed = 16
                            hum.JumpPower = 50
                        end
                        local animate = char:FindFirstChild("Animate")
                        if animate then animate.Disabled = false end
                    end
                end)
            end
            if _G.FlyPlatformGodz then pcall(function() _G.FlyPlatformGodz:Destroy() end) end
            if fovCircle then pcall(function() fovCircle:Destroy() end) end
            if aimTracer then pcall(function() aimTracer:Destroy() end) end
            if linhaESP then pcall(function() linhaESP:Remove() end) end
            
            clearAllESP()
            gerenciarCarESP() 
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

    _G.BtnOpenFabrica.MouseButton1Click:Connect(function()
        pcall(function()
            local Event = game:GetService("ReplicatedStorage").FabricaRemotes.AbreFabrica
            firesignal(Event.OnClientEvent)
            _G.StatusLabelGodz.Text = "Fábrica de Arma aberta!"
            _G.StatusLabelGodz.TextColor3 = Color3.fromRGB(46, 204, 113)
        end)
    end)

    _G.BtnOpenMercadoNegro.MouseButton1Click:Connect(function()
        pcall(function()
            local Event = game:GetService("ReplicatedStorage").Mercadinho.AbreMercadoNegro
            firesignal(Event.OnClientEvent)
            _G.StatusLabelGodz.Text = "Mercado Negro aberto!"
            _G.StatusLabelGodz.TextColor3 = Color3.fromRGB(46, 204, 113)
        end)
    end)

    _G.BtnOpenMercadinho.MouseButton1Click:Connect(function()
        pcall(function()
            local Event = game:GetService("ReplicatedStorage").Mercadinho.AbreMercado
            firesignal(Event.OnClientEvent)
            _G.StatusLabelGodz.Text = "Mercadinho aberto!"
            _G.StatusLabelGodz.TextColor3 = Color3.fromRGB(46, 204, 113)
        end)
    end)

    atualizarInterface()
end)

-- =============================================================================
-- [2] THREAD DO SEGUNDO SCRIPT (STAFF TRACKER SYSTEM)
-- =============================================================================
task.spawn(function()
    -- [[ CONFIGURAÇÕES GERAIS ]]
    local TEAM_NAME = "STAFF"                  
    local SOUND_ID = "rbxassetid://2865227271"  
    local NOTIFY_ICON = "rbxassetid://6034287525" 

    -- [[ SERVIÇOS ]]
    local Players = game:GetService("Players")
    local Teams = game:GetService("Teams")
    local StarterGui = game:GetService("StarterGui")
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")

    -- [[ CRIAÇÃO DA UI ]]
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "StaffTrackerSystem"
    ScreenGui.ResetOnSpawn = false

    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 140, 0, 40)
    MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0) 
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    local UIBorder = Instance.new("UIStroke")
    UIBorder.Color = Color3.fromRGB(60, 60, 60)
    UIBorder.Thickness = 1
    UIBorder.Parent = MainFrame

    local CounterLabel = Instance.new("TextLabel")
    CounterLabel.Size = UDim2.new(1, 0, 1, 0)
    CounterLabel.BackgroundTransparency = 1
    CounterLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    CounterLabel.TextSize = 14
    CounterLabel.Font = Enum.Font.GothamBold
    CounterLabel.Text = "STAFFs: O"
    CounterLabel.Parent = MainFrame

    local AlertSound = Instance.new("Sound")
    AlertSound.SoundId = SOUND_ID
    AlertSound.Volume = 1
    AlertSound.Parent = MainFrame

    -- [[ SISTEMA ARRASTÁVEL (DRAGGABLE) ]]
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)

    -- [[ LÓGICA DE DETECÇÃO ]]
    local function getStaffCount()
        local count = 0
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Team and player.Team.Name == TEAM_NAME then
                count = count + 1
            end
        end
        return count
    end

    local function updateDisplay()
        local currentStaff = getStaffCount()
        CounterLabel.Text = "STAFFs Online: " .. currentStaff
        
        if currentStaff > 0 then
            CounterLabel.TextColor3 = Color3.fromRGB(255, 75, 75) 
        else
            CounterLabel.TextColor3 = Color3.fromRGB(255, 255, 255) 
        end
    end

    local function notifyStaffJoined(player)
        StarterGui:SetCore("SendNotification", {
            Title = "⚠️ ADM NO SERVER!",
            Text = player.Name .. " entrou para o time STAFF.",
            Duration = 6,
            Icon = NOTIFY_ICON
        })
        AlertSound:Play()
    end

    local function setupPlayerTracking(player)
        player:GetPropertyChangedSignal("Team"):Connect(function()
            updateDisplay()
            if player.Team and player.Team.Name == TEAM_NAME then
                notifyStaffJoined(player)
            end
        end)
    end

    for _, player in ipairs(Players:GetPlayers()) do
        setupPlayerTracking(player)
    end

    Players.PlayerAdded:Connect(function(player)
        setupPlayerTracking(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        task.wait(0.2) 
        updateDisplay()
    end)

    updateDisplay()
end)
