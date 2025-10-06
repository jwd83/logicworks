-- ui.lua
-- User interface system for LogicWorks

local Components = require('components')

local UI = {}
UI.__index = UI

function UI:new()
    local ui = {
        componentPalette = {
            x = 10,
            y = 50,
            width = 180,
            height = 600,
            components = Components.getComponentTypes()
        },
        toolbar = {
            x = 10,
            y = 10,
            width = 800,
            height = 35,
            buttons = {
                {text = "Step", key = "step", x = 10, y = 10, width = 60, height = 25},
                {text = "Reset", key = "reset", x = 80, y = 10, width = 60, height = 25},
                {text = "Wire", key = "wire", x = 150, y = 10, width = 60, height = 25},
                {text = "Clear", key = "clear", x = 220, y = 10, width = 60, height = 25},
                {text = "Run", key = "run", x = 290, y = 10, width = 60, height = 25}
            }
        },
        selectedButton = nil,
        mousePos = {x = 0, y = 0}
    }
    setmetatable(ui, self)
    return ui
end

function UI:update(dt)
    -- Update any animations or timers here
end

function UI:draw(gameState)
    -- Draw toolbar
    self:drawToolbar(gameState)
    
    -- Draw component palette
    self:drawComponentPalette(gameState)
    
    -- Draw status information
    self:drawStatusInfo(gameState)
end

function UI:drawToolbar(gameState)
    -- Toolbar background
    love.graphics.setColor(0.2, 0.2, 0.2, 0.9)
    love.graphics.rectangle("fill", self.toolbar.x, self.toolbar.y, self.toolbar.width, self.toolbar.height)
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.rectangle("line", self.toolbar.x, self.toolbar.y, self.toolbar.width, self.toolbar.height)
    
    -- Draw buttons
    for _, button in ipairs(self.toolbar.buttons) do
        local isActive = false
        if button.key == "wire" and gameState.wireMode then isActive = true end
        if button.key == "run" and gameState.running then isActive = true end
        
        local color = isActive and {r=0.5, g=0.7, b=0.5} or {r=0.3, g=0.3, b=0.3}
        love.graphics.setColor(color.r, color.g, color.b, 1)
        love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
        
        love.graphics.setColor(0.7, 0.7, 0.7, 1)
        love.graphics.rectangle("line", button.x, button.y, button.width, button.height)
        
        love.graphics.setColor(1, 1, 1, 1)
        local textWidth = love.graphics.getFont():getWidth(button.text)
        local textHeight = love.graphics.getFont():getHeight()
        love.graphics.print(button.text, 
                           button.x + (button.width - textWidth) / 2,
                           button.y + (button.height - textHeight) / 2)
    end
end

function UI:drawComponentPalette(gameState)
    -- Palette background
    love.graphics.setColor(0.15, 0.15, 0.15, 0.9)
    love.graphics.rectangle("fill", self.componentPalette.x, self.componentPalette.y, 
                           self.componentPalette.width, self.componentPalette.height)
    love.graphics.setColor(0.4, 0.4, 0.4, 1)
    love.graphics.rectangle("line", self.componentPalette.x, self.componentPalette.y, 
                           self.componentPalette.width, self.componentPalette.height)
    
    -- Title
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Components", self.componentPalette.x + 10, self.componentPalette.y + 10)
    
    -- Component list
    local yOffset = 40
    for i, componentType in ipairs(self.componentPalette.components) do
        local y = self.componentPalette.y + yOffset + (i - 1) * 35
        local isSelected = gameState.selectedComponent == componentType
        
        -- Button background
        local color = isSelected and {r=0.4, g=0.6, b=0.4} or {r=0.25, g=0.25, b=0.25}
        love.graphics.setColor(color.r, color.g, color.b, 1)
        love.graphics.rectangle("fill", self.componentPalette.x + 10, y, 
                               self.componentPalette.width - 20, 30)
        
        love.graphics.setColor(0.6, 0.6, 0.6, 1)
        love.graphics.rectangle("line", self.componentPalette.x + 10, y, 
                               self.componentPalette.width - 20, 30)
        
        -- Component preview
        self:drawComponentPreview(componentType, self.componentPalette.x + 15, y + 5)
        
        -- Component name
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(self:getComponentDisplayName(componentType), 
                           self.componentPalette.x + 40, y + 8)
    end
end

function UI:drawComponentPreview(componentType, x, y)
    -- Draw a small preview of each component type
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.scale(0.6, 0.6)
    
    if componentType == "toggle" then
        love.graphics.setColor(0.8, 0.2, 0.2, 1)
        love.graphics.rectangle("fill", 0, 0, 25, 25)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("T", 8, 8, 0, 0.8, 0.8)
    elseif componentType == "led" then
        love.graphics.setColor(1, 0.2, 0.2, 1)
        love.graphics.rectangle("fill", 0, 0, 25, 25)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.circle("fill", 12, 12, 6)
    elseif componentType == "and" then
        love.graphics.setColor(0.4, 0.4, 0.6, 1)
        love.graphics.rectangle("fill", 0, 0, 25, 20)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("&", 8, 6, 0, 0.8, 0.8)
    elseif componentType == "or" then
        love.graphics.setColor(0.4, 0.4, 0.6, 1)
        love.graphics.rectangle("fill", 0, 0, 25, 20)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("+", 8, 6, 0, 0.8, 0.8)
    elseif componentType == "not" then
        love.graphics.setColor(0.4, 0.4, 0.6, 1)
        love.graphics.rectangle("fill", 0, 0, 25, 15)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("!", 10, 4, 0, 0.8, 0.8)
    elseif componentType == "xor" then
        love.graphics.setColor(0.4, 0.4, 0.6, 1)
        love.graphics.rectangle("fill", 0, 0, 25, 20)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("⊕", 8, 6, 0, 0.8, 0.8)
    elseif componentType == "register" then
        love.graphics.setColor(0.3, 0.3, 0.5, 1)
        love.graphics.rectangle("fill", 0, 0, 25, 25)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("R", 8, 8, 0, 0.8, 0.8)
    end
    
    love.graphics.pop()
