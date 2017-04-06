listMyRepos(c::Client) = getParsedResponse(Vector{Repository},c,Requests.get,"/user/repos")

listUserRepos(c::Client, user::String) = getParsedResponse(Vector{Repository},c,Requests.get,"/user/$(user)/repos")

listOrgRepos(c::Client, org::String) = getParsedResponse(Vector{Repository},c,Requests.get,"/orgs/$(org)/repos")

FieldTags.@tag immutable CreateRepoOption
	name::String
	description::Nullable{String}
	private::Nullable{Bool}
	autoInit::Nullable{Bool} => json:"auto_init"
	gitignores::Nullable{String}
	license::Nullable{String}
	readme::Nullable{String}
end

function CreateRepoOption(name; kwargs...)
	kwargsDict = Dict{Symbol,Any}(k=>v for (k,v) in kwargs)

	args = Any[name]

	for field in fieldnames(CreateRepoOption)[2:end]
		push!(args,get(kwargsDict,field, fieldtype(CreateRepoOption,field)()))
	end

	CreateRepoOption(args...)
end

createRepo(c::Client,opt::CreateRepoOption) = getParsedResponse(Repository,c,Requests.post,"/user/repos"; json = marshalJSON(opt))
createOrgRepo(c::Client, org::String, opt::CreateRepoOption) = getParsedResponse(Repository,c,Requests.post,"/org/$(org)/repos"; json = marshalJSON(opt))

getRepo(c::Client, owner::String, repo::String) = getParsedResponse(Repository,c,Requests.get,"/repos/$owner/$repo")

getRepo(c::Client, owner::User, repo::String) = getRepo(c,owner.userName,repo)

getRepo(c::Client, index::Int) = getParsedResponse(Repository,c,Requests.get,"/repositories/$(index)")

deleteRepo(c::Client, owner::String, repo::String) = (getResponse(c,Requests.delete,"/repos/$owner/$repo"); nothing)

deleteRepo(c::Client, owner::User, repo::String) = deleteRepo(c,owner.userName,repo)

deleteRepo(c::Client, repo::Repository) = deleteRepo(c,repo.owner,repo.name)


FieldTags.@tag immutable MigrateRepoOption
	cloneAddr::String => json:"clone_addr"
	uid::Int
	repoName::String
	authUsername::Nullable{String} => json:"auth_username"
	authPassword::Nullable{String} => json:"auth_password"
	mirror::Nullable{Bool}
	private::Nullable{Bool}
	description::Nullable{String}
end
 function MigrateRepoOption(cloneAddr,uid,name; kwargs...)
	kwargsDict = Dict{Symbol,Any}(k=>v for (k,v) in kwargs)

	args = Any[cloneAddr,uid,name]

	for field in fieldnames(MigrateRepoOption)[4:end]
		push!(args,get(kwargsDict,field, fieldtype(MigrateRepoOption,field)()))
	end

	MigrateRepoOption(args...)
end


migrateRepo(c::Client, opt::MigrateRepoOption) = getParsedResponse(Repository,c,Requests.post,"/repos/migrate"; json = marshalJSON(opt))

################
### Branches ###
################

listRepoBranches(c::Client, user::String, repo::String) = getParsedResponse(Vector{Branch},c,Requests.get,"/repos/$(user)/$(repo)/branches")

listRepoBranches(c::Client, repo::Repository) = listRepoBranches(c,repo.owner.userName,repo.name)

getRepoBranch(c::Client, user::String, repo::String, branch::String) = getParsedResponse(Branch,c,Requests.get,"/repos/$(user)/$(repo)/branches/$(branch)")

getRepoBranch(c::Client, repo::Repository, branch::String) = listRepoBranches(c,repo.owner.userName,repo.name,branch)

####################
### Collaborator ###
####################

listCollaborators(c::Client, user::String, repo::String) = getParsedResponse(Vector{User},c,Requests.get,"/repos/$(user)/$(repo)/collaborators")

function isCollaborator(c::Client, user::String, repo::String, collaborator::String)
	code = getStatusCode(c,Requests.get,"/repos/$(user)/$(repo)/collaborators/$(collaborator)")
	return code == 204
end

function addCollaborator(c::Client, user::String, repo::String, collaborator::String, permission::String)
	data = Dict("permission" => permission)
	getResponse(c,Requests.post,"/repos/$(user)/$(repo)/collaborators/$(collaborator)";json = data)
	return nothing
end

deleteCollaborator(c::Client, user::String, repo::String, collaborator::String) = (getResponse(Repository,c,Requests.delete,"/repos/$(user)/$(repo)/collaborators/$(collaborator)"); nothing)

############
### File ###
############

function getFile(c::Client, user::String, repo::String, ref::String, tree::String)
	f = getResponse(c,Requests.get,"/repos/$(user)/$(repo)/raw/$(ref)/$(tree)")
	IOBuffer(Requests.bytes(f))
end

getFile(c::Client, repo::Repository, ref::String, tree::String) = listRepoBranches(c,repo.owner.userName,repo.name,ref,tree)


##################
### Deploy Key ###
##################

listDeployKeys(c::Client, user::String, repo::String) = getParsedResponse(Vector{DeployKey},c,Requests.get,"/repos/$(user)/$(repo)/keys")

getDeployKey(c::Client, user::String, repo::String, keyID::Int64) = getParsedResponse(DeployKey,c,Requests.get,"/repos/$(user)/$(repo)/keys/$(keyID)")

function createDeployKey(c::Client, user::String, repo::String, title::String, key::String)
	data = Dict("title" => title, "key" => key)
	getParsedResponse(DeployKey,c,Requests.put,"/repos/$(user)/$(repo)/keys"; json = data)
end

deleteDeployKey(c::Client, user::String, repo::String, keyID::Int64) = (getResponse(c,Requests.delete,"/repos/$(user)/$(repo)/keys/$(keyID)"); nothing)


