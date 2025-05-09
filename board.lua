local Constants = require('constants')
local Tetrominoes = require('tetrominoes')

local Board = {}

function Board:new(initialSpeed)
    local board = {
        grid = {},
        width = Constants.GRID_WIDTH,
        height = Constants.GRID_HEIGHT,
        currentPiece = nil,
        nextPiece = nil,
        heldPiece = nil,
        canHold = true,
        dropTimer = 0,
        lockTimer = 0,
        softDrop = false,
        level = 1,
        score = 0,
        lines = 0,
        gameOver = false,
        combo = 0,
        lastDamageDealt = 0,
        dropSpeed = initialSpeed or Constants.BASE_DROP_INTERVAL
    }
    setmetatable(board, {__index = self})
    
    for y = 1, board.height do
        board.grid[y] = {}
        for x = 1, board.width do
            board.grid[y][x] = nil
        end
    end
    
    board.nextPiece = Tetrominoes:new()
    board:spawnNewPiece()
    
    return board
end

function Board:update(dt)
    if self.gameOver then return end
    
    self.dropTimer = self.dropTimer + dt
    local dropInterval = self.softDrop and Constants.SPEEDS.SOFT_DROP or self.dropSpeed
    
    if not self.currentPiece:canMove(self, 0, 1) then
        self.lockTimer = self.lockTimer + dt
        if self.lockTimer >= Constants.SPEEDS.LOCK_DELAY then
            self:lockCurrentPiece()
        end
    else
        self.lockTimer = 0
    end
    
    if self.dropTimer >= dropInterval then
        self.dropTimer = 0
        self:movePieceDown()
    end
end

function Board:movePieceDown()
    if not self.currentPiece:canMove(self, 0, 1) then
        return false
    end
    
    self.currentPiece.y = self.currentPiece.y + 1
    self.lockTimer = 0
    return true
end

function Board:setSoftDrop(enabled)
    self.softDrop = enabled
    self.dropTimer = 0
end

function Board:holdPiece()
    if not self.canHold then return end
    
    local temp = self.currentPiece.shape
    if self.heldPiece then
        self.currentPiece = Tetrominoes:new(self.heldPiece)
        self.heldPiece = temp
    else
        self.heldPiece = temp
        self:spawnNewPiece()
    end
    
    self.currentPiece.x = math.floor(self.width / 2) - 1
    self.currentPiece.y = 1
    
    self.canHold = false
end

function Board:lockCurrentPiece()
    self.currentPiece:lock(self)
    
    local linesCleared = self:checkLines()
    if linesCleared > 0 then
        self.combo = self.combo + 1
        self:updateScore(linesCleared)
    else
        self.combo = 0
    end
    
    self:spawnNewPiece()
    
    self.lockTimer = 0
    self.dropTimer = 0
    self.canHold = true
end

function Board:movePiece(dx)
    if self.currentPiece:canMove(self, dx, 0) then
        self.currentPiece.x = self.currentPiece.x + dx
        self.lockTimer = 0
        return true
    end
    return false
end

function Board:rotatePiece()
    local originalMatrix = self.currentPiece.matrix
    local originalRotation = self.currentPiece.rotation
    
    self.currentPiece:rotate()
    
    local kicks = {
        {0, 0},
        {-1, 0},
        {1, 0},
        {0, -1},
        {-1, -1},
        {1, -1}
    }
    
    for _, kick in ipairs(kicks) do
        if self.currentPiece:canMove(self, kick[1], kick[2]) then
            self.currentPiece.x = self.currentPiece.x + kick[1]
            self.currentPiece.y = self.currentPiece.y + kick[2]
            self.lockTimer = 0
            return true
        end
    end
    
    self.currentPiece.matrix = originalMatrix
    self.currentPiece.rotation = originalRotation
    return false
end

function Board:hardDrop()
    local dropDistance = 0
    while self:movePieceDown() do
        dropDistance = dropDistance + 1
    end
    self:lockCurrentPiece()
    return dropDistance
end

function Board:spawnNewPiece()
    self.currentPiece = self.nextPiece
    self.nextPiece = Tetrominoes:new()
    
    local spawn = Tetrominoes.SPAWN_POSITIONS[self.currentPiece.shape]
    self.currentPiece.x = math.floor(self.width / 2) - 1
    self.currentPiece.y = 1
    
    if not self:isValidPosition(self.currentPiece) then
        self.gameOver = true
    end
end

function Board:isValidPosition(piece)
    for y = 1, #piece.matrix do
        for x = 1, #piece.matrix[y] do
            if piece.matrix[y][x] == 1 then
                local boardX = piece.x + x - 1
                local boardY = piece.y + y - 1
                
                if boardX < 1 or boardX > self.width or
                   boardY < 1 or boardY > self.height then
                    return false
                end
                
                if self.grid[boardY] and self.grid[boardY][boardX] then
                    return false
                end
            end
        end
    end
    return true
end

function Board:checkLines()
    local linesCleared = 0
    local y = self.height
    
    while y > 0 do
        local complete = true
        for x = 1, self.width do
            if not self.grid[y][x] then
                complete = false
                break
            end
        end
        
        if complete then
            table.remove(self.grid, y)
            table.insert(self.grid, 1, {})
            for x = 1, self.width do
                self.grid[1][x] = nil
            end
            linesCleared = linesCleared + 1
        else
            y = y - 1
        end
    end
    
    return linesCleared
end

function Board:updateScore(linesCleared)
    self.lines = self.lines + linesCleared
    
    local points = {
        [1] = 100,
        [2] = 300,
        [3] = 500,
        [4] = 800
    }
    
    local comboMultiplier = 1 + (self.combo * 0.1)
    self.score = self.score + (points[linesCleared] or 0) * self.level * comboMultiplier
    
    self.level = math.floor(self.lines / 10) + 1
    
    local damage = linesCleared * Constants.COMBAT.DAMAGE_PER_LINE * comboMultiplier
    self.lastDamageDealt = math.min(damage, Constants.COMBAT.MAX_HEALTH)
