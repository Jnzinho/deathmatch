local Background = {}

function Background:new()
    local background = {
        images = {
            menu = love.graphics.newImage("assets/background.png"),
            gameplay = love.graphics.newImage("assets/gameplay-background.png")
        },
        currentImage = "menu",
        timer = 0
    }
    setmetatable(background, {__index = self})
    
    for _, img in pairs(background.images) do
        img:setFilter("nearest", "nearest")
    end
    
    return background
end

function Background:setBackground(type)
    self.currentImage = type
end

function Background:update(dt)
    self.timer = self.timer + dt
end

function Background:draw()
    local image = self.images[self.currentImage]
    if not image then return end
    
    local scaleX = love.graphics.getWidth() / image:getWidth()
    local scaleY = love.graphics.getHeight() / image:getHeight()
    local scale = math.max(scaleX, scaleY)
    
    local x = (love.graphics.getWidth() - image:getWidth() * scale) / 2
    local y = (love.graphics.getHeight() - image:getHeight() * scale) / 2
    
    love.graphics.setColor(0.2, 0.8, 0.6, 1)  -- Cyberpunk greenish-blue tint
    love.graphics.draw(image, x, y, 0, scale, scale)
    love.graphics.setColor(1, 1, 1, 1)
    
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)
end

return Background 