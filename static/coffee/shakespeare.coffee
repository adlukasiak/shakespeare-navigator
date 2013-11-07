# parse a spec and create a visualization view
parse_details = (spec, data) ->  
  
  vg.parse.spec spec, (chart) ->
    view = chart
      el: "#vis_details"
      data: data
      renderer: "svg"
    .on "mouseover", (event, item) ->
      # invoke hover properties on cousin one hop forward in scenegraph
      if (item.mark.marktype != "rect") then return # want to ignore everything but the rectangle
      view.update
        props: "hover"
        items: item
    .on "mouseout", (event, item) ->
      # reset cousin item, using animated transition
      if (item.mark.marktype != "rect") then return # want to ignore everything but the rectangle
      view.update
        props: "update"
        items: item
    .update()
    

# parse a spec and create a visualization view
parse_details_2 = (spec) ->  
  
  vg.parse.spec spec, (chart) ->
    view = chart
      el: "#vis_details_2"
      renderer: "svg"
    .on "mouseover", (event, item) ->
      # invoke hover properties on cousin one hop forward in scenegraph
      if (item.mark.marktype != "rect") then return # want to ignore everything but the rectangle
      view.update
        props: "hover"
        items: item
    .on "mouseout", (event, item) ->
      # reset cousin item, using animated transition
      if (item.mark.marktype != "rect") then return # want to ignore everything but the rectangle
      view.update
        props: "update"
        items: item
    .update()

# parse a spec and create a visualization view
parse_details_4 = (data) ->  
  console.log "parse_details_4"
  svg = dimple.newSvg("#vis_details_4",300,400)
  myChart = new dimple.chart(svg, data)
  myChart.setBounds(52, 10, 170, 148)
  x = myChart.addCategoryAxis("x", "paragraph_num")
  y = myChart.addMeasureAxis("y", "word_count")
  x.addOrderRule("paragraph_num");
  myChart.addSeries(null, dimple.plot.bar)
  x.tickFormat = d3.format ".0f"
  myChart.draw()
  x.titleShape.text "Bins"
  y.titleShape.text "Frequency"



# parse a spec and create a visualization view
generate_png = (spec) ->  
  console.log "Woohoo"
  # $.ajax
  #   url: spec
  #   success: (data) ->
  #     console.log "Successful AJAX"

  s = "<img class='inline' src='#{spec}' />"
  console.log s
  $("#vis_details_3 img").replaceWith(s)

# parse a spec and create a visualization view
parse_works = (spec, data) ->
  vg.parse.spec spec, (chart) -> 
    view = chart
      el: "#vis_works"
      data: data
      renderer: "svg"
    .on "mouseover", (event, item) ->
      # invoke hover properties on cousin one hop forward in scenegraph
      if (item.mark.marktype != "rect") then return # want to ignore everything but the rectangle
      view.update
        props: "hover"
        items: item.cousin(1)
    .on "mouseout", (event, item) ->
      # reset cousin item, using animated transition
      if (item.mark.marktype != "rect") then return # want to ignore everything but the rectangle
      view.update
        props: "update"
        items: item.cousin(1)
        duration: 250
    .on "click", (event, item) ->
      # get details for the work
      if (item.mark.marktype != "rect") then return # want to ignore everything but the rectangle
      work_id = indexData.table[item.key].work_id
      console.log "work_id #{work_id}"
      filters = [
        "name": "work_id"
        "op": "eq"
        "val": work_id
      ]

      $.ajax
        # url: 'http://localhost:5000/api/paragraph'
        url: '/api/paragraph'
        data: {"q": JSON.stringify({"filters": filters})}
        dataType: "json"
        contentType: "application/json"
        success: (data) ->
          console.log "data in callback is " , data
          d = (obj.word_count for obj in data.objects)  
          data = 
            table: utils.histogram_(d)
          data2 = 
            utils.histogram_(d)
          parse_details("static/vincent_details.json", data)
          #Solution 1: use created on the client histogram but convert to simple json table
          parse_details_4(data2)

      # parse_details_2("http://localhost:5000/api/hist/#{work_id}.json")
      parse_details_2("/api/hist/#{work_id}.json")
      # generate_png("http://localhost:5000/api/hist/#{work_id}.svg")
      generate_png("/api/hist/#{work_id}.svg")
      #Solution 2: create histogram on the server with tsv
      #parse_details_4("/api/hist/#{work_id}.tsv")
      #Solution 3: create histogram on the server with simple json table
      #parse_details_4("/api/hist/#{work_id}_simple_json.json")

      view.update
        props: "update"
        items: item.cousin(1)
        duration: 250

    .update()

indexData = 0

order_by = [
  "field": "year"
  "direction": "asc"
]

$.ajax
  # url: 'http://localhost:5000/api/work'
  url: '/api/work'
  data: {"q": JSON.stringify({"order_by": order_by})}
  dataType: "json"
  contentType: "application/json"
  success: (data) ->
    data =
      table: data.objects
    parse_works("static/vincent_works.json", data)
    indexData = data
