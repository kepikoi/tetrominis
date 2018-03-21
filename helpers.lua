local helpers = {};
local conf = require('./conf');

--sort model by its z
helpers.sortz = function(t)
    local sorted = t
    local temp = {}

    for j = 1, #sorted - 1 do
        if (t[j].z) < (sorted[j + 1].z) then
            temp = sorted[j + 1]
            sorted[j + 1] = sorted[j]
            sorted[j] = temp
        end
    end

    if (conf.debug) then
        for s = 1, #sorted do
            print('id:' .. sorted[s].id .. ' z:' .. helpers.flrd(sorted[s].z, 1) .. ' x:' .. helpers.flrd(sorted[s].x, 1) .. ' y:' .. helpers.flrd(sorted[s].y, 1), 0, 7 * s, sorted[s].colors[1])
        end
    end

    return sorted
end

--floor to set amount of deimals
--@param {Float value - number to apply floor to
--@param {Integer} d - amount of decimals to round the value to
helpers.flrd = function(value, d)
    return flr(value * (10 ^ d)) / (10 ^ d)
end

--
helpers.pointinsidearea = function(px, py, points)
    local pointarea = 0;

    for i = 1, #points do
        if (i < #points) then
            local point = { points[i], points[i + 1], { x = px, y = py } }
            pointarea = pointarea + helpers.polygonarea(point)
        else
            local point = { points[i], points[1], { x = px, y = py } }
            pointarea = pointarea + helpers.polygonarea(point)
        end
    end

    return pointarea <= helpers.polygonarea(points)
end

--calculate area of polygon
--@param {Table} points - e.g. {{x,y,z,{x,y,z}}
helpers.polygonarea = function(points)
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

return helpers;