local Constants = require('constants')
local Board = require('board')
local Fighter = require('fighter')
local Background = require('background')
local Audio = require('audio')

local Game = {
    state = Constants.GAME_STATES.MENU,
    menuItems = {
        {text = "Start Game", action = "start"},
        {text = "Tutorial", action = "tutorial"},
        {text = "Settings", action = "settings"},  -- Changed from separate volume/language options
        {text = "Quit", action = "quit"}
    },
    selectedMenuItem = 1,
    selectedLevel = 1,
    selectedSetting = 1,  -- For settings menu navigation
    settings = {
        {text = "Difficulty", action = "difficulty"},
        {text = "Volume", action = "volume"},
        {text = "Language", action = "language"},
        {text = "Back", action = "back"}
    },
    volumeButtons = {
        {text = "-", action = "decrease"},
        {text = "+", action = "increase"}
    },
    selectedVolumeButton = 1,
    logo = nil
}

function Game:new()
    local game = {
        board = nil,
        player = nil,
        enemy = nil,
        background = Background:new(),
        audio = Audio:new(),  -- Initialize audio system
        state = Constants.GAME_STATES.MENU,
        selectedMenuItem = 1,
        selectedLevel = 1,  -- Default to first level
        language = Constants.LANGUAGES.EN,
        tutorial = {
            step = 1,
            timer = 0,
            messages = {}
        },
        menuItems = {},
        currentLevel = nil,  -- Store current level settings
        logo = love.graphics.newImage("assets/logo.png"),  -- Load the logo
        selectedSetting = 1,  -- Initialize selected setting
        settings = {
            {text = "Difficulty", action = "difficulty"},
            {text = "Volume", action = "volume"},
            {text = "Language", action = "language"},
            {text = "Back", action = "back"}
        }
    }
    setmetatable(game, {__index = self})
    game:updateLanguageTexts()
    
    -- Start playing menu music
    game.audio:playMenuMusic()
    
    return game
end

function Game:updateLanguageTexts()
    self.menuItems = {
        {text = Constants.TEXT[self.language].MENU.START, action = "start"},
        {text = Constants.TEXT[self.language].MENU.TUTORIAL, action = "tutorial"},
        {text = "Settings", action = "settings"},  -- Add translation in constants.lua
        {text = Constants.TEXT[self.language].MENU.QUIT, action = "quit"}
    }
    self.settings = {
        {text = Constants.TEXT[self.language].GAME.DIFFICULTY, action = "difficulty"},
        {text = Constants.TEXT[self.language].MENU.VOLUME, action = "volume"},
        {text = Constants.TEXT[self.language].MENU.LANGUAGE, action = "language"},
        {text = "Back", action = "back"}  -- Add translation in constants.lua
    }
    self.tutorial.messages = Constants.TEXT[self.language].TUTORIAL.CONTROLS
end

function Game:toggleLanguage()
    self.language = self.language == Constants.LANGUAGES.EN and Constants.LANGUAGES.PT or Constants.LANGUAGES.EN
    self:updateLanguageTexts()
end

function Game:startGame()
    -- Clean up any existing game state
    if self.board then
        self.board = nil
    end
    if self.player then
        self.player = nil
    end
    if self.enemy then
        self.enemy = nil
    end
    
    -- Get level settings
    local levelSettings = Constants.LEVELS[self.selectedLevel]
    
    -- Initialize new game state with level settings
    self.board = Board:new()
    self.board.level = self.selectedLevel  -- Set the actual level number
    self.board.dropSpeed = levelSettings.speed  -- Set the speed from level settings
    
    -- Initialize fighters
    self.player = Fighter:new("player")
    self.enemy = Fighter:new("enemy")
    self.enemy.aiTimer = 0
    self.enemy.aiInterval = levelSettings.ai_attack_interval
    self.enemy.aiDifficulty = levelSettings.ai_difficulty
    
    -- Switch to gameplay background
    self.background:setBackground("gameplay")
    
    self.state = Constants.GAME_STATES.PLAYING
    
    -- Switch to gameplay music
    self.audio:playGameMusic()
end

function Game:startTutorial()
    self.state = Constants.GAME_STATES.TUTORIAL
    self.tutorial.step = 1
    self.tutorial.timer = 0
end

