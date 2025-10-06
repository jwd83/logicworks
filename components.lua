-- components.lua
-- Component system for LogicWorks

local Components = {}

-- Base Component class
local Component = {}
Component.__index = Component

function Component:new(x, y, componentType)
    local comp = {
        x = x,
        y = y,
        type = componentType,
        inputs = {},
        outputs = {},
        state = {},
        connections = {},
        id = tostring(math.random(1000000))
    }
    setmetatable(comp, self)
    return comp
end

function Component:getInputPos(index)
    return self.x * 20 - 5, self.y * 20 + 10
end

function Component:getOutputPos(index)
    return self.x * 20 + 25, self.y * 20 + 10
end

function Component:addInput(name, x, y)
    table.insert(self.inputs, {name = name, x = x or 0, y = y or 0, value = false, connected = false})
end

function Component:addOutput(name, x, y)
    table.insert(self.outputs, {name = name, x = x or 0, y = y or 0, value = false, connections = {}})
end

function Component:setInput(index, value)
    if self.inputs[index] then
        self.inputs[index].value = value
    end
end

function Component:getOutput(index)
    if self.outputs[index] then
        return self.outputs[index].value
    end
    return false
end

function Component:update()
    -- Override in subclasses
end

function Component:draw()
    -- Override in subclasses
end

function Component:drawBase(color, width, height)
    width = width or 1
    height = height or 1
    local pixelWidth = width * 20
    local pixelHeight = height * 20
    
    love.graphics.setColor(color.r or 0.5, color.g or 0.5, color.b or 0.5, 1)
    love.graphics.rectangle("fill", self.x * 20, self.y * 20, pixelWidth, pixelHeight)
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.rectangle("line", self.x * 20, self.y * 20, pixelWidth, pixelHeight)
end

-- Toggle Input Component
local Toggle = setmetatable({}, {__index = Component})
Toggle.__index = Toggle

function Toggle:new(x, y)
    local comp = Component:new(x, y, "toggle")
    setmetatable(comp, Toggle)
    comp:addOutput("out")
    comp.state.on = false
    return comp
end

function Toggle:toggle()
    self.state.on = not self.state.on
    self.outputs[1].value = self.state.on
end

function Toggle:update()
    self.outputs[1].value = self.state.on
end

function Toggle:draw()
    local color = self.state.on and {r=0.8, g=0.2, b=0.2} or {r=0.3, g=0.3, b=0.3}
    self:drawBase(color, 2, 2)  -- Make it 2x2 blocks
    
    -- Draw T for Toggle
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("TOGGLE", self.x * 20 + 4, self.y * 20 + 8, 0, 0.8, 0.8)
    
    -- Draw state indicator
    love.graphics.setColor(self.state.on and 1 or 0.3, self.state.on and 1 or 0.3, self.state.on and 1 or 0.3, 1)
    love.graphics.circle("fill", self.x * 20 + 20, self.y * 20 + 20, 4)
    
    -- Draw output pin
    love.graphics.setColor(self.state.on and 1 or 0.3, self.state.on and 0.3 or 0.3, self.state.on and 0.3 or 0.3, 1)
    love.graphics.circle("fill", self.x * 20 + 40, self.y * 20 + 20, 3)
end

-- LED Output Component
local LED = setmetatable({}, {__index = Component})
LED.__index = LED

function LED:new(x, y)
    local comp = Component:new(x, y, "led")
    setmetatable(comp, LED)
    comp:addInput("in")
    return comp
end

function LED:update()
    -- LED state follows input
end

