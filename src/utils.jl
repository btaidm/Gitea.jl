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
	if isa(tName,Expr)
		tName.head != :curly && error("Type Name is not a curly type")
		tName = tName.args[1]
	end
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
	currentMod = current_module()
	if currentMod != Main
		tagRegistry[Symbol(module_name(currentMod),".",tName)] = tagDict
	else
		tagRegistry[Symbol(tName)] = tagDict
	end

	return esc(t)
end

function queryTag{T}(::Type{T}, tagName::Symbol)
	println(Symbol(T))
	typeTags = tagRegistry[Symbol(T)]
	return get(typeTags,tagName,Dict{Symbol,Any}())
end

function queryTag(sym::Symbol, tagName::Symbol)
	println(sym)
	typeTags = tagRegistry[sym]
	return get(typeTags,tagName,Dict{Symbol,Any}())
end

end


@generated marshallJSON{T}(data::T) = marshallJSON_impl(data)

function marshallJSON_impl(T)
	println(T)
	if T <: Union{Number,AbstractString}
		return :(data)
	elseif T <: Vector
		return :(map(marshallJSON,data))
	else
		tagData = FieldTags.queryTag(T.name.name,:json)
		expr = quote
		jsonData = Dict{String,Any}()
		end
		fields = fieldnames(T)

		if isempty(fields)
			error("Invalid Type")
		end

		for field in fields
			fType = fieldtype(T,field)
			fArgString = split(get(tagData,field,""),',')
			f = string(field)

			fName = isspace(fArgString[1]) ? f : fArgString[1]
			shift!(fArgString)
			fArgs = Dict{String,Any}()
			if fType <: Nullable
				expr = quote
					$expr
					!isnull(getfield(data,:($field))) && jsonData[$(fName)] = marshallJSON(get(getfield(data,Symbol($f))))
				end
			else
				expr = quote
					$expr
					jsonData[$(fName)] = marshallJSON(getfield(data, Symbol($f) ))
				end
			end
		end
	end
	return quote
		$expr
		return jsonData
	end
end

@genarated unmarshallJSON{T}(::Type{T},data) = unmarshallJSON_impl(T,data)

function unmarshallJSON_impl{T}(::Type{T},data)
	println(T," ", data)

end