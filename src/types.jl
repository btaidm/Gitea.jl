#################
### User Info ###
#################

"""
Gitea User
"""
FieldTags.@tag immutable User
	id::Int64
	userName::String => json:"login"
	fullName::String => json:"full_name"
	email::String => json:"email"
	avatarURL::String => json:"avatar_url"
end

##########################
### Application Tokens ###
##########################

"""
AccessToken represents a API access token.
"""
immutable AccessToken
	name::String
	sha1::String
end

####################
### User Email ###
####################

immutable Email
	email::String
	verified::Bool
	primary::Bool
end

####################
### User GPG Key ###
####################

immutable GPGKeyEmail
	email::String
	verified::Bool
end

FieldTags.@tag immutable GPGKey
	id::Int64
	primaryKeyID::String => json:"primary_key_id"
	keyID::String => json:"key_id"
	publicKey::String => json:"public_key"
	emails::Vector{GPGKeyEmail}
	subkeys::Vector{GPGKey}
	canSign::Bool => json:"can_sign"
	canEncryptComms::Bool => json:"can_encrypt_comms"
	canEncryptStorage::Bool => json:"can_encrypt_storage"
	canCertify::Bool => json:"can_certify"
	created::Nullable{DateTime} => json:"created_at,format:y-m-dTH:M:SZ"
	expires::Nullable{DateTime} => json:"expires_at,format:y-m-dTH:M:SZ"
end

####################
### User SSH Key ###
####################

FieldTags.@tag immutable PublicKey
	id::Int64
	key::String
	url::Nullable{String}
	title::Nullable{String}
	create::Nullable{DateTime} => json:"created_at,format:y-m-dTH:M:SZ"
end

##############
### Issues ###
##############

const StateType = String
const StateOpen = "open"
const StateClosed = "closed"

FieldTags.@tag immutable PullRequestMeta
	hasMerged::Bool => json:"merged"
	merged::DateTime => json:"merged_at,format:y-m-dTH:M:SZ"
end


FieldTags.@tag immutable Label
	id::Int64
	name::String
	color::String
	url::String
end


FieldTags.@tag immutable Milestone
	id::Int64
	title::String
	description::String
	state::StateType
	openIssues::Int => json:"open_issues"
	closedIssues::Int => json:"closed_issues"
	closed::Nullable{DateTime} => json:"closed_at,format:y-m-dTH:M:SZ"
	deadline::Nullable{DateTime} => json:"due_on,format:y-m-dTH:M:SZ"
end

FieldTags.@tag immutable Issue
	id::Int64
	url::String
	index::Int64 => json:"number"
	poster::User => json:"user"
	title::String
	body::String
	labels::Vector{Label}
	milestone::Nullable{Milestone}
	assignee::Nullable{User}
	state::StateType
	comments::Int
	created::DateTime => json:"created_at,format:y-m-dTH:M:SZ"
	updated::DateTime => json:"updated_at,format:y-m-dTH:M:SZ"

	pullRequest::Nullable{PullRequestMeta} => json:"pull_request"
end

FieldTags.@tag immutable Comment
	id::Int64
	htmlURL::String => json:"html_url"
	prURL::String => json:"pull_request_url"
	issueURL::String => json:"issue_url"
	poster::Nullable{User}
	body::String
	created::DateTime => json:"created_at,format:y-m-dTH:M:SZ"
	updated::DateTime => json:"updated_at,format:y-m-dTH:M:SZ"
end


####################
### Repositories ###
####################

immutable Permission
	admin::Bool
	push::Bool
	pull::Bool
end

FieldTags.@tag immutable Repository
	id::Int64
	owner::User
	name::String
	fullName::String => json:"full_name"
	description::String
	private::Bool
	fork::Bool
	mirror::Bool
	htmlURL::String => json:"html_url"
	sshURL::String => json:"ssh_url"
	cloneURL::String => json:"clone_url"
	website::String
	stars::Int => json:"stars_count"
	forks::Int => json:"forks_count"
	watchers::Int => json:"watchers_count"
	openIssues::Int => json:"open_issues_count"
	defaultBranch::String => json:"default_branch"
	created::DateTime => json:"created_at,format:y-m-dTH:M:SZ"
	updated::DateTime => json:"updated_at,format:y-m-dTH:M:SZ"
	permissions::Nullable{Permission}
