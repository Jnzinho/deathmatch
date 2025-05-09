local Constants = require('constants')

local Menu = {
    selected = 1,
    options = {
        "Modo Arcade",
        "Jogador vs Jogador",
        "Opções",
        "Sair"
    },
    logo = nil
}

function Menu:new()
    local menu = {}
    setmetatable(menu, {__index = self})
    menu.logo = love.graphics.newImage("assets/logo.png")
    return menu
end

function Menu:update(dt)
    -- Atualização de animações do menu se necessário
end

function Menu:keypressed(key)
    if key == "up" then
        self.selected = self.selected - 1
        if self.selected < 1 then
            self.selected = #self.options
        end
    elseif key == "down" then
        self.selected = self.selected + 1
        if self.selected > #self.options then
            self.selected = 1
        end
    elseif key == "return" then
        return self:selectOption()
    end
end

function Menu:selectOption()
    if self.selected == 1 then
        return "arcade"
    elseif self.selected == 2 then
        return "versus"
    elseif self.selected == 3 then
        return "options"
    elseif self.selected == 4 then
        love.event.quit()
    end
end

function Menu:draw()
    -- Desenha o logo
    love.graphics.setColor(1, 1, 1)
    if self.logo then
        local scale = 0.5  -- Adjust this value to fit your needs
        local logoW, logoH = self.logo:getDimensions()
        local x = (love.graphics.getWidth() - (logoW * scale)) / 2
        love.graphics.draw(self.logo, x, 50, 0, scale, scale)
    end
    
    -- Desenha as opções do menu
    love.graphics.setFont(love.graphics.newFont(Constants.UI.MENU_FONT_SIZE))
    for i, option in ipairs(self.options) do
        if i == self.selected then
            love.graphics.setColor(1, 1, 0) -- Amarelo para seleção
        else
            love.graphics.setColor(1, 1, 1) -- Branco para não selecionado
        end
        love.graphics.printf(option, 0, 300 + (i * 50), love.graphics.getWidth(), "center")
    end
    
    -- Desenha instruções
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.printf("Use as setas para selecionar e ENTER para confirmar", 
        0, love.graphics.getHeight() - 50, love.graphics.getWidth(), "center")
end

return Menu 