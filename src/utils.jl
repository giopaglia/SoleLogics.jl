# Fast isempty(intersect(u, v))
function intersects(u, v)
    for x in u
        if x in v
            return true
        end
    end
    false
end

initrng(rng::Union{Integer,AbstractRNG}) =
    (rng isa AbstractRNG) ? rng : Random.MersenneTwister(rng)
initrng!(rng::Union{Integer,AbstractRNG}) =
    rng = initirng(rng)

inittruths(truthvalues::Union{Vector{<:Truth},AbstractAlgebra}) =
    return (truthvalues isa AbstractAlgebra) ? domain(truthvalues) : truthvalues
inittruths!(truthvalues::Union{Vector{<:Truth},AbstractAlgebra}) =
    truthvalues = inittruths(truthvalues)


function displaysyntaxvector(a, maxnum = 8; quotes = true)
    els = begin
        if length(a) > maxnum
            [(syntaxstring.(a)[1:div(maxnum, 2)])..., "...", syntaxstring.(a)[end-div(maxnum, 2):end]...]
        else
            syntaxstring.(a)
        end
    end
    "$(eltype(a))[$(join(map(e->(quotes ? "\"$(e)\"" : "$(e)"), els), ", "))]"
end
