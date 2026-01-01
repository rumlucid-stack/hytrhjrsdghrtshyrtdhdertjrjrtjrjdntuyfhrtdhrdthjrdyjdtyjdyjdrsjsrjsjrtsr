--// Stand Creator 1.1.0 \\--

-- Fixed/restructured loader logic for more reliable execution
-- Ensures script loads after game & player are fully loaded

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer

-- Wait for the game to finish loading
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Wait for Players and LocalPlayer to be present/retry if necessary
repeat
    LocalPlayer = Players.LocalPlayer
    wait(0.1)
until LocalPlayer ~= nil

-- Wait for Settings
repeat wait() until _G.Settings or Settings
Settings = _G.Settings or Settings

-- Check for all required tables/fields before attempting to use them
if not Settings or type(Settings) ~= "table" then
    warn("Settings table is nil or invalid. Please ensure it is declared and a table before this script executes.")
    return
end

if not Settings['Made By PekChan'] or type(Settings['Made By PekChan']) ~= "table" then
    warn("Settings['Made By PekChan'] is missing or invalid.")
    return
end

local pek = Settings['Made By PekChan']

if not pek.STANDS or type(pek.STANDS) ~= "table" then
    warn("Settings['Made By PekChan'].STANDS is nil or not a table.")
    return
end

if not pek.OWNER or type(pek.OWNER) ~= "string" then
    warn("Settings['Made By PekChan'].OWNER is nil or not a string.")
    return
end

local function safeWaitForChild(obj, child, t)
    local ok, result = pcall(function() return obj:WaitForChild(child, t or 10) end)
    if ok then return result end
    warn("Failed to WaitForChild:", child, "in", obj)
    return nil
end

