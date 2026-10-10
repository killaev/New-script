--[==[
    REDCLIFF CITY RP
    TACTICAL LASER + FLASHLIGHT SYSTEM

    REDESIGN PREMIUM — VERTICAL HAND GRIP
    FRONT LENS EMITTER + FLUSH WARNING LABELS

    MANTIDO:
    - Base original do módulo
    - Hand grip vertical com nervuras antiderrapantes
    - Laser verde e feixe físico
    - Ajustes originais de posição e rotação
    - Interface LASER / LANTERNA / AMBOS
    - Marca OLIGHT

    CORRIGIDO:
    - Lente frontal com dimensões cilíndricas corretas
    - Lanterna emitindo pela lente frontal
    - Laser originando na frente da mesma lente
    - Emissor luminoso invisível, sem peça flutuante
    - Adesivos DANGER e LASER WARNING junto às laterais
    - Ponto verde do módulo não cobre a lente
]==]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

--==================================================
-- CONFIGURAÇÃO
--==================================================

local LaserRange = 150
local LaserDotSize = 0.14
local LaserDotColor = Color3.fromRGB(0, 255, 0)

local LaserRightAngle = -3.5
local LaserDownAngle = 24.0

local EmitterColor = Color3.fromRGB(18, 19, 19)
local EmitterTopColor = Color3.fromRGB(27, 28, 28)
local EmitterFrontColor = Color3.fromRGB(12, 13, 13)
local EmitterLensColor = Color3.fromRGB(3, 4, 4)
local EmitterDetailColor = Color3.fromRGB(9, 10, 10)
local EmitterEdgeColor = Color3.fromRGB(31, 32, 32)

local EmitterSize = Vector3.new(0.25, 0.19, 0.36)

local EmitterForwardOffset = 0.12
local EmitterSideOffset = 0.02
local EmitterVerticalOffset = 0.24

local EmitterRightAngle = -3.0
local ShowEmitter = true
local BrandName = "OLIGHT"

local FlashBrightness = 5
local FlashRange = 35
local FlashAngle = 55
local FlashColor = Color3.fromRGB(255, 255, 255)

-- O emissor é apenas um suporte invisível para a luz.
local FlashEmitterSize = Vector3.new(0.01, 0.01, 0.01)

-- Mantidos para compatibilidade com a configuração original.
local FlashEmitterForwardOffset = 0.035
local FlashEmitterVerticalOffset = -0.065

-- Hand grip vertical
local GripWidth = 0.105
local GripLength = 0.32
local GripDepth = 0.105
local GripDrop = 0.285

-- Posição frontal da lente e da saída óptica.
local LensCenterZ = -0.311
local LensDepth = 0.018
local LensFrontZ = LensCenterZ - LensDepth / 2
local OpticalExitOffset = 0.002

--==================================================
-- ESTADO
--==================================================

local LaserEnabled = false
local FlashlightEnabled = false

local CurrentTool
local CurrentHandle

local CurrentEmitter
local CurrentEmitterFront
local CurrentEmitterLens
local CurrentEmitterGreenDot
local CurrentEmitterGreenLight

local CurrentFlashEmitter
local CurrentFlashBall
local CurrentFlashlight

local CurrentDot
local CurrentDotLight

local CurrentLaserBeam
local CurrentLaserBeamStart
local CurrentLaserBeamEnd

local RenderConnection
local CharacterConnections = {}
local DetailParts = {}
local WatchedTools = {}

--==================================================
-- INTERFACE
--==================================================

local PlayerGui = Player:WaitForChild("PlayerGui")

local OldGui = PlayerGui:FindFirstChild("TacticalAttachmentUI")
if OldGui then
    OldGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TacticalAttachmentUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 210, 0, 180)
MainFrame.Position = UDim2.new(0, 15, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -45, 0, 35)
Title.Position = UDim2.new(0, 12, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "TACTICAL SYSTEM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 17
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 25
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = MainFrame

local function CreateButton(Name, Text, Y)
    local Button = Instance.new("TextButton")
    Button.Name = Name
    Button.Size = UDim2.new(1, -24, 0, 38)
    Button.Position = UDim2.new(0, 12, 0, Y)
    Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Button.BorderSizePixel = 0
    Button.Text = Text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamBold
    Button.Parent = MainFrame

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 7)
    Corner.Parent = Button

    return Button
end

local LaserButton = CreateButton("LaserButton", "LASER: OFF", 45)
local FlashButton = CreateButton("FlashButton", "LANTERNA: OFF", 88)
local BothButton = CreateButton("BothButton", "AMBOS: OFF", 131)

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.new(0, 55, 0, 55)
OpenButton.Position = UDim2.new(0, 15, 0.5, -27)
OpenButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
OpenButton.BorderSizePixel = 0
OpenButton.Text = "⚙"
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.TextSize = 25
OpenButton.Font = Enum.Font.GothamBold
OpenButton.Visible = false
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenButton.Visible = false
end)

--==================================================
-- DETECÇÃO DA ARMA
--==================================================

