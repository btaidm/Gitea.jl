convertDateTime(dt::String) = DateTime(dt[1:end-1],"y-m-dTH:M:S")

module FieldTags

using Compat

export @tag, queryTag


typealias TagDict Dict{Symbol,Dict{Symbol,Any}}

const tagRegistry = Dict{Symbol,TagDict}()

macro tag(t)
	dump(t)
	println()

	isa(t,Expr) || error("Tagging can only happen on a type")

	isMut = t.args[1]
	tName = t.args[2]
	fields = Any[]
	tTags = Dict{Symbol,Expr}()
	x = t.args[end].args
	for y in x
		if isa(y, LineNumberNode) || (isa(y,Expr) && y.head == :line)
			# line number node
			continue
		else isa(y,Expr)
			println(y)
			dump(y)
			println()
			if y.head == :(=>)
				push!(fields,y.args[1])
				tTags[y.args[1].args[1]] = y.args[2]
			else
				push!(fields,y)
			end
		end
	end
	t.args[end].args = fields

	tagDict = Dict{Symbol,Dict{Symbol,Any}}()

	for (value,tags) in tTags
		if tags.head == :(:)
			tags = (tags,)
		end

		for tag in tags
			tagData = get(tagDict,tag.args[1],Dict{Symbol,Any}())
			tagData[value] = tag.args[2]
			tagDict[tag.args[1]] = tagData
		end
	end

	tagRegistry[Symbol(module_name(current_module()),".",tName)] = tagDict

	return t
end

function queryTag{T}(::Type{T}, tagName::Symbol)
	println(Symbol(T))
	typeTags = tagRegistry[Symbol(T)]
	return get(typeTags,tagName,Dict{Symbol,Any}())
end

end


marshallJSON{T}(data::T) = marshallJSON_impl(data)

@generated function marshallJSON_impl{T}(data::T)
	if T <: Union{Number,AbstractString}
		return :(data)
	elseif T <: Vector
		return :(map(marshallJSON,data))
	else
		tagData = FieldTags.queryTag(T,:json)
		exprs = Expr[]
		fields = fieldnames(T)

		if isempty(fieldnames)
			error("Invalid Type")
		end

		for field in fields
			fType = fieldtype(T,field)
			fArgString = split(get(tagData,field,""),',')

			fName = isspace(fArgString[1]) ? String(fName) : fArgString[1]
			shift!(fArgString)
			fArgs = Dict{String,Any}()

			for arg in fArgString
				sarg = split(arg,':')
				if length(sarg) == 1
					fArgs[sarg[1]] = nothing

			end


			if fType <: Nullable

			else
				push!(exprs,
					quote
						"$(fName)" => getfield(data,field)
					end
				)
			end
		end
end

unmarshallJSON{T}(::Type{T},data) = marshallJSON_impl(T,data)

@generated function unmarshallJSON_impl{T}(::Type{T},data)
	FieldTags.queryTag(typeof(data),:json)
end