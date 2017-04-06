###########################
### Basic Pull Requests ###
###########################

listRepoPullRequests(c::Client,owner::String,repo::String,page::Int,state::String) =  getParsedResponse(Vector{PullRequest},c,Requests.get,"/repos/$(owner)/$(repo)/pulls"; json = Dict("page" => page, "state" => state))

getPullRequest(c::Client,owner::String,repo::String,index::Int) =  getParsedResponse(PullRequest,c,Requests.get,"/repos/$(owner)/$(repo)/pulls/$(index)")

FieldTags.@tag immutable CreatePullRequestOption
	title::String
	head::String
	base::String
	body::Nullable{String}
	assignee::Nullable{String}
	milestone::Nullable{Int64}
	labels::Nullable{Vector{Int64}}
end

function CreatePullRequestOption(title, head, base; kwargs...)
	kwargsDict = Dict{Symbol,Any}(k=>v for (k,v) in kwargs)

	args = Any[title,head,base]

	for field in fieldnames(CreatePullRequestOption)[4:end]
		push!(args,get(kwargsDict,field, fieldtype(CreatePullRequestOption,field)()))
	end

	CreatePullRequestOption(args...)
end

createPullRequest(c::Client,owner::String,repo::String,opt::CreatePullRequestOption) =  getParsedResponse(PullRequest,c,Requests.post,"/repos/$(owner)/$(repo)/pulls"; json = marshalJSON(opt))

FieldTags.@tag immutable EditPullRequestOption
	title::Nullable{String}
	body::Nullable{String}
	assignee::Nullable{String}
	milestone::Nullable{Int64}
	labels::Nullable{Vector{Int64}}
	state::Nullable{String}
end

function EditPullRequestOption(;kwargs...)
	kwargsDict = Dict{Symbol,Any}(k=>v for (k,v) in kwargs)

	args = Any[]

	for field in fieldnames(EditPullRequestOption)[1:end]
		push!(args,get(kwargsDict,field, fieldtype(EditPullRequestOption,field)()))
	end

	EditPullRequestOption(args...)
end

editPullRequest(c::Client,owner::String,repo::String,index::Int, opt::EditPullRequestOption) =  getParsedResponse(PullRequest,c,Requests.patch,"/repos/$(owner)/$(repo)/pulls/$(index)"; json = marshalJSON(opt))

mergePullRequest(c::Client,owner::String,repo::String,index::Int) =  getParsedResponse(PullRequest,c,Requests.post,"/repos/$(owner)/$(repo)/pulls/$(index)/merge")

function isPullRequestMerged(c::Client, user::String, repo::String, index::String)
	code = getStatusCode(c,Requests.get,"/repos/$(user)/$(repo)/pulls/$(index)/merge")
	return code == 204
end
