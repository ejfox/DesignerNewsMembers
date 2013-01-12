dn = []
dn.nodes = []
dn.links = []

makeDNViz = () ->
	#d3.json("json/dn_tree.flat.r1.json", (error, json) ->
	d3.json("https://news.layervault.com/u/tree_flat.json", (error, json) ->
		if(error)
			console.warn("ERROR", error);

		data = json;
		makeForceLayout(data)
	)

makeForceLayout = (data) ->
	width = $("#network").width();
	height = $("#network").height();

	r = 6

	makeLinks(data)

	force = d3.layout.force()
		.gravity(0.35)
		.charge((d) ->
			defaultCharge = -200
			console.log (d)
			if d.invited_by_id isnt null
				if d.invited_by_id is 2
					-500
				else
					defaultCharge
			else
				defaultCharge
		)
		.linkDistance((d) ->
			if d.target.id is 1
				80
			else if d.target.id is 2
				80
			else
				2
		)
		.linkStrength(1.6)
		.theta(.6)
		.friction(0.85)
		.size([width, height])

	svg = d3.select("#network")

	link = svg.selectAll("line.link")
	.data(dn.links)
	.enter().append("line")
	.attr("class", "link")
		.style({
			"stroke-width": 1
			"stroke": "#2D72D9"
			"stroke-dasharray": "2, 3"
			opacity: 0.5
			})

	node = svg.selectAll(".node")
		.data(data)
		.enter().append("svg:g")
		.attr("class", "node")
		.attr("id", (d) -> d.id - 1)
		.call(force.drag)
		.on("click", (d) ->
			#alert("CLICKED")
			window.open("https://news.layervault.com/u/"+d.id)
		)

	label = node.append("g").attr("class", "label")
	.append("svg:text")
	.text((d) ->
		d.display_name;
	)
	.attr({
		"text-anchor": "start",
		"dx": r*2.5
		"dy": ".4em"
		"id": (d,i) -> "label"+i
	})
	#.style("opacity", 0)





	circle = node.append("svg:circle")
			.attr("r", r)
			.style({
				"fill": (d) ->
					if d.id is 1
						"red"
					else if d.id is 2
						"red"
					else
						"#2D72D9"
			})

	force.nodes(data)
		.on("tick", () ->
			###circle.attr("cx", (d) -> d.x = Math.max(r, Math.min(width - r, d.x)) )
			.attr("cy", (d) -> d.y = Math.max(r, Math.min(width - r, d.y)) )
			###

			node.attr("transform", (d) ->
				# If the node isn't in the bottom portion of the height
				if d.y < height - (height * 0.25)

					# If the user is an early user, make their node rise
					if d.id < 25
						d.y = d.y - .1

					# Cause a node to fall in relation to how early the user joined
					d.y = d.y + ( d.id / 400)

				# Keep nodes from leaving viewing area
				newx = d.x = Math.max(r+6, Math.min(width - r, d.x))
				newy = d.y = Math.max(r+6, Math.min(height - 40, d.y))

				"translate(" + newx + "," + newy + ")"

			)

			link.attr("x1", (d) -> return d.source.x)
			.attr("y1", (d) -> return d.source.y)
			.attr("x2", (d) -> return d.target.x)
			.attr("y2", (d) -> return d.target.y);
		)
		.links(dn.links)
		.start()

	return force

makeLinks = (data) ->
	_.each(data, (row, index) ->
		console.log("r>",row.id + " > " + row.invited_by_id)
		if row.invited_by_id isnt null
			dn['links'].push({"source": index, "target": row.invited_by_id-1, "value": 1})
	)
	console.log dn.links

allLabelsOn = false
$("#labels-toggle").on("click", () ->
	if allLabelsOn
		$("#content").removeClass("labels-on")
		$("#content").addClass("labels-off")

		allLabelsOn = false
	else
		$("#content").addClass("labels-on")
		$("#content").removeClass("labels-off")
		allLabelsOn = true
)
