return function(cmd, narg, options, usage)
    local opts = {}
    local args = {}
    if options then
        local i = 1
        while i<=#cmd do
            if string.byte(cmd[i],1) == 45 then
                local found = false
                for _, v in ipairs(options) do
                    if cmd[i] == v[1] then
                        opts[v.dest] = cmd[i+1]
                        found = true
                        break
                    end
                end
                if not found then
                    print("unknown option:"..cmd[i])
                    print(usage)
                    os.exit(1)
                end
                i = i+2
            else
                table.insert(args,cmd[i])
                i = i+1
            end
        end
    end
    --default
    for _, v in ipairs(options) do
        if not opts[v.dest] then
            if v.default then
                opts[v.dest] = v.default
            end
        end
    end
    if #args < narg then
        print(usage)
        os.exit(1)
    end
    return args, opts
end
