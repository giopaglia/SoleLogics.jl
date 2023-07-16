var documenterSearchIndex = {"docs":
[{"location":"base/syntax/#Syntax","page":"Syntax","title":"Syntax","text":"","category":"section"},{"location":"base/syntax/","page":"Syntax","title":"Syntax","text":"SoleLogics.AbstractSyntaxToken\n\narity(::Type{<:SoleLogics.AbstractSyntaxToken})\n\nsyntaxstring(tok::SoleLogics.AbstractSyntaxToken; kwargs...)\n\nProposition\n\nnegation(p::Proposition)\n\nSoleLogics.AbstractSyntaxStructure\n\nSyntaxTree\n\nBase.in(tok::SoleLogics.AbstractSyntaxToken, f::SoleLogics.AbstractFormula)\n\nntokens\n\ntree","category":"page"},{"location":"base/syntax/#SoleLogics.AbstractSyntaxToken","page":"Syntax","title":"SoleLogics.AbstractSyntaxToken","text":"abstract type AbstractSyntaxToken end\n\nA token in a syntactic structure, most commonly, a syntax tree. A syntax tree is a tree-like structure representing a logical formula, where each node holds a token, and has as many children as the arity of the token.\n\nSee also SyntaxTree, AbstractSyntaxStructure, arity, syntaxstring.\n\n\n\n\n\n","category":"type"},{"location":"base/syntax/#SoleLogics.arity-Tuple{Type{<:SoleLogics.AbstractSyntaxToken}}","page":"Syntax","title":"SoleLogics.arity","text":"arity(::Type{<:AbstractSyntaxToken})::Integer\narity(tok::AbstractSyntaxToken)::Integer = arity(typeof(tok))\n\nReturn the arity of a syntax token. The arity of a syntax token is an integer representing the number of allowed children in a SyntaxTree. Tokens with arity equal to 0, 1 or 2 are called nullary, unary and binary, respectively.\n\nSee also AbstractSyntaxToken.\n\n\n\n\n\n","category":"method"},{"location":"base/syntax/#SoleLogics.syntaxstring-Tuple{SoleLogics.AbstractSyntaxToken}","page":"Syntax","title":"SoleLogics.syntaxstring","text":"syntaxstring(φ::AbstractFormula; kwargs...)::String\nsyntaxstring(tok::AbstractSyntaxToken; kwargs...)::String\n\nProduces the string representation of a formula or syntax token by performing a tree traversal of the syntax tree representation of the formula. Note that this representation may introduce redundant brackets. kwargs can be used to specify how to display syntax tokens/trees under some specific conditions.\n\nThe following kwargs are currently supported:\n\nfunction_notation = false::Bool: when set to true, it forces the use of\n\nfunction notation for binary operators. See here.\n\nExamples\n\njulia> syntaxstring((parsebaseformula(\"◊((p∧s)→q)\")))\n\"(◊(p ∧ s)) → q\"\n\njulia> syntaxstring((parsebaseformula(\"◊((p∧s)→q)\")); function_notation = true)\n\"→(◊(∧(p, s)), q)\"\n\nSee also parsebaseformula, parsetree, SyntaxTree, AbstractSyntaxToken.\n\nImplementation\n\nIn the case of a syntax tree, syntaxstring is a recursive function that calls itself on the syntax children of each node. For a correct functioning, the syntaxstring must be defined (including kwargs...) for every newly defined AbstractSyntaxToken (e.g., operators and Propositions), in a way that it produces a unique string representation, since Base.hash and Base.isequal, at least for SyntaxTrees, rely on it.\n\nIn particular, for the case of Propositions, the function calls itself on the atom:\n\nsyntaxstring(p::Proposition; kwargs...) = syntaxstring(atom(p); kwargs...)\n\nThen, the syntaxstring for a given atom can be defined. For example, with String atoms, the function can simply be:\n\nsyntaxstring(atom::String; kwargs...) = atom\n\nwarning: Warning\nThe syntaxstring for syntax tokens (e.g., propositions, operators) should not be prefixed/suffixed by whitespaces, as this may cause ambiguities upon parsing. For similar reasons, syntaxstrings should not contain brackets ('(', ')'), and, when parsing in function notation, commas (','). See also parsebaseformula.\n\n\n\n\n\n","category":"method"},{"location":"base/syntax/#SoleLogics.Proposition","page":"Syntax","title":"SoleLogics.Proposition","text":"struct Proposition{A} <: AbstractSyntaxToken\n    atom::A\nend\n\nA proposition, sometimes called a propositional letter (or simply letter), of type Proposition{A} wraps a value atom::A representing a fact which truth can be assessed on a logical interpretation.\n\nPropositions are nullary tokens (i.e, they are at the leaves of a syntax tree). Note that their atom cannot be a Proposition.\n\nSee also AbstractSyntaxToken, AbstractInterpretation, check.\n\n\n\n\n\n","category":"type"},{"location":"base/syntax/#SoleLogics.AbstractSyntaxStructure","page":"Syntax","title":"SoleLogics.AbstractSyntaxStructure","text":"abstract type AbstractSyntaxStructure <: AbstractFormula end\n\nA logical formula unanchored to any logic, and solely represented by its syntactic component. Classically, this structure is implemented as a tree structure (see SyntaxTree); however, the implementation in some cases (e.g., conjuctive/disjuctive normal forms) can differ.\n\nSee also tree, SyntaxTree, AbstractFormula, AbstractLogic.\n\n\n\n\n\n","category":"type"},{"location":"base/syntax/#SoleLogics.SyntaxTree","page":"Syntax","title":"SoleLogics.SyntaxTree","text":"struct SyntaxTree{\n    T<:AbstractSyntaxToken,\n} <: AbstractSyntaxStructure\n    token::T\n    children::NTuple{N,SyntaxTree} where {N}\nend\n\nA syntax tree encoding a logical formula. Each node of the syntax tree holds a token::T, and has as many children as the arity of the token.\n\nThis implementation is arity-compliant, in that, upon construction, the arity is checked against the number of children provided.\n\nSee also token, children, tokentype, tokens, operators, propositions, ntokens, npropositions, height, tokenstype, operatorstype, propositionstype, AbstractSyntaxToken, arity, Proposition, Operator.\n\n\n\n\n\n","category":"type"},{"location":"base/syntax/#Base.in-Tuple{SoleLogics.AbstractSyntaxToken, AbstractFormula}","page":"Syntax","title":"Base.in","text":"Base.in(tok::AbstractSyntaxToken, f::AbstractFormula)::Bool\n\nReturn whether a syntax token appears in a formula.\n\nSee also AbstractSyntaxToken.\n\n\n\n\n\n","category":"method"},{"location":"base/syntax/#SoleLogics.tree","page":"Syntax","title":"SoleLogics.tree","text":"tree(f::AbstractFormula)::SyntaxTree\n\nExtract the SyntaxTree representation of a formula (equivalent to Base.convert(SyntaxTree, f)).\n\nSee also SyntaxTree, AbstractSyntaxStructure. AbstractFormula,\n\n\n\n\n\n","category":"function"},{"location":"NOTE/#Quick-start","page":"-","title":"Quick start","text":"","category":"section"},{"location":"NOTE/","page":"-","title":"-","text":"make.jl structure is inspired by the official julia language repo:  https://github.com/JuliaLang/julia/blob/master/doc/make.jl","category":"page"},{"location":"NOTE/","page":"-","title":"-","text":"Move inside this folder (doc) and run julia --project=. make.jl to build documentation; a new private \"build\" folder will be created if no errors occur.","category":"page"},{"location":"NOTE/","page":"-","title":"-","text":"This is Documenter.jl documentation: https://documenter.juliadocs.org/stable/man/guide/","category":"page"},{"location":"NOTE/#Troubleshooting","page":"-","title":"Troubleshooting","text":"","category":"section"},{"location":"NOTE/","page":"-","title":"-","text":"The command make can generate very large warning logs. Here it is a list of common mistakes. ","category":"page"},{"location":"NOTE/#Missing-docstring","page":"-","title":"Missing docstring","text":"","category":"section"},{"location":"NOTE/","page":"-","title":"-","text":"If the documentation is generated properly but some yellow frames \"Missing docstring\" appears, check if the definition is exported from your Package entry (e.g. SoleLogics.jl). If it is not exported, the following block","category":"page"},{"location":"NOTE/","page":"-","title":"-","text":"```@doc AbstractFormula ```","category":"page"},{"location":"NOTE/","page":"-","title":"-","text":"has to be rewritten like this, for example","category":"page"},{"location":"NOTE/","page":"-","title":"-","text":"```@doc SoleLogics.AbstractFormula ```","category":"page"},{"location":"NOTE/","page":"-","title":"-","text":"Note that if we want to specify a specific dispatch docstring, the same rule applies, for example","category":"page"},{"location":"NOTE/","page":"-","title":"-","text":"```@doc SoleLogics.propositions(f::SoleLogics.AbstractFormula) ```","category":"page"},{"location":"NOTE/","page":"-","title":"-","text":"instead of ","category":"page"},{"location":"NOTE/","page":"-","title":"-","text":"```@doc SoleLogics.propositions(f::AbstractFormula) ```","category":"page"},{"location":"base/alphabets/#Alphabets","page":"Alphabets","title":"Alphabets","text":"","category":"section"},{"location":"base/alphabets/","page":"Alphabets","title":"Alphabets","text":"SoleLogics.AbstractAlphabet\n\nBase.in\n\nBase.isiterable\n\nBase.isfinite\n\nExplicitAlphabet\n\nAlphabetOfAny","category":"page"},{"location":"base/alphabets/#SoleLogics.AbstractAlphabet","page":"Alphabets","title":"SoleLogics.AbstractAlphabet","text":"abstract type AbstractAlphabet{A} end\n\nAbstract type for representing an alphabet of propositions with atoms of type A. An alphabet (or propositional alphabet) is a set of propositions, and it is assumed to be countable.\n\nSee also ExplicitAlphabet, AlphabetOfAny, propositionstype, atomtype, Proposition, AbstractGrammar.\n\nExamples\n\njulia> Proposition(1) in ExplicitAlphabet(Proposition.(1:10))\ntrue\n\njulia> Proposition(1) in ExplicitAlphabet(1:10)\ntrue\n\njulia> Proposition(1) in AlphabetOfAny{String}()\nfalse\n\njulia> Proposition(\"mystring\") in AlphabetOfAny{String}()\ntrue\n\njulia> \"mystring\" in AlphabetOfAny{String}()\n┌ Warning: Please, use Base.in(Proposition(mystring), alphabet::AlphabetOfAny{String}) instead of Base.in(mystring, alphabet::AlphabetOfAny{String})\n└ @ SoleLogics ...\ntrue\n\nImplementation\n\nWhen implementing a new alphabet type MyAlphabet, you should provide a method for establishing whether a proposition belongs to it or not; while, in general, this method should be:\n\nfunction Base.in(p::Proposition, a::MyAlphabet)::Bool\n\nin the case of finite alphabets, it suffices to define a method:\n\nfunction propositions(a::AbstractAlphabet)::AbstractVector{propositionstype(a)}\n\nBy default, an alphabet is considered finite:\n\nBase.isfinite(::Type{<:AbstractAlphabet}) = true\nBase.isfinite(a::AbstractAlphabet) = Base.isfinite(typeof(a))\nBase.in(p::Proposition, a::AbstractAlphabet) = Base.isfinite(a) ? Base.in(p, propositions(a)) : error(...)\n\n\n\n\n\n","category":"type"},{"location":"base/alphabets/#Base.in","page":"Alphabets","title":"Base.in","text":"Base.in(tok::AbstractSyntaxToken, f::AbstractFormula)::Bool\n\nReturn whether a syntax token appears in a formula.\n\nSee also AbstractSyntaxToken.\n\n\n\n\n\nBase.in(tok::AbstractSyntaxToken, tree::SyntaxTree)::Bool\n\nReturn whether a token appears in a syntax tree or not.\n\nSee also tokens, SyntaxTree.\n\n\n\n\n\nBase.in(t::SyntaxTree, g::AbstractGrammar)::Bool\n\nReturn whether a formula, encoded as a SyntaxTree, belongs to a grammar.\n\nSee also AbstractGrammar, SyntaxTree.\n\n\n\n\n\n","category":"function"},{"location":"base/alphabets/#SoleLogics.ExplicitAlphabet","page":"Alphabets","title":"SoleLogics.ExplicitAlphabet","text":"struct ExplicitAlphabet{A} <: AbstractAlphabet{A}\n    propositions::Vector{Proposition{A}}\nend\n\nAn alphabet wrapping propositions in a (finite) Vector.\n\nSee also propositions, AbstractAlphabet.\n\n\n\n\n\n","category":"type"},{"location":"base/alphabets/#SoleLogics.AlphabetOfAny","page":"Alphabets","title":"SoleLogics.AlphabetOfAny","text":"struct AlphabetOfAny{A} <: AbstractAlphabet{A} end\n\nAn implicit, infinite alphabet that includes all propositions with atoms of a subtype of A.\n\nSee also AbstractAlphabet.\n\n\n\n\n\n","category":"type"},{"location":"base/formulas/#Formulas","page":"Formulas","title":"Formulas","text":"","category":"section"},{"location":"base/formulas/","page":"Formulas","title":"Formulas","text":"SoleLogics.AbstractFormula\n\nSoleLogics.joinformulas(op::SoleLogics.AbstractOperator, ::NTuple{N,F}) where {N,F<:SoleLogics.AbstractFormula}\n\ntokens(f::SoleLogics.AbstractFormula)::AbstractVector{<:SoleLogics.AbstractSyntaxToken}\n\noperators(f::SoleLogics.AbstractFormula)\n\npropositions(f::SoleLogics.AbstractFormula)\n\nntokens(f::SoleLogics.AbstractFormula)\n\nnpropositions(f::SoleLogics.AbstractFormula)\n\nheight","category":"page"},{"location":"base/formulas/#SoleLogics.AbstractFormula","page":"Formulas","title":"SoleLogics.AbstractFormula","text":"abstract type AbstractFormula end\n\nA logical formula encoding a statement which truth can be evaluated on interpretations (or models) of the logic.\n\nIts syntactic component is canonically encoded via a syntax tree (see SyntaxTree), and it can be anchored to a logic (see Formula).\n\nImplementation\n\nWhen implementing a new formula type MyCustomFormulaType, please provide the method for extracting its syntax tree representation:\n\nfunction tree(f::MyCustomFormulaType)::SyntaxTree\n    ...\nend\n\nAs well as the one used for composing formulas:\n\nfunction (op::AbstractOperator)(\n    children::NTuple{N,Union{AbstractSyntaxToken,MyCustomFormulaType}},\n)::AbstractFormula where {N}\n    # Composed formula\nend\n\nSee also Formula, SyntaxTree, AbstractSyntaxStructure, AbstractLogic.\n\n\n\n\n\n","category":"type"},{"location":"base/formulas/#SoleLogics.joinformulas-Union{Tuple{F}, Tuple{N}, Tuple{SoleLogics.AbstractOperator, Tuple{Vararg{F, N}}}} where {N, F<:AbstractFormula}","page":"Formulas","title":"SoleLogics.joinformulas","text":"joinformulas(\n    op::AbstractOperator,\n    ::NTuple{N,F}\n)::F where {N,F<:AbstractFormula}\n\nReturn a new formula of type F by composing N formulas of the same type via an operator op. This function provides a way for composing formulas, but it allows to use operators for a more flexible composition; see the examples (and more in the extended help).\n\nExamples\n\njulia> f = parseformula(\"◊(p→q)\");\n\njulia> p = Proposition(\"p\");\n\njulia> syntaxstring(∧(f, p))\n\"(◊(p → q)) ∧ p\"\n\njulia> syntaxstring(f ∧ ¬p) # Leverage infix notation ;)\n\"(◊(p → q)) ∧ (¬(p))\"\n\njulia> syntaxstring(∧(f, p, ¬p))\n\"(◊(p → q)) ∧ (p ∧ (¬(p)))\"\n\nImplementation\n\nUpon joinformulas lies a more flexible way of using operators for composing formulas and syntax tokens (e.g., propositions), given methods like the following:\n\nfunction (op::AbstractOperator)(\n    children::NTuple{N,Union{AbstractSyntaxToken,AbstractFormula}},\n) where {N}\n    ...\nend\n\nThese allow composing formulas as in ∧(f, ¬p), and in order to access this composition with any newly defined subtype of AbstractFormula, a new method for joinformulas should be defined, together with promotion from/to other AbstractFormulas should be taken care of (see here and here).\n\nSimilarly, for allowing a (possibly newly defined) operator to be applied on a number of syntax tokens/formulas that differs from its arity, for any newly defined operator op, new methods similar to the two above should be defined. For example, although ∧ and ∨ are binary, (i.e., have arity equal to 2), compositions such as ∧(f, f2, f3, ...) and ∨(f, f2, f3, ...) can be done thanks to the following two methods that were defined in SoleLogics:\n\nfunction ∧(\n    c1::Union{AbstractSyntaxToken,AbstractFormula},\n    c2::Union{AbstractSyntaxToken,AbstractFormula},\n    c3::Union{AbstractSyntaxToken,AbstractFormula},\n    cs::Union{AbstractSyntaxToken,AbstractFormula}...\n)\n    return ∧(c1, ∧(c2, c3, cs...))\nend\nfunction ∨(\n    c1::Union{AbstractSyntaxToken,AbstractFormula},\n    c2::Union{AbstractSyntaxToken,AbstractFormula},\n    c3::Union{AbstractSyntaxToken,AbstractFormula},\n    cs::Union{AbstractSyntaxToken,AbstractFormula}...\n)\n    return ∨(c1, ∨(c2, c3, cs...))\nend\n\nSee also AbstractFormula, AbstractOperator.\n\n\n\n\n\n","category":"method"},{"location":"base/formulas/#SoleLogics.operators-Tuple{AbstractFormula}","page":"Formulas","title":"SoleLogics.operators","text":"tokens(f::AbstractFormula)::AbstractVector{<:AbstractSyntaxToken}\noperators(f::AbstractFormula)::AbstractVector{<:AbstractOperator}\npropositions(f::AbstractFormula)::AbstractVector{<:Proposition}\nntokens(f::AbstractFormula)::Integer\nnoperators(f::AbstractFormula)::Integer\nnpropositions(f::AbstractFormula)::Integer\n\nReturn the list or the number of (unique) syntax tokens/operators/propositions appearing in a formula.\n\nSee also AbstractSyntaxStructure.\n\n\n\n\n\n","category":"method"},{"location":"base/formulas/#SoleLogics.propositions-Tuple{AbstractFormula}","page":"Formulas","title":"SoleLogics.propositions","text":"tokens(f::AbstractFormula)::AbstractVector{<:AbstractSyntaxToken}\noperators(f::AbstractFormula)::AbstractVector{<:AbstractOperator}\npropositions(f::AbstractFormula)::AbstractVector{<:Proposition}\nntokens(f::AbstractFormula)::Integer\nnoperators(f::AbstractFormula)::Integer\nnpropositions(f::AbstractFormula)::Integer\n\nReturn the list or the number of (unique) syntax tokens/operators/propositions appearing in a formula.\n\nSee also AbstractSyntaxStructure.\n\n\n\n\n\n","category":"method"},{"location":"base/grammars/#Grammar","page":"Grammar","title":"Grammar","text":"","category":"section"},{"location":"base/grammars/","page":"Grammar","title":"Grammar","text":"SoleLogics.AbstractGrammar\n\nalphabet(g::SoleLogics.AbstractGrammar{A} where {A})\n\nBase.in(tok::SoleLogics.AbstractSyntaxToken, g::SoleLogics.AbstractGrammar)\n\npropositions","category":"page"},{"location":"base/grammars/#SoleLogics.AbstractGrammar","page":"Grammar","title":"SoleLogics.AbstractGrammar","text":"abstract type AbstractGrammar{A<:AbstractAlphabet,O<:AbstractOperator} end\n\nAbstract type for representing a context-free grammar based on a single alphabet of type A, and a set of operators that consists of all the (singleton) child types of O. A context-free grammar is a simple structure for defining formulas inductively.\n\nSee also alphabet, propositionstype, tokenstype, operatorstype, alphabettype, AbstractAlphabet, AbstractOperator.\n\n\n\n\n\n","category":"type"},{"location":"base/grammars/#SoleLogics.alphabet-Tuple{SoleLogics.AbstractGrammar{A} where A}","page":"Grammar","title":"SoleLogics.alphabet","text":"alphabet(g::AbstractGrammar{A} where {A})::A\n\nReturn the propositional alphabet of a grammar.\n\nSee also AbstractAlphabet, AbstractGrammar.\n\n\n\n\n\n","category":"method"},{"location":"base/grammars/#SoleLogics.propositions","page":"Grammar","title":"SoleLogics.propositions","text":"tokens(f::AbstractFormula)::AbstractVector{<:AbstractSyntaxToken}\noperators(f::AbstractFormula)::AbstractVector{<:AbstractOperator}\npropositions(f::AbstractFormula)::AbstractVector{<:Proposition}\nntokens(f::AbstractFormula)::Integer\nnoperators(f::AbstractFormula)::Integer\nnpropositions(f::AbstractFormula)::Integer\n\nReturn the list or the number of (unique) syntax tokens/operators/propositions appearing in a formula.\n\nSee also AbstractSyntaxStructure.\n\n\n\n\n\npropositions(t::SyntaxTree)::AbstractVector{Proposition}\n\nList all propositions appearing in a syntax tree.\n\nSee also npropositions, operators, tokens, Proposition.\n\n\n\n\n\npropositions(a::AbstractAlphabet)::AbstractVector{propositionstype(a)}\n\nList the propositions of a finite alphabet.\n\nSee also AbstractAlphabet, Base.isfinite.\n\n\n\n\n\n","category":"function"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = SoleLogics.jl\nDocTestSetup = quote\n    using SoleLogics\nend","category":"page"},{"location":"#SoleLogics","page":"Home","title":"SoleLogics","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Welcome to the documentation for SoleLogics.","category":"page"},{"location":"","page":"Home","title":"Home","text":"SoleLogics.jl provides a fresh codebase for computational logic, featuring easy manipulation of:","category":"page"},{"location":"","page":"Home","title":"Home","text":"Propositional and (multi)modal logics (propositions, logical constants, alphabet, grammars, crisp/fuzzy algebras);\nLogical formulas (random generation, parsing, minimization);\nLogical interpretations (e.g., propositional valuations, Kripke structures);\nAlgorithms for model checking, that is, checking that a formula is satisfied by an interpretation.","category":"page"},{"location":"","page":"Home","title":"Home","text":"SoleLogics.jl lays the logical foundations for Sole.jl, an open-source framework for symbolic machine learning.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [SoleModels]","category":"page"},{"location":"base/operators/#Operators","page":"Operators","title":"Operators","text":"","category":"section"},{"location":"base/operators/","page":"Operators","title":"Operators","text":"SoleLogics.AbstractOperator\n\nSoleLogics.iscommutative(::Type{SoleLogics.AbstractOperator})\n\noperators\n\nnoperators","category":"page"},{"location":"base/operators/#SoleLogics.AbstractOperator","page":"Operators","title":"SoleLogics.AbstractOperator","text":"abstract type AbstractOperator <: AbstractSyntaxToken end\n\nAn operator is a logical constant which establishes a relation between propositions (i.e., facts). For example, the boolean operators AND, OR and IMPLIES (stylized as ∧, ∨ and →) are used to connect propositions and/or formulas to express derived concepts.\n\nSince operators display very different algorithmic behaviors, all structs that are subtypes of AbstractOperator must be parametric singleton types, which can be dispatched upon.\n\nImplementation\n\nWhen implementing a new type for a commutative operator O with arity higher than 1, please provide a method iscommutative(::Type{O}). This can help model checking operations.\n\nSee also AbstractSyntaxToken, NamedOperator, check.\n\n\n\n\n\n","category":"type"},{"location":"base/operators/#SoleLogics.iscommutative-Tuple{Type{SoleLogics.AbstractOperator}}","page":"Operators","title":"SoleLogics.iscommutative","text":"iscommutative(::Type{AbstractOperator})\niscommutative(o::AbstractOperator) = iscommutative(typeof(o))\n\nReturn whether it is known that an AbstractOperator is commutative.\n\nExamples\n\njulia> iscommutative(∧)\ntrue\n\njulia> iscommutative(→)\nfalse\n\nNote that nullary and unary operators are considered commutative.\n\nSee also AbstractOperator.\n\nImplementation\n\nWhen implementing a new type for a commutative operator O with arity higher than 1, please provide a method iscommutative(::Type{O}). This can help model checking operations.\n\n\n\n\n\n","category":"method"},{"location":"base/operators/#SoleLogics.operators","page":"Operators","title":"SoleLogics.operators","text":"tokens(f::AbstractFormula)::AbstractVector{<:AbstractSyntaxToken}\noperators(f::AbstractFormula)::AbstractVector{<:AbstractOperator}\npropositions(f::AbstractFormula)::AbstractVector{<:Proposition}\nntokens(f::AbstractFormula)::Integer\nnoperators(f::AbstractFormula)::Integer\nnpropositions(f::AbstractFormula)::Integer\n\nReturn the list or the number of (unique) syntax tokens/operators/propositions appearing in a formula.\n\nSee also AbstractSyntaxStructure.\n\n\n\n\n\noperators(t::SyntaxTree)::AbstractVector{AbstractOperator}\n\nList all operators appearing in a syntax tree.\n\nSee also noperators, propositions, tokens, AbstractOperator.\n\n\n\n\n\n","category":"function"}]
}
