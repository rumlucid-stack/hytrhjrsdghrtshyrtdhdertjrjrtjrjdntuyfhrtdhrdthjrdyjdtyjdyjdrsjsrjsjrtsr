--// Stand Creator 1.1.0 \\--

-- Simplified working base version,
-- All defensive checks removed for testing basic functionality "its not working" fix.
-- Only runs for LocalPlayer as STAND with OWNER determination.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local Settings = Settings or getgenv().Settings
local config = Settings and Settings['Made By PekChan']
local STANDS = config and config.STANDS

if not config or not config.STANDS or not config.OWNER then
    warn("Basic configuration is missing!")
    return
end

for _,v in pairs(config.STANDS) do
    if LocalPlayer.Name == v then
        local STAND = Players:FindFirstChild(LocalPlayer.Name)
        local OWNER = Players:FindFirstChild(config.OWNER) or Players:WaitForChild(config.OWNER)
        if not (STAND and OWNER) then warn("Owner or Stand not found!"); return end

        -- Essential environment
        local rs = RunService
        local Stand = { Action = "", Target = "" }

        -- Basic mask stuff
        repeat rs.Stepped:Wait()
            local paintMask = game.Workspace.Ignored.Shop["[Paintball Mask] - $60"]
            STAND.Character.HumanoidRootPart.CFrame = CFrame.new(paintMask.Head.Position)
            fireclickdetector(paintMask.ClickDetector)
        until STAND.Backpack:FindFirstChild("Mask")

        -- Teleport
        if config.TELEPORTMAIN then
            pcall(function()
                STAND.Character:WaitForChild('HumanoidRootPart').CFrame = OWNER.Character:WaitForChild('HumanoidRootPart').CFrame * CFrame.new(0,0,math.random(2,4))
            end)
        else
            STAND.Character.HumanoidRootPart.CFrame = STAND.Character.HumanoidRootPart.CFrame*CFrame.new(0,3,0)
        end

        -- Equip mask and melee
        local mask = STAND.Backpack:FindFirstChild("Mask")
        local melee = STAND.Backpack:FindFirstChild("Combat")
        if mask then
            mask.Parent = STAND.Character
            mask:Activate()
            mask.Parent = STAND.Backpack
        end
        if melee then
            melee.Parent = STAND.Character
        end

        -- Send basic notification
        function Notify(title, text)
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification",  {
                    Title = title; Text = text; Duration = 3;
                })
            end)
        end
        Notify("JoJo's Stand Framework 1.0.9", "Loaded.")

        -- Basic idle anti-AFK
        STAND.Idled:Connect(function()
            local vu = game:GetService("VirtualUser")
            vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            wait(1)
            vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        end)

        -- Slightly simplified
        break
    end
end

