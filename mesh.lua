--3D Mesh metatable
Mesh = {
    x = 0, --x pos
    y = 0, --y pos
    z = 0, --z pos
    p = 0, --pitch
    w = 0, -- yaw
    r = 0, --roll
    id = rnd(1000),
    colors = { 7, 7 },
    v = {}, --vertices
    f = {}, --faces
    draw = function(self, parent) --todo: collect all mesh faces and draw in sorted order to correctly dislay depth
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
    end,
    --convert 3d space to 2d projection
    get2d = function(self, parent)

        if (not parent) then
            --parent is required
            parent = self
        end

        local _x = self.x - parent.x
        local _y = self.y - parent.y
        local _z = self.z - parent.z

        local p = parent.p
        local r = parent.r
        local w = parent.w

        local _px = _x * cos(p) - _y * sin(p)
        local _py = _x * sin(p) + _y * cos(p)

        local _wx = _py * cos(w) - _z * sin(w)
        local _wy = _py * sin(w) + _z * cos(w)

        local _rx = _px * cos(r) - _wx * sin(r)
        local _ry = _px * sin(r) + _wx * cos(r)

        local X = _rx + camera.x + parent.x
        local Y = _ry + camera.y + parent.y
        local Z = _wy + camera.z + parent.z

        return {
            --convert 2d
            x = 64 + X / Z * camera.f,
            y = 64 + Y / Z * camera.f,
            z = Z, --depth information
            visible = Z > 1; --magic number of visibility
        }
    end
}
Mesh.__index = Mesh

return Mesh