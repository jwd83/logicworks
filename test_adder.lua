-- test_adder.lua
-- Test configuration for verifying adder functionality

local Components = require('components')
local Grid = require('grid')
local Logic = require('logic')

local function createHalfAdder()
    print("Creating Half Adder test circuit...")
    
    -- Create grid and logic system
    local grid = Grid:new(40, 30, 20)
    local logic = Logic:new(grid)
    
    -- Create components for half adder
    local toggleA = Components.createComponent("toggle", 2, 2)  -- Input A
    local toggleB = Components.createComponent("toggle", 2, 4)  -- Input B
    local xorGate = Components.createComponent("xor", 6, 3)     -- Sum = A XOR B
    local andGate = Components.createComponent("and", 6, 5)     -- Carry = A AND B
    local ledSum = Components.createComponent("led", 10, 3)     -- Sum output
    local ledCarry = Components.createComponent("led", 10, 5)   -- Carry output
    
    -- Add components to grid
    grid:addComponent(toggleA)
    grid:addComponent(toggleB)
    grid:addComponent(xorGate)
    grid:addComponent(andGate)
    grid:addComponent(ledSum)
    grid:addComponent(ledCarry)
    
    -- Add wires (simulated connections)
    grid:addWire(2, 2, 6, 3)  -- A -> XOR input
    grid:addWire(2, 4, 6, 3)  -- B -> XOR input
    grid:addWire(2, 2, 6, 5)  -- A -> AND input
    grid:addWire(2, 4, 6, 5)  -- B -> AND input
    grid:addWire(6, 3, 10, 3) -- XOR -> Sum LED
    grid:addWire(6, 5, 10, 5) -- AND -> Carry LED
    
    return grid, logic
end

local function testHalfAdderTruthTable(grid, logic)
    print("\\nTesting Half Adder Truth Table:")
    print("A | B | Sum | Carry")
    print("--|---|-----|------")
    
    local truthTable = {
        {false, false, false, false},  -- 0 + 0 = 0 (Sum=0, Carry=0)
        {true,  false, true,  false},  -- 1 + 0 = 1 (Sum=1, Carry=0)
        {false, true,  true,  false},  -- 0 + 1 = 1 (Sum=1, Carry=0)
        {true,  true,  false, true}    -- 1 + 1 = 10 (Sum=0, Carry=1)
    }
    
    local passed = 0
    local total = #truthTable
    
    for i, test in ipairs(truthTable) do
        local a, b, expectedSum, expectedCarry = test[1], test[2], test[3], test[4]
        
        -- Set input states
        logic:setToggleStates({a, b})
        
        -- Get output states
        local outputs = logic:getLEDStates()
        local actualSum = outputs[1] or false
        local actualCarry = outputs[2] or false
        
        -- Check results
        local sumCorrect = actualSum == expectedSum
        local carryCorrect = actualCarry == expectedCarry
        local testPassed = sumCorrect and carryCorrect
        
        if testPassed then
            passed = passed + 1
        end
        
        print(string.format("%s | %s | %s%s | %s%s %s",
              a and "1" or "0",
              b and "1" or "0",
              actualSum and "1" or "0",
              sumCorrect and "" or "❌",
              actualCarry and "1" or "0", 
              carryCorrect and "" or "❌",
              testPassed and "✓" or "❌"))
    end
    
    print(string.format("\\nResults: %d/%d tests passed", passed, total))
    return passed == total
end

local function runAdderTest()
    print("=== LogicWorks Half Adder Test ===")
    
    -- Create and test half adder
    local grid, logic = createHalfAdder()
    local success = testHalfAdderTruthTable(grid, logic)
    
    if success then
        print("\\n🎉 Half Adder test PASSED! The logic simulation is working correctly.")
        print("You can now build adders in the main game and verify they work properly.")
    else
        print("\\n❌ Half Adder test FAILED. There may be issues with the logic simulation.")
    end
    
    return success
end

-- For standalone testing
if arg and arg[0] and arg[0]:match("test_adder.lua") then
    runAdderTest()
end

return {
    createHalfAdder = createHalfAdder,
    testHalfAdderTruthTable = testHalfAdderTruthTable,
    runAdderTest = runAdderTest
}