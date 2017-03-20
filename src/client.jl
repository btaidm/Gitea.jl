

immutable Client
	url::String
	auth::Union{String,Tuple{String,String}}

	Client(url,auth) = new(rstrip(url,'/'),auth)

end

function Client(url::String, user::String, password::String)
	return Client(url,(user,password))
end

function doRequest(c::Client,method::Function, path::String; kwargs...)
	kwargsDict = Dict{String,Any}(string(k) => v for (k,v) in kwargs)
	
	url = c.url * "/api/v1" * path


	if isa(c.auth,String) && !haskey(get(kwargsDict,"headers",Dict{String,String}()),"Authorization")
		get!(kwargsDict,"headers",Dict{String,String}())["Authorization"] = "token $(c.auth)"
	else
		replace(url,"://","://$(c.auth[1]):$(c.auth[2])@",1)
	end

	return method(url; Dict(Symbol(k) => v for (k,v) in kwargsDict)...)
end

function getResponse(c::Client, method::Function, path::String; kwargs...)
	resp = doRequest(c,method,path;kwargs...)

	status = Requests.statuscode(resp)
	status == 401 && throw(GiteaError(status,HttpCommon.STATUS_CODES[status]))
	status == 403 && throw(GiteaError(status,HttpCommon.STATUS_CODES[status]))
	status == 404 && throw(GiteaError(status,HttpCommon.STATUS_CODES[status]))

	if status÷100 != 2
		errMap = Requests.json(resp)
		throw(GiteaError(status,errMap["message"]))
	end

	return resp
end

function getParsedResponse{T}(::Type{T}, c::Client, method::Function, path::String;kwargs...)
	resp = getResponse(c,method,path;kwargs...)
	JSON.print(Requests.json(resp),2)
	return convert(T,Requests.json(resp))
end

function getStatusCode(c::Client, method::Function, path::String; kwargs...)
	return Requests.status(doRequest(c,method,path;kwargs...))
end