function Game:update(dt)
    if self.state == Constants.GAME_STATES.PLAYING then
        -- Update background
        if self.background then
            self.background:update(dt)
        end
        
        -- Update board with level-specific speed
        if self.board then
            self.board:update(dt)
        end
        
        -- Update fighters
        if self.player then
            self.player:update(dt)
        end
        if self.enemy then
            self.enemy:update(dt)
            -- Update AI with level-specific settings
            self.enemy.aiTimer = (self.enemy.aiTimer or 0) + dt
            if self.enemy.aiTimer >= self.enemy.aiInterval then
                self.enemy.aiTimer = 0
                if love.math.random() < self.enemy.aiDifficulty then
                    local damage = love.math.random(3, 8)
                    self.player:takeDamage(damage)
                end
            end
        end
        
        -- Check for damage dealt
        if self.board and self.board.lastDamageDealt and self.board.lastDamageDealt > 0 then
            if self.enemy then
                self.enemy:takeDamage(self.board.lastDamageDealt)
                self.board.lastDamageDealt = 0
            end
        end
        
        -- Check for game over conditions
        if (self.board and self.board.gameOver) or 
           (self.player and self.player.health <= 0) then
            self.state = Constants.GAME_STATES.GAME_OVER
        elseif self.enemy and self.enemy.health <= 0 then
            self.state = Constants.GAME_STATES.VICTORY
        end
    elseif self.state == Constants.GAME_STATES.TUTORIAL then
        -- Tutorial is now shown all at once, no need for timer
    elseif self.state == Constants.GAME_STATES.LEVEL_SELECT then
        -- Draw level selection
        love.graphics.setColor(1, 1, 1, 1)
        local menuY = Constants.UI.MENU_START_Y
        
        love.graphics.printf(Constants.TEXT[self.language].LEVEL_SELECT.TITLE, 
            0, menuY - 100, Constants.SCREEN.WIDTH, "center")
        
        for i, level in ipairs(Constants.LEVELS) do
            local color = i == self.selectedLevel and {1, 1, 0} or {1, 1, 1}
            love.graphics.setColor(unpack(color))
            love.graphics.printf(level.displayName[self.language], 
                0, menuY + (i-1) * Constants.UI.MENU_ITEM_SPACING,
                Constants.SCREEN.WIDTH, "center")
        end
        
        -- Draw back instruction
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(Constants.TEXT[self.language].LEVEL_SELECT.BACK,
            0, Constants.SCREEN.HEIGHT - 50, Constants.SCREEN.WIDTH, "center")
    end
end