local function IsPistol(Tool)
    if not Tool or not Tool:IsA("Tool") then
        return false
    end

    if Tool:GetAttribute("IsGun") == true
        or Tool:GetAttribute("IsPistol") == true then
        return true
    end

    local Name = string.lower(Tool.Name)

    local Keywords = {
        "pistol", "gun", "glock", "revolver",
        "deagle", "desert", "beretta", "usp",
        "1911", "handgun"
    }

    for _, Word in ipairs(Keywords) do
        if string.find(Name, Word, 1, true) then
            return true
        end
    end

    return Tool:FindFirstChild("Handle") ~= nil
end

local function FindHandle(Tool)
    if not Tool then
        return nil
    end

    local Handle = Tool:FindFirstChild("Handle")

    if Handle and Handle:IsA("BasePart") then
        return Handle
    end

    for _, Object in ipairs(Tool:GetDescendants()) do
        if Object:IsA("BasePart") then
            return Object
        end
    end

    return nil
end

local function FindMuzzle(Tool)
    if not Tool then
        return nil
    end

    local Names = {
        muzzle = true,
        muzzleattachment = true,
        laserpoint = true,
        laserattachment = true
    }

    for _, Object in ipairs(Tool:GetDescendants()) do
        if Object:IsA("Attachment")
            and Names[string.lower(Object.Name)] then
            return Object
        end
    end

    return nil
end

local function CalculateWeaponDirection(Tool, Handle)
    if not Handle then
        return Vector3.new(0, 0, -1)
    end

    local Muzzle = FindMuzzle(Tool)

    if Muzzle then
        local Difference = Muzzle.WorldPosition - Handle.Position

        if Difference.Magnitude > 0.01 then
            return Difference.Unit
        end
    end

    local FurthestPart
    local FurthestDistance = 0

    for _, Object in ipairs(Tool:GetDescendants()) do
        if Object:IsA("BasePart") and Object ~= Handle then
            local Name = string.lower(Object.Name)

            local Ignore =
                string.find(Name, "grip", 1, true)
                or string.find(Name, "handle", 1, true)
                or string.find(Name, "mag", 1, true)
                or string.find(Name, "trigger", 1, true)

            if not Ignore then
                local Distance =
                    (Object.Position - Handle.Position).Magnitude

                if Distance > FurthestDistance then
                    FurthestDistance = Distance
                    FurthestPart = Object
                end
            end
        end
    end

    if FurthestPart then
        local Difference = FurthestPart.Position - Handle.Position

        if Difference.Magnitude > 0.01 then
            return Difference.Unit
        end
    end

    return Handle.CFrame.LookVector
end

local function ApplyLaserAdjustment(Direction, Handle)
    if not Handle then
        return Direction
    end

    local RightAngle = math.rad(LaserRightAngle)

    Direction = (
        Direction * math.cos(RightAngle)
        + Handle.CFrame.RightVector * math.sin(RightAngle)
    ).Unit

    local DownAngle = math.rad(LaserDownAngle)

    Direction = (
        Direction * math.cos(DownAngle)
        - Handle.CFrame.UpVector * math.sin(DownAngle)
    ).Unit

    return Direction
end

local function ApplyEmitterVisualAngle(Direction, Handle)
    if not Handle then
        return Direction
    end

    return (
        CFrame.fromAxisAngle(
            Handle.CFrame.UpVector,
            math.rad(EmitterRightAngle)
        ):VectorToWorldSpace(Direction)
    ).Unit
end

local function CalculateEmitterPosition(Tool, Handle, Direction)
    if not Handle then
        return Vector3.zero
    end

    local Muzzle = FindMuzzle(Tool)
    local Position

    if Muzzle then
        Position = Muzzle.WorldPosition
    else
        Position = Handle.Position
            + Direction * (Handle.Size.Z / 2 + EmitterForwardOffset)
    end

    Position += Direction * EmitterForwardOffset
    Position += Handle.CFrame.RightVector * EmitterSideOffset
    Position += Handle.CFrame.UpVector * EmitterVerticalOffset

    return Position
end

--==================================================
-- CRIAÇÃO DAS PEÇAS
--==================================================

local function CreatePart(Name, Size, Color, Material, Shape)
    local Part = Instance.new("Part")
    Part.Name = Name
    Part.Size = Size
    Part.Color = Color
    Part.Material = Material or Enum.Material.SmoothPlastic
    Part.Anchored = true
    Part.CanCollide = false
    Part.CanTouch = false
    Part.CanQuery = false
    Part.CastShadow = false
    Part.TopSurface = Enum.SurfaceType.Smooth
    Part.BottomSurface = Enum.SurfaceType.Smooth

    if Shape then
        Part.Shape = Shape
    end

    Part.Parent = Workspace
    return Part
end

local function AddDetail(Name, Size, Color, Material, Offset, Shape)
    local Part = CreatePart(Name, Size, Color, Material, Shape)

    table.insert(DetailParts, {
        Part = Part,
        Offset = Offset
    })

    return Part
end

local function UpdateDetails(BaseCF)
    for _, Detail in ipairs(DetailParts) do
        if Detail.Part and Detail.Part.Parent then
            Detail.Part.CFrame = BaseCF * Detail.Offset
        end
    end
end

