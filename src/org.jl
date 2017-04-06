###########################
### Basic Organizations ###
###########################

listMyOrgs(c::Client) = getParsedResponse(Vector{Organization},c,Requests.get,"/user/orgs")

listUserOrgs(c::Client, user::String) = getParsedResponse(Vector{Organization},c,Requests.get,"/users/$(user)/orgs")

getOrg(c::Client,org::String) = getParsedResponse(Organization,c,Requests.get,"/orgs/$(org)")

FieldTags.@tag immutable CreateOrgOption
	orgName::String => json:"username"
	fullName::Nullable{String} => json:"full_name"
	description::Nullable{String}
	website::Nullable{String}
	location::Nullable{String}
end

function CreateOrgOption(username; kwargs...)
	kwargsDict = Dict{Symbol,Any}(k=>v for (k,v) in kwargs)

	args = Any[username]

	for field in fieldnames(CreateOrgOption)[2:end]
		push!(args,get(kwargsDict,field, fieldtype(CreateOrgOption,field)()))
	end

	CreateOrgOption(args...)
end


FieldTags.@tag immutable EditOrgOption
	fullName::Nullable{String} => json:"full_name"
	description::Nullable{String}
	website::Nullable{String}
	location::Nullable{String}
end

function EditOrgOption(;kwargs...)
	kwargsDict = Dict{Symbol,Any}(k=>v for (k,v) in kwargs)

	args = Any[]

	for field in fieldnames(EditOrgOption)[1:end]
		push!(args,get(kwargsDict,field, fieldtype(EditOrgOption,field)()))
	end

	EditOrgOption(args...)
end

editOrg(c::Client,orgname::String,opt::EditOrgOption) = getParsedResponse(Organization,c,Requests.patch,"/orgs/$(orgname)"; json = marshalJSON(opt))

################################
### Organizations Membership ###
################################

## TODO: Bug Gitea Devs for member ship API examples

addOrgMembership(c::Client,orgname::String,user::String,role::String) = ( error("Gitea API broken"); getResponse(c,Requests.put,"/orgs/$(orgname)/members/$(user)"; json = Dict("role"=>role)); nothing)


