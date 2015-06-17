mesice = <[leden únor březen duben květen červen červenec srpen září říjen listopad prosinec]>
ig.doCeny = ->
  container = d3.select ig.containers.base
  data = d3.tsv.parse ig.data.ceny, (row) ->
    row.benzin = parseFloat row.natural
    row.diesel = parseFloat row.nafta
    row.rok = parseInt row.rok, 10
    row.tyden = parseInt row.tyden, 10
    row.x = row.rok + row.tyden / 51
    # row.date = new Date!
    #   ..setTime 0
    #   ..setFullYear row.rok
    #   ..setDate row.tyden * 7
    # row.time = row.date.getTime!
    row
  container = container.append \div
    ..attr \class \ceny
  width = container.node!.clientWidth - 10
  height = container.node!.clientHeight - 10
  margin = top:0 right:19 bottom:20 left:50

  svg = container.append \svg
    ..attr \class \ceny
    ..attr \width width
    ..attr \height height

  width -= margin.left + margin.right
  height -= margin.top + margin.bottom

  drawing = svg.append \g
    ..attr \transform "translate(#{margin.left},#{margin.top})"

  xScale = d3.scale.linear!
    ..domain [data.0.x, data[*-1].x]
    ..range [-1 width]
  yScale = d3.scale.linear!
    ..domain [22 39]
    ..range [height, 0]

  dieselLine = d3.svg.line!
    ..x -> xScale it.x
    ..y -> yScale it.diesel

  benzinLine = d3.svg.line!
    ..x -> xScale it.x
    ..y -> yScale it.benzin
  dieselPath = drawing.append \path .datum data
    ..attr \class "line diesel"
    ..attr \d dieselLine

  benzinPath = drawing.append \path .datum data
    ..attr \class "line benzin"
    ..attr \d benzinLine

  xAxis = d3.svg.axis!
    ..scale xScale
    ..orient \bottom
    ..tickSize 6, 1
    ..tickValues [2005 to 2015].map ->
      new Date!
        ..setTime 0
        ..setFullYear it
    ..tickFormat -> it.getFullYear!
  svg.append \g
    ..attr \class "axis x"
    ..attr \transform "translate(#{margin.left}, #{margin.top + height})"
    ..call xAxis

  yAxis = d3.svg.axis!
    ..scale yScale
    ..orient \left
    ..tickFormat -> it + " Kč"
    ..tickSize 6, 1
  svg.append \g
    ..attr \class "axis y"
    ..attr \transform "translate(#{margin.left}, #{margin.top})"
    ..call yAxis
  tipArea = container.append \div
    ..attr \class \tip-area

  svg.on \mousemove ->
    x = xScale.invert d3.event.x - margin.left
    diff = Infinity
    for datum in data
      d = Math.abs datum.x - x
      if diff > d
        diff = d
      else
        break
    {date, diesel, benzin} = datum
    date = "#{datum.tyden}. týden #{datum.rok}"
    tipArea.html "<b>#{date}</b><br> <span class='benzin'>Benzin: <b>#{ig.utils.formatNumber benzin, 2} Kč</b></span><span class='diesel'>Nafta: <b>#{ig.utils.formatNumber diesel, 2} Kč</b></span>"
    moveLine datum

  line = drawing.append \g
    ..attr \transform "translate(-200,0)"
    ..attr \class \highlight-line
    ..append \line
      ..attr \x1 0
      ..attr \y1 0
      ..attr \x2 0
      ..attr \y2 height
  dieselLinePoint = line.append \circle
    ..attr \class \diesel
    ..attr \r 3
  benzinLinePoint = line.append \circle
    ..attr \class \benzin
    ..attr \r 3
  moveLine = (datum) ->
    x = Math.round xScale datum.x
    if x < 0 or x > width
      x = -200
    line.attr \transform "translate(#x,0)"
    dieselLinePoint.attr \cy yScale datum.diesel
    benzinLinePoint.attr \cy yScale datum.benzin
