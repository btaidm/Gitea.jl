
immutable GiteaError <: Exception
	code::Int64
	msg::Union{String,Vector{Dict{String,Any}},Dict{String,Any}}
end

function Base.show(io::IO,err::GiteaError)
	if isa(err.msg,String)
		msg = err.msg
	elseif isa(err.msg,Vector)
		msg = err.msg[1]["message"]
	else
		msg = err.msg["message"]
	end
	print(io, "Gitea Error:\tError Code: $(err.code)\tError Msg: \"$(JSON.json(err.msg))\"")

end