end

##################
### Hook Types ###
##################

FieldTags.@tag immutable Hook
	id::Int64
	hookType::String => json:"type"
	url::Nullable{String}
	config::Dict{String,String}
	events::Vector{String}
	active::Bool
	created::DateTime => json:"created_at,format:y-m-dTH:M:SZ"
	updated::DateTime => json:"updated_at,format:y-m-dTH:M:SZ"
end

#####################
### Hook Payloads ###
#####################

immutable UserPayload
	name::String
	email::String
	username::String
end

immutable CommitVerificationPayload
	verified::Bool
	reason::String
	signature::String
	payload::String
end

FieldTags.@tag immutable CommitPayload
	id::String
	message::String
	url::String
	author::UserPayload
	committer::UserPayload
	verification::Nullable{CommitVerificationPayload}
	timestamp::DateTime => json:",format:y-m-dTH:M:SZ"
end

#########################
### Repository Branch ###
#########################

immutable Branch
	name::String
	commit::CommitPayload
end

#############################
### Repository Deploy Key ###
#############################

FieldTags.@tag immutable DeployKey
	id::Int64
	key::String
	url::String
	title::String
	created::DateTime => json:"created_at,format:y-m-dTH:M:SZ"
	readonly::Bool => json:"read_only"
end

####################
### Organization ###
####################

FieldTags.@tag immutable Organization
	id::Int64
	username::String
	fullName::String => json:"full_name"
	avatarURL::String => json:"avatar_url"
	description::String
	website::String
	location::String
end

immutable Team
	id::Int64
	name::String
	description::String
	permission::String
end

####################
### Pull Request ###
####################

FieldTags.@tag immutable PRBranchInfo
	name::String
	ref::String
	sha::String
	repoID::Int64 => json:"repo_id"
	repo::Nullable{Repository}
end

FieldTags.@tag immutable PullRequest
	id::Int64
	url::String
	index::Int64
	poster::Nullable{User} => json:"user"
	title::String
	body::String
	labels::Vector{Label}
	milestone::Nullable{Milestone}
	assignee::Nullable{User}
	state::StateType
	comments::Int

	htmlURL::String => json:"html_url"
	diffURL::String => json:"diff_url"
	patchURL::String => json:"patch_url"

	mergeable::Bool
	hasMerged::Bool
	merged::Nullable{DateTime} => json:"merged_at,format:y-m-dTH:M:SZ"
	mergedCommitID::Nullable{String} => json:"merge_commit_sha"
	mergedBy::Nullable{User} => json:"merged_by"

	base::Nullable{PRBranchInfo}
	head::Nullable{PRBranchInfo}
	mergeBase::String => json:"merge_base"
end

###############
### Release ###
###############

FieldTags.@tag immutable Release
	id::Int64
	tagName::String => json:"name"
	target::String => json:"target_commitish"
	title::String => json:"name"
	note::String => json:"body"
	url::String
	tarURL::String => json:"tarball_url"
	zipURL::String => json:"zipball_url"
	isDraft::Bool => json:"draft"
	isPrerelease::Bool => json:"prelease"
	createdAt::DateTime => json:"created_at,format:y-m-dTH:M:SZ"
	publishedAt::DateTime => json:"published_at,format:y-m-dTH:M:SZ"
	publisher::User => json:"author"
end

##############
### Status ###
##############

const StatusState = String
const StatusPending = "pending"
const StatusSuccess = "success"
const StatusError   = "error"
const StatusFailure = "failure"
const StatusWarning = "warning"

FieldTags.@tag immutable Status
	id::Int64
	state::StatusState
	targetURL::String => json:"target_url"
	description::String
	url::String
	context::String
	creator::User
	created::DateTime => json:"created_at,format:y-m-dTH:M:SZ"
	updated::DateTime => json:"updated_at,format:y-m-dTH:M:SZ"
end

FieldTags.@tag immutable CombinedStatus
	state::StatusState
	sha::String
	totalCount::Int => json:"total_count"
	statuses::Vector{Status}
	repository::Repository
	commitURL::String => json:"commit_url"
	url::String
end
