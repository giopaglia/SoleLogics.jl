import Base: show, promote_rule, length, getindex
using SoleBase

doc_lmlf = """
    struct LeftmostLinearForm{C<:Connective,SS<:AbstractSyntaxStructure} <: AbstractSyntaxStructure
        children::Vector{<:SS}
    end

A syntax structure representing the `foldl` of a set of other syntax structure of type `SS`
by means of a connective `C`. This structure enables a structured instantiation of
formulas in conjuctive/disjunctive forms, and
conjuctive normal form (CNF) or disjunctive normal form (DNF), defined as:

    const LeftmostConjunctiveForm{SS<:AbstractSyntaxStructure} = LeftmostLinearForm{typeof(∧),SS}
    const LeftmostDisjunctiveForm{SS<:AbstractSyntaxStructure} = LeftmostLinearForm{typeof(∨),SS}

    const CNF{SS<:AbstractSyntaxStructure} = LeftmostLinearForm{typeof(∧),LeftmostLinearForm{typeof(∨),SS}}
    const DNF{SS<:AbstractSyntaxStructure} = LeftmostLinearForm{typeof(∨),LeftmostLinearForm{typeof(∧),SS}}

# Examples
```julia-repl
julia> LeftmostLinearForm(→, parseformula.(["p", "q", "r"]))
LeftmostLinearForm{SoleLogics.NamedOperator{:→},SyntaxBranch{Atom{String}}}
    (p) → (q) → (r)

julia> LeftmostConjunctiveForm(parseformula.(["¬p", "q", "¬r"]))
LeftmostLinearForm{SoleLogics.NamedOperator{:∧},SyntaxBranch}
    (¬(p)) ∧ (q) ∧ (¬(r))

julia> LeftmostDisjunctiveForm{Literal}([Literal(false, Atom("p")), Literal(true, Atom("q")), Literal(false, Atom("r"))])
LeftmostLinearForm{SoleLogics.NamedOperator{:∨},Literal}
    (¬(p)) ∨ (q) ∨ (¬(r))

julia> LeftmostDisjunctiveForm([LeftmostConjunctiveForm(parseformula.(["¬p", "q", "¬r"]))]) isa SoleLogics.DNF
true

```
"""

"""$(doc_lmlf)

See also [`AbstractSyntaxStructure`](@ref), [`SyntaxBranch`](@ref),
[`LeftmostConjunctiveForm`](@ref), [`LeftmostDisjunctiveForm`](@ref),
[`Literal`](@ref).
"""
struct LeftmostLinearForm{C<:Connective,SS<:AbstractSyntaxStructure} <: AbstractSyntaxStructure
    children::Vector{SS}

    function LeftmostLinearForm{C,SS}(
        children::Vector,
    ) where {C<:Connective,SS<:AbstractSyntaxStructure}
        a = arity(C)
        n_children = length(children)

        if a == 0
            n_children == 0 ||
                error("Mismatching number of children ($n_children) and connective's arity ($a).")
        elseif a == 1
            n_children == 1 ||
                error("Mismatching number of children ($n_children) and connective's arity ($a).")
        else
            h = (n_children-1)/(a-1)
            (isinteger(h) && h >= 0) ||
            # TODO figure out whether the base case n_children = 0 makes sense
                error("Mismatching number of children ($n_children) and connective's arity ($a).")
        end

        new{C,SS}(children)
    end

    function LeftmostLinearForm{C}(
        children::Vector,
    ) where {C<:Connective}
        length(children) > 0 || error("Cannot instantiate LeftmostLinearForm{$(C)} with no children.")
        SS = SoleBase._typejoin(typeof.(children)...)
        LeftmostLinearForm{C,SS}(children)
    end

    function LeftmostLinearForm(
        C::Type{<:SoleLogics.Connective},
        children::Vector,
    )
        LeftmostLinearForm{C}(children)
    end

    function LeftmostLinearForm(
        op::Connective,
        children::Vector,
    )
        LeftmostLinearForm(typeof(op), children)
    end

    function LeftmostLinearForm(
        tree::SyntaxBranch,
        conn::Union{<:SoleLogics.Connective,Nothing} = nothing
    )
        # Check conn correctness; it should not be nothing (thus, auto inferred) if
        # tree root contains something that is not a connective
        if (!(token(tree) isa Connective) && !isnothing(conn))
            error("Syntax tree cannot be converted to a LeftmostLinearForm:" *
                "tree root is $(token(tree))")
        end

        if isnothing(conn)
            conn = token(tree)
        end

        # Get a vector of `SyntaxBranch`s, having `conn` as common ancestor, then,
        # call LeftmostLinearForm constructor.
        _children = AbstractSyntaxStructure[]

        function _dig_and_retrieve(tree::SyntaxBranch, conn::SoleLogics.Connective)
            token(tree) != conn ?
            push!(_children, tree) :    # Lexical scope
            for c in children(tree)
                _dig_and_retrieve(c, conn)
            end
        end
        _dig_and_retrieve(tree, conn)

        LeftmostLinearForm(conn, _children)
    end