local function CreateBrandMark(Emitter)
    local Gui = Instance.new("SurfaceGui")
    Gui.Name = "TacticalBrandMark"
    Gui.Face = Enum.NormalId.Right
    Gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    Gui.PixelsPerStud = 180
    Gui.LightInfluence = 1
    Gui.Parent = Emitter

    local Brand = Instance.new("TextLabel")
    Brand.Size = UDim2.fromScale(1, 1)
    Brand.BackgroundTransparency = 1
    Brand.Text = BrandName
    Brand.TextColor3 = Color3.fromRGB(115, 115, 115)
    Brand.TextTransparency = 0.18
    Brand.TextScaled = true
    Brand.Font = Enum.Font.GothamBlack
    Brand.TextStrokeTransparency = 0.65
    Brand.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    Brand.Parent = Gui

    return Gui
end

local function CreateWarningLabel(Part)
    local Gui = Instance.new("SurfaceGui")
    Gui.Name = "LaserSafetyLabel"
    Gui.Face = Enum.NormalId.Right
    Gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    Gui.PixelsPerStud = 250
    Gui.LightInfluence = 0.15
    Gui.Parent = Part

    local Background = Instance.new("Frame")
    Background.Size = UDim2.fromScale(1, 1)
    Background.BackgroundColor3 = Color3.fromRGB(218, 177, 34)
    Background.BorderSizePixel = 0
    Background.Parent = Gui

    local Border = Instance.new("UIStroke")
    Border.Color = Color3.fromRGB(20, 20, 20)
    Border.Thickness = 2
    Border.Parent = Background

    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.fromScale(1, 1)
    Text.BackgroundTransparency = 1
    Text.Text = "LASER WARNING"
    Text.TextColor3 = Color3.fromRGB(20, 20, 16)
    Text.TextScaled = true
    Text.Font = Enum.Font.GothamBlack
    Text.Parent = Background

    return Gui
end

local function CreateDangerLabel(Part)
    local Gui = Instance.new("SurfaceGui")
    Gui.Name = "DangerWarningLabel"
    Gui.Face = Enum.NormalId.Left
    Gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    Gui.PixelsPerStud = 250
    Gui.LightInfluence = 0.1
    Gui.Parent = Part

    local Background = Instance.new("Frame")
    Background.Size = UDim2.fromScale(1, 1)
    Background.BackgroundColor3 = Color3.fromRGB(150, 20, 20)
    Background.BorderSizePixel = 0
    Background.Parent = Gui

    local Border = Instance.new("UIStroke")
    Border.Color = Color3.fromRGB(0, 0, 0)
    Border.Thickness = 2
    Border.Parent = Background

    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.fromScale(1, 1)
    Text.BackgroundTransparency = 1
    Text.Text = "DANGER"
    Text.TextColor3 = Color3.fromRGB(0, 0, 0)
    Text.TextScaled = true
    Text.Font = Enum.Font.GothamBlack
    Text.TextStrokeTransparency = 0.8
    Text.Parent = Background

    return Gui
end

--==================================================
-- CRIAÇÃO DO MÓDULO
--==================================================

