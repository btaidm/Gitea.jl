####################
### Repositories ###
####################

immutable Permission
	admin::Bool
	push::Bool
	pull::Bool
end

function Base.convert(::Type{Permission},data::Dict{String,Any})
	return Permission(data["admin"],data["push"],data["pull"])
end

immutable Repository
	id::Int64
	owner::User
	name::String
	fullName::String
	description::String
	private::Bool
	fork::Bool
	mirror::Bool
	htmlURL::String
	sshURL::String
	cloneURL::String
	website::String
	stars::Int
	forks::Int
	watchers::Int
	openIssues::Int
	defaultBranch::String
	created::DateTime
	updated::DateTime
	permissions::Nullable{Permission}
end

function Base.convert(::Type{Repository},data::Dict{String,Any})
	id = data["id"]
	owner = data["owner"]
	name = data["name"]
	fullName = data["full_name"]
	description = data["description"]
	private = data["private"]
	fork = data["fork"]
	mirror = data["mirror"]
	htmlURL = data["html_url"]
	sshURL = data["ssh_url"]
	cloneURL = data["clone_url"]
	website = data["website"]
	stars = data["stars_count"]
	forks = data["forks_count"]
	watchers = data["watchers_count"]
	openIssues = data["open_issues_count"]
	defaultBranch = data["default_branch"]
	created = convertDateTime(data["created_at"])
	updated = convertDateTime(data["updated_at"])
	permissions = get(data,"permissions",Nullable{Permission}())
	return Repository(id,owner,name,fullName,description,private,fork,mirror,htmlURL,sshURL,cloneURL,website,stars,forks,watchers,openIssues,defaultBranch,created,updated,permissions)
end


listMyRepos(c::Client) = getParsedResponse(Vector{Repository},c,Requests.get,"/user/repos")

listUserRepos(c::Client, user::String) = getParsedResponse(Vector{Repository},c,Requests.get,"/user/$(user)/repos")

listOrgRepos(c::Client, org::String) = getParsedResponse(Vector{Repository},c,Requests.get,"/orgs/$(org)/repos")

immutable createRepoOption
	name::String
	description::String
	private::Bool
	autoInit::Bool
	gitignores::String
	license::String
	readme::String
end

function createRepo(c::Client,opt::createRepoOption)
	data = Dict{String,Any}
	data["name"] = opt.name
	data["description"] = opt.description
	data["auto_init"] = opt.autoInit
	data["gitignores"] = opt.gitignores
	data["license"] = opt.license
	data["readme"] = opt.readme

	return getParsedResponse(Repository,c,Requests.post,"/user/repos"; json = data)
end

function createOrgRepo(c::Client,org::String, opt::createRepoOption)
	data = Dict{String,Any}
	data["name"] = opt.name
	data["description"] = opt.description
	data["auto_init"] = opt.autoInit
	data["gitignores"] = opt.gitignores
	data["license"] = opt.license
	data["readme"] = opt.readme

	return getParsedResponse(Repository,c,Requests.post,"/org/$(org)/repos"; json = data)
end