function LED:draw()
    local isOn = self.inputs[1] and self.inputs[1].value
    local color = isOn and {r=1, g=0.2, b=0.2} or {r=0.2, g=0.2, b=0.2}
    self:drawBase(color, 2, 2)  -- Make it 2x2 blocks
    
    -- Draw LED circle
    love.graphics.setColor(isOn and 1 or 0.3, isOn and 0.2 or 0.2, isOn and 0.2 or 0.2, 1)
    love.graphics.circle("fill", self.x * 20 + 20, self.y * 20 + 20, 10)
    
    -- Draw LED label
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("LED", self.x * 20 + 12, self.y * 20 + 4, 0, 0.8, 0.8)
    
    -- Draw input pin
    love.graphics.setColor(isOn and 1 or 0.3, isOn and 0.3 or 0.3, isOn and 0.3 or 0.3, 1)
    love.graphics.circle("fill", self.x * 20, self.y * 20 + 20, 3)
end


-- Logic Gates
local function createGate(gateType, logic)
    local Gate = setmetatable({}, {__index = Component})
    Gate.__index = Gate
    
    function Gate:new(x, y)
        local comp = Component:new(x, y, gateType)
        setmetatable(comp, Gate)
        if gateType == "not" then
            comp:addInput("in")
        else
            comp:addInput("in1")
            comp:addInput("in2")
        end
        comp:addOutput("out")
        comp.logic = logic
        return comp
    end
    
    function Gate:update()
        if self.type == "not" then
            self.outputs[1].value = not (self.inputs[1] and self.inputs[1].value)
        else
            local a = self.inputs[1] and self.inputs[1].value or false
            local b = self.inputs[2] and self.inputs[2].value or false
            self.outputs[1].value = self.logic(a, b)
        end
    end
    
    function Gate:draw()
        local output = self.outputs[1].value
        local height = (self.type == "not") and 2 or 3  -- NOT gate is smaller
        self:drawBase({r=0.4, g=0.4, b=0.6}, 3, height)
        
        -- Draw gate symbol and name
        love.graphics.setColor(1, 1, 1, 1)
        local symbol = ""
        local name = ""
        if self.type == "and" then 
            symbol = "&"
            name = "AND"
        elseif self.type == "or" then 
            symbol = "+"
            name = "OR"
        elseif self.type == "not" then 
            symbol = "!"
            name = "NOT"
        elseif self.type == "xor" then 
            symbol = "⊕"
            name = "XOR"
        end
        
        love.graphics.print(name, self.x * 20 + 8, self.y * 20 + 4, 0, 0.8, 0.8)
        love.graphics.print(symbol, self.x * 20 + 25, self.y * 20 + 25, 0, 1.5, 1.5)
        
        -- Draw input pins
        if self.type == "not" then
            local isOn = self.inputs[1] and self.inputs[1].value
            love.graphics.setColor(isOn and 1 or 0.3, isOn and 0.3 or 0.3, isOn and 0.3 or 0.3, 1)
            love.graphics.circle("fill", self.x * 20, self.y * 20 + 20, 3)
        else
            for i = 1, 2 do
                local isOn = self.inputs[i] and self.inputs[i].value
                love.graphics.setColor(isOn and 1 or 0.3, isOn and 0.3 or 0.3, isOn and 0.3 or 0.3, 1)
                love.graphics.circle("fill", self.x * 20, self.y * 20 + 10 + (i * 20), 3)
            end
        end
        
        -- Draw output pin
        love.graphics.setColor(output and 1 or 0.3, output and 0.3 or 0.3, output and 0.3 or 0.3, 1)
        local outputY = (self.type == "not") and 20 or 30
        love.graphics.circle("fill", self.x * 20 + 60, self.y * 20 + outputY, 3)
    end
    
    return Gate
end

-- Create specific gate types
local ANDGate = createGate("and", function(a, b) return a and b end)
local ORGate = createGate("or", function(a, b) return a or b end)
local NOTGate = createGate("not", nil)
local XORGate = createGate("xor", function(a, b) return (a and not b) or (not a and b) end)

-- 8-bit Register
local Register = setmetatable({}, {__index = Component})
Register.__index = Register

function Register:new(x, y)
    local comp = Component:new(x, y, "register")
    setmetatable(comp, Register)
    -- Single data input + clock input
    comp:addInput("data")
    comp:addInput("clock")
    
    -- Single data output
    comp:addOutput("out")
    
    comp.state.data = false
    comp.state.lastClock = false
    return comp
