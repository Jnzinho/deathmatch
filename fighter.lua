local Constants = require('constants')

local Fighter = {}

local SPRITE_SCALE = 3.5
local ANIMATION_TIMER = 0.1

function Fighter:new(type)
    local fighter = {
        type = type,
        health = Constants.COMBAT.MAX_HEALTH,
        shield = 0,
        power = 0,
        x = 0,
        y = 0,
        sprites = {},
        currentAnimation = "IDLE",
        animationTimer = 0,
        currentFrame = 1,
        facingRight = type == "player",
        copiesInSheet = type == "player" and 4 or 6
    }
    setmetatable(fighter, {__index = self})
    
    if type == "player" then
        fighter.sprites = {
            IDLE = love.graphics.newImage("assets/samurai1/Sprites/IDLE.png"),
            ATTACK = love.graphics.newImage("assets/samurai1/Sprites/ATTACK 1.png"),
            HURT = love.graphics.newImage("assets/samurai1/Sprites/HURT.png")
        }
        fighter.frameCount = {
            IDLE = 10,
            ATTACK = 7,
            HURT = 4
        }
        fighter.x = Constants.SCREEN.LEFT_PANEL_X + Constants.SCREEN.PADDING * -2

        fighter.y = Constants.SCREEN.HEIGHT - Constants.SCREEN.PADDING * 19.5
    else
        fighter.sprites = {
            IDLE = love.graphics.newImage("assets/knight1/Sprites/with_outline/IDLE.png"),
            ATTACK = love.graphics.newImage("assets/knight1/Sprites/with_outline/ATTACK 1.png"),
            HURT = love.graphics.newImage("assets/knight1/Sprites/with_outline/HURT.png")
        }
        fighter.frameCount = {
            IDLE =
            7,
            ATTACK = 6,
            HURT = 4
        }
        fighter.x = Constants.SCREEN.RIGHT_PANEL_X + Constants.SCREEN.PADDING * 0
        fighter.y = Constants.SCREEN.HEIGHT - Constants.SCREEN.PADDING * 16
    end
    
    for _, sprite in pairs(fighter.sprites) do
        sprite:setFilter("nearest", "nearest")
    end
    
    return fighter
end

function Fighter:update(dt)
    self.animationTimer = self.animationTimer + dt
    if self.animationTimer >= ANIMATION_TIMER then
        self.animationTimer = 0
        self.currentFrame = self.currentFrame + 1
        if self.currentFrame > self.frameCount[self.currentAnimation] then
            self.currentFrame = 1
            if self.currentAnimation == "ATTACK" or self.currentAnimation == "HURT" then
                self.currentAnimation = "IDLE"
            end
        end
    end
    
    if self.shield > 0 then
        self.shield = math.max(0, self.shield - Constants.COMBAT.SHIELD_DECAY * dt)
    end
end

function Fighter:draw()
    local sprite = self.sprites[self.currentAnimation]
    if not sprite then return end
    
    local frameWidth = sprite:getWidth() / self.frameCount[self.currentAnimation]
    local frameHeight = sprite:getHeight()
    
    local quad = love.graphics.newQuad(
        (self.currentFrame - 1) * frameWidth,
        0,
        frameWidth,
        frameHeight,
        sprite:getWidth(),
        sprite:getHeight()
    )
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
        sprite,
        quad,
        self.x + (self.facingRight and 0 or frameWidth * SPRITE_SCALE),
        self.y,
        0,
        self.facingRight and SPRITE_SCALE or -SPRITE_SCALE,
        SPRITE_SCALE
    )
    
    love.graphics.setColor(1, 1, 1, 1)
    local label = self.type == "player" and "Player" or "Enemy"
    local healthBarY = self.type == "player" and self.y + 90 or self.y + 25
    local healthBarX = self.type == "player" and self.x + 100 or self.x + 80
    love.graphics.print(label, healthBarX + 35, healthBarY - 20)
    
    local healthBarY = self.type == "player" and self.y + 100 or self.y + 35
    local healthBarX = self.type == "player" and self.x + 100 or self.x + 80
    local healthBarWidth = 100
    local healthPercentage = self.health / Constants.COMBAT.MAX_HEALTH
    
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.rectangle("fill",
        healthBarX,
        healthBarY,
        healthBarWidth,
        10
    )
    
    local r = 1 - healthPercentage
    local g = healthPercentage
    love.graphics.setColor(r, g, 0, 1)
    love.graphics.rectangle("fill",
        healthBarX,
        healthBarY,
        healthBarWidth * healthPercentage,
        10
    )
    
    love.graphics.setColor(1, 1, 1, 1)
    local healthText = math.floor(self.health) .. "/" .. Constants.COMBAT.MAX_HEALTH
    love.graphics.print(healthText, healthBarX + healthBarWidth + 10, healthBarY - 2)
end

function Fighter:takeDamage(amount)
    if self.shield > 0 then
        local shieldDamage = math.min(self.shield, amount)
        self.shield = self.shield - shieldDamage
        amount = amount - shieldDamage
    end
    
    if amount > 0 then
        self.health = math.max(0, self.health - amount)
        self.currentAnimation = "HURT"
        self.currentFrame = 1
        self.animationTimer = 0
    end
end

function Fighter:attack()
    self.currentAnimation = "ATTACK"
    self.currentFrame = 1
    self.animationTimer = 0
end

function Fighter:addShield(amount)
    self.shield = math.min(Constants.COMBAT.MAX_SHIELD, self.shield + amount)
end

function Fighter:addPower(amount)
    self.power = math.min(Constants.COMBAT.SPECIAL_THRESHOLD, self.power + amount)
end

function Fighter:useSpecial()
    if self.power >= Constants.COMBAT.SPECIAL_THRESHOLD then
        self.power = 0
        self.currentAnimation = "ATTACK"
        self.currentFrame = 1
        self.animationTimer = 0
        return true
    end
    return false
end

return Fighter 