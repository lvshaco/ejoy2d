local scale9 = {}

local function _reset(self, spr, w, h)
    local scale9x = self.__scale9x
    local scale9y = self.__scale9y
    local cw = w - scale9x - self.__scale9x2
    local ch = h - scale9y - self.__scale9y2
    local scalex = cw/self.__scale9w
    local scaley = ch/self.__scale9h

    c = spr:fetch_by_index(1)
    c:sr(scalex, 1)
    c:ps(scale9x, 0)
    c = spr:fetch_by_index(2)
    c:ps(scale9x+cw, 0)

    c = spr:fetch_by_index(3)
    c:sr(1, scaley)
    c:ps(0, scale9y)
    c = spr:fetch_by_index(4)
    c:sr(scalex, scaley)
    c:ps(scale9x, scale9y)
    c = spr:fetch_by_index(5)
    c:sr(1, scaley)
    c:ps(scale9x+cw, scale9y)

    c = spr:fetch_by_index(6)
    c:ps(0, scale9y+ch)
    c = spr:fetch_by_index(7)
    c:sr(scalex, 1)
    c:ps(scale9x, scale9y+ch)
    c = spr:fetch_by_index(8)
    c:ps(scale9x+cw, scale9y+ch)
end


function scale9.new(spr)
    local self = {}
    local _,x2,y2 
    _,_,x2,y2 = spr:fetch_by_index(0):aabb()
    self.__scale9x = x2
    self.__scale9y = y2
    _,_,x2,y2 = spr:fetch_by_index(4):aabb()
    self.__scale9w = x2
    self.__scale9h = y2
    _,_,x2,y2 = spr:fetch_by_index(8):aabb()
    self.__scale9x2 = x2
    self.__scale9y2 = y2
    self.__scale9 = true
    
    self.reset = _reset
    return self
end

return scale9
