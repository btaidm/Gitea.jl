convertDateTime(dt::String) = DateTime(dt[1:end-1],"y-m-dTH:M:S")

module Tag

using Compat

immutable TagFormat{sym} end

macro tag_str(s)
	:(TagFormat{$(Expr(:quote, @compat Symbol(s)))})
end

const unknown_tf = TagFormat{:UNKNOWN}


macro tag(t)
	dump(t)
	println()

	isa(t,Expr) || error("Tagging can only happen on a type")

	isMut = t.args[1]
	tName = t.args[2]
	fields = Any[]
	tags = Dict{Symbol,Expr}()
	x = t.args[end].args
	i = 1
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
				tags[y.args[1].args[1]] = y.args[2]
			else
				push!(fields,y)
			end
		end
	end
	t.args[end].args = fields

	ret = quote
		$t
	end

	convertBlock = quote end
	for (field, tag) in tags
		if tag.head == :(:)
			tag = [tag]
		end
		for tagMarker in tag

		end
	end

	return ret
end

end