convertDateTime(dt::String) = DateTime(dt[1:end-1],"y-m-dTH:M:S")

module FieldTags

using Compat

export @tag, queryTag


typealias TagDict Dict{Symbol,Dict{Symbol,Any}}

const tagRegistry = Dict{Symbol,TagDict}()

macro tag(t)
	# dump(t)
	# println()

	isa(t,Expr) || error("Tagging can only happen on a type")

	isMut = t.args[1]
	tName = t.args[2]
	# if isa(tName,Expr)
	# 	tName.head != :curly && error("Type Name is not a curly type")
	# 	tName = tName.args[1]
	# end
	fields = Any[]
	tTags = Dict{Symbol,Expr}()
	x = t.args[end].args
	for y in x
		if isa(y, LineNumberNode) || (isa(y,Expr) && y.head == :line)
			# line number node
			continue
		else isa(y,Expr)
			# println(y)
			# dump(y)
			# println()
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
	typeTags = tagRegistry[Symbol(T)]
	return get(typeTags,tagName,Dict{Symbol,Any}())
end

function queryTag(sym::Symbol, tagName::Symbol)
	typeTags = tagRegistry[sym]
	return get(typeTags,tagName,Dict{Symbol,Any}())
end

end


@generated marshalJSON{T}(data::T) = marshalJSON_impl(data)

function marshalJSON_impl(T)
	if T <: Union{Number,AbstractString,}
		return :(data)
	elseif T <: Vector
		return :(map(marshalJSON,data))
	elseif T <: Dict{String}
		return :(Dict( (k=>marshalJSON(v) for (k,v) in data)))
	else
		tagData = try
				FieldTags.queryTag(getfield(T.name.module,T.name.name),:json)
		catch
			FieldTags.TagDict()
		end
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

			for fArg in fArgString
				fA = split(fArg,':'; limit = 2)
				if length(fA) == 1
					fArgs[fA[1]] = Nullable{String}()
				elseif length(fA) == 2
					fArgs[fA[1]] = fA[2]
				end
			end



			if fType <: Nullable

				if fType.parameters[1] <: Dates.TimeType
					dFormat = get(get(fArgs,"format",Nullable{String}("y-m-dTH:M:S")))
					setexpr = :(Dates.format(get(getfield(data,Symbol($f))),$dFormat))
				else
					setexpr = :(marshalJSON(get(getfield(data,Symbol($f)))))
				end
				expr = quote
					$expr
					!isnull(getfield(data,Symbol($f))) && (jsonData[$(fName)] = $(setexpr))
				end
			else

				if fType <: Dates.TimeType
					dFormat = get(get(fArgs,"format",Nullable{String}("y-m-dTH:M:S")))
					setexpr = :(Dates.format(getfield(data,Symbol($f)),$dFormat))
				else
					setexpr = :(marshalJSON(getfield(data,Symbol($f))))
				end

				expr = quote
					$expr
					jsonData[$(fName)] = $setexpr
				end
			end
		end
	end
	return quote
		$expr
		return jsonData
	end
end

@generated unmarshalJSON{T}(::Type{T},data) = unmarshalJSON_impl(T,data)

function unmarshalJSON_impl{T}(::Type{T},data)
	if T <: Union{Number,AbstractString}
		return :(data)
	elseif T <: Vector
		return :(map( x -> unmarshalJSON(eltype(T),x),data))
	else
		tagData = try
			FieldTags.queryTag(getfield(T.name.module,T.name.name),:json)
		catch
			FieldTags.TagDict()
		end

		exprs = Expr[]
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
			fArgs = Dict{String,Nullable{String}}()

			for fArg in fArgString
				fA = split(fArg,':'; limit = 2)
				if length(fA) == 1
					fArgs[fA[1]] = Nullable{String}()
				elseif length(fA) == 2
					fArgs[fA[1]] = fA[2]
				end
			end


			if fType <: Nullable


				if fType.parameters[1] <: Dates.TimeType
					dFormat = get(get(fArgs,"format",Nullable{String}("y-m-dTH:M:S")))
					getexpr = :($(fType.parameters[1])(data[$fName],$(dFormat)))
				else
					getexpr = :(unmarshalJSON($(fType.parameters[1]),data[$fName]))
				end

				expr = quote
					haskey(data,$fName) ? $(getexpr) : Nullable{$(fType.parameters[1])}()
				end
				push!(exprs,expr);
			else

				if fType <: Dates.TimeType
					dFormat = get(get(fArgs,"format",Nullable{String}("y-m-dTH:M:S")))
					getexpr = :($(fType)(data[$fName],$(dFormat)))
				else
					getexpr = :(unmarshalJSON($(fType),data[$fName]))
				end

				expr = getexpr
				push!( exprs, expr)
			end
		end
	end
	return quote
		return $(T)($(exprs...))
	end
end

