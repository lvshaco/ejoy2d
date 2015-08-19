-- easing

-- Adapted from https://github.com/EmmanuelOga/easing. See LICENSE.txt for credits.
-- For all easing functions:
-- t = time == how much time has to pass for the tweening to complete
-- b = begin == starting property value
-- c = change == ending - beginning
-- d = duration == running time. How much time has passed *right now*

local sin, cos, pi, abs, asin = math.sin, math.cos, math.pi, math.abs, math.asin

-- linear
local function linear(t, b, c, d) return c * t / d + b end

-- quad
local function inquad(t, b, c, d) return c * (t / d)^2 + b end
local function outquad(t, b, c, d)
  t = t / d
  return -c * t * (t - 2) + b
end
local function inoutquad(t, b, c, d)
  t = t / d * 2
  if t < 1 then return c / 2 * (t^2) + b end
  return -c / 2 * ((t - 1) * (t - 3) - 1) + b
end
local function outinquad(t, b, c, d)
  if t < d / 2 then return outquad(t * 2, b, c / 2, d) end
  return inquad((t * 2) - d, b + c / 2, c / 2, d)
end

-- cubic
local function incubic (t, b, c, d) return c * ((t / d)^3) + b end
local function outcubic(t, b, c, d) return c * (((t / d - 1)^3) + 1) + b end
local function inoutcubic(t, b, c, d)
  t = t / d * 2
  if t < 1 then return c / 2 * t * t * t + b end
  t = t - 2
  return c / 2 * (t * t * t + 2) + b
end
local function outincubic(t, b, c, d)
  if t < d / 2 then return outcubic(t * 2, b, c / 2, d) end
  return incubic((t * 2) - d, b + c / 2, c / 2, d)
end

-- quart
local function inquart(t, b, c, d) return c * ((t / d)^4) + b end
local function outquart(t, b, c, d) return -c * (((t / d - 1)^4) - 1) + b end
local function inoutquart(t, b, c, d)
  t = t / d * 2
  if t < 1 then return c / 2 * (t^4) + b end
  return -c / 2 * (((t - 2)^4) - 2) + b
end
local function outinquart(t, b, c, d)
  if t < d / 2 then return outquart(t * 2, b, c / 2, d) end
  return inquart((t * 2) - d, b + c / 2, c / 2, d)
end

-- quint
local function inquint(t, b, c, d) return c * ((t / d)^5) + b end
local function outquint(t, b, c, d) return c * (((t / d - 1)^5) + 1) + b end
local function inoutquint(t, b, c, d)
  t = t / d * 2
  if t < 1 then return c / 2 * (t^5) + b end
  return c / 2 * (((t - 2)^5) + 2) + b
end
local function outinquint(t, b, c, d)
  if t < d / 2 then return outquint(t * 2, b, c / 2, d) end
  return inquint((t * 2) - d, b + c / 2, c / 2, d)
end

-- sine
local function insine(t, b, c, d) return -c * cos(t / d * (pi / 2)) + c + b end
local function outsine(t, b, c, d) return c * sin(t / d * (pi / 2)) + b end
local function inoutsine(t, b, c, d) return -c / 2 * (cos(pi * t / d) - 1) + b end
local function outinsine(t, b, c, d)
  if t < d / 2 then return outsine(t * 2, b, c / 2, d) end
  return insine((t * 2) -d, b + c / 2, c / 2, d)
end

-- expo
local function inexpo(t, b, c, d)
  if t == 0 then return b end
  return c * (2^(10 * (t / d - 1))) + b - c * 0.001
end
local function outexpo(t, b, c, d)
  if t == d then return b + c end
  return c * 1.001 * (-(2^(-10 * t / d)) + 1) + b
end
local function inoutexpo(t, b, c, d)
  if t == 0 then return b end
  if t == d then return b + c end
  t = t / d * 2
  if t < 1 then return c / 2 * (2^(10 * (t - 1))) + b - c * 0.0005 end
  return c / 2 * 1.0005 * (-(2^(-10 * (t - 1))) + 2) + b
end
local function outinexpo(t, b, c, d)
  if t < d / 2 then return outexpo(t * 2, b, c / 2, d) end
  return inexpo((t * 2) - d, b + c / 2, c / 2, d)
end

-- circ
local function incirc(t, b, c, d) return(-c * ((1 - ((t / d)^2))^0.5 - 1) + b) end
local function outcirc(t, b, c, d)  return(c * (1 - ((t / d - 1)^2))^0.5 + b) end
local function inoutcirc(t, b, c, d)
  t = t / d * 2
  if t < 1 then return -c / 2 * ((1 - t * t)^0.5 - 1) + b end
  t = t - 2
  return c / 2 * ((1 - t * t)^0.5 + 1) + b
end
local function outincirc(t, b, c, d)
  if t < d / 2 then return outcirc(t * 2, b, c / 2, d) end
  return incirc((t * 2) - d, b + c / 2, c / 2, d)
end

-- elastic
local function calculatepas(p,a,c,d)
  p, a = p or d * 0.3, a or 0
  if a < abs(c) then return p, c, p / 4 end -- p, a, s
  return p, a, p / (2 * pi) * asin(c/a) -- p,a,s
end
local function inelastic(t, b, c, d, a, p)
  local s
  if t == 0 then return b end
  t = t / d
  if t == 1  then return b + c end
  p,a,s = calculatepas(p,a,c,d)
  t = t - 1
  return -(a * (2^(10 * t)) * sin((t * d - s) * (2 * pi) / p)) + b
