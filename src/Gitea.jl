module Gitea

# package code goes here
import Requests
import HttpCommon
import JSON

export Client

include("utils.jl")
include("errors.jl")
include("client.jl")
include("user.jl")
include("repo.jl")
include("admin.jl")

end # module
