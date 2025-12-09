-- External Module for "Own Script" Tab
-- Returns a function to be called by the main loader

return function(Page, API)
    -- Unpack API helpers
    local isVIP = API.isVIP
    local UI_COLOR = API.UI_COLOR
    local CARD_COLOR = API.CARD_COLOR
    local notify = API.notify
    local createCorner = API.createCorner
    local createStroke = API.createStroke
    local RegisterTheme = API.RegisterTheme
    local HttpService = API.HttpService
    local Players = API.Players
    local player = Players.LocalPlayer

    -- Data Logic
    local teleportLocations = {}
    local FILENAME = "XuKrost_Teleports.json"

    local function saveToDisk()
        if writefile then
            writefile(FILENAME, HttpService:JSONEncode(teleportLocations))
        end
    end

    local function loadFromDisk()
        if isfile and isfile(FILENAME) then
            local s, d = pcall(function() return HttpService:JSONDecode(readfile(FILENAME)) end)
            if s and d then teleportLocations = d end
        end
    end

    -- Initial Load
    loadFromDisk()

    -- :: UI CONSTRUCTION ::
    
    -- Main Scroll Wrapper for this Tab
    local mainScrollFrame = Instance.new("ScrollingFrame", Page)
    mainScrollFrame.Size = UDim2.new(1, 0, 1, 0)
    mainScrollFrame.BackgroundTransparency = 1
    mainScrollFrame.BorderSizePixel = 0
    mainScrollFrame.ScrollBarThickness = 4
    mainScrollFrame.ScrollBarImageColor3 = UI_COLOR
    mainScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    mainScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    RegisterTheme(mainScrollFrame, "ScrollBarImageColor3")

    -- List Layout for Main Scroll
    local mainLayout = Instance.new("UIListLayout", mainScrollFrame)
    mainLayout.SortOrder = Enum.SortOrder.LayoutOrder
    mainLayout.Padding = UDim.new(0, 10)

    -- SECTION 1: SAVE MANAGER
    local saveSection = Instance.new("Frame", mainScrollFrame)
    saveSection.Size = UDim2.new(0.98, 0, 0, 80)
    saveSection.BackgroundColor3 = CARD_COLOR
    saveSection.BackgroundTransparency = 0.2
    saveSection.LayoutOrder = 1
    createCorner(saveSection, 6)
    createStroke(saveSection, Color3.fromRGB(60,60,70), 1)

    local saveTitle = Instance.new("TextLabel", saveSection)
    saveTitle.Size = UDim2.new(1, -10, 0, 20)
    saveTitle.Position = UDim2.new(0, 10, 0, 5)
    saveTitle.BackgroundTransparency = 1
    saveTitle.Text = "Save Current Position"
    saveTitle.TextColor3 = Color3.new(1,1,1)
    saveTitle.Font = Enum.Font.GothamBold
    saveTitle.TextSize = 12
    saveTitle.TextXAlignment = Enum.TextXAlignment.Left

    local nameInput = Instance.new("TextBox", saveSection)
    nameInput.Size = UDim2.new(0.65, 0, 0, 30)
    nameInput.Position = UDim2.new(0, 10, 0, 35)
    nameInput.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    nameInput.PlaceholderText = "Location Name..."
    nameInput.Text = ""
    nameInput.TextColor3 = Color3.new(1,1,1)
    nameInput.Font = Enum.Font.Gotham
    nameInput.TextSize = 11
    createCorner(nameInput, 4)
    createStroke(nameInput, Color3.fromRGB(60,60,60), 1)

    local saveBtn = Instance.new("TextButton", saveSection)
    saveBtn.Size = UDim2.new(0.28, 0, 0, 30)
    saveBtn.Position = UDim2.new(0.7, 0, 0, 35)
    saveBtn.BackgroundColor3 = UI_COLOR
    saveBtn.Text = "SAVE"
    saveBtn.TextColor3 = Color3.new(1,1,1)
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 11
    createCorner(saveBtn, 4)
    RegisterTheme(saveBtn, "BackgroundColor3")

    -- SECTION 2: FILE / VIP TOOLS
    local fileSection = Instance.new("Frame", mainScrollFrame)
    fileSection.Size = UDim2.new(0.98, 0, 0, 110)
    fileSection.BackgroundColor3 = CARD_COLOR
    fileSection.BackgroundTransparency = 0.2
    fileSection.LayoutOrder = 2
    createCorner(fileSection, 6)
    createStroke(fileSection, Color3.fromRGB(60,60,70), 1)

    local fileLayout = Instance.new("UIListLayout", fileSection)
    fileLayout.SortOrder = Enum.SortOrder.LayoutOrder
    fileLayout.Padding = UDim.new(0, 5)
    fileLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    local filePad = Instance.new("UIPadding", fileSection)
    filePad.PaddingTop = UDim.new(0, 10)

    local function createToolBtn(text, color, callback, isVipBtn)
        local btn = Instance.new("TextButton", fileSection)
        btn.Size = UDim2.new(0.92, 0, 0, 25)
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        createCorner(btn, 4)

        if isVipBtn and not isVIP then
            btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
            btn.Text = text .. " (VIP Only)"
            btn.TextColor3 = Color3.fromRGB(150,150,150)
            btn.AutoButtonColor = false
        else
            btn.MouseButton1Click:Connect(callback)
        end
        return btn
    end

    -- VIP Buttons
    createToolBtn("Save All as Preset (VIP)", Color3.fromRGB(80, 50, 120), function()
        notify("VIP Feature", "Preset Saved successfully!", 2)
        -- Logic save preset bisa ditambahkan disini
    end, true)

    createToolBtn("Load Preset (VIP)", Color3.fromRGB(65, 120, 200), function()
        notify("VIP Feature", "Preset Loaded!", 2)
        -- Logic load preset bisa ditambahkan disini
    end, true)

    -- Free Clear Button
    createToolBtn("Clear All Locations", Color3.fromRGB(170, 65, 65), function()
        teleportLocations = {}
        saveToDisk()
        notify("System", "All locations cleared.", 2)
    end, false)

    -- SECTION 3: LIST DISPLAY
    local listLabel = Instance.new("TextLabel", mainScrollFrame)
    listLabel.Size = UDim2.new(1, 0, 0, 20)
    listLabel.BackgroundTransparency = 1
    listLabel.Text = "  Saved Locations:"
    listLabel.TextColor3 = Color3.fromRGB(200,200,200)
    listLabel.Font = Enum.Font.GothamBold
    listLabel.TextSize = 12
    listLabel.TextXAlignment = Enum.TextXAlignment.Left
    listLabel.LayoutOrder = 3

    local locationsFrame = Instance.new("Frame", mainScrollFrame)
    locationsFrame.Size = UDim2.new(0.98, 0, 0, 0)
    locationsFrame.BackgroundTransparency = 1
    locationsFrame.LayoutOrder = 4

    local locListLayout = Instance.new("UIListLayout", locationsFrame)
    locListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    locListLayout.Padding = UDim.new(0, 4)

    -- Function to Refresh List
    local function refreshList()
        -- Clear old items
        for _, v in pairs(locationsFrame:GetChildren()) do
            if v:IsA("Frame") then v:Destroy() end
        end

        local count = 0
        for name, pos in pairs(teleportLocations) do
            count = count + 1
            local item = Instance.new("Frame", locationsFrame)
            item.Size = UDim2.new(1, 0, 0, 30)
            item.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            createCorner(item, 4)

            local lbl = Instance.new("TextLabel", item)
            lbl.Size = UDim2.new(0.7, 0, 1, 0)
            lbl.Position = UDim2.new(0, 10, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = name
            lbl.TextColor3 = Color3.new(1,1,1)
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 11
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            
            local tpBtn = Instance.new("TextButton", item)
            tpBtn.Size = UDim2.new(0, 40, 0, 20)
            tpBtn.Position = UDim2.new(1, -95, 0.5, 0)
            tpBtn.AnchorPoint = Vector2.new(0, 0.5)
            tpBtn.BackgroundColor3 = UI_COLOR
            tpBtn.Text = "TP"
            tpBtn.TextColor3 = Color3.new(1,1,1)
            tpBtn.Font = Enum.Font.GothamBold
            tpBtn.TextSize = 10
            createCorner(tpBtn, 3)
            RegisterTheme(tpBtn, "BackgroundColor3")

            local delBtn = Instance.new("TextButton", item)
            delBtn.Size = UDim2.new(0, 40, 0, 20)
            delBtn.Position = UDim2.new(1, -45, 0.5, 0)
            delBtn.AnchorPoint = Vector2.new(0, 0.5)
            delBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
            delBtn.Text = "DEL"
            delBtn.TextColor3 = Color3.new(1,1,1)
            delBtn.Font = Enum.Font.GothamBold
            delBtn.TextSize = 10
            createCorner(delBtn, 3)

            -- TP Logic
            tpBtn.MouseButton1Click:Connect(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local cf
                    if typeof(pos) == "CFrame" then cf = pos
                    elseif typeof(pos) == "table" then 
                         cf = CFrame.new(unpack(pos))
                    end
                    if cf then 
                        player.Character.HumanoidRootPart.CFrame = cf 
                    else
                         notify("Error", "Invalid Coordinate Data", 2)
                    end
                end
            end)

            -- Delete Logic
            delBtn.MouseButton1Click:Connect(function()
                teleportLocations[name] = nil
                saveToDisk()
                refreshList()
            end)
        end
        
        -- Resize container
        locationsFrame.Size = UDim2.new(0.98, 0, 0, count * 34)
        mainScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 220 + (count * 34))
    end

    -- Hook up Save Button
    saveBtn.MouseButton1Click:Connect(function()
        local name = nameInput.Text
        if name == "" then notify("Error", "Please enter a name", 2) return end
        if teleportLocations[name] then notify("Error", "Name already exists", 2) return end
        
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local cf = player.Character.HumanoidRootPart.CFrame
            -- Save as table of components for JSON compatibility
            teleportLocations[name] = {cf:GetComponents()} 
            saveToDisk()
            refreshList()
            nameInput.Text = ""
            notify("Success", "Location saved: " .. name, 2)
        end
    end)

    -- Hook up Clear Button Refresher
    for _, btn in pairs(fileSection:GetChildren()) do
        if btn:IsA("TextButton") and btn.Text == "Clear All Locations" then
            btn.MouseButton1Click:Connect(function() refreshList() end)
        end
    end

    refreshList()
end
