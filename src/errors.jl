
immutable GiteaError <: Exception
	code::Int64
	msg::Union{String,Vector{Dict{String,Any}},Dict{String,Any}}
end

function Base.show(io::IO,err::GiteaError)
    show(io, "Gitea Error: Error Code: $(err.code) Error Msg: $(JSON.json(err.msg))")
end