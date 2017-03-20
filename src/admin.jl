############################
### Administration Users ###
############################

immutable CreateUserOption
	userName::String
	email::String
	sourceID::Int64
	fullName::Nullable{String}
	loginName::Nullable{String}
	password::Nullable{String}
	sendNotify::Nullable{Bool}
end

function CreateUserOption(userName::String,email::String;sourceID::Int64 = 1, kwargs...)
	kwargsDict = Dict{Symbol,Any}(k=>v for (k,v) in kwargs)
end

function adminCreateUser(c::Client,userOpt::CreateUserOption)

end