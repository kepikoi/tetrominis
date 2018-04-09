return {
    tetrominoside = 4, -- size of tetromino cube
    maxCpu = 0.85, --allow add models until max cpu threshold
    maxModels = 6, --maximal amount of models until cpu threshold,
    pause = false, --show stats, can be toggled by second players "a" button,
    debug  = false, -- stop drawing when paused. Updates are still runnung,
    toggleDebug = function(self)
        self.debug = not self.debug
    end,
    togglePause = function(self)
        self.pause = not self.pause
    end
}