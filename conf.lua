function love.conf(t)
    -- Configurações básicas
    t.window.title = "Death Match"
    t.window.width = 1280
    t.window.height = 720
    t.window.vsync = true
    t.window.resizable = false
    
    -- Para debugar
    t.console = true

    -- Módulos necessários
    t.modules.audio = true
    t.modules.data = true
    t.modules.event = true
    t.modules.font = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.sound = true
    t.modules.system = true
    t.modules.timer = true
    t.modules.window = true
end 