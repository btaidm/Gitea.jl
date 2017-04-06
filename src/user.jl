#################
### User Info ###
#################

getUserInfo(c::Client) = getParsedResponse(User,c,Requests.get,"/user")

getUserInfo(c::Client, user::String) = getParsedResponse(User,c,Requests.get,"/users/$(user)")

##########################
### Application Tokens ###
##########################

listAccessTokens(c::Client, user::String,pass::String) = getParsedResponse(Vector{AccessToken},c,Requests.get,"/users/$(user)/tokens"; headers = Dict("Authorization" => "Basic $(base64encode("$(user):$(pass)"))"))

function createAccessToken(c::Client,user::String,pass::String,name::String)
	data = Dict{String,Any}("name"=>name)
	headers = Dict("Authorization" => "Basic $(base64encode("$(user):$(pass)"))")
	getParsedResponse(AccessToken,c,Requests.post,"/users/$(user)/tokens"; headers = headers, json = data)
end

####################
### User E-mails ###
####################

function listEmails(c::Client)
	getParsedResponse(Vector{Email},c,Requests.get,"/user/emails")
end

addEmail(c::Client, emails::String) = addEmail(c,[emails])

function addEmail(c::Client, emails::Vector{String})
	data = Dict{String,Any}("emails"=>emails)
	getParsedResponse(Vector{Email},c,Requests.post,"/user/emails";json = data)
end

deleteEmail(c::Client, emails::String) = deleteEmail(c,[emails])

function deleteEmail(c::Client, emails::Vector{String})
	data = Dict{String,Any}("emails"=>emails)
	getResponse(c,Requests.delete,"/user/emails";json = data)
	nothing
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

follow(c::Client,target::String) = (getResponse(c, Requests.put, "/user/following/$(target)"); nothing)

unfollow(c::Client,target::String) = (getResponse(c, Requests.delete, "/user/following/$(target)"); nothing)

####################
### User GPG Key ###
####################

listGPGKeys(c::Client,user::String) = getParsedResponse(Vector{GPGKey},c,Requests.get,"/users/$(user)/gpg_keys")

listMyGPGKeys(c::Client) = getParsedResponse(Vector{GPGKey},c,Requests.get,"/user/gpg_keys")

getGPGKey(c::Client,id::Int64) = getParsedResponse(GPGKey,c,Requests.get,"/user/gpg_keys/$(id)")

function createPublicKey(c::Client,key::String)
	data = Dict{String,Any}("armored_public_key"=>key)
	return getParsedResponse(PublicKey,c,Requests.post,"/user/gpg_keys";json = data)
end

deleteGPGKey(c::Client,keyID::Int64) = (getResponse(c,Requests.delete,"/user/gpg_keys/$(keyID)"); nothing)

####################
### User SSH Key ###
####################

listPublicKeys(c::Client,user::String) = getParsedResponse(Vector{PublicKey},c,Requests.get,"/users/$(user)/keys")

listMyPublicKeys(c::Client) = getParsedResponse(Vector{PublicKey},c,Requests.get,"/user/keys")

getPublicKey(c::Client,keyID::Int64) = getParsedResponse(PublicKey,c,Requests.get,"/user/keys/$(keyID)")

function createPublicKey(c::Client,title::String,key::String)
	data = Dict{String,Any}("title"=>title,"key"=>key)
	return getParsedResponse(PublicKey,c,Requests.post,"/user/keys";json = data)
end

deletePublicKey(c::Client,keyID::Int64) = (getResponse(c,Requests.delete,"/user/keys/$(keyID)"); nothing)

