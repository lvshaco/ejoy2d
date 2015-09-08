return function(cmd, options)
    local function optionline(opt, key)
        if opt.required then return '-'..key
        else return string.format('[-%s]',key)
        end
    end
    local function optionblock(opt, key)
        return string.format('  %s    %s', '-'..key, opt.desc or opt.dest)
    end
    local function exit(tip)
        if tip then
            print(tip)
        end
        local t1 = {}
        local t2 = {}
        for k, v in pairs(options) do
            if type(k) == 'string' then
                table.insert(t1, optionline(v,k))
                table.insert(t2, optionblock(v,k))
            end
        end
        for _, v in ipairs(options) do
            table.insert(t1, v.dest)
        end
        print('usage: PROG '..table.concat(t1, ' '))
        print('')
        print('optional arguments:')
        print(table.concat(t2, '\n'))
        os.exit(1)
    end

    local opts = {}
    local args = {}
    if options then
        local argindex = 1
        local i = 1
        while i<=#cmd do
            if string.byte(cmd[i],1) == 45 then
                local found = false
                for k, v in pairs(options) do
                    if type(k) == 'string' then
                        if cmd[i] == '-'..k then
                            opts[v.dest] = cmd[i+1]
                            found = true
                            break
                        end
                    end
                end
                if not found then
                    exit("unknown option:"..cmd[i])
                end
                i = i+2
            else
                if argindex > #options then
                    exit('too much arguments')
                end
                opts[options[argindex].dest] = cmd[i]
                argindex = argindex+1
                i = i+1
            end
        end
        --default
        for k, v in pairs(options) do
            if not opts[v.dest] then
                if v.default then
                    opts[v.dest] = v.default
                end
                if v.required or type(k) == 'number' then
                    if not opts[v.dest] then
                        exit(string.format('`-%s` is required', k))
                    end
                end
            end
        end
    else
        table.move(cmd,1,#cmd,1,args)
    end
    return opts
end
