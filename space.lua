--triangle flight
--by kepikoi
local helpers = require('./helpers');
local tetromino = require('./tetromino');
local conf = require('./conf');
local listencontrols = require('./listencontrols');

function _init()

    poke(0x5f2d, 1) --mouse support for shits and giggles

    lastCpu = stat(1);

    camera = {
        x = 0,
        y = 0,
        z = 20,
        p = 0, --pitch - rotation around x axis
        w = 0, --yaw - rotation around y axis
        r = 0, --roll - rotation around z axis
        f = 40 --focal length of camera
    }

    --Model metatable models store
    models = {}

    function drawmouse()
        spr(1, stat(32), stat(33))
    end

    function drawdebug()
        print('mousex: ' .. stat(32) .. ' mousey: ' .. stat(33) .. ' click:' .. stat(34), 0, 0, 7)
        print('p:' .. camera.p .. ' w:' .. camera.w .. ' r:' .. helpers.flrd(camera.r, 2), 0, 104, 7)
        print('x:' .. helpers.flrd(camera.x, 2) .. ' y:' .. helpers.flrd(camera.y, 2) .. ' z:' .. helpers.flrd(camera.z, 1) .. ' f:' .. camera.f, 0, 110, 7)
        print('models:' .. #models, 0, 116, 7)
        print('cpu:' .. helpers.flrd(100 * stat(1), 0) .. '% ram:' .. helpers.flrd(stat(0), 2), 0, 122, 7)
    end
end

function _update60()

    listencontrols()

    if (not conf.pause) then
        -- add tetrominos until cpu threshold
        if lastCpu < conf.maxCpu and #models < conf.maxModels then
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
    lastCpu = stat(1);
end