local function CreateEmitter(Tool, Handle, Direction, VisualDirection)
    table.clear(DetailParts)

    local Position = CalculateEmitterPosition(Tool, Handle, Direction)
    local BaseCF = CFrame.lookAt(Position, Position + VisualDirection)

    local Black = Color3.fromRGB(10, 11, 11)
    local DarkMetal = Color3.fromRGB(22, 23, 23)
    local EdgeMetal = Color3.fromRGB(43, 44, 43)
    local Steel = Color3.fromRGB(58, 59, 57)
    local Rubber = Color3.fromRGB(17, 18, 18)
    local RibColor = Color3.fromRGB(35, 36, 36)

    local Emitter = CreatePart(
        "TacticalLaserBody",
        EmitterSize,
        EmitterColor,
        Enum.Material.SmoothPlastic
    )

    Emitter.Transparency = ShowEmitter and 0 or 1
    Emitter.CFrame = BaseCF

    CreateBrandMark(Emitter)

    -- ARMADURA SUPERIOR
    AddDetail(
        "UpperArmorPlate",
        Vector3.new(0.205, 0.035, 0.265),
        EmitterTopColor,
        Enum.Material.Metal,
        CFrame.new(0, 0.112, 0.012)
    )

    AddDetail(
        "UpperRailFoundation",
        Vector3.new(0.13, 0.018, 0.235),
        Black,
        Enum.Material.Metal,
        CFrame.new(0, 0.139, 0.015)
    )

    for i = 0, 6 do
        AddDetail(
            "RailTooth_" .. i,
            Vector3.new(0.145, 0.012, 0.014),
            Steel,
            Enum.Material.Metal,
            CFrame.new(0, 0.153, -0.085 + i * 0.033)
        )
    end

    -- LATERAIS REFORÇADAS
    AddDetail(
        "LeftArmorRail",
        Vector3.new(0.024, 0.115, 0.29),
        DarkMetal,
        Enum.Material.Metal,
        CFrame.new(-0.137, 0, 0.012)
    )

    AddDetail(
        "RightArmorRail",
        Vector3.new(0.024, 0.115, 0.29),
        DarkMetal,
        Enum.Material.Metal,
        CFrame.new(0.137, 0, 0.012)
    )

    AddDetail(
        "LeftSideInset",
        Vector3.new(0.009, 0.064, 0.185),
        EmitterDetailColor,
        Enum.Material.SmoothPlastic,
        CFrame.new(-0.151, 0, 0.01)
    )

    AddDetail(
        "RightSideInset",
        Vector3.new(0.009, 0.064, 0.185),
        EmitterDetailColor,
        Enum.Material.SmoothPlastic,
        CFrame.new(0.151, 0, 0.01)
    )

    -- PERFIL ANGULAR
    AddDetail(
        "RightAngularShoulder",
        Vector3.new(0.052, 0.105, 0.205),
        Black,
        Enum.Material.Metal,
        CFrame.new(0.163, 0.015, -0.008)
    )

    AddDetail(
        "RightTriangularUpperSlope",
        Vector3.new(0.065, 0.045, 0.135),
        EdgeMetal,
        Enum.Material.Metal,
        CFrame.new(0.184, 0.068, -0.035)
            * CFrame.Angles(0, 0, math.rad(-17))
    )

    AddDetail(
        "RightTriangularLowerSlope",
        Vector3.new(0.065, 0.038, 0.145),
        DarkMetal,
        Enum.Material.Metal,
        CFrame.new(0.184, -0.061, 0.035)
            * CFrame.Angles(0, 0, math.rad(17))
    )

    AddDetail(
        "RightRaisedSideSpine",
        Vector3.new(0.014, 0.018, 0.19),
        Steel,
        Enum.Material.Metal,
        CFrame.new(0.218, 0.005, 0.005)
    )

    for i = 1, 3 do
        AddDetail(
            "SideCoolingRib_" .. i,
            Vector3.new(0.012, 0.012, 0.058),
            Steel,
            Enum.Material.Metal,
            CFrame.new(0.224, -0.018, -0.052 + i * 0.044)
        )
    end

    -- PLACA TRASEIRA
    AddDetail(
        "ReinforcedRearPlate",
        Vector3.new(0.225, 0.16, 0.026),
        Black,
        Enum.Material.Metal,
        CFrame.new(0, 0, 0.194)
    )

    AddDetail(
        "RearPlateInset",
        Vector3.new(0.175, 0.112, 0.008),
        DarkMetal,
        Enum.Material.Metal,
        CFrame.new(0, 0, 0.211)
    )

    for Side = -1, 1, 2 do
        for Row = -1, 1, 2 do
            AddDetail(
                "RearFastener_" .. Side .. "_" .. Row,
                Vector3.new(0.018, 0.018, 0.009),
                Steel,
                Enum.Material.Metal,
                CFrame.new(Side * 0.078, Row * 0.044, 0.218),
                Enum.PartType.Cylinder
            )
        end
    end

    --==================================================
    -- CABEÇA FRONTAL E LENTE
    --==================================================

    local Front = CreatePart(
        "TacticalLaserFront",
        Vector3.new(0.18, 0.145, 0.055),
        EmitterFrontColor,
        Enum.Material.Metal
    )

    Front.CFrame = BaseCF * CFrame.new(0, 0, -0.207)

    -- O eixo local X do cilindro é o seu eixo longitudinal.
    -- Por isso, a primeira dimensão representa a espessura.
    local CylinderRotation = CFrame.Angles(0, math.rad(90), 0)

    AddDetail(
        "FlashlightHeadOuterBezel",
        Vector3.new(0.032, 0.158, 0.158),
        Color3.fromRGB(27, 28, 28),
        Enum.Material.Metal,
        CFrame.new(0, 0, -0.239) * CylinderRotation,
        Enum.PartType.Cylinder
    )

    AddDetail(
        "FlashlightHeadRim",
        Vector3.new(0.018, 0.139, 0.139),
        Color3.fromRGB(65, 66, 64),
        Enum.Material.Metal,
        CFrame.new(0, 0, -0.257) * CylinderRotation,
        Enum.PartType.Cylinder
    )

    AddDetail(
        "FlashlightHeadInnerRing",
        Vector3.new(0.014, 0.119, 0.119),
        Color3.fromRGB(12, 13, 13),
        Enum.Material.Metal,
        CFrame.new(0, 0, -0.273) * CylinderRotation,
        Enum.PartType.Cylinder
    )

    AddDetail(
        "FlashlightReflector",
        Vector3.new(0.012, 0.098, 0.098),
        Color3.fromRGB(42, 43, 42),
        Enum.Material.Metal,
        CFrame.new(0, 0, -0.288) * CylinderRotation,
        Enum.PartType.Cylinder
    )

    AddDetail(
        "FlashlightReflectorCenter",
        Vector3.new(0.009, 0.075, 0.075),
        Color3.fromRGB(8, 9, 9),
        Enum.Material.Metal,
        CFrame.new(0, 0, -0.301) * CylinderRotation,
        Enum.PartType.Cylinder
    )

    -- A lente fica à frente do refletor e é a saída óptica.
    local Lens = CreatePart(
        "TacticalLaserLens",
        Vector3.new(LensDepth, 0.066, 0.066),
        Color3.fromRGB(22, 25, 25),
        Enum.Material.Glass,
        Enum.PartType.Cylinder
    )

    Lens.Transparency = 0.12
    Lens.CFrame =
        BaseCF
        * CFrame.new(0, 0, LensCenterZ)
        * CylinderRotation

    -- Pequenas ranhuras decorativas no aro.
    for i = 1, 8 do
        local Angle = math.rad((i - 1) * 45)
        local X = math.cos(Angle) * 0.069
        local Y = math.sin(Angle) * 0.069

        AddDetail(
            "FlashlightBezelNotch_" .. i,
            Vector3.new(0.012, 0.009, 0.012),
            Color3.fromRGB(14, 15, 15),
            Enum.Material.Metal,
            CFrame.new(X, Y, -0.263)
        )
    end

    --==================================================
    -- BASE INFERIOR
    --==================================================

    AddDetail(
        "LowerArmorPlate",
        Vector3.new(0.17, 0.025, 0.25),
        Black,
        Enum.Material.Metal,
        CFrame.new(0, -0.112, 0.005)
    )

    AddDetail(
        "LowerCenterSpine",
        Vector3.new(0.065, 0.018, 0.19),
        EdgeMetal,
        Enum.Material.Metal,
        CFrame.new(0, -0.13, 0.012)
    )

    --==================================================
    -- EMPUNHADURA VERTICAL
    --==================================================

    AddDetail(
        "VerticalGripMountPlate",
        Vector3.new(0.145, 0.035, 0.145),
        Black,
        Enum.Material.Metal,
        CFrame.new(0, -0.157, 0.018)
    )

    AddDetail(
        "VerticalGripMountCollar",
        Vector3.new(0.125, 0.065, 0.125),
        DarkMetal,
        Enum.Material.Metal,
        CFrame.new(0, -0.195, 0.018)
    )

    AddDetail(
        "VerticalHandGripCore",
        Vector3.new(GripWidth, GripLength, GripDepth),
        Rubber,
        Enum.Material.Rubber,
        CFrame.new(0, -GripDrop, 0.018)
    )

    AddDetail(
        "VerticalGripFrontPanel",
        Vector3.new(0.073, GripLength * 0.78, 0.009),
        Black,
        Enum.Material.Rubber,
        CFrame.new(0, -GripDrop, -0.038)
    )

    AddDetail(
        "VerticalGripLeftPanel",
        Vector3.new(0.009, GripLength * 0.78, 0.073),
        DarkMetal,
        Enum.Material.Rubber,
        CFrame.new(-0.057, -GripDrop, 0.018)
    )

    AddDetail(
        "VerticalGripRightPanel",
        Vector3.new(0.009, GripLength * 0.78, 0.073),
        DarkMetal,
        Enum.Material.Rubber,
        CFrame.new(0.057, -GripDrop, 0.018)
    )

    for i = 1, 9 do
        local Y = -GripDrop + 0.125 - (i - 1) * 0.031

        AddDetail(
            "VerticalGripRib_" .. i,
            Vector3.new(GripWidth + 0.012, 0.012, GripDepth + 0.012),
            i % 2 == 0 and RibColor or Black,
            Enum.Material.Rubber,
            CFrame.new(0, Y, 0.018)
        )
    end

    AddDetail(
        "VerticalGripLeftSpine",
        Vector3.new(0.012, GripLength * 0.72, 0.014),
        Steel,
        Enum.Material.Metal,
        CFrame.new(-0.064, -GripDrop, 0.018)
    )

    AddDetail(
        "VerticalGripRightSpine",
        Vector3.new(0.012, GripLength * 0.72, 0.014),
        Steel,
        Enum.Material.Metal,
        CFrame.new(0.064, -GripDrop, 0.018)
    )

    AddDetail(
        "VerticalGripEndCap",
        Vector3.new(0.125, 0.035, 0.125),
        Black,
        Enum.Material.Metal,
        CFrame.new(
            0,
            -GripDrop - GripLength / 2 - 0.012,
            0.018
        )
    )

    AddDetail(
        "VerticalGripLockingPin",
        Vector3.new(0.025, 0.025, 0.025),
        Steel,
        Enum.Material.Metal,
        CFrame.new(0, -0.18, -0.057),
        Enum.PartType.Ball
    )

    for Side = -1, 1, 2 do
        for i = 1, 3 do
            local Y = -GripDrop + 0.09 - (i - 1) * 0.085

            AddDetail(
                "VerticalGripScrew_" .. Side .. "_" .. i,
                Vector3.new(0.012, 0.018, 0.018),
                Steel,
                Enum.Material.Metal,
                CFrame.new(Side * 0.064, Y, 0.018),
                Enum.PartType.Cylinder
            )
        end
    end

    --==================================================
    -- ETIQUETAS FIXADAS ÀS LATERAIS
    --==================================================

    -- Os adesivos agora ficam na região das placas laterais,
    -- em vez de serem deslocados para longe do corpo.
    local WarningPlate = AddDetail(
        "LaserWarningPlate",
        Vector3.new(0.008, 0.046, 0.09),
        Color3.fromRGB(218, 177, 34),
        Enum.Material.SmoothPlastic,
        CFrame.new(0.157, -0.025, 0.005)
    )

    CreateWarningLabel(WarningPlate)

    local DangerPlate = AddDetail(
        "DangerWarningPlate",
        Vector3.new(0.008, 0.046, 0.09),
        Color3.fromRGB(150, 20, 20),
        Enum.Material.SmoothPlastic,
        CFrame.new(-0.157, -0.025, 0.005)
    )

    CreateDangerLabel(DangerPlate)

    -- Painel secundário do fabricante no lado oposto.
    AddDetail(
        "SideManufacturerPanel",
        Vector3.new(0.008, 0.022, 0.105),
        Black,
        Enum.Material.Metal,
        CFrame.new(-0.157, -0.067, 0.015)
    )

    AddDetail(
        "SideManufacturerInset",
        Vector3.new(0.008, 0.009, 0.065),
        Steel,
        Enum.Material.Metal,
        CFrame.new(-0.162, -0.067, 0.015)
    )

    --==================================================
    -- INDICADOR VERDE DO MÓDULO
    --==================================================

    local GreenDot = CreatePart(
        "TacticalLaserGreenDot",
        Vector3.new(0.025, 0.025, 0.025),
        LaserDotColor,
        Enum.Material.Neon,
        Enum.PartType.Ball
    )

    -- Mantido atrás da lente para não cobrir a abertura.
    GreenDot.Transparency = 1

    local GreenLight = Instance.new("PointLight")
    GreenLight.Name = "LaserEmitterGreenLight"
    GreenLight.Color = LaserDotColor
    GreenLight.Brightness = 1
    GreenLight.Range = 1.5
    GreenLight.Enabled = false
    GreenLight.Parent = GreenDot

    --==================================================
    -- SUPORTE INVISÍVEL DA LUZ
    --==================================================

    -- Não existe mais uma peça visível flutuando na frente.
    -- Este suporte transparente fica exatamente junto à lente.
    local FlashEmitter = CreatePart(
        "TacticalFlashlightEmitter",
        FlashEmitterSize,
        Color3.fromRGB(255, 255, 255),
        Enum.Material.SmoothPlastic
    )

    FlashEmitter.Transparency = 1
    FlashEmitter.LocalTransparencyModifier = 1
    FlashEmitter.CastShadow = false

    local FlashBall = CreatePart(
        "TacticalFlashlightGlow",
        Vector3.new(0.01, 0.01, 0.01),
        Color3.fromRGB(255, 255, 255),
        Enum.Material.Neon,
        Enum.PartType.Ball
    )

    FlashBall.Transparency = 1
    FlashBall.LocalTransparencyModifier = 1

    return
        Emitter,
        Front,
        Lens,
        GreenDot,
        GreenLight,
        FlashEmitter,
        FlashBall
