return {
    LANGUAGES = {
        EN = "en",
        PT = "pt"
    },
    
    TEXT = {
        en = {
            TITLE = "DEATH MATCH",
            MENU = {
                START = "Start Game",
                LEVEL = "Select difficulty",
                TUTORIAL = "Tutorial",
                LANGUAGE = "Change Language",
                VOLUME = "Volume Control",
                QUIT = "Quit"
            },
            VOLUME_CONTROL = {
                TITLE = "Volume Control",
                CURRENT = "Current Volume: %d%%",
                INSTRUCTIONS = "Use LEFT/RIGHT to select, ENTER to adjust, ESC to return"
            },
            LEVEL_SELECT = {
                TITLE = "Select Difficulty Level",
                BACK = "Press ENTER to confirm or ESC to go back",
                SELECTED = "(Selected)"
            },
            GAME = {
                LEVEL = "Level",
                SCORE = "Score",
                LINES = "Lines",
                NEXT = "Next",
                HOLD = "Hold",
                PAUSED = "PAUSED",
                GAME_OVER = "GAME OVER",
                VICTORY = "VICTORY!",
                DIFFICULTY = "Difficulty",
                HEALTH = "Health",
                RETURN_TO_MENU = "Press any key to return to menu"
            },
            TUTORIAL = {
                TITLE = "How to Play",
                CONTROLS = {
                    "Left/Right Arrow: Move piece",
                    "Up Arrow: Rotate piece",
                    "Down Arrow: Soft drop",
                    "Space: Hard drop",
                    "C: Hold piece",
                    "ESC: Pause game"
                },
                BACK = "Press any key to return to menu"
            }
        },
        pt = {
            TITLE = "DEATH MATCH",
            MENU = {
                START = "Iniciar Jogo",
                LEVEL = "Selecionar dificuldade",
                TUTORIAL = "Tutorial",
                LANGUAGE = "Mudar Idioma",
                VOLUME = "Controle de Volume",
                QUIT = "Sair"
            },
            VOLUME_CONTROL = {
                TITLE = "Controle de Volume",
                CURRENT = "Volume Atual: %d%%",
                INSTRUCTIONS = "Use ESQUERDA/DIREITA para selecionar, ENTER para ajustar, ESC para voltar"
            },
            LEVEL_SELECT = {
                TITLE = "Selecionar Dificuldade",
                BACK = "Pressione ENTER para confirmar ou ESC para voltar",
                SELECTED = "(Selecionado)"
            },
            GAME = {
                LEVEL = "Nível",
                SCORE = "Pontos",
                LINES = "Linhas",
                NEXT = "Próxima",
                HOLD = "Reserva",
                PAUSED = "PAUSADO",
                GAME_OVER = "FIM DE JOGO",
                VICTORY = "VITÓRIA!",
                DIFFICULTY = "Dificuldade",
                HEALTH = "Vida",
                RETURN_TO_MENU = "Pressione qualquer tecla para voltar ao menu"
            },
            TUTORIAL = {
                TITLE = "Como Jogar",
                CONTROLS = {
                    "Setas Esq/Dir: Mover peça",
                    "Seta Cima: Girar peça",
                    "Seta Baixo: Queda suave",
                    "Espaço: Queda rápida",
                    "C: Reservar peça",
                    "ESC: Pausar jogo"
                },
                BACK = "Pressione qualquer tecla para voltar"
            }
        }
    },

    -- Dimensões do grid do Tetris
    GRID_WIDTH = 10,
    GRID_HEIGHT = 20,
    CELL_SIZE = 28,

    -- Estados do jogo
    GAME_STATES = {
        MENU = "menu",
        LANGUAGE = "language",
        TUTORIAL = "tutorial",
        PLAYING = "playing",
        PAUSED = "paused",
        GAME_OVER = "game_over",
        VICTORY = "victory",
        LEVEL_SELECT = "level_select",
        SETTINGS = "settings"
    },

    -- Cores das peças (R, G, B)
    COLORS = {
        I = {0, 1, 1},    -- Ciano
        O = {1, 1, 0},    -- Amarelo
        T = {1, 0, 1},    -- Magenta
        S = {0, 1, 0},    -- Verde
        Z = {1, 0, 0},    -- Vermelho
        J = {0, 0, 1},    -- Azul
        L = {1, 0.5, 0}   -- Laranja
    },

    -- Configurações de combate
    COMBAT = {
        -- Dano base por linha
        SINGLE_LINE = 2,
        DOUBLE_LINE = 5,
        TRIPLE_LINE = 8,
        TETRIS = 15,
        MAX_HEALTH = 100,
        COMBO_MULTIPLIER = 1.1,
        MAX_COMBO = 3,
        DAMAGE_PER_LINE = 3,
        SHIELD_PER_TSPIN = 10,
        SHIELD_PER_SPECIAL = 15,
        MAX_SHIELD = 50,
        SHIELD_DECAY = 2,
        SPECIAL_THRESHOLD = 50,
        AI_ATTACK_INTERVAL = 3.0,
        AI_DIFFICULTY = 0.7
    },

    -- Velocidades do jogo (em segundos)
    SPEEDS = {
        INITIAL_DROP = 1.0,     -- Velocidade inicial de queda
        SOFT_DROP = 0.05,       -- Queda suave (seta para baixo)
        LOCK_DELAY = 0.5,       -- Delay para travar a peça
        CLEAR_DELAY = 0.2,      -- Delay ao limpar linhas
        ATTACK_ANIMATION = 0.3   -- Duração da animação de ataque
    },

    -- Configurações de UI
    UI = {
        MENU_FONT_SIZE = 32,
        GAME_FONT_SIZE = 24,
        SMALL_FONT_SIZE = 16,
        HEALTH_BAR_WIDTH = 200,
        HEALTH_BAR_HEIGHT = 20,
        POWER_BAR_WIDTH = 200,
        POWER_BAR_HEIGHT = 10,
        SHIELD_BAR_WIDTH = 200,
        SHIELD_BAR_HEIGHT = 5,
        MENU_ITEM_SPACING = 50,
        MENU_START_Y = 200
    },

    -- Layout da tela
    SCREEN = {
        WIDTH = 1280,
        HEIGHT = 720,
        
        LEFT_PANEL_WIDTH = 300,
        GAME_WIDTH = 400,
        RIGHT_PANEL_WIDTH = 300,
        BOARD_OFFSET_X = 490,
        BOARD_OFFSET_Y = 60,
        
        LEFT_PANEL_X = 50,
        LEFT_PANEL_Y = 60,
        
        RIGHT_PANEL_X = 930,      -- BOARD_OFFSET_X + GAME_WIDTH + padding
        RIGHT_PANEL_Y = 60,
        
        HOLD_PIECE_X = 380,       -- Adjust this value to move horizontally
        HOLD_PIECE_Y = 220,       -- Adjust this value to move vertically
        
        NEXT_PIECE_X = 800,       -- Adjust this value to move horizontally
        NEXT_PIECE_Y = 220,       -- Adjust this value to move vertically
        
        HEALTH_BAR_WIDTH = 250,
        HEALTH_BAR_HEIGHT = 25,
        HEALTH_BAR_SPACING = 50,  -- Vertical space between bars
        
        FIGHTER_WIDTH = 80,
        FIGHTER_HEIGHT = 80,
        FIGHTER_SPACING = 40,     -- Space between fighter and health bar
        
        PIECE_PREVIEW_SIZE = 120,
        
        PADDING = 20,
        INFO_LINE_HEIGHT = 30,
        
        SECTION_HEIGHT = 160,     -- Height for each major section in side panels
        
        INFO_X = 930,            -- Same as RIGHT_PANEL_X
        INFO_Y = 120,            -- Positioned below the panel header
        
        SECTION_SPACING = 20
    },

    TUTORIAL_MESSAGE_DURATION = 3.0,  -- Duration of each tutorial message in seconds

    BASE_DROP_INTERVAL = 2.0,    -- Slower initial drop speed (was 1.2)
    LEVEL_SPEED_INCREASE = 0.05,  -- More gradual speed increase (was 0.1)
    
    LEVELS = {
        {
            name = "Beginner",
            displayName = {
                en = "Beginner",
                pt = "Iniciante"
            },
            speed = 2.0,
            ai_difficulty = 0.3,
            ai_attack_interval = 4.0
        },
        {
            name = "Easy",
            displayName = {
                en = "Easy",
                pt = "Fácil"
            },
            speed = 1.8,
            ai_difficulty = 0.4,
            ai_attack_interval = 3.5
        },
        {
            name = "Normal",
            displayName = {
                en = "Normal",
                pt = "Normal"
            },
            speed = 1.5,
            ai_difficulty = 0.6,
            ai_attack_interval = 3.0
        },
        {
            name = "Hard",
            displayName = {
                en = "Hard",
                pt = "Difícil"
            },
            speed = 1.2,
            ai_difficulty = 0.7,
            ai_attack_interval = 2.5
        },
        {
            name = "Expert",
            displayName = {
                en = "Expert",
                pt = "Especialista"
            },
            speed = 1.0,
            ai_difficulty = 0.8,
            ai_attack_interval = 2.0
        }
    }
} 