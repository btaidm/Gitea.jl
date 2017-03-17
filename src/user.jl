
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

end