end

--==================================================
-- PONTO DO LASER
--==================================================

local function CreateLaserDot()
    local Dot = CreatePart(
        "TacticalLaserTarget",
        Vector3.new(LaserDotSize, LaserDotSize, LaserDotSize),
        LaserDotColor,
        Enum.Material.Neon,
        Enum.PartType.Ball
    )

    Dot.Transparency = 1

    local Light = Instance.new("PointLight")
    Light.Name = "LaserTargetGreenLight"
    Light.Color = LaserDotColor
    Light.Brightness = 2
    Light.Range = 3
    Light.Enabled = false
    Light.Parent = Dot

    return Dot, Light
end

--==================================================
-- LIMPEZA
--==================================================

local function Cleanup()
    if RenderConnection then
        RenderConnection:Disconnect()
        RenderConnection = nil
    end

    local Objects = {
        CurrentDot,
        CurrentEmitter,
        CurrentEmitterFront,
        CurrentEmitterLens,
        CurrentEmitterGreenDot,
        CurrentFlashEmitter,
        CurrentFlashBall,
        CurrentLaserBeamStart,
        CurrentLaserBeamEnd
    }

    for _, Object in ipairs(Objects) do
        if Object then
            Object:Destroy()
        end
    end

    for _, Detail in ipairs(DetailParts) do
        if Detail.Part then
            Detail.Part:Destroy()
        end
    end

    table.clear(DetailParts)

    CurrentDot = nil
    CurrentDotLight = nil

    CurrentEmitter = nil
    CurrentEmitterFront = nil
    CurrentEmitterLens = nil
    CurrentEmitterGreenDot = nil
    CurrentEmitterGreenLight = nil

    CurrentFlashEmitter = nil
    CurrentFlashBall = nil
    CurrentFlashlight = nil

    CurrentLaserBeam = nil
    CurrentLaserBeamStart = nil
    CurrentLaserBeamEnd = nil

    CurrentTool = nil
    CurrentHandle = nil
