-- logic.lua
-- Logic simulation engine for LogicWorks

local Logic = {}
Logic.__index = Logic

function Logic:new(grid)
    local logic = {
        grid = grid,
        clockState = false,
        stepCount = 0,
        updateTimer = 0,
        updateRate = 0.1, -- 10 Hz update rate when running
        maxIterations = 100 -- Prevent infinite loops in signal propagation
    }
    setmetatable(logic, self)
    return logic
end

function Logic:reset()
    self.clockState = false
    self.stepCount = 0
    
    -- Reset all components
    for _, component in ipairs(self.grid:getAllComponents()) do
        if component.type == "toggle" then
            component.state.on = false
            component.outputs[1].value = false
        elseif component.type == "register" then
            component.state.data = {false, false, false, false, false, false, false, false}
            component.state.lastClock = false
            for i = 1, 8 do
                component.outputs[i].value = false
            end
        end
        -- Reset inputs
        for _, input in ipairs(component.inputs) do
            input.value = false
            input.connected = false
        end
    end
    
    -- Reset wire signals
    for _, wire in ipairs(self.grid:getAllWires()) do
        wire.signal = false
    end
    
    print("Logic simulation reset")
end

function Logic:stepClock()
    self.clockState = not self.clockState
    self.stepCount = self.stepCount + 1
    
    print("Clock step " .. self.stepCount .. " - Clock is " .. (self.clockState and "HIGH" or "LOW"))
    
    -- Update all clock inputs for registers
    for _, component in ipairs(self.grid:getAllComponents()) do
        if component.type == "register" and component.inputs[2] then -- Clock is second input
            component.inputs[2].value = self.clockState
            print("Updated register clock input to", self.clockState)
        end
    end
    
    -- Propagate signals
    self:propagateSignals()
end

function Logic:updateContinuous(dt)
    self.updateTimer = self.updateTimer + dt
    if self.updateTimer >= self.updateRate then
        self:propagateSignals()
        self.updateTimer = 0
    end
end

function Logic:propagateSignals()
    -- Simple approach: just update all components
    -- Components will read their input values from connected wires
    
    -- First, update all wire signals based on their source components
    for _, wire in ipairs(self.grid:getAllWires()) do
        local sourceComp = self.grid:getComponentAt(wire.x1, wire.y1)
        if sourceComp and #sourceComp.outputs > 0 then
            wire.signal = sourceComp.outputs[1].value
            print("Wire from", sourceComp.type, "signal:", wire.signal)
        else
            wire.signal = false
        end
    end
    
    -- Then update all component inputs based on connected wires
    for _, component in ipairs(self.grid:getAllComponents()) do
        if component.type ~= "toggle" then -- Don't override toggle states
            -- Clear inputs first
            for _, input in ipairs(component.inputs) do
                input.value = false
            end
            
            -- Update inputs from connected wires
            self:updateComponentInputsFromWires(component)
        end
    end
    
    -- Finally, update all components
    local componentCount = 0
    for _, component in ipairs(self.grid:getAllComponents()) do
        if component.type == "and" then
            print("AND gate inputs:", 
                  component.inputs[1] and component.inputs[1].value or false, 
                  component.inputs[2] and component.inputs[2].value or false)
        end
        component:update()
        if component.type == "and" then
            print("AND gate output:", component.outputs[1].value)
        end
        componentCount = componentCount + 1
    end
    
    print("Updated", componentCount, "components")
end


function Logic:updateComponentInputsFromWires(component)
    -- Find all wires connected to this component and update inputs
    local inputIndex = 1
    
    for _, wire in ipairs(self.grid:getAllWires()) do
        -- Check if wire connects TO this component (component is the target)
        local targetComp = self.grid:getComponentAt(wire.x2, wire.y2)
        if targetComp and targetComp == component then
            -- This wire feeds into this component
            if component.type == "led" then
                -- LED has only one input
                if component.inputs[1] then
                    component.inputs[1].value = component.inputs[1].value or wire.signal  -- OR multiple inputs together
                end
            elseif component.type == "and" or component.type == "or" or component.type == "xor" then
                -- Gates have multiple inputs - assign to next available input
                if inputIndex <= #component.inputs then
                    component.inputs[inputIndex].value = wire.signal
                    inputIndex = inputIndex + 1
                end
            elseif component.type == "not" then
                -- NOT gate has only one input
                if component.inputs[1] then
                    component.inputs[1].value = wire.signal
                end
            elseif component.type == "register" then
                -- For registers, assume first wire is data, others ignored for now
                if component.inputs[1] then
                    component.inputs[1].value = wire.signal
                end
            end
        end
    end
end

function Logic:getConnectionsForComponent(component)
    -- Get all wires connected to a specific component
    local connections = {inputs = {}, outputs = {}}
    
    for _, wire in ipairs(self.grid:getAllWires()) do
        if wire.x1 == component.x and wire.y1 == component.y then
            table.insert(connections.outputs, wire)
        elseif wire.x2 == component.x and wire.y2 == component.y then
            table.insert(connections.inputs, wire)
        end
    end
    
    return connections
end

function Logic:analyzeCircuit()
    local components = self.grid:getAllComponents()
    local wires = self.grid:getAllWires()
    
    local analysis = {
        componentCount = #components,
        wireCount = #wires,
        inputCount = 0,
        outputCount = 0,
        gateCount = 0
    }
    
    for _, component in ipairs(components) do
        if component.type == "toggle" then
            analysis.inputCount = analysis.inputCount + 1
        elseif component.type == "led" then
            analysis.outputCount = analysis.outputCount + 1
        elseif component.type == "and" or component.type == "or" or 
               component.type == "not" or component.type == "xor" then
            analysis.gateCount = analysis.gateCount + 1
        end
    end
    
    return analysis
end

-- Helper function for testing circuits
function Logic:setToggleStates(states)
    local toggleIndex = 1
    for _, component in ipairs(self.grid:getAllComponents()) do
        if component.type == "toggle" and toggleIndex <= #states then
            component.state.on = states[toggleIndex]
            component.outputs[1].value = states[toggleIndex]
            toggleIndex = toggleIndex + 1
        end
    end
    self:propagateSignals()
end

-- Helper function to get LED states for testing
function Logic:getLEDStates()
    local states = {}
    for _, component in ipairs(self.grid:getAllComponents()) do
        if component.type == "led" then
            table.insert(states, component.inputs[1] and component.inputs[1].value or false)
        end
    end
    return states
end


return Logic