end

function UI:getComponentDisplayName(componentType)
    local names = {
        toggle = "Toggle Input",
        led = "LED Output",
        ["and"] = "AND Gate",
        ["or"] = "OR Gate",
        ["not"] = "NOT Gate",
        xor = "XOR Gate",
        register = "1-bit Register"
    }
    return names[componentType] or componentType
end

function UI:drawStatusInfo(gameState)
    -- Status panel
    local statusY = love.graphics.getHeight() - 120
    love.graphics.setColor(0.1, 0.1, 0.1, 0.8)
    love.graphics.rectangle("fill", 10, statusY, 400, 110)
    love.graphics.setColor(0.4, 0.4, 0.4, 1)
    love.graphics.rectangle("line", 10, statusY, 400, 110)
    
    -- Status text
    love.graphics.setColor(1, 1, 1, 1)
    local y = statusY + 10
    love.graphics.print("Status:", 15, y)
    
    y = y + 20
    if gameState.wireMode then
        love.graphics.setColor(0.8, 0.8, 0.2, 1)
        love.graphics.print("Wire Mode: Click two components to connect", 15, y)
    elseif gameState.selectedComponent then
        love.graphics.setColor(0.2, 0.8, 0.2, 1)
        love.graphics.print("Placing: " .. self:getComponentDisplayName(gameState.selectedComponent), 15, y)
    else
        love.graphics.setColor(0.7, 0.7, 0.7, 1)
        love.graphics.print("Click components to select from palette", 15, y)
    end
    
    y = y + 20
    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    local analysis = gameState.logic:analyzeCircuit()
    love.graphics.print("Components: " .. analysis.componentCount .. 
                       ", Wires: " .. analysis.wireCount, 15, y)
    
    y = y + 15
    love.graphics.print("Clock Steps: " .. gameState.logic.stepCount, 15, y)
    
    -- Controls
    y = y + 20
    love.graphics.setColor(0.5, 0.8, 1, 1)
    love.graphics.print("Controls:", 15, y)
    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    y = y + 15
    love.graphics.print("Space: Step Clock | R: Reset | C: Clear", 15, y, 0, 0.8, 0.8)
end

function UI:handleMousePressed(x, y, button, gameState)
    -- Check toolbar buttons
    if self:isPointInRect(x, y, self.toolbar.x, self.toolbar.y, 
                         self.toolbar.width, self.toolbar.height) then
        for _, btn in ipairs(self.toolbar.buttons) do
            if self:isPointInRect(x, y, btn.x, btn.y, btn.width, btn.height) then
                self:handleButtonPress(btn.key, gameState)
                return true
            end
        end
        return true
    end
    
    -- Check component palette
    if self:isPointInRect(x, y, self.componentPalette.x, self.componentPalette.y, 
                         self.componentPalette.width, self.componentPalette.height) then
        local yOffset = 40
        for i, componentType in ipairs(self.componentPalette.components) do
            local btnY = self.componentPalette.y + yOffset + (i - 1) * 35
            if self:isPointInRect(x, y, self.componentPalette.x + 10, btnY, 
                                 self.componentPalette.width - 20, 30) then
                gameState.selectedComponent = componentType
                gameState.wireMode = false
                print("Selected component: " .. componentType)
                return true
            end
        end
        return true
    end
    
    return false
end

function UI:handleMouseReleased(x, y, button, gameState)
    -- Handle mouse release events
end

function UI:handleMouseMoved(x, y, dx, dy, gameState)
    self.mousePos.x = x
    self.mousePos.y = y
end

function UI:handleButtonPress(buttonKey, gameState)
    if buttonKey == "step" then
        gameState.logic:stepClock()
    elseif buttonKey == "reset" then
        gameState.logic:reset()
    elseif buttonKey == "wire" then
        gameState.wireMode = not gameState.wireMode
        gameState.selectedComponent = nil
        gameState.wireStart = nil
        print("Wire mode: " .. (gameState.wireMode and "ON" or "OFF"))
    elseif buttonKey == "clear" then
        gameState.grid:clear()
        gameState.logic:reset()
        print("Grid cleared")
    elseif buttonKey == "run" then
        gameState.running = not gameState.running
        print("Running mode: " .. (gameState.running and "ON" or "OFF"))
    end
end

function UI:isPointInRect(px, py, x, y, width, height)
    return px >= x and px <= x + width and py >= y and py <= y + height
end

return UI