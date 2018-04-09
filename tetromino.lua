local Mesh = require('./mesh');
local cube = require('./cube');
local conf = require('./conf');

-- create random tetromino
function tetromino()
    local axi = { "p", "r", "w" }
    local randomFastAxis = axi[flr(rnd(3) + 1)];
    axi[randomFastAxis] = nil;
    local randomSlowAxis = axi[flr(rnd(2) + 1)];

    local tetromino = {
        cubes = {}, -- a tetromino consists of four cubes
        id = flr(rnd(1000)),
        exploded = false, --cubes will acclerate indepedantly
        colors = { rnd(8) + 1, rnd(7) + 9 },
        speedFast = (rnd(4) + 2) / 1000, --rotation & fall speed
        speedSlow = (rnd(4) + 2) / 5000, --rotation & fall speed for second axis
        x = rnd(64) - 32,
        y = rnd(64) - 32,
        z = rnd(64) - 32,
        draw = function(self)
            --draw all cubes inside tetromino
            for cube in all(self.cubes) do
                cube:draw(self)
            end

            if (conf.debug) then
                -- draw tetromino center point
                local t = self:get2d();
                circfill(t.x, t.y, camera.f / t.z, rnd(1) > 0.5 and self.colors[1] or self.colors[2]);
            end
        end,
        update = function(self)
            -- self.x = self.x + self.speed / 10
            -- self.y = self.y + self.speed / 10
            -- self.z = self.z + self.speed / 10
            -- self.p = self.p + self.speed / 100 --(rnd(100) - 50)
            --self.r = self.r + self.speed / 100 --(rnd(100) - 50)
            -- self.w = self.w + self.speed / 100 --(rnd(100) - 50)

            self[randomFastAxis] = self[randomFastAxis] + self.speedFast
            self[randomSlowAxis] = self[randomSlowAxis] + self.speedFast


            if (btn(0)) then self.p = self.p + 0.008 end
            if (btn(1)) then self.w = self.w - 0.008 end
            if (btn(2)) then self.r = self.r + 0.008 end
            if (btn(3)) then self.r = self.r - 0.008 end

            if rnd(100) < 1 and not self.exploded then
                self.exploded = true
            end

            for cube in all(self.cubes) do
                cube:update(self)
            end
        end
    }
    setmetatable(tetromino, Mesh)

    -- tetromino build schemas. four cubes, {x,y} per cube
    local shapes = {
        { { -2, -1 }, { -1, -1 }, { 0, -1 }, { 0, 0 } }, --L
        { { -1, 0 }, { -1, -1 }, { 0, -1 }, { 1, -1 } }, --J
        { { -1, -1 }, { 0, -1 }, { 1, -1 }, { 0, 0 } }, --T
        { { -1, -1 }, { 0, -1 }, { 0, 0 }, { -1, 0 } }, --O
        { { -2, 0 }, { -1, 0 }, { 0, 0 }, { 1, 0 } }, --I
        { { -1, -1 }, { 0, -1 }, { 0, 0 }, { -1, 0 } }, --Z
        { { -1, 0 }, { 0, 0 }, { 0, -1 }, { 1, -1 } } --S
    }

    --decide on random shape
    local shape = shapes[flr(rnd(#shapes)) + 1]

    --add shape cubes to cubes table
    for i = 1, #shape do
        local x = shape[i][1] * conf.tetrominoside
        local y = shape[i][2] * conf.tetrominoside
        local cube = cube(x, y, 0, conf.tetrominoside)
        add(tetromino.cubes, cube)
    end

    return tetromino
end

return tetromino;