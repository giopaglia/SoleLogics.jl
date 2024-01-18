module SoleLogics

import Base: show
using DataStructures
using Dictionaries
using PrettyTables
using Random
using StatsBase
using Reexport
using Lazy

############################################################################################

export iscrisp, isfinite, isnullary, isunary, isbinary

export Syntactical, Connective,
    Formula, AbstractSyntaxStructure, SyntaxTree, SyntaxLeaf,
    Atom, Truth, SyntaxBranch

export Operator, SyntaxToken

export syntaxstring

export arity, valuetype, tokentype, tokenstype,
        atomstype, operatorstype, truthtype,
        associativity, precedence
export value, token, children, formulas
export tree

export tokens, ntokens, atoms, natoms, truths, ntruths, leaves, nleaves,
        connectives, nconnectives, operators, noperators, height
export composeformulas

export interpret, check

include("core.jl")

############################################################################################

export AlphabetOfAny, ExplicitAlphabet

export alphabet
export domain, top, bot, grammar, algebra, logic

include("logics.jl")

############################################################################################

export TOP, ⊤
export BOT, ⊥
export BooleanTruth
export istop, isbot

export NamedConnective, CONJUNCTION, NEGATION, DISJUNCTION, IMPLICATION
export ∧, ¬, ∨, →

export BooleanAlgebra

export BaseLogic

include("base-logic.jl")

############################################################################################

export propositionallogic

export TruthDict, DefaultedTruthDict
export truth_table

include("propositional-logic.jl")

############################################################################################

export accessibles
export ismodal, modallogic

export DIAMOND, BOX, ◊, □
export DiamondRelationalConnective, BoxRelationalConnective
export diamond, box
export globaldiamond, globalbox

export KripkeStructure
export truthtype, worldtype

export AbstractWorld

export AbstractWorlds, Worlds

export Interval, Interval2D, OneWorld

include("modal-logic.jl")

############################################################################################

export LeftmostLinearForm, LeftmostConjunctiveForm, LeftmostDisjunctiveForm, Literal

export subformulas, normalize

export CNF, DNF, cnf

include("syntax-utils.jl")

############################################################################################

export HeytingTruth, HeytingAlgebra
export label, index
export domain, top, bot, graph
export precedes, succeedes, precedeq, succedeq
export collatetruth
export @heytingtruths, @heytingalgebra

export iscomplete

include("fuzzy.jl")

############################################################################################

include("interpretation-sets.jl")

############################################################################################

export parseformula

include("parse.jl")

############################################################################################

export randbaseformula, randformula
export randframe, randmodel

include("random.jl")

############################################################################################

export AnchoredFormula

include("anchored-formula.jl")

############################################################################################

export @atoms, @synexpr

include("ui.jl")

############################################################################################

include("experimentals.jl")

############################################################################################

include("deprecate.jl")

############################################################################################

include("utils.jl")

############################################################################################

end
