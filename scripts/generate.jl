#====================================================================================================
This script generates latex symbols and names from the Julia RPL list and outputs a lua file
Based on https://gitlab.com/ExpandingMan/cmp-latex/-/blob/master/generate_items.jl
====================================================================================================#

using REPL

function add!(s, pair)
    x, y = pair
    if count(elem -> elem[1] == x, s) == 0
        push!(s, string(x) => string(y))
    end
end

function unicode_list()
    s = []
    out = readlines(open(`curl -L http://milde.users.sourceforge.net/LUCR/Math/data/unimathsymbols.txt`))
    out = filter(x -> !startswith(x, "#"), out) # Remove comments
    out = split.(out, '^') # Split on ^
    out = filter( x -> startswith(x[3], '\\') || startswith(x[4], '\\'), out) # Only get some elements
    for elem in out
        if strip(elem[2]) == ""
            continue
        end
        if startswith(elem[3], "\\")
            add!(s, elem[3] => elem[2])
        end
        if startswith(elem[4], "\\")
            add!(s, elem[4] => elem[2])
        end
        m = match(r"= (\\\w+)", elem[end])
        if !isnothing(m)
            add!(s, m.captures[1] => elem[2])
        end
        m = match(r"# (\\\w+)", elem[end])
        if !isnothing(m)
            add!(s, m.captures[1] => elem[2])
        end
    end
    _s = collect(REPL.REPLCompletions.latex_symbols)
    for elem in _s
        add!(s, elem)
    end
    s
end

function luaitem(io::IO, p::Pair)
    k, v = p
    k = replace(k, "\\"=>"\\\\")
    kq = "\"$k\""
    vq = "\"$v\""
    label = '"'*k*" "*v*'"'
    write(io, "{word=$kq, label=$label, insertText=$vq, filterText=$kq}")
end

function luaitems(io::IO, l=unicode_list())
    foreach(l) do p
        print(io, "  ")
        luaitem(io, p)
        print(io, ",\n")
    end
end

function luafile(io::IO, l=unicode_list(), objname="symbols")
    print(io, "local $objname = {\n")
    luaitems(io, l)
    print(io, "}\n")
    print(io, "\n")
    print(io, "return $objname")
end

luafile(fname::AbstractString="./lua/cmp_latex_symbols/items.lua", l=unicode_list()) = open(io -> luafile(io, l), fname, write=true, create=true)
