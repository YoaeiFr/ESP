-- Settings
local ESP = {
    Enabled = false,
    PlayersESP = {},
    Overrides = {},
}

-- Declarations
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Exploit = getexploitname and getexploitname() or syn and "Synapse" or pebc_execute and "Vega X" or "Unknown"

-- Functions
local function CreateTextLabel(parent, props)
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "ESPTextLabel"
    textLabel.Parent = parent

    for prop, value in pairs(props) do
        textLabel[prop] = value
    end

    return textLabel
end

local function CreateBox(parent, props)
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESPBox"
    box.Parent = parent

    for prop, value in pairs(props) do
        box[prop] = value
    end

    return box
end

function ESP:AddPlayerESP(player, components)
    if ESP.PlayersESP[player] then
        return
    end

    local character = player.Character
    if not character or not character:IsDescendantOf(workspace) then
        return
    end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return
    end

    local playerESP = {
        Player = player,
        Character = character,
        Humanoid = humanoid,
        RootPart = rootPart,
        Components = {},
    }

    for _, component in ipairs(components or {}) do
        local componentName = component.Name or "Component"
        local componentTextLabel = CreateTextLabel(rootPart, {
            Size = component.Size or 16,
            Text = componentName,
            TextColor3 = component.Color or Color3.new(1, 1, 1),
            BackgroundTransparency = 1,
            Position = Vector3.new(0, (16 * #playerESP.Components), 0),
            Visible = false,
            ZIndex = 10,
            Font = Enum.Font.SourceSansBold,
            TextSize = 14,
        })

        table.insert(playerESP.Components, {
            Name = componentName,
            TextLabel = componentTextLabel,
        })
    end

    ESP.PlayersESP[player] = playerESP
end

function ESP:RemovePlayerESP(player)
    local playerESP = ESP.PlayersESP[player]
    if not playerESP then
        return
    end

    for _, component in ipairs(playerESP.Components) do
        component.TextLabel:Destroy()
    end

    ESP.PlayersESP[player] = nil
end

function ESP:AddESPListener(parent, options)
    local listeners = {}

    options = options or {}
    options.CheckChildren = options.CheckChildren or false

    table.insert(listeners, parent.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Player") and Players:GetPlayerFromCharacter(descendant) then
            ESP:AddPlayerESP(Players:GetPlayerFromCharacter(descendant), options.Components)
        end
    end))

    if options.CheckChildren then
        table.insert(listeners, parent.ChildAdded:Connect(function(child)
            if child:IsA("Model") and child:FindFirstChild("Humanoid") and Players:GetPlayerFromCharacter(child) then
                ESP:AddPlayerESP(Players:GetPlayerFromCharacter(child), options.Components)
            end
        end))
    end

    return listeners
end

function ESP:UpdatePlayerESP(player)
    local playerESP = ESP.PlayersESP[player]
    if not playerESP then
        return
    end

    if playerESP.RootPart then
        for _, component in ipairs(playerESP.Components) do
            component.TextLabel.Visible = false
        end

        local index = 1
        for _, overrideComponent in ipairs(ESP.Overrides) do
            local component = playerESP.Components[overrideComponent.Index]
            if component then
                component.TextLabel.Position = Vector3.new(0, (16 * index), 0)
                component.TextLabel.Size = overrideComponent.Size or 16
                component.TextLabel.TextColor3 = overrideComponent.Color or Color3.new(1, 1, 1)
                component.TextLabel.Visible = true
                index = index + 1
            end
        end
    end
end

function ESP:Enable()
    if ESP.Enabled then
        return
    end

    ESP.Enabled = true

    ESP.Listeners = ESP:AddESPListener(workspace, {
        CheckChildren = true,
        Components = ESP.Overrides,
    })

    RunService.RenderStepped:Connect(function()
        if not ESP.Enabled then
            return
        end

        for _, playerESP in pairs(ESP.PlayersESP) do
            ESP:UpdatePlayerESP(playerESP.Player)
        end
    end)
end

function ESP:Disable()
    if not ESP.Enabled then
        return
    end

    ESP.Enabled = false

    for _, listener in ipairs(ESP.Listeners) do
        listener:Disconnect()
    end
    ESP.Listeners = {}

    for player, _ in pairs(ESP.PlayersESP) do
        ESP:RemovePlayerESP(player)
    end
end

function ESP:ChangeThinkers(thinkers)
    for _, playerESP in pairs(ESP.PlayersESP) do
        for _, component in ipairs(playerESP.Components) do
            component.TextLabel.Font = thinkers.Font or Enum.Font.SourceSansBold
            component.TextLabel.TextSize = thinkers.TextSize or 14
        end
    end
end

function ESP:ChangeSize(size)
    for _, playerESP in pairs(ESP.PlayersESP) do
        for _, component in ipairs(playerESP.Components) do
            component.TextLabel.Size = size or 16
        end
    end
end

function ESP:ChangeColor(color)
    for _, playerESP in pairs(ESP.PlayersESP) do
        for _, component in ipairs(playerESP.Components) do
            component.TextLabel.TextColor3 = color or Color3.new(1, 1, 1)
        end
    end
end

function ESP:AddComponent(component)
    table.insert(ESP.Overrides, component)
end