end

function Board:draw(language)
    love.graphics.push()
    love.graphics.translate(Constants.SCREEN.BOARD_OFFSET_X, Constants.SCREEN.BOARD_OFFSET_Y)
    
    for y = 1, self.height do
        for x = 1, self.width do
            love.graphics.setColor(0.1, 0.1, 0.1, 1)
            love.graphics.rectangle("fill",
                (x-1) * Constants.CELL_SIZE,
                (y-1) * Constants.CELL_SIZE,
                Constants.CELL_SIZE,
                Constants.CELL_SIZE)
            
            love.graphics.setColor(0.2, 0.2, 0.2, 1)
            love.graphics.rectangle("line",
                (x-1) * Constants.CELL_SIZE,
                (y-1) * Constants.CELL_SIZE,
                Constants.CELL_SIZE,
                Constants.CELL_SIZE)
            
            if self.grid[y][x] then
                local color = Constants.COLORS[self.grid[y][x]]
                if color then
                    love.graphics.setColor(color[1], color[2], color[3], 1)
                    love.graphics.rectangle("fill",
                        (x-1) * Constants.CELL_SIZE,
                        (y-1) * Constants.CELL_SIZE,
                        Constants.CELL_SIZE,
                        Constants.CELL_SIZE)
                end
            end
        end
    end
    
    if self.currentPiece then
        local shadowPiece = {
            x = self.currentPiece.x,
            y = self.currentPiece.y,
            matrix = self.currentPiece.matrix,
            shape = self.currentPiece.shape
        }
        
        while shadowPiece.y < self.height do
            local canMove = true
            for y = 1, #shadowPiece.matrix do
                for x = 1, #shadowPiece.matrix[y] do
                    if shadowPiece.matrix[y][x] == 1 then
                        local boardX = shadowPiece.x + x - 1
                        local boardY = shadowPiece.y + y
                        
                        if boardY > self.height or 
                           (self.grid[boardY] and self.grid[boardY][boardX]) then
                            canMove = false
                            break
                        end
                    end
                end
                if not canMove then break end
            end
            if not canMove then break end
            shadowPiece.y = shadowPiece.y + 1
        end
        
        local color = Constants.COLORS[shadowPiece.shape]
        if color then
            love.graphics.setColor(color[1], color[2], color[3], 0.2)
            for y = 1, #shadowPiece.matrix do
                for x = 1, #shadowPiece.matrix[y] do
                    if shadowPiece.matrix[y][x] == 1 then
                        love.graphics.rectangle("fill",
                            (shadowPiece.x + x - 2) * Constants.CELL_SIZE,
                            (shadowPiece.y + y - 2) * Constants.CELL_SIZE,
                            Constants.CELL_SIZE,
                            Constants.CELL_SIZE)
                    end
                end
            end
        end
    end
    
    if self.currentPiece then
        local color = Constants.COLORS[self.currentPiece.shape]
        if color then
            love.graphics.setColor(color[1], color[2], color[3], 1)
            for y = 1, #self.currentPiece.matrix do
                for x = 1, #self.currentPiece.matrix[y] do
                    if self.currentPiece.matrix[y][x] == 1 then
                        love.graphics.rectangle("fill",
                            (self.currentPiece.x + x - 2) * Constants.CELL_SIZE,
                            (self.currentPiece.y + y - 2) * Constants.CELL_SIZE,
                            Constants.CELL_SIZE,
                            Constants.CELL_SIZE)
                    end
                end
            end
        end
    end
    
    love.graphics.pop()
    
    if self.heldPiece then
        love.graphics.push()
        love.graphics.translate(Constants.SCREEN.HOLD_PIECE_X, Constants.SCREEN.HOLD_PIECE_Y)
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(Constants.TEXT[language].GAME.HOLD, 0, -25)
        
        local heldPieceDisplay = Tetrominoes:new(self.heldPiece)
        if heldPieceDisplay then
            local color = Constants.COLORS[heldPieceDisplay.shape]
            if color then
                love.graphics.setColor(color[1], color[2], color[3], 1)
                for y = 1, #heldPieceDisplay.matrix do
                    for x = 1, #heldPieceDisplay.matrix[y] do
                        if heldPieceDisplay.matrix[y][x] == 1 then
                            love.graphics.rectangle("fill",
                                (x-1) * Constants.CELL_SIZE,
                                (y-1) * Constants.CELL_SIZE,
                                Constants.CELL_SIZE,
                                Constants.CELL_SIZE)
                        end
                    end
                end
            end
        end
        love.graphics.pop()
    end
    
    if self.nextPiece then
        love.graphics.push()
        love.graphics.translate(Constants.SCREEN.NEXT_PIECE_X, Constants.SCREEN.NEXT_PIECE_Y)
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(Constants.TEXT[language].GAME.NEXT, 0, -25)
        
        local color = Constants.COLORS[self.nextPiece.shape]
        if color then
            love.graphics.setColor(color[1], color[2], color[3], 1)
            for y = 1, #self.nextPiece.matrix do
                for x = 1, #self.nextPiece.matrix[y] do
                    if self.nextPiece.matrix[y][x] == 1 then
                        love.graphics.rectangle("fill",
                            (x-1) * Constants.CELL_SIZE,
                            (y-1) * Constants.CELL_SIZE,
                            Constants.CELL_SIZE,
                            Constants.CELL_SIZE)
                    end
                end
            end
        end
        love.graphics.pop()
    end
end

return Board 