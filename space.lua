--triangle flight
--by kepikoi
local helpers = require('./helpers');
local tetromino = require('./tetromino');
local conf = require('./conf');

function _init()

    poke(0x5f2d, 1) --mouse support for shits and giggles

    camera = {
        x = 0,
        y = 0,
        z = 20,
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


    function drawmouse()
        spr(1, stat(32), stat(33))
    end

    function drawdebug()
        --print('mousex: ' .. stat(32) .. ' mousey: ' .. stat(33) .. ' click:' .. stat(34), 0, 0, 7)
        --print('lastx:'..laststats.x,0,7,7)
        print('p:' .. camera.p .. ' w:' .. camera.w .. ' r:' .. helpers.flrd(camera.r, 2), 0, 104, 7)
        print('x:' .. helpers.flrd(camera.x, 2) .. ' y:' .. helpers.flrd(camera.y, 2) .. ' z:' .. helpers.flrd(camera.z, 1) .. ' f:' .. camera.f, 0, 110, 7)
        print('models:' .. #models, 0, 116, 7)
        print('cpu:' .. helpers.flrd(100 * laststats.cpu, 0) .. '% ram:' .. helpers.flrd(stat(0), 2), 0, 122, 7)
    end

    function listencontrols()
        if (btn(0)) then camera.p = camera.p + 0.005 end
        if (btn(1)) then camera.p = camera.p - 0.005 end
        if (btn(2)) then camera.w = camera.w + 0.005 end
        if (btn(3)) then camera.w = camera.w - 0.005 end
        if (btn(4, 0)) then camera.z = camera.z + 0.1 end
        if (btn(5, 0)) then camera.z = camera.z - 0.1 end

        if (btnp(4, 1)) then conf.pause = not conf.pause end
        if (btnp(5, 1)) then conf.debug = not conf.debug end

        if stat(34) == 1 then
            if (laststats.m1 == -1) then
                laststats.m1 = stat(32)
                laststats.m2 = stat(33)
                laststats.x = camera.x
                laststats.y = camera.y
            end

            --  rotate camera
            camera.x = laststats.x - (laststats.m1 - stat(32))
            camera.y = laststats.y - (laststats.m2 - stat(33))
        else
            laststats.m1 = -1
        end
    end
end

function _update60()
    listencontrols()

    if (not conf.pause) then
        -- add tetrominos until cpu threshold
        if laststats.cpu < conf.maxCpu and #models < conf.maxmodels then
            add(models, tetromino())
        end

        for model in all(models) do
            model:update()
        end

        --autorotate camera
        -- camera.p = camera.p + 0.0001
    end
end

function _draw()
    cls()

    -- sort tetrominos by z-index before drawing
    local _m = helpers.sortz(models)
    for model in all(_m) do
        model:draw()
    end

    if conf.debug then
        drawdebug()
    end

    drawmouse()

    laststats.cpu = stat(1)
end