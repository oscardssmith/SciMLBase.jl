"""
IMPORTANT:

These types are used by the following packages, please notify with an issue if you need to
modify these structures:
- `SciML/MethodOfLines.jl`
"""

"""
$(TYPEDEF)

Solution to a PDE, solved from an ODEProblem generated by a discretizer.

## Fields
- `u`: the solution to the PDE, as a dictionary of symbols to Arrays of values. The
  Arrays are of the same shape as the domain of the PDE. Time is always the first axis.
- `original_sol`: The original ODESolution that was used to generate this solution.
- `t`: the time points corresponding to the saved values of the ODE solution.
- `ivdomain`: The full list of domains for the independent variables. May be a grid for a
  discrete solution, or a vector/tuple of tuples for a continuous solution.
- `ivs`: The list of independent variables for the solution.
- `dvs`: The list of dependent variables for the solution.
- `disc_data`: Metadata about the discretization process and type.
- `prob`: The ODEProblem that was used to generate this solution.
- `alg`: The algorithm used to solve the ODEProblem.
- `interp`: Interpolations for the solution.
- `retcode`: the return code from the solver. Used to determine whether the solver solved
  successfully, whether it terminated early due to a user-defined callback, or whether it
  exited due to an error. For more details, see
  [the return code documentation](https://docs.sciml.ai/SciMLBase/stable/interfaces/Solutions/#retcodes).
- `stats`: statistics of the solver, such as the number of function evaluations required.
"""
struct PDETimeSeriesSolution{T, N, uType, Disc, Sol, DType, tType, domType, ivType, dvType,
    P, A,
    IType, S} <: AbstractPDETimeSeriesSolution{T, N, uType, Disc}
    u::uType
    original_sol::Sol
    errors::DType
    t::tType
    ivdomain::domType
    ivs::ivType
    dvs::dvType
    disc_data::Disc
    prob::P
    alg::A
    interp::IType
    dense::Bool
    tslocation::Int
    retcode::ReturnCode.T
    stats::S
end

TruncatedStacktraces.@truncate_stacktrace PDETimeSeriesSolution 1 2

"""
Dispatch for the following function should be implemented in each discretizer package, for their relevant metadata type `D`.
"""
function (sol::PDETimeSeriesSolution{T, N, S, D})(args...; kwargs...) where {T, N, S, D}
    error(ArgumentError("Call for PDETimeSeriesSolution not implemented for solution metadata type $D, please post an issue on the relevant discretizer package's github page."))
end

"""
$(TYPEDEF)

Solution to a PDE, solved from an NonlinearProblem generated by a discretizer.

## Fields
- `u`: the solution to the PDE, as a dictionary of symbols to Arrays of values. The
  Arrays are of the same shape as the domain of the PDE. Time is always the first axis.
- `original_sol`: The original NonlinearSolution that was used to generate this solution.
- `ivdomain`: The full list of domains for the independent variables. May be a grid for a
  discrete solution, or a vector/tuple of tuples for a continuous solution.
- `ivs`: The list of independent variables for the solution.
- `dvs`: The list of dependent variables for the solution.
- `disc_data`: Metadata about the discretization process and type.
- `prob`: The NonlinearProblem that was used to generate this solution.
- `alg`: The algorithm used to solve the NonlinearProblem.
- `interp`: Interpolations for the solution.
- `retcode`: The return code from the solver. Used to determine whether the solver solved
  successfully (`sol.retcode === ReturnCode.Success`), whether it terminated due to a user-defined
  callback (`sol.retcode === ReturnCode.Terminated`), or whether it exited due to an error. For more
  details, see the return code section of the ODEProblem.jl documentation.
"""
struct PDENoTimeSolution{T, N, uType, Disc, Sol, domType, ivType, dvType, P, A,
    IType, S} <: AbstractPDENoTimeSolution{T, N, uType, Disc}
    u::uType
    original_sol::Sol
    ivdomain::domType
    ivs::ivType
    dvs::dvType
    disc_data::Disc
    prob::P
    alg::A
    interp::IType
    retcode::ReturnCode.T
    stats::S
end

TruncatedStacktraces.@truncate_stacktrace PDENoTimeSolution 1 2

const PDESolution{T, N, S, D} = Union{PDETimeSeriesSolution{T, N, S, D},
    PDENoTimeSolution{T, N, S, D}}

"""
Dispatch for the following function should be implemented in each discretizer package, for their relevant metadata type `D`.
"""
function (sol::PDENoTimeSolution{T, N, S, D})(args...; kwargs...) where {T, N, S, D}
    error(ArgumentError("Call for PDENoTimeSolution not implemented for solution metadata type $D, please post an issue on the relevant discretizer package's github page."))
end

"""
Intercept PDE wrapping. Please implement a method for the PDESolution types in your discretizer.
"""
function SciMLBase.wrap_sol(sol,
        metadata::AbstractDiscretizationMetadata{hasTime}) where {
        hasTime,
}
    if hasTime isa Val{true}
        return PDETimeSeriesSolution(sol, metadata)
    else
        return PDENoTimeSolution(sol, metadata)
    end
end

function Base.show(io::IO, m::MIME"text/plain", A::PDETimeSeriesSolution)
    println(io, string("retcode: ", A.retcode))
    println(io, string("Interpolation: "), typeof(A.interp))
    print(io, "t: ")
    show(io, m, A.t)
    print(io, "ivs: ")
    show(io, m, A.ivs)
    print(io, "domain:")
    show(io, m, A.ivdomain)
    println(io)
    print(io, "u: ")
    show(io, m, A.u)
end

function Base.show(io::IO, m::MIME"text/plain", A::PDENoTimeSolution)
    println(io, string("retcode: ", A.retcode))
    println(io, string("Interpolation: "), typeof(A.interp))
    print(io, "ivs: ")
    show(io, m, A.ivs)
    print(io, "domain:")
    show(io, m, A.ivdomain)
    println(io)
    print(io, "u: ")
    show(io, m, A.u)
end
