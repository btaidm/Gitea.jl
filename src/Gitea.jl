module Gitea

# package code goes here
import Requests
import HttpCommon

export Client

include("utils.jl")
include("errors.jl")
include("client.jl")
include("user.jl")

end # module
