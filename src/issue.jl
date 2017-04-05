############################
### Base Issue Functions ###
############################

listIssue(c::Client, page::Int64, state::String = "") = getParsedResponse(Vector{Issue},c,Requests.get,"/issues?page=$(page)")

listUserIssue(c::Client, page::Int64, state::String = "") = getParsedResponse(Vector{Issue},c,Requests.get,"/user/issues?page=$(page)")

listRepoIssues(c::Client,owner::String, repo::String, page::Int64, state::String = "") = getParsedResponse(Vector{Issue},c,Requests.get,"/repos/$(owner)/$(repo)/issues?page=$(page)")

getIssue(c::Client,owner::String, repo::String, index::Int64) = getParsedResponse(Issue,c,Requests.get,"/repos/$(owner)/$(repo)/issues/$(index)")


FieldTags.@tag immutable CreateIssueOption
	title::String
	body::Nullable{String}
	assignee::Nullable{String}
	milestone::Nullable{Int64}
	labels::Nullable{Vector{Int64}}
	closed::Nullable{Bool}
end

function CreateIssueOption(title; kwargs...)
	kwargsDict = Dict{Symbol,Any}(k=>v for (k,v) in kwargs)

	args = Any[title]

	for field in fieldnames(CreateIssueOption)[2:end]
		push!(args,get(kwargsDict,field, fieldtype(CreateIssueOption,field)()))
	end

	CreateIssueOption(args...)
end

createIssue(c::Client,owner::String,repo::String,opt::CreateIssueOption) = getParsedResponse(Issue,c,Requests.post,"/repos/$(owner)/$(repo)/issues"; json = marshalJSON(opt))

FieldTags.@tag immutable EditIssueOption
	title::Nullable{String}
	body::Nullable{String}
	assignee::Nullable{String}
	milestone::Nullable{Int64}
	state::Nullable{String}
end

function EditIssueOption(;kwargs...)
	kwargsDict = Dict{Symbol,Any}(k=>v for (k,v) in kwargs)
	args = Any[]

	for field in fieldnames(EditIssueOption)
		push!(args,get(kwargsDict,field, fieldtype(EditIssueOption,field)()))
	end
	EditIssueOption(args...)
end

editIssue(c::Client,owner::String,repo::String, index::Int64, opt::EditIssueOption) = getParsedResponse(Issue,c,Requests.patch,"/repos/$(owner)/$(repo)/issues/$(index)"; json = marshalJSON(opt))


######################
### Issue Comments ###
######################

listIssueComments(c,owner::String, repo::String, index::Int64) = getParsedResponse(Vector{Comment},c,Requests.get,"/repos/$(owner)/$(repo)/issues/$(index)/comments")

listRepoComments(c,owner::String, repo::String) = getParsedResponse(Vector{Comment},c,Requests.get,"/repos/$(owner)/$(repo)/issues/comments")

createIssueComment(c,owner::String, repo,index::Int64,body::String) = getParsedResponse(Comment,c,Requests.post,"/repos/$(owner)/$(repo)/issues/$(index)/comments"; json = Dict("body" = body))

editIssueComment(c,owner::String, repo,index::Int64, commentID::Int64, body::String) = getParsedResponse(Comment,c,Requests.patch,"/repos/$(owner)/$(repo)/issues/$(index)/comments/$(commentID)"; json = Dict("body" = body))

deleteIssueComment(c,owner::String, repo,index::Int64, commentID::Int64) = ( getResponse(c,Requests.delete,"/repos/$(owner)/$(repo)/issues/$(index)/comments/$(commentID)"); nothing)


####################
### Issue Labels ###
####################

listRepoLabels(c, owner::String, repo::String) = getParsedResponse(Vector{Label},c,Requests.get,"/repos/$(owner)/$(repo)/labels")

listRepoLabel(c, owner::String, repo::String, index::Int64) = getParsedResponse(Vector{Label},c,Requests.get,"/repos/$(owner)/$(repo)/labels/$(index)")

createLabel(c, owner::String, repo::String, name::String, color::String) = getParsedResponse(Label,c,Requests.post,"/repos/$(owner)/$(repo)/labels"; json = Dict("name" = name, "color" = color))

FieldTags.@tag immutable EditLabelOption
	name::Nullable{String}
	color::Nullable{String}
end

function EditLabelOption(;kwargs...)
	kwargsDict = Dict{Symbol,Any}(k=>v for (k,v) in kwargs)
	args = Any[]

	for field in fieldnames(EditLabelOption)
		push!(args,get(kwargsDict,field, fieldtype(EditLabelOption,field)()))
	end
	EditLabelOption(args...)
end

editLabel(c::Client,owner::String,repo::String, index::Int64, opt::EditLabelOption) = getParsedResponse(Issue,c,Requests.patch,"/repos/$(owner)/$(repo)/labels/$(index)"; json = marshalJSON(opt))