end

children(lf::LeftmostLinearForm) = lf.children
connective(::LeftmostLinearForm{C}) where {C} = C()

operatortype(::LeftmostLinearForm{C}) where {C} = C
childrentype(::LeftmostLinearForm{C,SS}) where {C,SS} = SS

Base.length(lf::LeftmostLinearForm) = Base.length(children(lf))
function Base.getindex(
    lf::LeftmostLinearForm{C,SS},
    idxs::AbstractVector
) where {C,SS}
    return LeftmostLinearForm{C,SS}(children(lf)[idxs])
end
Base.getindex(lf::LeftmostLinearForm, idx::Integer) = Base.getindex(lf,[idx])

nchildren(lf::LeftmostLinearForm) = length(children(lf))

# TODO: add parameter remove_redundant_parentheses
# TODO: add parameter parenthesize_atoms
function syntaxstring(
    lf::LeftmostLinearForm;
    function_notation = false,
    kwargs...,
)
    if function_notation
        syntaxstring(tree(lf); function_notation = function_notation, kwargs...)
    else
        ch = children(lf)
        if length(ch) == 0
            syntaxstring(connective(lf); kwargs...)
        else
            children_ss = map(
                c->syntaxstring(c; kwargs...),
                ch
            )
            "(" * join(children_ss, ") $(syntaxstring(connective(lf); kwargs...)) (") * ")"
        end
    end
end

function tree(lf::LeftmostLinearForm)
    conn = connective(lf)
    a = arity(conn)
    cs = children(lf)

    st = begin
        if length(cs) == 0
            # No children
            SyntaxBranch(conn)
        elseif length(cs) == 1
            # Only child
            tree(cs[1])
        else
            function _tree(childs::Vector{<:SyntaxBranch})
                @assert (length(childs) != 0) "$(childs); $(lf); $(conn); $(a); $(cs)"
                return length(childs) == a ?
                    SyntaxBranch(conn, childs...) :
                    SyntaxBranch(conn, childs[1:(a-1)]..., _tree(childs[a:end]))
            end
            _tree(tree.(children(lf)))
        end
    end

    return st
end

function Base.show(io::IO, lf::LeftmostLinearForm{C,SS}) where {C,SS}
    println(io, "LeftmostLinearForm{$(C),$(SS)} with $(nchildren(lf)) children")
    println(io, "\t$(syntaxstring(lf))")
end

Base.promote_rule(::Type{<:LeftmostLinearForm}, ::Type{<:LeftmostLinearForm}) = SyntaxBranch
Base.promote_rule(::Type{SS}, ::Type{LF}) where {SS<:AbstractSyntaxStructure,LF<:LeftmostLinearForm} = SyntaxBranch
Base.promote_rule(::Type{LF}, ::Type{SS}) where {LF<:LeftmostLinearForm,SS<:AbstractSyntaxStructure} = SyntaxBranch

############################################################################################

"""
    struct Literal{T<:SyntaxToken} <: AbstractSyntaxStructure
        ispos::Bool
        prop::T
    end

An atom, or its negation.

See also [`CNF`](@ref), [`DNF`](@ref), [`AbstractSyntaxStructure`](@ref).
"""
struct Literal{T<:SyntaxToken} <: AbstractSyntaxStructure
    ispos::Bool
    prop::T

    function Literal{T}(
        ispos::Bool,
        prop::T,
    ) where {T<:SyntaxToken}
        new{T}(ispos, prop)
    end

    function Literal(
        ispos::Bool,
        prop::T,
    ) where {T<:SyntaxToken}
        Literal{T}(ispos, prop)
    end
end

