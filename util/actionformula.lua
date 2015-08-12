local actionformula = {}

function actionformula.linear(begin, range, duration, t)
    return begin + t/duration * range
end

function actionformula.easeinexpo(begin, range, duration, t)
    return begin + 2^(10*(t/duration-1)) * range
end

function actionformula.easeoutexpo(begin, range, duration, t)
    return begin + (-(2^(-10*t/duration))+1) * range
end

return actionformula
