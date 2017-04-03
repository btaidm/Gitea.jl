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
	merged::DataTime => json:"merged_at,format:y-m-dTH:M:SZ"
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
	closed::DataTime => json:"closed_at,format:y-m-dTH:M:SZ"
	deadline::DataTime => json:"due_on,format:y-m-dTH:M:SZ"
end

FieldTags.@tag immutable Issue
	id::Int64
	url::String
	index::Int64 => json:"number"
	poster::User => json:"user"
	title::String
	body::String
	labels::Vector{Label}
	milestone::Milestone
	assignee::User
	state::StateType
	comments::Int
	created::DateTime => json:"created_at,format:y-m-dTH:M:SZ"
	updated::DateTime => json:"updated_at,format:y-m-dTH:M:SZ"

	pullRequest::PullRequestMeta => json:"pull_request"
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

################
### Hook Payloads ###
################

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

immutable CommitPayload
	id::String
	message::String
	url::String
	author::UserPayload
	commiter::UserPayload
	verification::CommitVerificationPayload
	timestamp::DateTime => json:",format:y-m-dTH:M:SZ"
end