end

--==================================================
-- CONFIGURAR ARMA
--==================================================

local function SetupTool(Tool)
    if not IsPistol(Tool) then
        return
    end

    Cleanup()

    local Handle = FindHandle(Tool)
    if not Handle then
        return
    end

    CurrentTool = Tool
    CurrentHandle = Handle

    local Direction = CalculateWeaponDirection(Tool, Handle)
    Direction = ApplyLaserAdjustment(Direction, Handle)

    local VisualDirection =
        ApplyEmitterVisualAngle(Direction, Handle)

    local Emitter, Front, Lens, GreenDot, GreenLight,
        FlashEmitter, FlashBall =
        CreateEmitter(Tool, Handle, Direction, VisualDirection)

    CurrentEmitter = Emitter
    CurrentEmitterFront = Front
    CurrentEmitterLens = Lens
    CurrentEmitterGreenDot = GreenDot
    CurrentEmitterGreenLight = GreenLight
    CurrentFlashEmitter = FlashEmitter
    CurrentFlashBall = FlashBall

    local Dot, DotLight = CreateLaserDot()
    CurrentDot = Dot
    CurrentDotLight = DotLight

    -- PONTOS DO FEIXE
    local BeamStartPart = CreatePart(
        "TacticalLaserBeamStart",
        Vector3.new(0.01, 0.01, 0.01),
        Color3.new(1, 1, 1),
        Enum.Material.SmoothPlastic
    )

    BeamStartPart.Transparency = 1

    local BeamEndPart = CreatePart(
        "TacticalLaserBeamEnd",
        Vector3.new(0.01, 0.01, 0.01),
        Color3.new(1, 1, 1),
        Enum.Material.SmoothPlastic
    )

    BeamEndPart.Transparency = 1

    local StartAttachment = Instance.new("Attachment")
    StartAttachment.Name = "LaserBeamStartAttachment"
    StartAttachment.Parent = BeamStartPart

    local EndAttachment = Instance.new("Attachment")
    EndAttachment.Name = "LaserBeamEndAttachment"
    EndAttachment.Parent = BeamEndPart

    local Beam = Instance.new("Beam")
    Beam.Name = "TacticalGreenLaserBeam"
    Beam.Attachment0 = StartAttachment
    Beam.Attachment1 = EndAttachment
    Beam.Color = ColorSequence.new(LaserDotColor)
    Beam.Width0 = 0.012
    Beam.Width1 = 0.006

    Beam.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.12),
        NumberSequenceKeypoint.new(0.85, 0.18),
        NumberSequenceKeypoint.new(1, 0.35)
    })

    Beam.LightEmission = 0.65
    Beam.LightInfluence = 0
    Beam.FaceCamera = true
    Beam.Segments = 1
    Beam.Enabled = false
    Beam.Parent = BeamStartPart

    CurrentLaserBeam = Beam
    CurrentLaserBeamStart = BeamStartPart
    CurrentLaserBeamEnd = BeamEndPart

    -- LANTERNA BRANCA SAINDO DA LENTE
    local Flashlight = Instance.new("SpotLight")
    Flashlight.Name = "TacticalFlashlight"
    Flashlight.Brightness = FlashBrightness
    Flashlight.Range = FlashRange
    Flashlight.Angle = FlashAngle
    Flashlight.Color = FlashColor
    Flashlight.Face = Enum.NormalId.Front
    Flashlight.Shadows = true
    Flashlight.Enabled = false
    Flashlight.Parent = FlashEmitter

    CurrentFlashlight = Flashlight

    --==================================================
    -- ATUALIZAÇÃO EM TEMPO REAL
    --==================================================

    RenderConnection = RunService.RenderStepped:Connect(function()
        if not CurrentTool
            or not CurrentHandle
            or not CurrentTool.Parent
            or not CurrentEmitter
            or not CurrentEmitter.Parent then

            Cleanup()
            return
        end

        local Character = Player.Character

        local WeaponDirection =
            CalculateWeaponDirection(CurrentTool, CurrentHandle)

        WeaponDirection =
            ApplyLaserAdjustment(WeaponDirection, CurrentHandle)

        local VisualDirection =
            ApplyEmitterVisualAngle(WeaponDirection, CurrentHandle)

        local EmitterPosition =
            CalculateEmitterPosition(
                CurrentTool,
                CurrentHandle,
                WeaponDirection
            )

        local BaseCF = CFrame.lookAt(
            EmitterPosition,
            EmitterPosition + VisualDirection
        )

        CurrentEmitter.CFrame = BaseCF

        -- Atualiza corpo, nervuras, etiquetas e todos os detalhes.
        UpdateDetails(BaseCF)

        CurrentEmitterFront.CFrame =
            BaseCF * CFrame.new(0, 0, -0.207)

        CurrentEmitterLens.CFrame =
            BaseCF
            * CFrame.new(0, 0, LensCenterZ)
            * CFrame.Angles(0, math.rad(90), 0)

        -- O indicador verde permanece escondido atrás da lente.
        CurrentEmitterGreenDot.CFrame =
            BaseCF * CFrame.new(0, 0, -0.285)

        CurrentEmitterGreenDot.Transparency = 1
        CurrentEmitterGreenLight.Enabled = false

        -- Suporte invisível alinhado com a superfície frontal da lente.
        -- O lado Front do suporte aponta para fora, no eixo -Z de BaseCF.
        CurrentFlashEmitter.CFrame =
            BaseCF * CFrame.new(0, 0, LensFrontZ - OpticalExitOffset)

        CurrentFlashBall.CFrame = CurrentFlashEmitter.CFrame
        CurrentFlashBall.Transparency = 1

        -- O laser começa na superfície frontal da lente.
        local LensExit =
            BaseCF:PointToWorldSpace(
                Vector3.new(0, 0, LensFrontZ - OpticalExitOffset)
            )

        local Origin = LensExit

        local Params = RaycastParams.new()
        Params.FilterType = Enum.RaycastFilterType.Exclude
        Params.IgnoreWater = true

        local IgnoreList = {
            CurrentTool,
            CurrentEmitter,
            CurrentEmitterFront,
            CurrentEmitterLens,
            CurrentEmitterGreenDot,
            CurrentFlashEmitter,
            CurrentFlashBall,
            CurrentLaserBeamStart,
            CurrentLaserBeamEnd,
            CurrentDot
        }

        for _, Detail in ipairs(DetailParts) do
            if Detail.Part then
                table.insert(IgnoreList, Detail.Part)
            end
        end

        if Character then
            table.insert(IgnoreList, Character)
        end

        Params.FilterDescendantsInstances = IgnoreList

        local Result = Workspace:Raycast(
            Origin,
            VisualDirection * LaserRange,
            Params
        )

        if LaserEnabled and Result then
            CurrentDot.Position = Result.Position
            CurrentDot.Transparency = 0
            CurrentDotLight.Enabled = true

            CurrentLaserBeamStart.Position = Origin
            CurrentLaserBeamEnd.Position = Result.Position
            CurrentLaserBeam.Enabled = true
        else
            CurrentDot.Transparency = 1
            CurrentDotLight.Enabled = false
            CurrentLaserBeam.Enabled = false
        end

        CurrentFlashlight.Enabled = FlashlightEnabled
    end)
