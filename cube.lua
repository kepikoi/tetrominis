local Mesh = require('./mesh');

-- create 3d cube
-- @param {Number} x,y,z - cube position
-- @param {Number} side - side length of the cube
function cube(x, y, z, side)
    local model = {
        v = {}, --points
        f = { { 1, 2, 4, 3 }, { 5, 6, 8, 7 }, { 1, 5, 7, 3 }, { 2, 6, 8, 4 } }, -- multiple connected points define a face
        speed = {
            --each cube has own speed. usually 0 except when exploded
            x = 0,-- rnd(1) - 0.5,
            y = 0, --rnd(1) - 0.5,
            z = 0, --rnd(1) - 0.5
        },
        update = function(self, parent)
            --noop
        end
    }
    setmetatable(model, Mesh);

    --create vertex map for a cube for given coordinates and side length
    for i = 0, 8 do
        local _x = i % 2 > 0 and x or x + side
        local _y = i % 4 > 1 and y or y + side
        local _z = i % 8 > 3 and z or z + side
        add(model.v, { _x, _y, _z })
    end

    return model
end

return cube;