for _,standName in pairs(pek.STANDS) do 
    if LocalPlayer.Name == standName then
        -- Remote load secondary framework (if needed)
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/overloadzawuardo/STAND-FRAMEWORK/refs/heads/main/v.1.0.9"))()
        end)
        if not success then
            warn("Failed to load remote STAND-FRAMEWORK:", err)
        end

        local STAND = Players:FindFirstChild(tostring(standName)) or LocalPlayer
        local OWNER = safeWaitForChild(Players, pek.OWNER)
        local rs = RunService

        -- Defensive: Check if character loads
        local function waitForCharacter(plr)
            local char = plr.Character
            if not char then char = plr.CharacterAdded:Wait() end
            return char
        end

        local function Notify(title, text)
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification",  {
                    Title = title;
                    Text = text;
                    Duration = 3;
                })
            end)
        end

        -- Fix for setfpscap if present
        if pek.FPS and type(pek.FPS)=="number" and setfpscap then
            setfpscap(pek.FPS)
        end

        -- Performance optimization if requested
        if pek.PERFORMANCE then
            pcall(function()
                RunService:Set3dRenderingEnabled(false)
                local l = game:GetService("Lighting")
                local t = workspace:FindFirstChild"Terrain" or workspace:WaitForChild"Terrain"
                t.WaterWaveSize = 0
                t.WaterWaveSpeed = 0
                t.WaterReflectance = 0
                t.WaterTransparency = 1
                l.GlobalShadows = false
                for _,v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("WedgePart") or v:IsA("SpawnLocation") then
                        v.BrickColor = BrickColor.new(155,155,155)
                        v.Material = Enum.Material.Plastic
                    elseif v:IsA("Decal") or v:IsA("Texture") then
                        v:Destroy()
                    end
                end
            end)
        end

        pcall(function()
            settings().Physics.PhysicsEnvironmentalThrottle = 1
            settings().Rendering.QualityLevel = "Level01"
            UserSettings():GetService("UserGameSettings").MasterVolume = 0 
        end)

        local function x()  
            Stand = {
                Action = "",
                Target = ""
            }
            STAND = Players:FindFirstChild(standName) or LocalPlayer
            OWNER = safeWaitForChild(Players, pek.OWNER)
            rs = RunService

            local Char = waitForCharacter(STAND)

            -- Wait for required char parts
            safeWaitForChild(Char, "Humanoid")
            safeWaitForChild(Char, "Head")
            safeWaitForChild(Char, "BodyEffects")
            safeWaitForChild(Char, "HumanoidRootPart")

            -- Titan mode tweaks
            if pek.TITAN and pek.TITAN.GODV3 then
                pcall(function()
                    local scripts = Char:GetChildren()
                    for _,v in ipairs(scripts) do
                        if v:IsA("Script") then v:Destroy() end
                    end
                end)
            end

            -- Godmode/scaling manip
            if pek.TITAN and pek.TITAN.ENABLED then
                coroutine.wrap(function()
                    repeat wait() until STAND.Backpack and STAND.Backpack:FindFirstChild("Mask")
                    coroutine.wrap(function()
                        local defense = safeWaitForChild(safeWaitForChild(Char, "BodyEffects"), "Defense")
                        if defense then
                            local ctb = defense:FindFirstChild("CurrentTimeBlock")
                            if ctb then ctb:Destroy() end
                        end
                    end)()
                    local function rm()
                        for _, v in ipairs(Char:GetDescendants()) do
                            if v.Name == "OriginalPosition" or v.Name == "OriginalSize" or v.Name == "AvatarPartScaleType" then
                                v:Destroy()
                            end
                        end
                    end
                    local tall, wide, default = false, false, false
                    if pek.TITAN.TALL and not wide and not default then
                        tall = true
                        for _, scaleName in ipairs({"HeadScale","BodyWidthScale","BodyDepthScale","BodyTypeScale"}) do
                            local scale = Char.Humanoid:FindFirstChild(scaleName)
                            if scale then rm(); wait(0.3); scale:Destroy(); wait(0.3) end
                        end
                    elseif pek.TITAN.WIDE and not tall and not default then
                        wide = true
                        for _, scaleName in ipairs({"HeadScale","BodyDepthScale"}) do
                            local scale = Char.Humanoid:FindFirstChild(scaleName)
                            if scale then rm(); wait(0.3); scale:Destroy(); wait(0.3) end
                        end
                    elseif pek.TITAN.DEFAULT and not tall and not wide then
                        default = true
                        for _, scaleName in ipairs({"HeadScale","BodyWidthScale","BodyDepthScale"}) do
                            local scale = Char.Humanoid:FindFirstChild(scaleName)
                            if scale then rm(); wait(0.3); scale:Destroy(); wait(0.3) end
                        end
                    end
                end)()
            else
                -- Simple fallback for godmode
                pcall(function()
                    local newCharacter = safeWaitForChild(workspace, STAND.Name)
                    if newCharacter and newCharacter:FindFirstChild("RagdollConstraints") then
                        newCharacter:FindFirstChild("RagdollConstraints"):Destroy()
                    end
                end)
            end

            -- Remove the face decal if requested
            if pek.FACELESS then
                local head = Char:FindFirstChild("Head")
                if head then
                    for _,f in ipairs(head:GetChildren()) do
                        if f:IsA("Decal") and f.Name == "face" then f:Destroy() end
                    end
                end
            end

            -- Disable unwanted states
            local H = Char:FindFirstChildOfClass("Humanoid")
            if H then
                local disStates = {
                    "Climbing","Ragdoll","Jumping","Landed","Flying","Freefall","Seated","PlatformStanding","Physics"
                }
                for _,st in ipairs(disStates) do
                    pcall(function() H:SetStateEnabled(Enum.HumanoidStateType[st], false) end)
                end
            end

            -- Remove Animate script
            local Animate = Char:FindFirstChild("Animate")
            if Animate then pcall(function() Animate:Destroy() end) end

            if pek.LEGS then
                pcall(function()
                    Char:FindFirstChild("RightUpperLeg"):Destroy()
                    Char:FindFirstChild("LeftUpperLeg"):Destroy()
                end)
            end

            -- Remove trail effects if specified
            if pek.TRAILS then
                coroutine.wrap(function()
                    local hum = Char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        local te = hum:FindFirstChild("TrailEffects")
                        if te then te:Destroy() end
                    end
                end)()
            end

            -- Mask sequence
            repeat
                rs.Stepped:Wait()
                if workspace.Ignored and workspace.Ignored.Shop and workspace.Ignored.Shop["[Paintball Mask] - $60"] then
                    local shop = workspace.Ignored.Shop["[Paintball Mask] - $60"]
                    if Char:FindFirstChild("HumanoidRootPart") and shop.Head then
                        Char.HumanoidRootPart.CFrame = CFrame.new(shop.Head.Position)
                        fireclickdetector(shop.ClickDetector)
                    end
                end
            until STAND.Backpack and STAND.Backpack:FindFirstChild("Mask")

            -- Teleport to OWNER or just up
            if pek.TELEPORTMAIN and OWNER and OWNER.Character and OWNER.Character:FindFirstChild('HumanoidRootPart') then
                pcall(function()
                    Char:FindFirstChild('HumanoidRootPart').CFrame = OWNER.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,math.random(2,4))
                end)
            else
                if Char:FindFirstChild('HumanoidRootPart') then
                    Char.HumanoidRootPart.CFrame = Char.HumanoidRootPart.CFrame * CFrame.new(0,3,0)
                end
            end

            -- Equip mask and combat
            local mask = STAND.Backpack and STAND.Backpack:FindFirstChild("Mask")
            local melee = STAND.Backpack and STAND.Backpack:FindFirstChild("Combat")
            if mask then
                mask.Parent = Char
                mask:Activate()
                mask.Parent = STAND.Backpack
            end
            if melee then
                melee.Parent = Char
            end

            -- Destroy Mask leftovers
            pcall(function()
                local igmask = safeWaitForChild(Char, 'In-gameMask', 2)
                if igmask then
                    local model = igmask:FindFirstChildWhichIsA("Model")
                    if model then model:Destroy() end
                    local handle = igmask:FindFirstChild("Handle")
                    if handle then handle:Destroy() end
                end
            end)

            -- Animation helpers
            function AnimPlay(ID, SPEED)
                local animation = Instance.new('Animation')
                animation.AnimationId = 'rbxassetid://'..ID
                local playing = H:LoadAnimation(animation)
                playing:Play()
                if tonumber(SPEED) then
                    playing:AdjustSpeed(SPEED)
                else
                    playing:AdjustSpeed(1)
                end
                animation:Destroy()
            end

            function AnimStop(ID, SPEED)
                for _,track in ipairs(H:GetPlayingAnimationTracks()) do
                    if track.Animation.AnimationId == 'rbxassetid://'..ID then
                        if tonumber(SPEED) then
                            track:Stop(SPEED)
                        else
                            track:Stop()
                        end
                    end
                end
            end

            -- Idle animation
            AnimPlay(3541114300, 1)

            -- FOLLOW owner animation, if specified
            if pek.FOLLOWANIM then
                local Glide = Instance.new('Animation')
                Glide.AnimationId = 'rbxassetid://'.. tonumber(pek.FOLLOWANIM.ID)
                Glide.Name = "Follow"
                local Glide2 = H:LoadAnimation(Glide)
                local function Moved()
                    local ohum = OWNER.Character and OWNER.Character:FindFirstChild("Humanoid")
                    if ohum and ohum.MoveDirection.Magnitude > 0 then
                        if not Glide2.IsPlaying then 
                            Glide2:Play(tonumber(pek.FOLLOWANIM.SPEED) or 1)
                        end
                    else
                        Glide2:Stop(tonumber(pek.FOLLOWANIM.SPEED) or 1)
                    end
                end
                local ohum = OWNER.Character and OWNER.Character:FindFirstChild("Humanoid")
                if ohum then
                    ohum:GetPropertyChangedSignal("MoveDirection"):Connect(Moved)
                end
            end

            Notify("JoJo's Stand Framework 1.0.9","Success!")
        end

        -- Character reset, godmode
        local Char = waitForCharacter(STAND)
        if not Char:FindFirstChild("ForceField_TESTING") then
            repeat wait() until Char:FindFirstChild("BodyEffects")
                and Char.BodyEffects:FindFirstChild("K.O") 
                and Char.BodyEffects.K.O.Value == false
            local humanoid = Char:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.Health = 0
            end
            x()
        else
            x()
        end
        
        -- Noclip functionality
        if pek.NOCLIP and pek.NOCLIP.SynapseX then
            local ok, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/LegoHacker1337/legohacks/main/PhysicsServiceOnClient.lua"))()
                setfflag("HumanoidParallelRemoveNoPhysics", "False")
                setfflag("HumanoidParallelRemoveNoPhysicsNoSimulate2", "False")
                rs:BindToRenderStep("", Enum.RenderPriority.Camera.Value, function()
                    safeWaitForChild(Char, "Humanoid"):ChangeState(11)
                    game:GetService("ReplicatedStorage").MainEvent:FireServer('Block', STAND.Name)
                    rs.RenderStepped:Wait()
                end)
            end)
            if not ok then warn("Failed to enable SynapseX Noclip:", err) end
        elseif pek.NOCLIP then
            local noclipPart = Instance.new('Part', workspace)
            noclipPart.Name = "noclip"
            noclipPart.Size = Vector3.new(6, 0.1, 6)
            noclipPart.Anchored = true
            noclipPart.Transparency = 1
            local offset = pek.NOCLIP.Offset or 0
            rs.Stepped:Connect(function()
                pcall(function()
                    for _,partName in ipairs({"Head","UpperTorso","HumanoidRootPart","LowerTorso"}) do
                        local p = Char:FindFirstChild(partName)
                        if p then p.CanCollide = false end
                    end
                    game:GetService("ReplicatedStorage").MainEvent:FireServer('Block', STAND.Name)
                    noclipPart.CFrame = safeWaitForChild(Char, "HumanoidRootPart").CFrame + Vector3.new(0, offset, 0)
                end)
            end)
        end

        -- Anti-Idle
        STAND.Idled:Connect(function()
            local vu = game:GetService("VirtualUser")
            vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            wait(1)
            vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        end)

        -- Particle cleaner & animation stopper
        rs.RenderStepped:Connect(function()
            pcall(function()
                local ut = Char:FindFirstChild("UpperTorso")
                if ut then
                    local Particle = ut:FindFirstChild('ElectricuteParticle') or ut:FindFirstChild('FlamethrowerFireParticle') or Char:FindFirstChild('Christmas_Sock')
                    if Particle then Particle:Destroy() end
                end
                local H = Char:FindFirstChildOfClass("Humanoid")
                if H then
                    for _,v in ipairs(H:GetPlayingAnimationTracks()) do
                        if v.Animation.AnimationId == 'rbxassetid://5641749824' or v.Name == 'Block' then
                            v:Stop()
                        end
                    end
                end
            end)
        end)

        -- Stand Attack Logic
        coroutine.wrap(function()
            while true do
                wait()
                pcall(function()
                    if Char and Char:FindFirstChild("BodyEffects") and Char.BodyEffects:FindFirstChild("Attacking") and Char.BodyEffects.Attacking.Value then
                        for _,v in ipairs(Players:GetPlayers()) do
                            if v ~= LocalPlayer and v.Character and Char:FindFirstChild("LeftHand") then
                                local prange = pek.RANGE or 12
                                if v.Character:FindFirstChild("HumanoidRootPart") and (v.Character.HumanoidRootPart.Position - Char.LeftHand.Position).magnitude <= prange then
                                    local tool = Char:FindFirstChildOfClass("Tool")
                                    if tool and tool:FindFirstChild('Handle') then
                                        firetouchinterest(tool.Handle, v.Character.UpperTorso, 0)
                                    else
                                        firetouchinterest(Char:FindFirstChild("RightHand"), v.Character.UpperTorso, 0)
                                        firetouchinterest(Char.LeftHand, v.Character.UpperTorso, 0)
                                        if not pek.LEGS then
                                            firetouchinterest(Char:FindFirstChild("RightFoot"), v.Character.UpperTorso, 0)
                                            firetouchinterest(Char:FindFirstChild("LeftFoot"), v.Character.UpperTorso, 0)
                                            firetouchinterest(Char:FindFirstChild("RightLowerLeg"), v.Character.UpperTorso, 0)
                                            firetouchinterest(Char:FindFirstChild("LeftLowerLeg"), v.Character.UpperTorso, 0)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end)()

        -- CharacterAdded hooks for Stand/Owner
        STAND.CharacterAdded:Connect(function()
            x()
        end)
        if OWNER then
            OWNER.CharacterAdded:Connect(function()
                if OWNER.Character and OWNER.Character:FindFirstChild("Humanoid") and pek.FOLLOWANIM then
                    local ohum = OWNER.Character.Humanoid
                    local function Moved()
                        -- Insert logic to play follow animation again if needed (duplicate of above)
                    end
                    ohum:GetPropertyChangedSignal("MoveDirection"):Connect(Moved)
                end
            end)
        end

        -- Antifling logic restored
        if pek.ANTIFLING then
            coroutine.wrap(function()
                local Services = setmetatable({}, {__index = function(Self, Index)
                    local NewService = game:GetService(Index)
                    if NewService then
                        Self[Index] = NewService
                    end
                    return NewService
                end})
                local function PlayerAdded(Player)
                    local Detected = false
                    local Character
                    local PrimaryPart
                    local function CharacterAdded(NewCharacter)
                        Character = NewCharacter
                        repeat wait() PrimaryPart = NewCharacter:FindFirstChild("HumanoidRootPart") until PrimaryPart
                        Detected = false
                    end
                    CharacterAdded(Player.Character or Player.CharacterAdded:Wait())
                    Player.CharacterAdded:Connect(CharacterAdded)
                    Services.RunService.Heartbeat:Connect(function()
                        if (Character and Character:IsDescendantOf(workspace)) and (PrimaryPart and PrimaryPart:IsDescendantOf(Character)) then
                            if PrimaryPart.AssemblyAngularVelocity.Magnitude > 50 or PrimaryPart.AssemblyLinearVelocity.Magnitude > 100 then
                                if not Detected then
                                    Detected = true
                                end
                                for _,v in ipairs(Character:GetDescendants()) do
                                    if v:IsA("BasePart") then
                                        v.CanCollide = false
                                        v.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                                        v.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                        v.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0)
                                    end
                                end
                                PrimaryPart.CanCollide = false
                                PrimaryPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
                                PrimaryPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
                                PrimaryPart.CustomPhysicalProperties = PhysicalProperties.new(0,0,0)
                            end
                        end
                    end)
                end
                for _,v in ipairs(Services.Players:GetPlayers()) do
                    if v ~= STAND then PlayerAdded(v) end
                end
                Services.Players.PlayerAdded:Connect(PlayerAdded)
                local LastPosition = nil
                Services.RunService.Heartbeat:Connect(function()
                    pcall(function()
                        local PrimaryPart = STAND.Character and STAND.Character.PrimaryPart
                        if PrimaryPart then
                            if PrimaryPart.AssemblyLinearVelocity.Magnitude > 150 or PrimaryPart.AssemblyAngularVelocity.Magnitude > 150 then
                                PrimaryPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
                                PrimaryPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
                                if LastPosition then PrimaryPart.CFrame = LastPosition end
                            elseif PrimaryPart.AssemblyLinearVelocity.Magnitude < 50 or PrimaryPart.AssemblyAngularVelocity.Magnitude > 50 then
                                LastPosition = PrimaryPart.CFrame
                            end
                        end
                    end)
                end)
            end)()
        end

        -- The rest of stand utilities and API remain as intended
        Stand = { Action = "", Target = "" }

        function gplr(str)
            str = tostring(str):lower()
            for _,v in ipairs(Players:GetPlayers()) do
                if v.Name:lower():sub(1, #str) == str or (v.DisplayName and v.DisplayName:lower():sub(1, #str) == str) then
                    return v
                end
            end
        end
        
        function CreateKeybind(keybind, callback)
            callback = callback or function() end
            game:GetService("UserInputService").InputBegan:Connect(function(Key)
                pcall(function()
                    if game:GetService("UserInputService"):GetFocusedTextBox() then return end
                    if Key.KeyCode == Enum.KeyCode[keybind] then
                        pcall(callback)
                    end
                end)
            end)
        end

        function Create(command, callback)
            callback = callback or function() end
            game.ReplicatedStorage.DefaultChatSystemChatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(msg)
                if msg.Message:lower() == command:lower() and msg.FromSpeaker == tostring(OWNER.Name) then
                    pcall(callback)
                end
            end)
        end

        function CreateAction(action, callback)
            callback = callback or function() end
            RunService.Heartbeat:Connect(function()
                if Stand.Action == action then
                    pcall(callback)
                end
            end)
        end

        function CreateLoop(Name, callback)
            callback = callback or function() end
            if not _G.CreatedLoops then _G.CreatedLoops = {} end
            table.insert(_G.CreatedLoops, Name)
            coroutine.wrap(function()
                while table.find(_G.CreatedLoops, Name) do
                    rs.Stepped:Wait()
                    pcall(callback)
                end
            end)()
        end

        function StopLoop(Name)
            if not _G.CreatedLoops then return end
            for i, name in ipairs(_G.CreatedLoops) do
                if name == Name then
                    table.remove(_G.CreatedLoops, i)
                    break
                end
            end
        end

        function CreateTargetAbility(command, callback)
            callback = callback or function() end
            game.ReplicatedStorage.DefaultChatSystemChatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(msg)
                if msg.FromSpeaker == tostring(OWNER.Name) then
                    local msgString = msg.Message:split(" ")
                    if msgString[1]:lower() == command:lower() then
                        local args = {}
                        for i = 2, #msgString, 1 do
                            table.insert(args, msgString[i])
                        end
                        if args[1] then
                            local Target = gplr(args[1])
                            if Target then
                                Stand.Target = Target
                                pcall(callback)
                            end
                        end
                    end
                end
            end)
        end

        function Chat(msg)
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
        end

        local OriginalKeyUpValue = 0
        function Stop()
            pcall(function()
                STAND.Character.LowerTorso.BOOMBOXSOUND:Stop()
            end)
        end

        function StopAudio(ID, Key)
            coroutine.wrap(function()
                wait(STAND.Character.LowerTorso.BOOMBOXSOUND.TimeLength-0.1)
                if STAND.Character.LowerTorso.BOOMBOXSOUND.SoundId == "rbxassetid://"..ID and OriginalKeyUpValue == Key then
                    Stop()
                end
            end)()
        end

        function Play(ID, STOP)
            if STAND.Backpack:FindFirstChild("[Boombox]") then
                local Tool = nil
                STAND.Backpack["[Boombox]"].Parent = STAND.Character
                game:GetService("ReplicatedStorage").MainEvent:FireServer("Boombox", ID)
                STAND.Character["[Boombox]"].RequiresHandle = false
                if STAND.Character["[Boombox]"]:FindFirstChild("Handle") then
                    STAND.Character["[Boombox]"].Handle:Destroy()
                end
                STAND.Character["[Boombox]"].Parent = STAND.Backpack
                STAND.PlayerGui.MainScreenGui.BoomboxFrame.Visible = false
                if Tool ~= true and Tool then Tool.Parent = STAND.Character end
                if STOP == true then
                    STAND.Character.LowerTorso:WaitForChild("BOOMBOXSOUND")
                    coroutine.wrap(function()
                        repeat wait() until STAND.Character.LowerTorso.BOOMBOXSOUND.SoundId == "rbxassetid://"..ID and STAND.Character.LowerTorso.BOOMBOXSOUND.TimeLength > 0.0001
                        OriginalKeyUpValue = OriginalKeyUpValue+1
                        StopAudio(ID, OriginalKeyUpValue)
                    end)()
                end
            end
        end

        function Hit(Charge)
            wait()
            local tool = STAND.Character:FindFirstChildWhichIsA("Tool")
            if tool then
                if Charge == false then
                    tool:Activate()
                    tool:Deactivate()
                elseif Charge == true then
                    tool:Activate()
                end
            end
        end

        function Crew(Join,ID)
            if not Join then
                game:GetService("ReplicatedStorage").MainEvent:FireServer("LeaveCrew")
            else
                game:GetService("ReplicatedStorage").MainEvent:FireServer("LeaveCrew")
                wait(0.5)
                game:GetService("ReplicatedStorage").MainEvent:FireServer("JoinCrew", ID)
            end
        end

        function DropMoney(Amount)
            game:GetService("ReplicatedStorage").MainEvent:FireServer("DropMoney",Amount)
        end

        function SilentChat(msg)
            game.Players:Chat(msg)
        end

        function MoveTo(X,Y,Z)
            if OWNER.Character and OWNER.Character:FindFirstChild("HumanoidRootPart") and STAND.Character:FindFirstChild("HumanoidRootPart") then
                STAND.Character.HumanoidRootPart.CFrame = OWNER.Character.HumanoidRootPart.CFrame * CFrame.new(X,Y,Z)
            end
        end

        function Equip(Tool)
            if STAND.Character:FindFirstChildWhichIsA("Tool") then
                STAND.Character.Humanoid:UnequipTools()
            end
            if STAND.Backpack:FindFirstChild(Tool) then
                STAND.Character.Humanoid:EquipTool(STAND.Backpack[Tool])
            end
        end

        function Unequip()
            if STAND.Character:FindFirstChildOfClass("Humanoid") then
                STAND.Character.Humanoid:UnequipTools()
            end
        end

        function GetNearest()
            local ClosestPlayer
            local ClosestDistance = math.huge
            for _,v in ipairs(Players:GetPlayers()) do
                if v.Character and OWNER.Character and v ~= OWNER then
                    local hasCrew = v:FindFirstChild('DataFolder') and v.DataFolder:FindFirstChild('Information') and v.DataFolder.Information:FindFirstChild('Crew')
                    local crewVal = hasCrew and v.DataFolder.Information.Crew.Value or ""
                    local ownerCrew = OWNER:FindFirstChild('DataFolder') and OWNER.DataFolder:FindFirstChild('Information') and OWNER.DataFolder.Information:FindFirstChild('Crew') and OWNER.DataFolder.Information.Crew.Value or ""
                    local vHRP = v.Character:FindFirstChild('HumanoidRootPart')
                    local Dead = v.Character:FindFirstChild("BodyEffects") and v.Character.BodyEffects:FindFirstChild("Dead") and v.Character.BodyEffects.Dead.Value == false
                    if vHRP and Dead and (not hasCrew or crewVal ~= ownerCrew) then
                        local dist = (vHRP.Position - OWNER.Character.HumanoidRootPart.Position).magnitude
                        if dist < ClosestDistance then
                            ClosestDistance = dist
                            ClosestPlayer = v
                        end
                    end
                end
            end
            return ClosestPlayer
        end

        -- Refactored Buy table: fast-fail on invalid tool names
        Buy = {}
        local buyDefs = {
            Knife={"[Knife] - $150","[Knife]"},
            Bat={"[Bat] - $250","[Bat]"},
            StopSign={"[StopSign] - $300","[StopSign]"},
            Shovel={"[Shovel] - $320","[Shovel]"},
            Pencil={"[Pencil] - $175","[Pencil]"},
            Nunchucks={"[Nunchucks] - $450","[Nunchucks]"},
            SledgeHammer={"[SledgeHammer] - $350","[SledgeHammer]"},
            Grenade={"[Grenade] - $1250","[Grenade]"},
            Flashbang={"[Flashbang] - $550","[Flashbang]"},
        }
        for tool,def in pairs(buyDefs) do
            Buy[tool] = function()
                if STAND.Character:FindFirstChildWhichIsA("Tool") then
                    STAND.Character:FindFirstChildWhichIsA("Tool").Parent = STAND.Backpack
                end
                local a, b = Stand.Action, Stand.Target
                local function restore() Stand = { Action = a, Target = b } end
                Stand = {Action="", Target=""}
                repeat rs.Stepped:Wait()
                    local shop = workspace.Ignored and workspace.Ignored.Shop and workspace.Ignored.Shop[def[1]]
                    if shop and shop.Head and STAND.Character:FindFirstChild("HumanoidRootPart") then
                        STAND.Character.HumanoidRootPart.CFrame = CFrame.new(shop.Head.Position)
                        fireclickdetector(shop.ClickDetector)
                    end
                until STAND.Backpack:FindFirstChild(def[2])
                restore()
                STAND.Backpack:FindFirstChild(def[2]).Parent = STAND.Character
            end
        end
        -- Special boxing case
        Buy.Boxing = function()
            if STAND.Character:FindFirstChildWhichIsA("Tool") then
                STAND.Character:FindFirstChildWhichIsA("Tool").Parent = STAND.Backpack
            end
            local a, b = Stand.Action, Stand.Target
            local function restore() Stand = { Action = a, Target = b } end
            Stand = {Action="", Target=""}
            local bought = false
            coroutine.wrap(function() wait(1.5) bought = true end)()
            repeat
                rs.Stepped:Wait()
                local shop = workspace.Ignored and workspace.Ignored.Shop and workspace.Ignored.Shop["Boxing Moveset (Require: Max Box Stat) - $0"]
                if shop and shop.Head and STAND.Character:FindFirstChild("HumanoidRootPart") then
                    STAND.Character.HumanoidRootPart.CFrame = CFrame.new(shop.Head.Position)
                    fireclickdetector(shop.ClickDetector)
                end
            until bought
            restore()
            bought = false
            if STAND.Backpack:FindFirstChild("Combat") then
                STAND.Backpack:FindFirstChild("Combat").Parent = STAND.Character
            end
        end
        -- Special default moveset
        Buy.Default = function()
            if STAND.Character:FindFirstChildWhichIsA("Tool") then
                STAND.Character:FindFirstChildWhichIsA("Tool").Parent = STAND.Backpack
            end
            local a, b = Stand.Action, Stand.Target
            local function restore() Stand = { Action = a, Target = b } end
            Stand = {Action="", Target=""}
            local bought = false
            coroutine.wrap(function() wait(1.5) bought = true end)()
            repeat
                rs.Stepped:Wait()
                local shop = workspace.Ignored and workspace.Ignored.Shop and workspace.Ignored.Shop["[Default Moveset] - $0"]
                if shop and shop.Head and STAND.Character:FindFirstChild("HumanoidRootPart") then
                    STAND.Character.HumanoidRootPart.CFrame = CFrame.new(shop.Head.Position)
                    fireclickdetector(shop.ClickDetector)
                end
            until bought
            restore()
            bought = false
            if STAND.Backpack:FindFirstChild("Combat") then
                STAND.Backpack:FindFirstChild("Combat").Parent = STAND.Character
            end
        end

        -- Auto pickup cash
        coroutine.wrap(function()
            while pek.AUTOPICKUPCASH == true do
                wait()
                local drop = workspace:FindFirstChild('Ignored') and workspace.Ignored:FindFirstChild('Drop')
                if drop and STAND.Character and STAND.Character:FindFirstChild('HumanoidRootPart') then
                    for _,v in ipairs(drop:GetChildren()) do
                        if v:IsA('Part') and (v.Position - STAND.Character.HumanoidRootPart.Position).Magnitude <= 12 then
                            wait(0.01)
                            local cd = v:FindFirstChildOfClass('ClickDetector')
                            if cd then fireclickdetector(cd) end
                        end
                    end
                end
            end
        end)()
        break
    end
end
