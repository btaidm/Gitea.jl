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
	typeTags = get(tagRegistry, Symbol(T), TagDict())
	return get(typeTags,tagName,Dict{Symbol,Any}())
end

end


marshallJSON{T}(data::T) = marshallJSON_impl(data)

@generated function marshallJSON_impl(data)
	FieldTags.queryTag(typeof(data),:json)




end

unmarshallJSON{T}(t::Type{T},data) = marshallJSON_impl(t,data)

@generated function marshallJSON_impl{T}(::Type{T},data)
	FieldTags.queryTag(typeof(data),:json)

	

	
end