end

--==================================================
-- BOTÕES
--==================================================

LaserButton.MouseButton1Click:Connect(function()
    LaserEnabled = not LaserEnabled

    LaserButton.Text =
        LaserEnabled and "LASER: ON" or "LASER: OFF"

    BothButton.Text =
        (LaserEnabled and FlashlightEnabled)
        and "AMBOS: ON" or "AMBOS: OFF"
end)

FlashButton.MouseButton1Click:Connect(function()
    FlashlightEnabled = not FlashlightEnabled

    FlashButton.Text =
        FlashlightEnabled and "LANTERNA: ON" or "LANTERNA: OFF"

    BothButton.Text =
        (LaserEnabled and FlashlightEnabled)
        and "AMBOS: ON" or "AMBOS: OFF"
end)

BothButton.MouseButton1Click:Connect(function()
    local NewState = not (LaserEnabled and FlashlightEnabled)

    LaserEnabled = NewState
    FlashlightEnabled = NewState

    BothButton.Text =
        NewState and "AMBOS: ON" or "AMBOS: OFF"

    LaserButton.Text =
        NewState and "LASER: ON" or "LASER: OFF"

    FlashButton.Text =
        NewState and "LANTERNA: ON" or "LANTERNA: OFF"
end)

--==================================================
-- PERSONAGEM E ARMAS
--==================================================

