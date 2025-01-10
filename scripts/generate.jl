#====================================================================================================
This script generates latex symbols and names from the Julia RPL list and outputs a lua file
Based on https://gitlab.com/ExpandingMan/cmp-latex/-/blob/master/generate_items.jl
====================================================================================================#

using REPL

@enum Strategy begin
    mixed
    julia
    latex
end

function add!(s, pair)
    x, y = pair
    if count(elem -> elem[1] == x, s) == 0
        push!(s, string(x) => string(y))
    end
end

function unicode_list()
    s = Pair{String, String}[]
    out = readlines(open(`curl -L http://milde.users.sourceforge.net/LUCR/Math/data/unimathsymbols.txt`))
    out = filter(x -> !startswith(x, "#"), out) # Remove comments
    out = split.(out, '^') # Split on ^
    out = filter(x -> startswith(x[3], '\\') || startswith(x[4], '\\'), out) # Only get some elements
    for elem in out
        if strip(elem[2]) == ""
            continue
        end
        # remove U+00A0 especially before combining characters
        symbol = strip(==(Char(0x00A0)), elem[2])
        if startswith(elem[3], "\\")
            add!(s, elem[3] => symbol)
        end
        if startswith(elem[4], "\\")
            add!(s, elem[4] => symbol)
        end
        m = match(r"= (\\\w+)", elem[end])
        if !isnothing(m)
            add!(s, m.captures[1] => symbol)
        end
        m = match(r"# (\\\w+)", elem[end])
        if !isnothing(m)
            add!(s, m.captures[1] => symbol)
        end
    end
    _s = collect(REPL.REPLCompletions.latex_symbols)
    for elem in _s
        add!(s, elem)
    end
    add!(s, "\\mathord" => "⍹")
    return s
end

function luaitem(io::IO, p::Pair, strategy::Strategy)
    k, v = p
    if endswith(v, '\\')
        v = v * "\\"
    end
    if k == "\\cdot"
        v = replace(v, "·" => "⋅")
    end
    k = replace(k, "\\" => "\\\\")
    kk = "\"$k\""
    vv = "\"$v\""
    if strategy == julia
        kq = vv
        vq = vv
    elseif strategy == latex
        kq = kk
        vq = kk
    else # if strategy == mixed
        kq = kk
        vq = vv
    end
    label = '"' * k * " " * v * '"'
    write(io, "{word=$kq, label=$label, insertText=$vq, filterText=$kk}")
end

function luaitems(io::IO, strategy::Strategy, l=unicode_list())
    foreach(l) do p
        print(io, "  ")
        luaitem(io, p, strategy)
        print(io, ",\n")
    end
end

function luafile(io::IO, strategy::Strategy, l=unicode_list(), objname="symbols")
    print(io, "local $objname = {\n")
    luaitems(io, strategy, l)
    print(io, "}\n")
    print(io, "\n")
    print(io, "return $objname")
end

mixedfile(fname::AbstractString="./lua/cmp_latex_symbols/items_mixed.lua", l=unicode_list()) = open(io -> luafile(io, mixed, l), fname, write=true, create=true)

juliafile(fname::AbstractString="./lua/cmp_latex_symbols/items_julia.lua", l=unicode_list()) = open(io -> luafile(io, julia, l), fname, write=true, create=true)

latexfile(fname::AbstractString="./lua/cmp_latex_symbols/items_latex.lua", l=unicode_list()) = open(io -> luafile(io, latex, l), fname, write=true, create=true)
