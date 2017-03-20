
"""
Gitea User
"""
immutable User
	ID::Int64
	userName::String
	fullName::String
	email::String
	avatarURL::String
end

function Base.convert(::Type{User}, data::Dict{String,Any})
	id = data["id"]
	userName = get(data,"login",data["username"])
	fullName = data["full_name"]
	email = data["email"]
	avatarURL = data["avatar_url"]
	return User(id,userName,fullName,email,avatarURL)
end

getUserInfo(c::Client, user::String) = getParsedResponse(User,c,Requests.get,"/users/$(user)")


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

function Base.convert(::Type{AccessToken}, data::Dict{String,Any})
	return AccessToken(data["name"],data["sha1"])
end

listAccessTokens(c::Client, user::String,pass::String) = getParsedResponse(Vector{AccessToken},c,Requests.get,"/users/$(user)/tokens"; headers = Dict("Authorization" => "Basic $(base64encode("$(user):$(pass)"))"))

function createAccessToken(c::Client,user::String,pass::String,name::String)
	data = Dict{String,Any}("name"=>name)
	headers = Dict("Authorization" => "Basic $(base64encode("$(user):$(pass)"))")
	getParsedResponse(AccessToken,c,Requests.post,"/users/$(user)/tokens"; headers = headers, json = data)
end

####################
### User E-mails ###
####################

immutable Email
	email::String
	verified::Bool
	primary::Bool
end

function Base.convert(::Type{Email}, data::Dict{String,Any})
	return Email(data["email"],data["verified"],data["primary"])
end

function listEmails(c::Client)
	getParsedResponse(Vector{Email},c,Requests.get,"/user/emails")
end

function addEmail(c::Client, emails::Vector{String})
	data = Dict{String,Any}("emails"=>emails)
	getParsedResponse(Vector{Email},c,Requests.post,"/user/emails";json = data)
end

function deleteEmail(c::Client, emails::Vector{String})
	data = Dict{String,Any}("emails"=>emails)
	getResponse(c,Requests.delete,"/user/emails";json = data)
end

###################
### User Follow ###
###################

listMyFollowers(c::Client,page::Int) = getParsedResponse(Vector{User},c,Requests.get,"/user/followers?page=$(page)")

listFollowers(c::Client,user::String, page::Int) = getParsedResponse(Vector{User},c,Requests.get,"/users/$(users)/followers?page=$(page)")

listMyFollowing(c::Client,page::Int) = getParsedResponse(Vector{User},c,Requests.get,"/user/following?page=$(page)")

listFollowing(c::Client,user::String, page::Int) = getParsedResponse(Vector{User},c,Requests.get,"/user/$(users)/following?page=$(page)")

function isFollowing(c::Client,target::String)
	try
		getResponse(c,Requests.get,"/user/following/$(target)")
	catch
		return false
	end
	return true
end

function isUserFollowing(c::Client,user::String, target::String)
	try
		getResponse(c,Requests.get,"/user/$(users)/following/$(target)")
	catch
		return false
	end
	return true
end

follow(c::Client,target::String) = getResponse(c, Requests.put, "/user/following/$(target)")

unfollow(c::Client,target::String) = getResponse(c, Requests.delete, "/user/following/$(target)")


####################
### User GPG Key ###
####################

immutable GPGKeyEmail
	email::String
	verified::Bool
end

immutable GPGKey
	ID::Int64
	primaryKeyID::String
	keyID::String
	publicKey::String
	emails::Vector{GPGKeyEmail}
	subsKey::Vector{GPGKey}
	canSign::Bool
	canEncryptComms::Bool
	canEncryptStorage::Bool
	canCertify::Bool
	created::DateTime
	expires::DateTime
end

function Base.convert(::Type{GPGKeyEmail}, data::Dict{String,Any})
	return GPGKeyEmail(data["email"],data["verified"])
end

function Base.convert(::Type{GPGKey}, data::Dict{String,Any})
	error("Not Implemented Yet")
end

####################
### User SSH Key ###
####################

immutable PublicKey
	id::Int64
	key::String
	url::Nullable{String}
	title::Nullable{String}
	create::Nullable{DateTime}
end

function Base.convert(::Type{PublicKey}, data::Dict{String,Any})
	id =data["id"]
	key = data["key"]
	url = get(data,"url",Nullable{String}())
	title = get(data,"title",Nullable{String}())
	create = begin
		if haskey(data,"created_at")
			DateTime(data["created_at"][1:end-1],"y-m-dTH:M:S")
		else
			Nullable{DateTime}()
		end
	end
	return PublicKey(id,key,url,title,create)
end

listPublicKeys(c::Client,user::String) = getParsedResponse(Vector{PublicKey},c,Requests.get,"/user/$(user)/keys")

listMyPublicKeys(c::Client) = getParsedResponse(Vector{PublicKey},c,Requests.get,"/user/keys")

getPublicKey(c::Client,keyID::Int64) = getParsedResponse(PublicKey,c,Requests.get,"/user/keys/$(keyID)")

function createPublicKey(c::Client,title::String,key::String)
	data = Dict{String,Any}("title"=>title,"key"=>key)
	return getParsedResponse(PublicKey,c,Requests.post,"/user/keys";json = data)
end

deletePublicKey(c::Client,keyID::Int64) = getResponse(c,Requests.delete,"/user/keys/$(keyID)")