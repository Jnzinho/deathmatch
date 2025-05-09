local Constants = require('constants')

local Tetrominoes = {}

Tetrominoes.SHAPES = {
    I = {
        {0,0,0,0},
        {1,1,1,1},
        {0,0,0,0},
        {0,0,0,0}
    },
    J = {
        {1,0,0},
        {1,1,1},
        {0,0,0}
    },
    L = {
        {0,0,1},
        {1,1,1},
        {0,0,0}
    },
    O = {
        {1,1},
        {1,1}
    },
    S = {
        {0,1,1},
        {1,1,0},
        {0,0,0}
    },
    T = {
        {0,1,0},
        {1,1,1},
        {0,0,0}
    },
    Z = {
        {1,1,0},
        {0,1,1},
        {0,0,0}
    }
}

Tetrominoes.SPAWN_POSITIONS = {
    I = {x = 3, y = 1},
    J = {x = 3, y = 1},
    L = {x = 3, y = 1},
    O = {x = 4, y = 1},
    S = {x = 3, y = 1},
    T = {x = 3, y = 1},
    Z = {x = 3, y = 1}
}

function Tetrominoes:new(shape)
    local tetromino = {
        shape = shape or self:randomShape(),
        rotation = 0,
        x = 0,
        y = 0,
        matrix = nil,
        ghost = true
    }
    setmetatable(tetromino, {__index = self})
    
    tetromino.matrix = self.SHAPES[tetromino.shape]
    
    local spawn = self.SPAWN_POSITIONS[tetromino.shape]
    tetromino.x = spawn.x
    tetromino.y = spawn.y
    
    return tetromino
end

function Tetrominoes:randomShape()
    local shapes = {'I', 'J', 'L', 'O', 'S', 'T', 'Z'}
    return shapes[love.math.random(#shapes)]
end

function Tetrominoes:rotate()
    if self.shape == 'O' then return end
    
    local N = #self.matrix
    local newMatrix = {}
    
    for i = 1, N do
        newMatrix[i] = {}
        for j = 1, N do
            newMatrix[i][j] = self.matrix[N - j + 1][i]
        end
    end
    
    self.matrix = newMatrix
    self.rotation = (self.rotation + 1) % 4
end

function Tetrominoes:canMove(board, offsetX, offsetY)
    local newX = self.x + (offsetX or 0)
    local newY = self.y + (offsetY or 0)
    
    for y = 1, #self.matrix do
        for x = 1, #self.matrix[y] do
            if self.matrix[y][x] == 1 then
                local boardX = newX + x - 1
                local boardY = newY + y - 1
                
                if boardX < 1 or boardX > Constants.GRID_WIDTH or
                   boardY < 1 or boardY > Constants.GRID_HEIGHT then
                    return false
                end
                
                if board.grid[boardY] and board.grid[boardY][boardX] then
                    return false
                end
            end
        end
    end
    
    return true
end

function Tetrominoes:getGhostPosition(board)
    local ghostY = self.y
    
    while self:canMove(board, 0, ghostY - self.y + 1) do
        ghostY = ghostY + 1
    end
    
    return ghostY
end

function Tetrominoes:lock(board)
    for y = 1, #self.matrix do
        for x = 1, #self.matrix[y] do
            if self.matrix[y][x] == 1 then
                local boardY = self.y + y - 1
                local boardX = self.x + x - 1
                if boardY >= 1 and boardY <= Constants.GRID_HEIGHT and
                   boardX >= 1 and boardX <= Constants.GRID_WIDTH then
                    board.grid[boardY][boardX] = self.shape
                end
            end
        end
    end
end

function Tetrominoes:draw(board)
    love.graphics.push()
    
    if self.ghost and board then
        local ghostY = self:getGhostPosition(board)
        local color = Constants.COLORS[self.shape]
        if color then
            love.graphics.setColor(color[1], color[2], color[3], 0.3)
            
            for y = 1, #self.matrix do
                for x = 1, #self.matrix[y] do
                    if self.matrix[y][x] == 1 then
                        love.graphics.rectangle("line",
                            (self.x + x - 2) * Constants.CELL_SIZE,
                            (ghostY + y - 2) * Constants.CELL_SIZE,
                            Constants.CELL_SIZE,
                            Constants.CELL_SIZE)
                    end
                end
            end
        end
    end
    
    local color = Constants.COLORS[self.shape]
    if color then
        love.graphics.setColor(color[1], color[2], color[3], 1)
        
        for y = 1, #self.matrix do
            for x = 1, #self.matrix[y] do
                if self.matrix[y][x] == 1 then
                    love.graphics.rectangle("fill",
                        (self.x + x - 2) * Constants.CELL_SIZE,
                        (self.y + y - 2) * Constants.CELL_SIZE,
                        Constants.CELL_SIZE,
                        Constants.CELL_SIZE)
                    
                    love.graphics.setColor(1, 1, 1, 0.5)
                    love.graphics.rectangle("line",
                        (self.x + x - 2) * Constants.CELL_SIZE,
                        (self.y + y - 2) * Constants.CELL_SIZE,
                        Constants.CELL_SIZE,
                        Constants.CELL_SIZE)
                    
                    if color then
                        love.graphics.setColor(color[1], color[2], color[3], 1)
                    end
                end
            end
        end
    end
    
    love.graphics.pop()
end

return Tetrominoes 