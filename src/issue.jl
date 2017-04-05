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

listIssueComments(c::Client,owner::String, repo::String, index::Int64) = getParsedResponse(Vector{Comment},c,Requests.get,"/repos/$(owner)/$(repo)/issues/$(index)/comments")

listRepoComments(c::Client,owner::String, repo::String) = getParsedResponse(Vector{Comment},c,Requests.get,"/repos/$(owner)/$(repo)/issues/comments")

createIssueComment(c::Client,owner::String, repo::String, index::Int64,body::String) = getParsedResponse(Comment,c,Requests.post,"/repos/$(owner)/$(repo)/issues/$(index)/comments"; json = Dict("body" => body))

editIssueComment(c::Client,owner::String, repo::String, index::Int64, commentID::Int64, body::String) = getParsedResponse(Comment,c,Requests.patch,"/repos/$(owner)/$(repo)/issues/$(index)/comments/$(commentID)"; json = Dict("body" => body))

deleteIssueComment(c::Client,owner::String, repo::String, index::Int64, commentID::Int64) = ( getResponse(c,Requests.delete,"/repos/$(owner)/$(repo)/issues/$(index)/comments/$(commentID)"); nothing)


####################
### Issue Labels ###
####################

listRepoLabels(c::Client, owner::String, repo::String) = getParsedResponse(Vector{Label},c,Requests.get,"/repos/$(owner)/$(repo)/labels")

listRepoLabel(c::Client, owner::String, repo::String, index::Int64) = getParsedResponse(Label,c,Requests.get,"/repos/$(owner)/$(repo)/labels/$(index)")

createLabel(c::Client, owner::String, repo::String, name::String, color::String) = getParsedResponse(Label,c,Requests.post,"/repos/$(owner)/$(repo)/labels"; json = Dict("name" => name, "color" => color))

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

editLabel(c::Client, owner::String, repo::String, index::Int64, opt::EditLabelOption) = getParsedResponse(Issue,c,Requests.patch,"/repos/$(owner)/$(repo)/labels/$(index)"; json = marshalJSON(opt))

deleteLabel(c::Client,owner::String, repo::String, index::Int64, commentID::Int64) = ( getResponse(c,Requests.delete,"/repos/$(owner)/$(repo)/labels/$(index)"); nothing)

getIssueLabels(c::Client, owner::String, repo::String, index::Int64) = getParsedResponse(Vector{Label},c,Requests.get,"/repos/$(owner)/$(repo)/issues/$(index)/labels")

addIssueLabels(c::Client, owner::String, repo::String, index::Int64, labels::Vector{Int64}) = getParsedResponse(Vector{Label},c,Requests.post,"/repos/$(owner)/$(repo)/issues/$(index)/labels"; json = Dict("labels" => labels))

replaceIssueLabels(c::Client, owner::String, repo::String, index::Int64, labels::Vector{Int64}) = getParsedResponse(Vector{Label},c,Requests.put,"/repos/$(owner)/$(repo)/issues/$(index)/labels"; json = Dict("labels" => labels))

deleteIssueLabel(c::Client,owner::String, repo::String, index::Int64, label::Int64) = ( getResponse(c,Requests.delete,"/repos/$(owner)/$(repo)/issues/$(index)/labels/$(issues)"); nothing)

deleteIssueLabels(c::Client,owner::String, repo::String, index::Int64) = ( getResponse(c,Requests.delete,"/repos/$(owner)/$(repo)/issues/$(index)/labels"); nothing)


########################
### Issue Milestones ###
########################

listRepoMilestones(c::Client, owner::String, repo::String) = getParsedResponse(Vector{Milestone},c,Requests.get,"/repos/$(owner)/$(repo)/milestones")

listRepoMilestone(c::Client, owner::String, repo::String, index::Int64) = getParsedResponse(Milestone,c,Requests.get,"/repos/$(owner)/$(repo)/milestones/$(index)")

FieldTags.@tag immutable CreateMilestoneOption
	title::String
	description::Nullable{String}
	deadline::Nullable{DateTime} => json:"due_on,format:y-m-dTH:M:SZ"
end

function CreateMilestoneOption(title;kwargs...)
	kwargsDict = Dict{Symbol,Any}(k=>v for (k,v) in kwargs)
	args = Any[title]

	for field in fieldnames(CreateMilestoneOption)[2:end]
		push!(args,get(kwargsDict,field, fieldtype(CreateMilestoneOption,field)()))
	end
	CreateMilestoneOption(args...)
end

createMilestone(c::Client, owner::String, repo::String, opt::CreateMilestoneOption) = getParsedResponse(Milestone,c,Requests.post,"/repos/$(owner)/$(repo)/milestones"; json = marshalJSON(opt))

FieldTags.@tag immutable EditMilestoneOption
	title::Nullable{String}
	description::Nullable{String}
	state::String
	deadline::Nullable{DateTime} => json:"due_on,format:y-m-dTH:M:SZ"
end

function EditMilestoneOption(;kwargs...)
	kwargsDict = Dict{Symbol,Any}(k=>v for (k,v) in kwargs)
	args = Any[]

	for field in fieldnames(EditMilestoneOption)
		push!(args,get(kwargsDict,field, fieldtype(EditMilestoneOption,field)()))
	end
	EditMilestoneOption(args...)
end

editMilestone(c::Client, owner::String, repo::String, index::Int64, opt::EditMilestoneOption) = getParsedResponse(Issue,c,Requests.patch,"/repos/$(owner)/$(repo)/milestones/$(index)"; json = marshalJSON(opt))

deleteMilestone(c::Client,owner::String, repo::String, index::Int64, commentID::Int64) = ( getResponse(c,Requests.delete,"/repos/$(owner)/$(repo)/milestones/$(index)"); nothing)