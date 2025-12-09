--[[ 
    FILENAME: logger.lua 
    DESCRIPTION: Simple logging utility for XuKrost Hub
]]

local Logger = {}
local UI_CONSOLE = nil -- Reference to the UI TextLabel/ScrollingFrame

-- Set referensi ke UI Console (dipanggil dari Main Script)
function Logger.SetConsole(instance)
    UI_CONSOLE = instance
end

-- Fungsi untuk menambahkan text ke console
function Logger.Log(text)
    local timestamp = os.date("%X")
    local formattedText = string.format("[%s] %s", timestamp, text)
    
    -- Print ke F9 Developer Console
    print("XuKrost: " .. text)
    
    -- Update UI jika ada
    if UI_CONSOLE then
        if UI_CONSOLE:IsA("TextLabel") or UI_CONSOLE:IsA("TextBox") then
            UI_CONSOLE.Text = UI_CONSOLE.Text .. formattedText .. "\n"
        elseif UI_CONSOLE:IsA("ScrollingFrame") then
            -- Jika console berupa list, buat label baru (opsional)
            local label = Instance.new("TextLabel", UI_CONSOLE)
            label.Text = formattedText
            label.Size = UDim2.new(1, 0, 0, 15)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.new(1,1,1)
            label.Font = Enum.Font.Code
            label.TextSize = 10
            label.TextXAlignment = Enum.TextXAlignment.Left
            UI_CONSOLE.CanvasPosition = Vector2.new(0, 9999) -- Auto scroll down
        end
    end
end

return Logger