local function DisconnectCharacterConnections()
    for _, Connection in ipairs(CharacterConnections) do
        Connection:Disconnect()
    end

    table.clear(CharacterConnections)
    table.clear(WatchedTools)
end

local function WatchTool(Tool)
    if not Tool:IsA("Tool") or not IsPistol(Tool) then
        return
    end

    if WatchedTools[Tool] then
        return
    end

    WatchedTools[Tool] = true

    table.insert(
        CharacterConnections,
        Tool.Equipped:Connect(function()
            SetupTool(Tool)
        end)
    )

    table.insert(
        CharacterConnections,
        Tool.Unequipped:Connect(function()
            if CurrentTool == Tool then
                Cleanup()
            end
        end)
    )

    table.insert(
        CharacterConnections,
        Tool.AncestryChanged:Connect(function()
            if CurrentTool == Tool
                and not Tool:IsDescendantOf(Player.Character or Workspace) then
                Cleanup()
            end
        end)
    )
end

local function SetupCharacter(Character)
    Cleanup()
    DisconnectCharacterConnections()

    for _, Child in ipairs(Character:GetChildren()) do
        if Child:IsA("Tool") then
            WatchTool(Child)
        end
    end

    table.insert(
        CharacterConnections,
        Character.ChildAdded:Connect(function(Child)
            if Child:IsA("Tool") then
                WatchTool(Child)
            end
        end)
    )

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")

    if Humanoid then
        table.insert(
            CharacterConnections,
            Humanoid.Died:Connect(function()
                Cleanup()
            end)
        )
    end
end

if Player.Character then
    SetupCharacter(Player.Character)
end

Player.CharacterAdded:Connect(function(Character)
    Character:WaitForChild("Humanoid")
    SetupCharacter(Character)
end)

Player.CharacterRemoving:Connect(function()
    Cleanup()
    DisconnectCharacterConnections()
end)
