print("Testando carregamento de módulos...")

local function testRequire(name, path)
    print("Tentando carregar " .. name .. " de " .. path)
    local success, module = pcall(require, path)
    if success then
        print("✓ " .. name .. " carregado com sucesso")
        return true
    else
        print("✗ ERRO ao carregar " .. name .. ": " .. tostring(module))
        return false
    end
end

-- Testa cada módulo
testRequire("Constants", "constants")
testRequire("Menu", "states.menu")
testRequire("Board", "board")
testRequire("Fighter", "fighter")

print("Teste concluído") 