--triangle flight
--by kepikoi
function _init()
    conf = {
        debug = false, --show stats, can be toggled by second players "a" button
        tetrominoside = 4, -- size of tetromino cube
        maxCpu = 0.85, --allow add models until max cpu threshold
        maxmodels = 6, --maximal amount of models until cpu threshold,
        pause = false -- pause action, can be toggled by second players "b" button
    }

    poke(0x5f2d, 1) --mouse support for shits and giggles

    camera = {
        x = 1.5,
        y = -3.5,
        z = 32,
        p = 0, --pitch - rotation around x axis
        w = 0, --yaw - rotation around y axis
        r = 0, --roll - rotation around z axis
        f = 40 --focal length of camera
    }

    --temp store for last click
    laststats = {
        cpu = 0
    }

    --Model metatable models store
    models = {}

    --3D Model metatable
    Model = {
        x = 0, --x pos
        y = 0, --y pos
        z = 0, --z pos
        p = 0, --pitch
        w = 0, -- yaw
        r = 0, --roll
        id = rnd(1000),
        colors = { 7, 7 },
        center = { x = 0, y = 0, z = 0 } --model rotation resolves around models center
    }
    Model.__index = Model

    --3D Mesh metatable
    Mesh = {
        v = {}, --vertices
        f = {}, --faces
        --convert 3d space to 2d projection
        get2d = function(self, parent)
            if parent == nil then
                --assign an dummy parent if not provided
                _parent = {}
                setmetatable(Model, _parent)
            end

            local _x = self.x --  - parent.center.x
            local _y = self.y -- - parent.center.y
            local _z = self.z -- - parent.center.z

            local p = parent.p -- - camera.p
            local r = parent.r -- - camera.r
            local w = parent.w -- - camera.w

            local _px = _x * cos(p) - _y * sin(p)
            local _py = _x * sin(p) + _y * cos(p)
            local _pz = _z

            local _wx = _py * cos(w) - _pz * sin(w);
            local _wy = _py * sin(w) + _pz * cos(w);
            local _wz = _px

            local _rx = _wz * cos(r) - _wx * sin(r);
            local _ry = _wz * sin(r) + _wx * cos(r);
            local _rz = _wy

            local X = _rx;
            local Y = _ry;
            local Z = _rz

            return {
                --convert 2d
                x = 64 + (camera.x + X + parent.center.x) / (camera.z + Z) * camera.f,
                y = 64 + (camera.y + Y + parent.center.y) / (camera.z + Z) * camera.f,
                color = Z < camera.z + parent.center.z and 8 or 3,
                --use z to decide z-index
                visible = camera.z + Z + parent.center.z > 5; --magic number of visibility
            }
        end,
        draw = function(self, parent) --todo: collect all faces in table and draw sorted in order to correctly dislay order
            local _parent = parent

            for _f in all(self.f) do --get all faces
                local points = {}
                for i in all(_f) do --get face vertex index
                    self.x = self.v[i][1] + _parent.x
                    self.y = self.v[i][2] + _parent.y
                    self.z = self.v[i][3] + _parent.z

                    --acclerate cubes individually if parent exploded
                    if _parent.exploded then
                        self.x = self.x + self.speed.x
                        self.y = self.y + self.speed.y
                        self.z = self.z + self.speed.z
                    end

                    add(points, self:get2d(_parent)) --get cube point in 2d context
                end
                for i = 1, #points do
                    local _xA = points[i].x
                    local _yA = points[i].y
                    local _visibleA = points[i].visible
                    local _xO, _yO, _visibleO, col

                    --connect 2d points
                    if (_visibleA) then
                        if (i < #points) then
                            _xO = points[i + 1].x
                            _yO = points[i + 1].y
                            _visibleO = points[i + 1].visible
                            col = _parent.colors[1]
                        else
                            _xO = points[1].x
                            _yO = points[1].y
                            _visibleO = points[1].visible
                            col = _parent.colors[2]
                        end

                        if (_visibleO) then
                            line(_xA, _yA, _xO, _yO, col)
                        end
                    end
                end
            end
        end
    }
    Mesh.__index = Mesh

    -- create random tetromino
    function maketetromino()
        local tetromino = {
            cubes = {}, --4 cubes a tetromino consists of
            id = flr(rnd(1000)),
            x = rnd(30) - 15, --init x coord
            y = rnd(30) - 15, --init y coord
            z = rnd(10) - 5, --init z coord
            p = rnd(1), --pitch
            w = rnd(1), --yaw
            r = rnd(1), --roll
            center = {
                x = 0,
                y = 0,
                z = 0
            },
            exploded = false, --cubes will acclerate indepedantly
            colors = { rnd(8) + 1, rnd(7) + 9 },
            speed = (rnd(4) + 2) / 20, --rotation & fall speed
            draw = function(self)
                --draw all cubes inside tetromino
                for cube in all(self.cubes) do
                    cube:draw(self)
                end
            end,
            update = function(self)
                --   self.x = self.x + self.speed
                -- self.y = self.y + self.speed
                -- self.z = self.z
                -- self.p = self.p + 0.01
                -- self.r = self.r + self.speed
                -- self.w = self.w + self.speed

                --remove condition tetromino
                -- if self.z ^ 2 > 0.25 then
                -- del(models, self)
                -- end

                if rnd(100) < 1 and not self.exploded then
                    self.exploded = true
                end

                for cube in all(self.cubes) do
                    cube:update(self)
                end
            end
        }
        setmetatable(tetromino, Model)

        -- tetromino build schemas
        local shapes = {
            { { 0, 0, 0, 1 }, { 1, 0, 0, 1 }, { 2, 0, 0, 1 }, { 2, 1, 0, 1 } }, --L
            { { 0, 1, 0, 1 }, { 0, 0, 0, 1 }, { 1, 0, 0, 1 }, { 2, 0, 0, 1 } }, --J
            { { 0, 0, 0, 1 }, { 1, 0, 0, 1 }, { 2, 0, 0, 1 }, { 1, 1, 0, 1 } }, --T
            { { 1, 1, 0, 1 }, { 1, 0, 0, 1 }, { 2, 0, 0, 1 }, { 2, 1, 0, 1 } }, --O
            { { 0, 0, 0, 1 }, { 1, 0, 0, 1 }, { 2, 0, 0, 1 }, { 3, 0, 0, 1 } }, --I
            { { 0, 0, 0, 1 }, { 1, 0, 0, 1 }, { 1, 1, 0, 1 }, { 2, 1, 0, 1 } }, --Z
            { { 0, 1, 0, 1 }, { 1, 1, 0, 1 }, { 1, 0, 0, 1 }, { 2, 0, 0, 1 } } --S
        }

        --decide on random shape
        local s = shapes[flr(rnd(#shapes)) + 1]
        local centercube = flr(rnd(4) + 1); -- rotation revolves around the center cube
        tetromino.center.x = s[centercube][1] + conf.tetrominoside / 2
        tetromino.center.y = s[centercube][2] + conf.tetrominoside / 2
        tetromino.center.z = s[centercube][3] + conf.tetrominoside / 2

        --add shape cubes to cubes table
        for i = 1, #s do
            local x = s[i][1] * conf.tetrominoside + tetromino.x
            local y = s[i][2] * conf.tetrominoside + tetromino.y
            local z = s[i][3] * conf.tetrominoside + tetromino.z
            local cube = makecube(x, y, z, conf.tetrominoside)
            add(tetromino.cubes, cube)
        end

        return tetromino
    end

    -- create 3d cube
    -- @param {Number} x,y,z - cube position
    -- @param {Number} side - side length of the cube
    function makecube(x, y, z, side)
        local model = {
            v = {}, --points
            f = { { 1, 2, 4, 3 }, { 5, 6, 8, 7 }, { 1, 5, 7, 3 }, { 2, 6, 8, 4 } }, -- multiple connected points yield faces
            speed = {
                --each cube has own speed. usually 0 except when exploded
                x = rnd(1) - 0.5,
                y = rnd(1) - 0.5,
                z = rnd(1) - 0.5
            },
            update = function(self, parent)
            end
        }
        setmetatable(model, Model);
        setmetatable(model, Mesh);

        --create vertex map for a cube
        for i = 0, 8 do
            local _x = i % 2 > 0 and x or x + side
            local _y = i % 4 > 1 and y or y + side
            local _z = i % 8 > 3 and z or z + side
            add(model.v, { _x, _y, _z })
        end

        return model
    end

    function drawmouse()
        spr(1, stat(32), stat(33))
    end

    --floor to set amount of deimals
    --@param {Float value - number to apply floor to
    --@param {Integer} d - amount of decimals to round the value to
    function flrd(value, d)
        return flr(value * (10 ^ d)) / (10 ^ d)
    end

    function pointinsidearea(px, py, points)
        local pointarea = 0;

        for i = 1, #points do
            if (i < #points) then
                local point = { points[i], points[i + 1], { x = px, y = py } }
                pointarea = pointarea + polygonarea(point)
            else
                local point = { points[i], points[1], { x = px, y = py } }
                pointarea = pointarea + polygonarea(point)
            end
        end

        return pointarea <= polygonarea(points)
    end

    --calculate area of polygon
    --@param {Table} points - e.g. {{x,y,z,{x,y,z}}
    function polygonarea(points)
        local area = 0

        for i = 1, #points do
            if (i < #points) then
                area = area + (points[i].x * points[i + 1].y - points[i + 1].x * points[1].y)
            else
                area = area + (points[i].x * points[1].y - points[1].x * points[i].y)
            end
        end

        return 0.5 * area
    end

    function drawdebug()
        print('mousex: ' .. stat(32) .. ' mousey: ' .. stat(33) .. ' click:' .. stat(34), 0, 0, 7)
        --print('lastx:'..laststats.x,0,7,7)
        print('p:' .. camera.p .. ' w:' .. camera.w .. ' r:' .. flrd(camera.r, 2), 0, 104, 7)
        print('x:' .. flrd(camera.x, 2) .. ' y:' .. flrd(camera.y, 2) .. ' z:' .. flrd(camera.z, 1) .. ' f:' .. camera.f, 0, 110, 7)
        print('models:' .. #models, 0, 116, 7)
        print('cpu:' .. flrd(100 * laststats.cpu, 0) .. '% ram:' .. flrd(stat(0), 2), 0, 122, 7)
    end

    function listencontrols()
        if (btn(0)) then camera.x = camera.x + 0.5 end
        if (btn(1)) then camera.x = camera.x - 0.5 end
        if (btn(2)) then camera.y = camera.y + 0.5 end
        if (btn(3)) then camera.y = camera.y - 0.5 end
        if (btn(4, 0)) then camera.z = camera.z + 0.1 end
        if (btn(5, 0)) then camera.z = camera.z - 0.1 end

        if (btnp(4, 1)) then conf.pause = not conf.pause end
        if (btnp(5, 1)) then conf.debug = not conf.debug end

        if stat(34) == 1 then
            if (laststats.x == -1) then
                laststats.x = stat(32)
                laststats.y = stat(33)
                laststats.p = camera.p
                laststats.w = camera.w
            end

            --  rotate camera
            camera.p = laststats.p + (laststats.x - stat(32)) * 0.01
            camera.w = laststats.w + (laststats.y - stat(33)) * 0.01
        else
            laststats.x = -1
        end
    end

    --sort model by its z
    function sortz(t)
        local sorted = t
        local temp = {}

        for j = 1, #sorted - 1 do
            if (t[j].z) > (sorted[j + 1].z) then
                temp = sorted[j + 1]
                sorted[j + 1] = sorted[j]
                sorted[j] = temp
            end
        end

        if (conf.debug) then
            for s = 1, #sorted do
                print('id:' .. sorted[s].id .. ' z:' .. flrd(sorted[s].z,1) ..' x:' .. flrd(sorted[s].x,1)..' y:' .. flrd(sorted[s].y,1), 0, 7 * s, sorted[s].colors[1])
            end
        end

        return sorted
    end
end

function _update60()
    listencontrols()

    if (not conf.pause) then
        -- add tetrominos until cpu threshold
        if laststats.cpu < conf.maxCpu and #models < conf.maxmodels then
            add(models, maketetromino())
        end

        for model in all(models) do
            model:update()
        end

        --autorotate camera
        --camera.p = camera.p + 0.0001
    end
end

function _draw()
    cls()

    -- sort tetrominos by z-index before drawing
    local _m = sortz(models)
    for model in all(_m) do
        model:draw()
    end

    if conf.debug then
        drawdebug()
    end

    drawmouse()

    laststats.cpu = stat(1)
end