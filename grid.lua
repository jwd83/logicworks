-- grid.lua
-- Grid system for LogicWorks

local Components = require('components')

local Grid = {}
Grid.__index = Grid

function Grid:new(width, height, cellSize)
    local grid = {
        width = width,
        height = height,
        cellSize = cellSize,
        components = {},
        wires = {},
        offsetX = 200, -- Leave space for UI panel
        offsetY = 50   -- Leave space for toolbar
    }
    setmetatable(grid, self)
    return grid
end

function Grid:clear()
    self.components = {}
    self.wires = {}
end

function Grid:getGridPos(screenX, screenY)
    local gridX = math.floor((screenX - self.offsetX) / self.cellSize)
    local gridY = math.floor((screenY - self.offsetY) / self.cellSize)
    return gridX, gridY
end

function Grid:getScreenPos(gridX, gridY)
    return gridX * self.cellSize + self.offsetX, gridY * self.cellSize + self.offsetY
end

function Grid:isValidPos(x, y)
    return x >= 0 and x < self.width and y >= 0 and y < self.height
end

function Grid:getComponentAt(x, y)
    for _, comp in ipairs(self.components) do
        -- Calculate component size
        local width, height = self:getComponentSize(comp.type)
        
        -- Check if click is within component bounds
        if x >= comp.x and x < comp.x + width and 
           y >= comp.y and y < comp.y + height then
            return comp
        end
    end
    return nil
end

function Grid:getComponentSize(componentType)
    -- Define component sizes in grid blocks
    local sizes = {
        toggle = {2, 2},
        led = {2, 2},
        ["and"] = {3, 3},
        ["or"] = {3, 3},
        ["not"] = {3, 2},
        xor = {3, 3},
        register = {3, 3}
    }
    local size = sizes[componentType] or {1, 1}
    return size[1], size[2]
end

function Grid:addComponent(component)
    local width, height = self:getComponentSize(component.type)
    
    -- Check if component fits within grid bounds
    if not self:isValidPos(component.x, component.y) or 
       not self:isValidPos(component.x + width - 1, component.y + height - 1) then
        return false
    end
    
    -- Check for collisions with existing components
    for checkX = component.x, component.x + width - 1 do
        for checkY = component.y, component.y + height - 1 do
            for _, existing in ipairs(self.components) do
                local exWidth, exHeight = self:getComponentSize(existing.type)
                if checkX >= existing.x and checkX < existing.x + exWidth and
                   checkY >= existing.y and checkY < existing.y + exHeight then
                    return false  -- Collision detected
                end
            end
        end
    end
    
    table.insert(self.components, component)
    return true
end

function Grid:removeComponent(component)
    for i, comp in ipairs(self.components) do
        if comp == component then
            table.remove(self.components, i)
            break
        end
    end
    
    -- Remove any wires connected to this component
    local wiresToRemove = {}
    for i, wire in ipairs(self.wires) do
        if (wire.x1 == component.x and wire.y1 == component.y) or
           (wire.x2 == component.x and wire.y2 == component.y) then
            table.insert(wiresToRemove, i)
        end
    end
    
    -- Remove wires in reverse order to maintain indices
    for i = #wiresToRemove, 1, -1 do
        table.remove(self.wires, wiresToRemove[i])
    end
end

function Grid:addWire(x1, y1, x2, y2)
    -- Check if wire already exists
    for _, wire in ipairs(self.wires) do
        if (wire.x1 == x1 and wire.y1 == y1 and wire.x2 == x2 and wire.y2 == y2) or
           (wire.x1 == x2 and wire.y1 == y2 and wire.x2 == x1 and wire.y2 == y1) then
            return false -- Wire already exists
        end
    end
    
    -- Only allow wires between components
    local comp1 = self:getComponentAt(x1, y1)
    local comp2 = self:getComponentAt(x2, y2)
    
    if comp1 and comp2 and comp1 ~= comp2 then
        local wire = Components.Wire:new(x1, y1, x2, y2)
        table.insert(self.wires, wire)
        return true
    end
    
    return false
end

function Grid:removeWire(x1, y1, x2, y2)
    for i, wire in ipairs(self.wires) do
        if (wire.x1 == x1 and wire.y1 == y1 and wire.x2 == x2 and wire.y2 == y2) or
           (wire.x1 == x2 and wire.y1 == y2 and wire.x2 == x1 and wire.y2 == y1) then
            table.remove(self.wires, i)
            return true
        end
    end
    return false
end