end

function Register:update()
    -- Check for clock edge (rising edge)
    local currentClock = self.inputs[2] and self.inputs[2].value or false
    if currentClock and not self.state.lastClock then
        -- Rising edge - latch data
        self.state.data = self.inputs[1] and self.inputs[1].value or false
    end
    self.state.lastClock = currentClock
    
    -- Update output
    self.outputs[1].value = self.state.data
end

function Register:draw()
    self:drawBase({r=0.3, g=0.3, b=0.5}, 3, 3)  -- Make it 3x3 blocks
    
    -- Draw REGISTER label
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("REG", self.x * 20 + 8, self.y * 20 + 4, 0, 0.8, 0.8)
    
    -- Draw current state indicator
    love.graphics.setColor(self.state.data and 1 or 0.3, self.state.data and 1 or 0.3, self.state.data and 1 or 0.3, 1)
    love.graphics.circle("fill", self.x * 20 + 30, self.y * 20 + 30, 6)
    
    -- Draw input pins
    local dataOn = self.inputs[1] and self.inputs[1].value
    local clockOn = self.inputs[2] and self.inputs[2].value
    
    -- Data input pin
    love.graphics.setColor(dataOn and 1 or 0.3, dataOn and 0.3 or 0.3, dataOn and 0.3 or 0.3, 1)
    love.graphics.circle("fill", self.x * 20, self.y * 20 + 20, 3)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("D", self.x * 20 + 8, self.y * 20 + 16, 0, 0.6, 0.6)
    
    -- Clock input pin
    love.graphics.setColor(clockOn and 1 or 0.3, clockOn and 0.3 or 0.3, clockOn and 0.3 or 0.3, 1)
    love.graphics.circle("fill", self.x * 20, self.y * 20 + 40, 3)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("CLK", self.x * 20 + 8, self.y * 20 + 36, 0, 0.6, 0.6)
    
    -- Output pin
    love.graphics.setColor(self.state.data and 1 or 0.3, self.state.data and 0.3 or 0.3, self.state.data and 0.3 or 0.3, 1)
    love.graphics.circle("fill", self.x * 20 + 60, self.y * 20 + 30, 3)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Q", self.x * 20 + 52, self.y * 20 + 26, 0, 0.6, 0.6)
end

-- Wire class
local Wire = {}
Wire.__index = Wire

function Wire:new(x1, y1, x2, y2)
    local wire = {
        x1 = x1,
        y1 = y1,
        x2 = x2,
        y2 = y2,
        signal = false,
        id = tostring(math.random(1000000))
    }
    setmetatable(wire, self)
    return wire
end

function Wire:draw()
    local color = self.signal and {r=1, g=0.3, b=0.3} or {r=0.4, g=0.4, b=0.4}
    love.graphics.setColor(color.r, color.g, color.b, 1)
    love.graphics.setLineWidth(2)
    love.graphics.line(self.x1 * 20 + 10, self.y1 * 20 + 10, self.x2 * 20 + 10, self.y2 * 20 + 10)
    love.graphics.setLineWidth(1)
end

-- Export all component types
Components.Component = Component
Components.Toggle = Toggle
Components.LED = LED
Components.ANDGate = ANDGate
Components.ORGate = ORGate
Components.NOTGate = NOTGate
Components.XORGate = XORGate
Components.Register = Register
Components.Wire = Wire

-- Component creation helpers
Components.createComponent = function(type, x, y)
    if type == "toggle" then return Toggle:new(x, y)
    elseif type == "led" then return LED:new(x, y)
    elseif type == "and" then return ANDGate:new(x, y)
    elseif type == "or" then return ORGate:new(x, y)
    elseif type == "not" then return NOTGate:new(x, y)
    elseif type == "xor" then return XORGate:new(x, y)
    elseif type == "register" then return Register:new(x, y)
    end
    return nil
end

Components.getComponentTypes = function()
    return {"toggle", "led", "and", "or", "not", "xor", "register"}
end

return Components