ispos(l::Literal) = l.ispos
prop(l::Literal) = l.prop

atomstype(::Literal{T}) where {T} = T

tree(l::Literal) = ispos(l) ? SyntaxBranch(l.prop) : ¬(SyntaxBranch(l.prop))

hasdual(l::Literal) = true
dual(l::Literal) = Literal(!ispos(l), prop(l))

function Base.show(io::IO, l::Literal)
    println(io,
        "Literal{$(atomstype(l))}: " * (ispos(l) ? "" : "¬") * syntaxstring(prop(l))
    )
end

############################################################################################

"""$(doc_lmlf)"""
const LeftmostConjunctiveForm{SS<:AbstractSyntaxStructure} = LeftmostLinearForm{typeof(∧),SS}
"""$(doc_lmlf)"""
const LeftmostDisjunctiveForm{SS<:AbstractSyntaxStructure} = LeftmostLinearForm{typeof(∨),SS}

"""$(doc_lmlf)"""
const CNF{SS<:AbstractSyntaxStructure} = LeftmostConjunctiveForm{LeftmostDisjunctiveForm{SS}}
"""$(doc_lmlf)"""
const DNF{SS<:AbstractSyntaxStructure} = LeftmostDisjunctiveForm{LeftmostConjunctiveForm{SS}}

conjuncts(m::Union{LeftmostConjunctiveForm,CNF}) = children(m)
nconjuncts(m::Union{LeftmostConjunctiveForm,CNF}) = nchildren(m)
disjuncts(m::Union{LeftmostDisjunctiveForm,DNF}) = children(m)
ndisjuncts(m::Union{LeftmostDisjunctiveForm,DNF}) = nchildren(m)

# conjuncts(m::DNF) = map(d->conjuncts(d), disjuncts(m))
# nconjuncts(m::DNF) = map(d->nconjuncts(d), disjuncts(m))
# disjuncts(m::CNF) = map(d->disjuncts(d), conjuncts(m))
# ndisjuncts(m::CNF) = map(d->ndisjuncts(d), conjuncts(m))

############################################################################################

subtrees(tree::SyntaxBranch) = [Iterators.flatten(_subtrees.(children(tree)))...]
_subtrees(tree::SyntaxBranch) = [tree, Iterators.flatten(_subtrees.(children(tree)))...]

"""
    treewalk(
        st::SyntaxBranch,
        args...;
        rng::AbstractRNG = Random.GLOBAL_RNG,
        criterion::Function = ntokens,
        toleaf::Bool = true,
        returnnode::Bool = false,
        transformnode::Function = nothing,
    )::SyntaxBranch

Return a subtree from passed SyntaxBranch by following options:
 - `criterion`: function used to calculate the probability of stopping at a random node;
 - `returnnode`: true if only the subtree is to be returned;
 - `transformnode`: function that will be applied to the chosen subtree.
"""
function treewalk(
    st::SyntaxBranch,
    args...;
    rng::AbstractRNG = Random.GLOBAL_RNG,
    criterion::Function = c->true,
    returnnode::Bool = false,
    transformnode::Union{Function,Nothing} = nothing,
)
    chs = children(st)

    return length(chs) == 0 ? begin
        isnothing(transformnode) ? st : transformnode(st, args...)
    end : begin
        c_chsub = map(c->length(filter(criterion, tokens(c))), chs)
        c_father = criterion(token(st)) ? 1 : 0

        @assert [c_chsub..., c_father] isa AbstractVector{<:Integer} "Not all values " *
        "calculated as criterion are integers, double check the passed function used for " *
        "calculating these; values: $([c_chsub..., c_father])"

        w_nodes = [c_chsub..., c_father]/sum([c_chsub..., c_father])
        idx_randnode = sample(rng, 1:length(w_nodes), Weights(w_nodes))

        if idx_randnode == length(w_nodes)
            isnothing(transformnode) ? st : transformnode(st, args...)
        else
            returnnode ?
                treewalk(
                    chs[idx_randnode],
                    args...;
                    rng=rng,
                    criterion=criterion,
                    returnnode=returnnode,
                    transformnode=transformnode,
                ) :
                SyntaxBranch(
                    token(st),
                    (
                        chs[1:(idx_randnode-1)]...,
                        treewalk(
                            chs[idx_randnode],
                            args...;
                            rng=rng,
                            criterion=criterion,
                            returnnode=returnnode,
                            transformnode=transformnode,
                        ),
                        chs[(idx_randnode+1):end]...
                    )
                )
        end
    end