function Grid:getWireAt(x, y)
    -- Check if clicking near a wire
    for _, wire in ipairs(self.wires) do
        local wx1, wy1 = self:getScreenPos(wire.x1, wire.y1)
        local wx2, wy2 = self:getScreenPos(wire.x2, wire.y2)
        wx1, wy1 = wx1 + 10, wy1 + 10
        wx2, wy2 = wx2 + 10, wy2 + 10
        
        -- Simple distance check to wire line
        local A = wy2 - wy1
        local B = wx1 - wx2
        local C = wx2 * wy1 - wx1 * wy2
        local distance = math.abs(A * x + B * y + C) / math.sqrt(A * A + B * B)
        
        if distance < 5 then -- 5 pixel tolerance
            -- Check if point is within wire bounds
            local minX, maxX = math.min(wx1, wx2), math.max(wx1, wx2)
            local minY, maxY = math.min(wy1, wy2), math.max(wy1, wy2)
            if x >= minX - 5 and x <= maxX + 5 and y >= minY - 5 and y <= maxY + 5 then
                return wire
            end
        end
    end
    return nil
end

function Grid:draw()
    -- Draw grid lines
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    
    -- Vertical lines
    for x = 0, self.width do
        local screenX = x * self.cellSize + self.offsetX
        love.graphics.line(screenX, self.offsetY, screenX, self.height * self.cellSize + self.offsetY)
    end
    
    -- Horizontal lines
    for y = 0, self.height do
        local screenY = y * self.cellSize + self.offsetY
        love.graphics.line(self.offsetX, screenY, self.width * self.cellSize + self.offsetX, screenY)
    end
    
    -- Draw wires first (so they appear behind components)
    for _, wire in ipairs(self.wires) do
        love.graphics.push()
        love.graphics.translate(self.offsetX, self.offsetY)
        wire:draw()
        love.graphics.pop()
    end
    
    -- Draw components
    for _, component in ipairs(self.components) do
        love.graphics.push()
        love.graphics.translate(self.offsetX, self.offsetY)
        component:draw()
        love.graphics.pop()
    end
    
    -- Draw grid boundaries
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.rectangle("line", self.offsetX, self.offsetY, 
                           self.width * self.cellSize, self.height * self.cellSize)
end

function Grid:handleMousePressed(x, y, button, gameState)
    local gridX, gridY = self:getGridPos(x, y)
    
    if not self:isValidPos(gridX, gridY) then
        return false
    end
    
    if button == 1 then -- Left click
        if gameState.wireMode then
            if gameState.wireStart then
                -- Complete wire
                if self:addWire(gameState.wireStart.x, gameState.wireStart.y, gridX, gridY) then
                    print("Wire added from " .. gameState.wireStart.x .. "," .. gameState.wireStart.y .. 
                          " to " .. gridX .. "," .. gridY)
                end
                gameState.wireStart = nil
                gameState.wireMode = false
            else
                -- Start wire
                local component = self:getComponentAt(gridX, gridY)
                if component then
                    gameState.wireStart = {x = gridX, y = gridY}
                    print("Wire started at " .. gridX .. "," .. gridY)
                end
            end
        elseif gameState.selectedComponent then
            -- Place component
            local component = Components.createComponent(gameState.selectedComponent, gridX, gridY)
            if component and self:addComponent(component) then
                print("Placed " .. gameState.selectedComponent .. " at " .. gridX .. "," .. gridY)
            else
                print("Cannot place component at " .. gridX .. "," .. gridY)
            end
        else
            -- Interact with existing component
            local component = self:getComponentAt(gridX, gridY)
            if component then
                if component.type == "toggle" then
                    component:toggle()
                    print("Toggled switch at " .. gridX .. "," .. gridY)
                end
            end
        end
    elseif button == 2 then -- Right click
        if gameState.wireMode then
            -- Cancel wire mode
            gameState.wireMode = false
            gameState.wireStart = nil
            print("Wire mode cancelled")
        else
            -- Delete component or wire
            local component = self:getComponentAt(gridX, gridY)
            if component then
                self:removeComponent(component)
                print("Removed component at " .. gridX .. "," .. gridY)
            else
                -- Check for wire deletion
                local wire = self:getWireAt(x, y)
                if wire then
                    self:removeWire(wire.x1, wire.y1, wire.x2, wire.y2)
                    print("Removed wire")
                end
            end
        end
    end
    
    return true
end

function Grid:handleMouseReleased(x, y, button, gameState)
    -- Handle any mouse release logic here
end

function Grid:handleMouseMoved(x, y, dx, dy, gameState)
    -- Handle any mouse move logic here (like wire preview)
end

function Grid:getAllComponents()
    return self.components
end

function Grid:getAllWires()
    return self.wires
end

return Grid