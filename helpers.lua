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
        for o = 1, #sorted do
            local s = sorted[o]
            local y = 7 * o;
            rectfill(0, y, 1, y + 4, s.colors[1])
            rectfill(2, y, 3, y + 4, s.colors[2])
            print('id' .. s.id .. ' z' .. helpers.flrd(s.z, 0) .. ' x' .. helpers.flrd(s.x, 0) .. ' y' .. helpers.flrd(s.y, 0) .. ' p' .. helpers.flrd(s.p, 0) .. ' r' .. helpers.flrd(s.r, 0) .. ' w' .. helpers.flrd(s.w, 0), 6, y, s.colors[1])
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