// Generated by CoffeeScript 1.3.3
var allLabelsOn, dn, makeDNViz, makeForceLayout, makeLinks;

dn = [];

dn.nodes = [];

dn.links = [];

makeDNViz = function() {
  return d3.json("https://news.layervault.com/u/tree_flat.json", function(error, json) {
    var data;
    if (error) {
      console.warn("ERROR", error);
    }
    data = json;
    return makeForceLayout(data);
  });
};

makeForceLayout = function(data) {
  var circle, force, height, label, link, node, r, svg, width;
  width = $("#network").width();
  height = $("#network").height();
  r = 7;
  makeLinks(data);
  force = d3.layout.force().gravity(0.5).charge(function(d) {
    var defaultCharge;
    defaultCharge = -330;
    console.log(d);
    if (d.invited_by_id !== null) {
      if (d.invited_by_id === 2) {
        return -540;
      } else {
        return defaultCharge;
      }
    } else {
      return defaultCharge;
    }
  }).linkDistance(function(d) {
    if (d.target.id === 1) {
      return 50;
    } else if (d.target.id === 2) {
      return 50;
    } else {
      return 2;
    }
  }).linkStrength(1.6).theta(.5).friction(0.6).size([width, height]);
  svg = d3.select("#network");
  link = svg.selectAll("line.link").data(dn.links).enter().append("line").attr("class", "link").style({
    "stroke-width": 1,
    "stroke": "#2D72D9",
    "stroke-dasharray": "2, 3",
    opacity: 0.5
  });
  node = svg.selectAll(".node").data(data).enter().append("svg:g").attr("class", "node").attr("id", function(d) {
    return d.id - 1;
  }).call(force.drag).on("click", function(d) {
    return window.open("https://news.layervault.com/u/" + d.id);
  });
  label = node.append("g").attr("class", "label").append("svg:text").text(function(d) {
    return d.display_name + " (" + d.id + ")";
  }).attr({
    "text-anchor": "start",
    "dx": r * 2.5,
    "dy": ".4em",
    "id": function(d, i) {
      return "label" + i;
    }
  });
  circle = node.append("svg:circle").attr("r", r).style({
    "fill": function(d) {
      if (d.id === 1) {
        return "red";
      } else if (d.id === 2) {
        return "red";
      } else {
        return "#2D72D9";
      }
    }
  });
  force.nodes(data).on("tick", function() {
    /*circle.attr("cx", (d) -> d.x = Math.max(r, Math.min(width - r, d.x)) )
    			.attr("cy", (d) -> d.y = Math.max(r, Math.min(width - r, d.y)) )
    */
    node.attr("transform", function(d) {
      var newx, newy;
      if (d.y < height - (height * 0.25)) {
        if (d.id < 25) {
          d.y = d.y - .1;
        }
        d.y = d.y + (d.id / 400);
      }
      newx = d.x = Math.max(r + 6, Math.min(width - r, d.x));
      newy = d.y = Math.max(r + 6, Math.min(height - 40, d.y));
      return "translate(" + newx + "," + newy + ")";
    });
    return link.attr("x1", function(d) {
      return d.source.x;
    }).attr("y1", function(d) {
      return d.source.y;
    }).attr("x2", function(d) {
      return d.target.x;
    }).attr("y2", function(d) {
      return d.target.y;
    });
  }).links(dn.links).start();
  return force;
};

makeLinks = function(data) {
  _.each(data, function(row, index) {
    console.log("r>", row.id + " > " + row.invited_by_id);
    if (row.invited_by_id !== null) {
      return dn['links'].push({
        "source": index,
        "target": row.invited_by_id - 1,
        "value": 1
      });
    }
  });
  return console.log(dn.links);
};

allLabelsOn = false;

$("#labels-toggle").on("click", function() {
  if (allLabelsOn) {
    $("#content").removeClass("labels-on");
    $("#content").addClass("labels-off");
    return allLabelsOn = false;
  } else {
    $("#content").addClass("labels-on");
    $("#content").removeClass("labels-off");
    return allLabelsOn = true;
  }
});
