-- LogicWorks: 2D Logic Workshop Game
-- Main entry point for Love2D

local Grid = require('grid')
local Components = require('components')
local Logic = require('logic')
local UI = require('ui')

-- Game state
local gameState = {
    grid = nil,
    logic = nil,
    ui = nil,
    selectedComponent = nil,
    placementMode = false,
    wireMode = false,
    wireStart = nil,
    clock = false,
    running = false
}

function love.load()
    -- Set up window
    love.window.setTitle("LogicWorks - Logic Workshop")
    love.window.setMode(1200, 800, {resizable = true, minwidth = 800, minheight = 600})
    
    -- Initialize systems
    gameState.grid = Grid:new(40, 30, 20) -- 40x30 grid, 20px cell size
    gameState.logic = Logic:new(gameState.grid)
    gameState.ui = UI:new()
    
    -- Set default font
    love.graphics.setFont(love.graphics.newFont(12))
    
    print("LogicWorks loaded successfully!")
end

function love.update(dt)
    if gameState.running then
        gameState.logic:updateContinuous(dt)
    end
    gameState.ui:update(dt)
end

function love.draw()
    -- Clear background
    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Draw grid
    gameState.grid:draw()
    
    -- Draw UI
    gameState.ui:draw(gameState)
    
    -- Draw debug info
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.print("LogicWorks v0.1 - MVP Beta", 10, love.graphics.getHeight() - 25)
end

function love.mousepressed(x, y, button)
    if gameState.ui:handleMousePressed(x, y, button, gameState) then
        return -- UI handled the click
    end
    
    gameState.grid:handleMousePressed(x, y, button, gameState)
end

function love.mousereleased(x, y, button)
    gameState.ui:handleMouseReleased(x, y, button, gameState)
    gameState.grid:handleMouseReleased(x, y, button, gameState)
end

function love.mousemoved(x, y, dx, dy)
    gameState.ui:handleMouseMoved(x, y, dx, dy, gameState)
    gameState.grid:handleMouseMoved(x, y, dx, dy, gameState)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "space" then
        gameState.logic:stepClock()
    elseif key == "r" then
        gameState.logic:reset()
    elseif key == "c" then
        gameState.grid:clear()
    end
end

-- Utility functions for other modules
function getGameState()
    return gameState
end