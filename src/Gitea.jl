module Gitea

# package code goes here
import Requests
import HttpCommon
import JSON

export Client

DEBUG = false


include("utils.jl")
include("errors.jl")
include("client.jl")

# Types
include("types.jl")

# Functions
include("user.jl")
include("repo.jl")
include("issue.jl")
include("pull.jl")
include("org.jl")
include("release.jl")
include("status.jl")
include("hook.jl")
include("miscellaneous.jl")

# include("admin.jl")

end # module