end
local function outelastic(t, b, c, d, a, p)
  local s
  if t == 0 then return b end
  t = t / d
  if t == 1 then return b + c end
  p,a,s = calculatepas(p,a,c,d)
  return a * (2^(-10 * t)) * sin((t * d - s) * (2 * pi) / p) + c + b
end
local function inoutelastic(t, b, c, d, a, p)
  local s
  if t == 0 then return b end
  t = t / d * 2
  if t == 2 then return b + c end
  p,a,s = calculatepas(p,a,c,d)
  t = t - 1
  if t < 0 then return -0.5 * (a * (2^(10 * t)) * sin((t * d - s) * (2 * pi) / p)) + b end
  return a * (2^(-10 * t)) * sin((t * d - s) * (2 * pi) / p ) * 0.5 + c + b
end
local function outinelastic(t, b, c, d, a, p)
  if t < d / 2 then return outelastic(t * 2, b, c / 2, d, a, p) end
  return inelastic((t * 2) - d, b + c / 2, c / 2, d, a, p)
end

-- back
local function inback(t, b, c, d, s)
  s = s or 1.70158
  t = t / d
  return c * t * t * ((s + 1) * t - s) + b
end
local function outback(t, b, c, d, s)
  s = s or 1.70158
  t = t / d - 1
  return c * (t * t * ((s + 1) * t + s) + 1) + b
end
local function inoutback(t, b, c, d, s)
  s = (s or 1.70158) * 1.525
  t = t / d * 2
  if t < 1 then return c / 2 * (t * t * ((s + 1) * t - s)) + b end
  t = t - 2
  return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
end
local function outinback(t, b, c, d, s)
  if t < d / 2 then return outback(t * 2, b, c / 2, d, s) end
  return inback((t * 2) - d, b + c / 2, c / 2, d, s)
end

-- bounce
local function outbounce(t, b, c, d)
  t = t / d
  if t < 1 / 2.75 then return c * (7.5625 * t * t) + b end
  if t < 2 / 2.75 then
    t = t - (1.5 / 2.75)
    return c * (7.5625 * t * t + 0.75) + b
  elseif t < 2.5 / 2.75 then
    t = t - (2.25 / 2.75)
    return c * (7.5625 * t * t + 0.9375) + b
  end
  t = t - (2.625 / 2.75)
  return c * (7.5625 * t * t + 0.984375) + b
end
local function inbounce(t, b, c, d) return c - outbounce(d - t, 0, c, d) + b end
local function inoutbounce(t, b, c, d)
  if t < d / 2 then return inbounce(t * 2, 0, c, d) * 0.5 + b end
  return outbounce(t * 2 - d, 0, c, d) * 0.5 + c * .5 + b
end
local function outinbounce(t, b, c, d)
  if t < d / 2 then return outbounce(t * 2, b, c / 2, d) end
  return inbounce((t * 2) - d, b + c / 2, c / 2, d)
end

tween.easing = {
  linear        = linear,
  inquad        = inquad,       outquad         = outquad, 
  inoutquad     = inoutquad,    outinquad       = outinquad,
  incubic       = incubic,      outcubic        = outcubic,   
  inoutcubic    = inoutcubic,   outincubic      = outincubic,
  inquart       = inquart,      outquart        = outquart,   
  inoutquart    = inoutquart,   outinquart      = outinquart,
  inquint       = inquint,      outquint        = outquint,   
  inoutquint    = inoutquint,   outinquint      = outinquint,
  insine        = insine,       outsine         = outsine,    
  inoutsine     = inoutsine,    outinsine       = outinsine,
  inexpo        = inexpo,       outexpo         = outexpo,    
  inoutexpo     = inoutexpo,    outinexpo       = outinexpo,
  incirc        = incirc,       outcirc         = outcirc,    
  inoutcirc     = inoutcirc,    outincirc       = outincirc,
  inelastic     = inelastic,    outelastic      = outelastic, 
  inoutelastic  = inoutelastic, outinelastic    = outinelastic,
  inback        = inback,       outback         = outback,    
  inoutback     = inoutback,    outinback       = outinback,
  inbounce      = inbounce,     outbounce       = outbounce,  
  inoutbounce   = inoutbounce,  outinbounce     = outinbounce
}

local mt = {}

function mt:update(dt, sprite)
    if self.__clock < self.__duration then
        self.__clock = self.__clock + dt 
        if self.__clock > duration then
            self.__clock = duration
        end
        if self.__easing then
            if type(self.__from) == "table" then
                local tov
                for k, v in pairs(self.__from) do
                    tov = self.__to[k]
                    if tov and tov ~= v then
                        self.__easing(self.__clock, 
                            v, 
                            tov-v, 
                            self.__duration)
                    end
                end
            else
                self.__easing(self.__clock, 
                    self.__from, 
                    self.__to-self.__from, 
                    self.__duration)
            end
        end
        return true -- updated
    end
end

function mt:reverse()
    local from, to
    if type(self.__from) == "table" then
        from, to = {}, {}
        local tov
        for k, v in pairs(self.__from) do
            tov = self.__to[k]
            if tov then
                from[k] = tov
                to[k] = v
            else
                from[k] = v
            end
        end
    else
        from = self.__to
        to = self.__from
    end
    return tween.new(from, to, 
        self.__duration, self.__easing)
end

function tween.new(from, to, duration, easing)
    local value
    local ty = type(from)
    if ty == "table" then
        value = {}
        for k, v in pairs(from) do
            value[k] = v
        end
    else
        assert(ty == "number")
        value = from
    end
    return setmetatable({
        __value = value,
        __from = from,
        __to = to,
        __duration = duration,
        __clock = 0,
        __easing = easing,
        __effect = effect,
    }, {__index = mt})
end

return tween
