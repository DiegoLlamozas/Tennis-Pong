Player = Class{}

function Player:init(x, y, width, height, movementRangeMin, movementRangeMax)
    self.x = x or 0
    self.y = y or 0
    self.width = width or 0
    self.height = height or 0
    self.movementRangeMin = movementRangeMin or 0
    self.movementRangeMax = movementRangeMax or 0
    self.dy = 0
    self.dx = 0
end

function Player:update(dt)
    -- Update vertical movement
    self.y = math.max(self.movementRangeMin, math.min(self.movementRangeMax - self.height, self.y + self.dy * dt))
    
    -- Update horizontal movement
    self.x = math.max(0, math.min(VIRTUAL_WIDTH - self.width, self.x + self.dx * dt))
end

function Player:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
