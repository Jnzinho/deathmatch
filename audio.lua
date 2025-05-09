local Audio = {}

function Audio:new()
    local audio = {
        menuMusic = love.audio.newSource("assets/menumusic.wav", "stream"),
        gameplayMusic = love.audio.newSource("assets/gameplaymusic.ogg", "stream"),
        currentMusic = nil,
        volume = 0.01
    }
    
    audio.menuMusic:setLooping(true)
    audio.gameplayMusic:setLooping(true)
    
    audio.menuMusic:setVolume(audio.volume)
    audio.gameplayMusic:setVolume(audio.volume)
    
    setmetatable(audio, {__index = self})
    return audio
end

function Audio:setVolume(volume)
    self.volume = math.max(0, math.min(1, volume))
    
    self.menuMusic:setVolume(self.volume)
    self.gameplayMusic:setVolume(self.volume)
end

function Audio:increaseVolume()
    self:setVolume(self.volume + 0.1)
end

function Audio:decreaseVolume()
    self:setVolume(self.volume - 0.1)
end

function Audio:getVolume()
    return self.volume
end

function Audio:playMenuMusic()
    if self.currentMusic == self.menuMusic then return end
    
    if self.currentMusic then
        self.currentMusic:stop()
    end
    
    self.menuMusic:play()
    self.currentMusic = self.menuMusic
end

function Audio:playGameMusic()
    if self.currentMusic == self.gameplayMusic then return end
    
    if self.currentMusic then
        self.currentMusic:stop()
    end
    
    self.gameplayMusic:play()
    self.currentMusic = self.gameplayMusic
end

function Audio:stopAll()
    if self.currentMusic then
        self.currentMusic:stop()
        self.currentMusic = nil
    end
end

return Audio 