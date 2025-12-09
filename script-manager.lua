--[[ 
    FILENAME: script-manager.lua
    DESCRIPTION: Handles File System, Teleport Logic, and Presets
]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Manager = {}
local Logger = nil -- Akan diisi saat init

-- Konfigurasi Folder
local ROOT_FOLDER = "XuKrostHub"
local PRESET_FOLDER = ROOT_FOLDER .. "/Presets"
local MAIN_FILE = ROOT_FOLDER .. "/teleports.json"

-- Data Runtime
Manager.TeleportLocations = {}

-- Inisialisasi
function Manager.Init(loggerInstance)
    Logger = loggerInstance
    
    -- Buat Folder jika belum ada
    if not isfolder(ROOT_FOLDER) then makefolder(ROOT_FOLDER) end
    if not isfolder(PRESET_FOLDER) then makefolder(PRESET_FOLDER) end
end

-- Get Current Position
function Manager.GetCurrentPosition()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local cf = player.Character.HumanoidRootPart.CFrame
        return {
            x = cf.X, y = cf.Y, z = cf.Z,
            rx = cf:toEulerAnglesXYZ() -- Rotasi opsional
        }
    end
    return nil
end

-- Save Data ke File Utama
function Manager.SaveTeleportData()
    writefile(MAIN_FILE, HttpService:JSONEncode(Manager.TeleportLocations))
end

-- Load Data dari File Utama
function Manager.LoadTeleportData()
    if isfile(MAIN_FILE) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(MAIN_FILE))
        end)
        if success then
            Manager.TeleportLocations = result
        else
            Logger.Log("Error decoding JSON data.")
        end
    end
end

-- Teleport Player
function Manager.TeleportTo(data)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local newCFrame = CFrame.new(data.x, data.y, data.z)
        player.Character.HumanoidRootPart.CFrame = newCFrame
    end
end

-- Preset System (VIP)
function Manager.SaveTeleportPreset(name)
    if name == "" then return false, "Invalid name" end
    local path = PRESET_FOLDER .. "/" .. name .. ".json"
    writefile(path, HttpService:JSONEncode(Manager.TeleportLocations))
    return true, "Preset '" .. name .. "' saved."
end

function Manager.LoadTeleportPreset(name)
    local path = PRESET_FOLDER .. "/" .. name .. ".json"
    if isfile(path) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)
        if success then
            Manager.TeleportLocations = result
            Manager.SaveTeleportData() -- Update main file
            return true, "Preset loaded."
        end
    end
    return false, "Preset not found/error."
end

-- Refresh UI List
function Manager.RefreshTeleportList(scrollFrame, deleteCallback)
    -- Bersihkan list lama
    for _, v in pairs(scrollFrame:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end

    local layoutOrder = 0
    for name, posData in pairs(Manager.TeleportLocations) do
        layoutOrder = layoutOrder + 1
        
        local item = Instance.new("Frame", scrollFrame)
        item.Size = UDim2.new(1, 0, 0, 30)
        item.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        item.BackgroundTransparency = 0.5
        Instance.new("UICorner", item).CornerRadius = UDim.new(0, 4)
        
        local lbl = Instance.new("TextLabel", item)
        lbl.Size = UDim2.new(0.6, -5, 1, 0)
        lbl.Position = UDim2.new(0, 5, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = name
        lbl.TextColor3 = Color3.new(1,1,1)
        lbl.Font = Enum.Font.GothamSemibold
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        -- Teleport Button
        local tpBtn = Instance.new("TextButton", item)
        tpBtn.Size = UDim2.new(0, 40, 0, 20)
        tpBtn.Position = UDim2.new(1, -75, 0.5, 0)
        tpBtn.AnchorPoint = Vector2.new(0, 0.5)
        tpBtn.BackgroundColor3 = Color3.fromRGB(65, 120, 200) -- UI_COLOR style
        tpBtn.Text = "TP"
        tpBtn.TextColor3 = Color3.new(1,1,1)
        tpBtn.Font = Enum.Font.GothamBold
        tpBtn.TextSize = 10
        Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 3)

        tpBtn.MouseButton1Click:Connect(function()
            Manager.TeleportTo(posData)
            Logger.Log("Teleported to: " .. name)
        end)

        -- Delete Button
        local delBtn = Instance.new("TextButton", item)
        delBtn.Size = UDim2.new(0, 25, 0, 20)
        delBtn.Position = UDim2.new(1, -30, 0.5, 0)
        delBtn.AnchorPoint = Vector2.new(0, 0.5)
        delBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        delBtn.Text = "X"
        delBtn.TextColor3 = Color3.new(1,1,1)
        delBtn.Font = Enum.Font.GothamBold
        delBtn.TextSize = 10
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 3)

        delBtn.MouseButton1Click:Connect(function()
            Manager.TeleportLocations[name] = nil
            Manager.SaveTeleportData()
            item:Destroy()
            Logger.Log("Deleted: " .. name)
            if deleteCallback then deleteCallback() end -- Trigger resize update
        end)
    end
end

return Manager