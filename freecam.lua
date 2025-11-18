local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local keys = {W=false, A=false, S=false, D=false}
local camera = workspace.CurrentCamera
local yaw, pitch = 0, 0
local sens = 0.0035
local speed = 4

local conRender, conBegan, conEnd, conMove

-- Properly builds rotation CFrame
local function buildCameraCF(pos)
    return CFrame.new(pos)
        * CFrame.Angles(0, yaw, 0)       -- yaw (horizontal)
        * CFrame.Angles(pitch, 0, 0)     -- pitch (vertical)
end

local function updateCamera(dt)
    camera.CameraType = Enum.CameraType.Scriptable

    local cf = buildCameraCF(camera.CFrame.Position)

    -- Movement
    local move = Vector3.new()
    if keys.W then move += cf.LookVector end
    if keys.S then move -= cf.LookVector end
    if keys.A then move -= cf.RightVector end
    if keys.D then move += cf.RightVector end

    -- Apply movement
    camera.CFrame = cf + move * speed * dt * 60
end

local function lockMouseCenter()
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    task.wait()
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
end

local function startFreecam()
    lockMouseCenter()

    local look = camera.CFrame.LookVector

    -- Initialize yaw/pitch from current camera
    yaw = math.atan2(-look.X, -look.Z)
    pitch = math.asin(look.Y)

    -- Key down events
    conBegan = UserInputService.InputBegan:Connect(function(i, gp)
        if gp then return end
        local k = i.KeyCode
        if keys[k.Name] ~= nil then keys[k.Name] = true end
    end)

    -- Key up events
    conEnd = UserInputService.InputEnded:Connect(function(i)
        local k = i.KeyCode
        if keys[k.Name] ~= nil then keys[k.Name] = false end
    end)

    -- Mouse movement (rotation)
    conMove = UserInputService.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then
            yaw -= i.Delta.X * sens
            pitch = math.clamp(pitch - i.Delta.Y * sens, -1.45, 1.45)
        end
    end)

    conRender = RunService.RenderStepped:Connect(updateCamera)
end

local function stopFreecam()
    camera.CameraType = Enum.CameraType.Custom
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default

    if conRender then conRender:Disconnect() end
    if conMove   then conMove:Disconnect()   end
    if conBegan  then conBegan:Disconnect()  end
    if conEnd    then conEnd:Disconnect()    end

    table.clear(keys)
end

-- Toggle: Shift + P
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    if input.KeyCode == Enum.KeyCode.P
       and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then

        if camera.CameraType ~= Enum.CameraType.Scriptable then
            startFreecam()
        else
            stopFreecam()
        end
    end
end)
