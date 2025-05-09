local Constants = require('constants')
local Menu = require('states/menu')
local Board = require('board')
local Fighter = require('fighter')
local Game = require('game')

-- Sistema de log com arquivo
local logFile

local function log(msg)
    if not logFile then
        logFile = io.open("game_log.txt", "a")
    end
    local logMsg = string.format("[%s] %s\n", os.date("%H:%M:%S"), msg)
    if logFile then
        logFile:write(logMsg)
        logFile:flush()
    end
end

-- Função para fechar o arquivo de log
function love.quit()
    if logFile then
        logFile:close()
    end
end

-- Handler de erros global mais detalhado
function love.errorhandler(msg)
    local errorMsg = string.format([[
-----------------
ERRO NO JOGO:
%s

TRACEBACK:
%s
-----------------]], tostring(msg), debug.traceback())
    
    -- Tenta salvar o erro em arquivo
    local errorFile = io.open("error_log.txt", "a")
    if errorFile then
        errorFile:write(os.date("%Y-%m-%d %H:%M:%S\n"))
        errorFile:write(errorMsg .. "\n")
        errorFile:close()
    end
    
    return true
end

local gameState = {
    current = Constants.GAME_STATES.MENU,
    menu = nil,
    board = nil,
    player = nil,
    opponent = nil,
    tutorial = {
        active = true,
        messages = {
            "Use LEFT/RIGHT to move",
            "Use UP to rotate",
            "Use DOWN to soft drop",
            "Use SPACE to hard drop",
            "Clear lines to deal damage!",
            "Press ENTER to start"
        },
        currentMessage = 1,
        timer = 0
    }
}

-- Função auxiliar para verificar se um módulo foi carregado corretamente
local function checkModule(name, module)
    if not module then
        log("ERRO: Falha ao carregar módulo " .. name)
        return false
    end
    log("Módulo " .. name .. " carregado com sucesso")
    return true
end

local game

function love.load()
    log("\n--- INICIANDO NOVO JOGO ---")
    
    -- Verifica se todos os módulos foram carregados corretamente
    if not (checkModule("Constants", Constants) and
            checkModule("Menu", Menu) and
            checkModule("Board", Board) and
            checkModule("Fighter", Fighter) and
            checkModule("Game", Game)) then
        log("ERRO FATAL: Falha ao carregar módulos essenciais")
        return
    end
    
    -- Configura a janela
    local success, err = pcall(function()
        love.window.setMode(Constants.SCREEN.WIDTH, Constants.SCREEN.HEIGHT)
        love.window.setTitle("Death Match")
    end)
    
    if not success then
        log("Erro ao configurar janela: " .. tostring(err))
    end
    
    -- Inicializa o menu com tratamento de erro
    success, err = pcall(function()
        gameState.menu = Menu:new()
    end)
    
    if not success then
        log("ERRO ao criar menu: " .. tostring(err))
        return
    end
    log("Menu inicializado com sucesso")
    
    -- Define a fonte padrão
    success, err = pcall(function()
        love.graphics.setNewFont(Constants.UI.GAME_FONT_SIZE)
    end)
    
    if not success then
        log("ERRO ao configurar fonte: " .. tostring(err))
    else
        log("Fonte configurada com sucesso")
    end
    
    -- Initialize random seed
    math.randomseed(os.time())
    
    -- Create game instance
    game = Game:new()
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end

function love.keypressed(key)
    game:keypressed(key)
end

function love.keyreleased(key)
    game:keyreleased(key)
end