function Game:keypressed(key)
    if self.state == Constants.GAME_STATES.MENU then
        if key == "up" then
            self.selectedMenuItem = math.max(1, self.selectedMenuItem - 1)
        elseif key == "down" then
            self.selectedMenuItem = math.min(#self.menuItems, self.selectedMenuItem + 1)
        elseif key == "return" or key == "space" then
            local action = self.menuItems[self.selectedMenuItem].action
            if action == "start" then
                self:startGame()
            elseif action == "tutorial" then
                self:startTutorial()
            elseif action == "settings" then
                self.state = Constants.GAME_STATES.SETTINGS
                self.selectedSetting = 1
            elseif action == "quit" then
                love.event.quit()
            end
        end
    elseif self.state == Constants.GAME_STATES.SETTINGS then
        if key == "up" then
            self.selectedSetting = math.max(1, self.selectedSetting - 1)
        elseif key == "down" then
            self.selectedSetting = math.min(#self.settings, self.selectedSetting + 1)
        elseif key == "return" or key == "space" then
            local action = self.settings[self.selectedSetting].action
            if action == "back" then
                self.state = Constants.GAME_STATES.MENU
            elseif action == "language" then
                self:toggleLanguage()
            end
        elseif key == "escape" then
            self.state = Constants.GAME_STATES.MENU
        elseif key == "left" or key == "right" then
            local action = self.settings[self.selectedSetting].action
            if action == "volume" then
                if key == "left" then
                    self.audio:decreaseVolume()
                else
                    self.audio:increaseVolume()
                end
            elseif action == "difficulty" then
                if key == "left" then
                    self.selectedLevel = ((self.selectedLevel - 2) % #Constants.LEVELS) + 1
                else
                    self.selectedLevel = (self.selectedLevel % #Constants.LEVELS) + 1
                end
            end
        end
    elseif self.state == Constants.GAME_STATES.PLAYING then
        if key == "left" then
            self.board:movePiece(-1)
        elseif key == "right" then
            self.board:movePiece(1)
        elseif key == "up" then
            self.board:rotatePiece()
        elseif key == "down" then
            self.board:setSoftDrop(true)
        elseif key == "space" then
            self.board:hardDrop()
        elseif key == "c" then
            self.board:holdPiece()
        elseif key == "escape" then
            -- Return to menu and play menu music
            self.state = Constants.GAME_STATES.MENU
            self.audio:playMenuMusic()
            self.background:setBackground("menu")  -- Switch back to menu background
            
            -- Clean up game state
            self.board = nil
            self.player = nil
            self.enemy = nil
        end
    elseif self.state == Constants.GAME_STATES.TUTORIAL then
        if key == "return" or key == "space" or key == "escape" then
            self.state = Constants.GAME_STATES.MENU
            -- Switch back to menu music when returning from tutorial
            self.audio:playMenuMusic()
        end
    elseif self.state == Constants.GAME_STATES.PAUSED then
        if key == "escape" then
            self.state = Constants.GAME_STATES.PLAYING
        end
    elseif self.state == Constants.GAME_STATES.GAME_OVER or 
           self.state == Constants.GAME_STATES.VICTORY then
        self.state = Constants.GAME_STATES.MENU
        -- Switch back to menu music when returning to menu
        self.audio:playMenuMusic()
    elseif self.state == Constants.GAME_STATES.LEVEL_SELECT then
        if key == "up" then
            self.selectedLevel = math.max(1, self.selectedLevel - 1)
        elseif key == "down" then
            self.selectedLevel = math.min(#Constants.LEVELS, self.selectedLevel + 1)
        elseif key == "return" or key == "space" or key == "escape" then
            self.state = Constants.GAME_STATES.MENU
        end
    end
end

function Game:keyreleased(key)
    if self.state == Constants.GAME_STATES.PLAYING then
        if key == "down" then
            self.board:setSoftDrop(false)
        end
    end
end

function Game:draw()
    -- Draw background for all states
    if self.background then
        self.background:draw()
    end
    
    -- Draw volume indicator only in gameplay
    if self.state == Constants.GAME_STATES.PLAYING then
        love.graphics.setColor(1, 1, 1, 1)
        local volumeText = string.format("Volume: %d%%", math.floor(self.audio:getVolume() * 100))
        love.graphics.printf(volumeText, 
            -20, 20, Constants.SCREEN.WIDTH - 20, "right")
    end
    
    if self.state == Constants.GAME_STATES.PLAYING then
        -- Draw game board
        if self.board then
            self.board:draw(self.language)
        end
        
        -- Draw fighters
        if self.player then
            self.player:draw()
        end
        if self.enemy then
            self.enemy:draw()
        end
        
        -- Draw pause message if needed
        if self.state == Constants.GAME_STATES.PAUSED then
            love.graphics.setColor(0, 0, 0, 0.5)
            love.graphics.rectangle("fill", 0, 0, Constants.SCREEN.WIDTH, Constants.SCREEN.HEIGHT)
            
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.printf(Constants.TEXT[self.language].GAME.PAUSED,
                0, Constants.SCREEN.HEIGHT/2,
                Constants.SCREEN.WIDTH, "center")
        end
        
        -- Draw game over message if needed
        if self.board and self.board.gameOver then
            love.graphics.setColor(0, 0, 0, 0.7)
            love.graphics.rectangle("fill", 0, 0, Constants.SCREEN.WIDTH, Constants.SCREEN.HEIGHT)
            
            love.graphics.setColor(1, 0, 0, 1)
            love.graphics.printf(Constants.TEXT[self.language].GAME.GAME_OVER,
                0, Constants.SCREEN.HEIGHT/2,
                Constants.SCREEN.WIDTH, "center")
        end
    elseif self.state == Constants.GAME_STATES.MENU then
        -- Draw menu
        love.graphics.setColor(1, 1, 1, 1)
        
        -- Calculate logo dimensions and position
        local logoScale = 0.25
        local logoW, logoH = self.logo:getDimensions()
        local scaledLogoW = logoW * logoScale
        local scaledLogoH = logoH * logoScale
        local logoX = (Constants.SCREEN.WIDTH - scaledLogoW) / 2
        local logoY = 50
        
        -- Draw logo
        if self.logo then
            love.graphics.draw(self.logo, logoX, logoY, 0, logoScale, logoScale)
        end
        
        -- Calculate menu start position below logo
        local menuStartY = logoY + scaledLogoH + 30
        
        -- Draw menu items
        local itemSpacing = 40
        for i, item in ipairs(self.menuItems) do
            local color = i == self.selectedMenuItem and {1, 1, 0} or {1, 1, 1}
            love.graphics.setColor(unpack(color))
            love.graphics.printf(item.text, 
                0, 
                menuStartY + (i-1) * itemSpacing,
                Constants.SCREEN.WIDTH, 
                "center")
        end
    elseif self.state == Constants.GAME_STATES.SETTINGS then
        -- Draw settings screen
        love.graphics.setColor(1, 1, 1, 1)
        
        -- Draw settings title
        love.graphics.printf("Settings", 0, 100, Constants.SCREEN.WIDTH, "center")
        
        -- Draw settings items
        local settingsY = 200
        local itemSpacing = 60  -- Increased spacing for settings
        
        for i, setting in ipairs(self.settings) do
            local isSelected = i == self.selectedSetting
            love.graphics.setColor(isSelected and {1, 1, 0} or {1, 1, 1})
            
            -- Draw setting name
            love.graphics.printf(setting.text, 
                Constants.SCREEN.WIDTH/4, 
                settingsY + (i-1) * itemSpacing,
                Constants.SCREEN.WIDTH/2, 
                "left")
            
            -- Draw current value
            local value = ""
            if setting.action == "difficulty" then
                value = Constants.LEVELS[self.selectedLevel].displayName[self.language]
            elseif setting.action == "volume" then
                value = string.format("%d%%", math.floor(self.audio:getVolume() * 100))
            elseif setting.action == "language" then
                value = self.language == Constants.LANGUAGES.EN and "English" or "Português"
            end
            
            if value ~= "" then
                love.graphics.printf(value,
                    Constants.SCREEN.WIDTH/4,
                    settingsY + (i-1) * itemSpacing,
                    Constants.SCREEN.WIDTH/2,
                    "right")
            end
        end
        
        -- Draw instructions
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.printf(
            "Use UP/DOWN to select, LEFT/RIGHT to adjust, ENTER to confirm, ESC to return",
            0, Constants.SCREEN.HEIGHT - 50, Constants.SCREEN.WIDTH, "center")
    elseif self.state == Constants.GAME_STATES.LEVEL_SELECT then
        -- Draw level selection
        love.graphics.setColor(1, 1, 1, 1)
        local menuY = Constants.UI.MENU_START_Y
        
        love.graphics.printf(Constants.TEXT[self.language].LEVEL_SELECT.TITLE, 
            0, menuY - 100, Constants.SCREEN.WIDTH, "center")
        
        for i, level in ipairs(Constants.LEVELS) do
            local color = i == self.selectedLevel and {1, 1, 0} or {1, 1, 1}
            love.graphics.setColor(unpack(color))
            
            -- Only show the currently selected level with the (Selected) indicator
            local text = level.displayName[self.language]
            if i == self.selectedLevel then
                text = text .. " " .. Constants.TEXT[self.language].LEVEL_SELECT.SELECTED
            end
            
            love.graphics.printf(text,
                0, menuY + (i-1) * Constants.UI.MENU_ITEM_SPACING,
                Constants.SCREEN.WIDTH, "center")
        end
        
        -- Draw back instruction
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(Constants.TEXT[self.language].LEVEL_SELECT.BACK,
            0, Constants.SCREEN.HEIGHT - 50, Constants.SCREEN.WIDTH, "center")
    elseif self.state == Constants.GAME_STATES.TUTORIAL then
        love.graphics.setColor(1, 1, 1, 1)
        
        -- Draw tutorial title
        love.graphics.printf(Constants.TEXT[self.language].TUTORIAL.TITLE,
            0, 50, Constants.SCREEN.WIDTH, "center")
        
        -- Draw all controls at once
        local startY = 150
        for i, msg in ipairs(self.tutorial.messages) do
            love.graphics.printf(msg,
                100, startY + (i-1) * 30,
                Constants.SCREEN.WIDTH-200, "left")
        end
        
        -- Draw back instruction
        love.graphics.printf(Constants.TEXT[self.language].TUTORIAL.BACK,
            0, Constants.SCREEN.HEIGHT - 50,
            Constants.SCREEN.WIDTH, "center")
    elseif self.state == Constants.GAME_STATES.GAME_OVER then
        -- Draw the final game state
        if self.board then
            self.board:draw(self.language)
        end
        if self.player then
            self.player:draw()
        end
        if self.enemy then
            self.enemy:draw()
        end
        
        -- Draw semi-transparent overlay
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, Constants.SCREEN.WIDTH, Constants.SCREEN.HEIGHT)
        
        -- Draw game over message
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.printf(Constants.TEXT[self.language].GAME.GAME_OVER,
            0, Constants.SCREEN.HEIGHT/2,
            Constants.SCREEN.WIDTH, "center")
            
        -- Draw instruction to return to menu
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(Constants.TEXT[self.language].GAME.RETURN_TO_MENU,
            0, Constants.SCREEN.HEIGHT/2 + 50,
            Constants.SCREEN.WIDTH, "center")
    elseif self.state == Constants.GAME_STATES.VICTORY then
        -- Draw the final game state
        if self.board then
            self.board:draw(self.language)
        end
        if self.player then
            self.player:draw()
        end
        if self.enemy then
            self.enemy:draw()
        end
        
        -- Draw semi-transparent overlay
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, Constants.SCREEN.WIDTH, Constants.SCREEN.HEIGHT)
        
        -- Draw victory message
        love.graphics.setColor(0, 1, 0, 1)
        love.graphics.printf(Constants.TEXT[self.language].GAME.VICTORY,
            0, Constants.SCREEN.HEIGHT/2,
            Constants.SCREEN.WIDTH, "center")
            
        -- Draw instruction to return to menu
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(Constants.TEXT[self.language].GAME.RETURN_TO_MENU,
            0, Constants.SCREEN.HEIGHT/2 + 50,
            Constants.SCREEN.WIDTH, "center")
    end
end

return Game 