end



"""
    subformulas(f::Formula; sorted=true)

Return all sub-formulas (sorted by size when `sorted=true`)
of a given formula.

# Examples
```julia-repl
julia> syntaxstring.(SoleLogics.subformulas(parsebaseformula("◊((p∧q)→r)")))
6-element Vector{String}:
 "p"
 "q"
 "r"
 "p ∧ q"
 "◊(p ∧ q)"
 "(◊(p ∧ q)) → r"
```

See also
[`SyntaxBranch`](@ref)), [`Formula`](@ref).
"""
subformulas(f::Formula, args...; kwargs...) = subformulas(tree(f), args...; kwargs...)
function subformulas(t::SyntaxBranch; sorted=true)
    # function _subformulas(_t::SyntaxBranch)
    #     SyntaxBranch[
    #         (map(SyntaxBranch, Iterators.flatten(subformulas.(children(_t)))))...,
    #         SyntaxBranch(_t)
    #     ]
    # end
    function _subformulas(_t::SyntaxBranch)
        SyntaxBranch[
            (Iterators.flatten(subformulas.(children(_t))))...,
            _t
        ]
    end
    ts = _subformulas(t)
    if sorted
        sort!(ts, by = t -> SoleLogics.height(t))
    end
    ts
end

# TODO move to utils and rename "normalize" -> "transform"/"reshape"/"simplify"
# TODO \to diventano \lor
# TODO explain profile's and other parameters
"""
    normalize(
        f::Formula;
        remove_boxes = true,
        reduce_negations = true,
        allow_atom_flipping = true,
    )

Return a modified version of a given formula, that has the same semantics
but different syntax. This is useful when dealing with the truth of many
(possibly similar) formulas; for example, when performing
[model checking](https://en.wikipedia.org/wiki/Model_checking).
BEWARE: it currently assumes the underlying algebra is Boolean!

# Arguments
- `f::Formula`: when set to `true`,
    the formula;
- `remove_boxes::Bool`: remove all (non-relational and relational) box operators by using the
    equivalence ◊φ ≡ ¬□¬φ. Note: this assumes an underlying Boolean algebra.
- `reduce_negations::Bool`: when set to `true`,
    attempts at reducing the number of negations by appling
    some transformation rules
    (e.g., [De Morgan's laws](https://en.wikipedia.org/wiki/De_Morgan%27s_laws)).
    Note: this assumes an underlying Boolean algebra.
- `allow_atom_flipping::Bool`: when set to `true`,
    together with `reduce_negations=true`, this may cause the negation of an atom
    to be replaced with the its [`dual`](@ref) atom.

# Examples
```julia-repl
julia> f = parsebaseformula("□¬((p∧¬q)→r)∧⊤");

julia> syntaxstring(f)
"□¬((p ∧ ¬q) → r) ∧ ⊤"

julia> syntaxstring(SoleLogics.normalize(f; profile = :modelchecking, allow_atom_flipping = false))
"¬◊(q ∨ ¬p ∨ r)"

julia> syntaxstring(SoleLogics.normalize(f; profile = :readability, allow_atom_flipping = false))
"□(¬r ∧ p ∧ ¬q)"
```

See also
[`SyntaxBranch`](@ref)), [`Formula`](@ref).
"""
normalize(f::Formula, args...; kwargs...) = normalize(tree(f), args...; kwargs...)
function normalize(
    t::SyntaxBranch;
    profile = :readability,
    remove_boxes = nothing,
    reduce_negations = nothing,
    simplify_constants = nothing,
    allow_atom_flipping = nothing,
    forced_negation_removal = nothing,
    remove_identities = nothing,
    rotate_commutatives = nothing
)
    if profile == :readability
        if isnothing(remove_boxes)               remove_boxes = false end
        if isnothing(reduce_negations)           reduce_negations = true end
        if isnothing(simplify_constants)         simplify_constants = true end
        if isnothing(allow_atom_flipping) allow_atom_flipping = false end
        if isnothing(remove_identities)          remove_identities = false end
        if isnothing(rotate_commutatives)        rotate_commutatives = true end
        # TODO leave \to's instead of replacing them with \lor's...
    elseif profile == :modelchecking
        if isnothing(remove_boxes)               remove_boxes = true end
        if isnothing(reduce_negations)           reduce_negations = true end
        if isnothing(simplify_constants)         simplify_constants = true end
        if isnothing(allow_atom_flipping) allow_atom_flipping = false end
        if isnothing(remove_identities)          remove_identities = true end
        if isnothing(rotate_commutatives)        rotate_commutatives = true end
    else
        error("Unknown normalization profile: $(repr(profile))")
    end

    if isnothing(forced_negation_removal)
        if isnothing(allow_atom_flipping)
            forced_negation_removal = true
        else
            forced_negation_removal = false
        end
    end

    # TODO we're currently assuming Boolean algebra!!! Very wrong.

    _normalize = t->normalize(t;
        profile = profile,
        remove_boxes = remove_boxes,
        reduce_negations = reduce_negations,
        simplify_constants = simplify_constants,
        allow_atom_flipping = allow_atom_flipping,
        forced_negation_removal = forced_negation_removal,
        rotate_commutatives = rotate_commutatives
    )

    newt = t

    # Remove modal operators based on the identity relation
    newt = begin
        tok, ch = token(newt), children(newt)
        if remove_identities && tok isa AbstractRelationalOperator &&
            relation(tok) == identityrel && arity(tok) == 1
            first(ch)
        else
            newt
        end
    end

    # Simplify
    newt = begin
        tok, ch = token(newt), children(newt)
        if (tok == ¬) && arity(tok) == 1
            child = ch[1]
            chtok, grandchildren = token(child), children(child)
            if reduce_negations && (chtok == ¬) && arity(chtok) == 1
                _normalize(grandchildren[1])
            elseif reduce_negations && (chtok == ∨) && arity(chtok) == 2
                ∧(_normalize(¬(grandchildren[1])), _normalize(¬(grandchildren[2])))
                # TODO use implication, maybe it's more interpretable?
            elseif reduce_negations && (chtok == ∧) && arity(chtok) == 2
                ∨(_normalize(¬(grandchildren[1])), _normalize(¬(grandchildren[2])))
            elseif reduce_negations && (chtok == →) && arity(chtok) == 2
                # _normalize(∨(¬(grandchildren[1]), grandchildren[2]))
                ∧(_normalize(grandchildren[1]), _normalize(¬(grandchildren[2])))
            elseif reduce_negations && chtok isa Atom
                if allow_atom_flipping && hasdual(chtok)
                    SyntaxBranch(dual(chtok))
                else
                    ¬(_normalize(child))
                end
            # elseif reduce_negations && chtok isa SoleLogics.AbstractRelationalOperator && arity(chtok) == 1
            #     dual_op = dual(chtok)
            #     if remove_boxes && dual_op isa SoleLogics.BoxRelationalOperator
            #         ¬(_normalize(child))
            #     else
            #         dual_op(_normalize(¬(grandchildren[1])))
            #     end
            elseif reduce_negations && ismodal(chtok) && arity(chtok) == 1
                dual_op = dual(chtok)
                # if remove_boxes && SoleLogics.isbox(dual_op)
                #     ¬(_normalize(child))
                # else
                dual_op(_normalize(¬(grandchildren[1])))
                # end
            elseif (reduce_negations || simplify_constants) && chtok == ⊤ && arity(chtok) == 1
                SyntaxBranch(⊥)
            elseif (reduce_negations || simplify_constants) && chtok == ⊥ && arity(chtok) == 1
                SyntaxBranch(⊤)
            elseif !forced_negation_removal
                SyntaxBranch(tok, _normalize.(ch))
            else
                error("Unknown chtok when removing negations: $(chtok) (type = $(typeof(chtok)))")
            end
        else
            SyntaxBranch(tok, _normalize.(ch))
        end
    end

    # Simplify constants
    newt = begin
        tok, ch = token(newt), children(newt)
        if simplify_constants && tok isa Operator
            if (tok == ∨) && arity(tok) == 2
                if     token(ch[1]) == ⊥  ch[2]          # ⊥ ∨ φ ≡ φ
                elseif token(ch[2]) == ⊥  ch[1]          # φ ∨ ⊥ ≡ φ
                elseif token(ch[1]) == ⊤  SyntaxBranch(⊤)  # ⊤ ∨ φ ≡ ⊤
                elseif token(ch[2]) == ⊤  SyntaxBranch(⊤)  # φ ∨ ⊤ ≡ ⊤
                else                      newt
                end
            elseif (tok == ∧) && arity(tok) == 2
                if     token(ch[1]) == ⊥  SyntaxBranch(⊥)  # ⊥ ∧ φ ≡ ⊥
                elseif token(ch[2]) == ⊥  SyntaxBranch(⊥)  # φ ∧ ⊥ ≡ ⊥
                elseif token(ch[1]) == ⊤  ch[2]          # ⊤ ∧ φ ≡ φ
                elseif token(ch[2]) == ⊤  ch[1]          # φ ∧ ⊤ ≡ φ
                else                      newt
                end
            elseif (tok == →) && arity(tok) == 2
                if     token(ch[1]) == ⊥  SyntaxBranch(⊤)       # ⊥ → φ ≡ ⊤
                elseif token(ch[2]) == ⊥  _normalize(¬ch[1])  # φ → ⊥ ≡ ¬φ
                elseif token(ch[1]) == ⊤  ch[2]               # ⊤ → φ ≡ φ
                elseif token(ch[2]) == ⊤  SyntaxBranch(⊤)       # φ → ⊤ ≡ ⊤
                else                      SyntaxBranch(∨, _normalize(¬ch[1]), ch[2])
                end
            elseif (tok == ¬) && arity(tok) == 1
                if     token(ch[1]) == ⊤  SyntaxBranch(⊥)
                elseif token(ch[1]) == ⊥  SyntaxBranch(⊤)
                else                      newt
                end
            elseif SoleLogics.isbox(tok) && arity(tok) == 1
                if     token(ch[1]) == ⊤  SyntaxBranch(⊤)
                else                      newt
                end
            elseif SoleLogics.isdiamond(tok) && arity(tok) == 1
                if     token(ch[1]) == ⊥  SyntaxBranch(⊥)
                else                      newt
                end
            else
                newt
            end
        else
            newt
        end
    end

    newt = begin
        tok, ch = token(newt), children(newt)
        if remove_boxes && tok isa Operator && SoleLogics.isbox(tok) && arity(tok) == 1
            # remove_boxes -> substitute every [X]φ with ¬⟨X⟩¬φ
            child = ch[1]
            dual_op = dual(tok)
            ¬(dual_op(_normalize(¬child)))
            # TODO remove
            # if relation(tok) == globalrel
            #     # Special case: [G]φ -> ⟨G⟩φ
            #     dual_op(_normalize(child))
            # else
            #     ¬(dual_op(_normalize(¬child)))
            # end
        else
            newt
        end
    end

    function _isless(st1::SyntaxBranch, st2::SyntaxBranch)
        isless(Base.hash(st1), Base.hash(st2))
    end

    # Rotate commutatives
    if rotate_commutatives
        newt = begin
            tok, ch = token(newt), children(newt)
            if tok isa Connective && iscommutative(tok) && arity(tok) > 1
                ch = children(LeftmostLinearForm(newt, tok))
                ch = Vector(sort(collect(_normalize.(ch)), lt=_isless))
                if tok in [∧,∨] # TODO create trait for this behavior: p ∧ p ∧ p ∧ q   -> p ∧ q
                    ch = unique(ch)
                end
                tree(LeftmostLinearForm(tok, ch))
            else
                SyntaxBranch(tok, ch)
            end
        end
    end

    return newt
end

"""
    isgrounded(f::Formula)::Bool

Return `true` if the formula is grounded, that is, if it can be inferred from its syntactic
structure that, given any frame-based model, the truth value of the formula is the same
on every world.

# Examples
```julia-repl
julia> f = parsebaseformula("⟨G⟩p → [G]q");

julia> syntaxstring(f)
"(⟨G⟩p) → ([G]q)"

julia> SoleLogics.isgrounded(f)
true
```

See also
[`isgrounding`](@ref)), [`SyntaxBranch`](@ref)), [`Formula`](@ref).
"""
isgrounded(f::Formula) = isgrounded(tree(f))
function isgrounded(t::SyntaxBranch)::Bool
    # (println(token(t)); println(children(t)); true) &&
    return (token(t) isa SoleLogics.AbstractRelationalOperator && isgrounding(relation(token(t)))) ||
    # (token(t) in [◊,□]) ||
    (token(t) isa Operator && all(c->isgrounded(c), children(t)))
end
