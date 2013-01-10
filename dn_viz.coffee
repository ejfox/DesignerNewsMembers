dn = []
dn.nodes = []
dn.links = []

makeDNViz = () ->
	d3.json("json/dn_tree.flat.r1.json", (error, json) ->
	#d3.json("https://news.layervault.com/u/tree_flat.json", (error, json) ->
		if(error)
			console.warn("ERROR", error);

		data = json;
		makeForceLayout(data)
	)

makeForceLayout = (data) ->
	width = $("#network").width();
	height = $("#network").height();

	r = 5

	makeLinks(data)

	force = d3.layout.force()
		.gravity(0.1)
		.charge(-135)
		.linkDistance((d) ->
			if d.target.id is 1
				150
			else if d.target.id is 2
				120
			else
				10
		)
		.linkStrength(1.3)
		.theta(.6)
		.friction(0.65)
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
			})

	node = svg.selectAll(".node")
		.data(data)
		.enter().append("svg:g")
		.attr("class", "node")
		.attr("id", (d) -> d.id)
		.call(force.drag)

	label = node.append("g").attr("class", "label")
	.append("svg:text")
	.text((d) ->
		d.display_name;
	)
	.attr({
		"text-anchor": "middle",
		"dy": r*2.5
	})





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
				newx = d.x = Math.max(r, Math.min(width - r, d.x))
				newy = d.y = Math.max(r, Math.min(width - r, d.y))

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
