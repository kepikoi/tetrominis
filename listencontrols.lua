local conf = require('./conf')

local mousestats = {
    m1 = -1,
    m2 = -1,
    x = 0,
    y = 0
}

function listencontrols()

    if (btn(4, 0)) then camera.z = camera.z + 0.1 end
    if (btn(5, 0)) then camera.z = camera.z - 0.1 end

    if (btnp(4, 1)) then conf:togglePause() end
    if (btnp(5, 1)) then conf:toggleDebug() end

    if stat(34) == 1 then

        if (mousestats.m1 == -1) then
            mousestats.m1 = stat(32)
            mousestats.m2 = stat(33)
            mousestats.x = camera.x
            mousestats.y = camera.y
        end

        --  rotate camera
        camera.x = mousestats.x - (mousestats.m1 - stat(32))
        camera.y = mousestats.y - (mousestats.m2 - stat(33))
    else
        mousestats.m1 = -1
    end
end

return listencontrols;