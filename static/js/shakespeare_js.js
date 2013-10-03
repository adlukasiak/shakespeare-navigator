var data = {table: [
  {"x": 1,  "y": 28}, {"x": 2,  "y": 55},
  {"x": 3,  "y": 43}, {"x": 4,  "y": 91},
  {"x": 5,  "y": 81}, {"x": 6,  "y": 53},
  {"x": 7,  "y": 19}, {"x": 8,  "y": 87},
  {"x": 9,  "y": 52}, {"x": 10, "y": 48},
  {"x": 11, "y": 24}, {"x": 12, "y": 49},
  {"x": 13, "y": 87}, {"x": 14, "y": 66},
  {"x": 15, "y": 17}, {"x": 16, "y": 27},
  {"x": 17, "y": 68}, {"x": 18, "y": 16},
  {"x": 19, "y": 49}, {"x": 20, "y": 75}
]};

// parse a spec and create a visualization view
function parse(spec) {
  vg.parse.spec(spec, function(chart) { 
    // var view = chart({el:"#view", data:data});    
    // var view = chart({el:"#vis", renderer:"svg"}).update();
    var view = chart({el:"#vis", renderer:"svg"});
    // view.on("mouseover", function(event, item) { console.log(item); 
    view
    .on("mouseover", function(event, item) {
      // invoke hover properties on cousin one hop forward in scenegraph
      view.update({
        props: "hover",
        items: item.cousin(1)
      });
    })
    .on("mouseout", function(event, item) {
      // reset cousin item, using animated transition
      view.update({
        props: "update",
        items: item.cousin(1),
        duration: 250,
        ease: "linear"
      });
    })
    .update();  
  //   })
  });
}


// parse a spec and create a visualization view
function parse_details(spec, data) {  
  console.log(data);
  vg.parse.spec(spec, function(chart) { 
    // var view = chart({el:"#view", data:data});    
    // var view = chart({el:"#vis", renderer:"svg"}).update();
    var view = chart({el:"#vis_details", data:data, renderer:"svg"});
    // view.on("mouseover", function(event, item) { console.log(item); 
    view
    .on("mouseover", function(event, item) {
      // invoke hover properties on cousin one hop forward in scenegraph
      if (item.mark.marktype != "rect") return; // want to ignore everything but the rectangle
      console.log(item);
      view.update({
        props: "hover",
        items: item.cousin(1)
      });
    })
    .on("mouseout", function(event, item) {
      // reset cousin item, using animated transition
      if (item.mark.marktype != "rect") return; // want to ignore everything but the rectangle
      view.update({
        props: "update",
        items: item.cousin(1),
        // duration: 250,
        // ease: "linear"
        duration: 250
      });
    })
    .update();  
  //   })
  });
}

var detailsData = 0;
// parse a spec and create a visualization view
function parse2(spec, dat) {
  // var dat = {
  //     table: [
  //       {
  //         "total_words": 14692,
  //         "col": "total_words",
  //         "work_id": "comedyerrors"
  //       },
  //       {
  //         "total_words": 25411,
  //         "col": "total_words",
  //         "work_id": "henry6p2"
  //       }
  //     ]
  //   };
   
  var dat = dat;
  console.log(dat);
  vg.parse.spec(spec, function(chart) { 
    // var view = chart({el:"#view", data:data});    
    // var view = chart({el:"#vis", renderer:"svg"}).update();
    var view = chart({el:"#vis", data:dat, renderer:"svg"});
    // view.on("mouseover", function(event, item) { console.log(item); 
    view
    .on("mouseover", function(event, item) {
      // invoke hover properties on cousin one hop forward in scenegraph
      if (item.mark.marktype != "rect") return; // want to ignore everything but the rectangle
      // console.log(item);
      view.update({
        props: "hover",
        items: item.cousin(1)
      });
    })
    .on("mouseout", function(event, item) {
      // reset cousin item, using animated transition
      if (item.mark.marktype != "rect") return; // want to ignore everything but the rectangle
      view.update({
        props: "update",
        items: item.cousin(1),
        // duration: 250,
        // ease: "linear"
        duration: 250
      });
    })
    .on("click", function(event, item) {
      // reset cousin item, using animated transition
      if (item.mark.marktype != "rect") return; // want to ignore everything but the rectangle
      console.log(item);
      console.log(item.key);
      var work_id = indexData.table[item.key].work_id;
      console.log(work_id);
      var filters = [{"name": "work_id", "op": "eq", "val": work_id}];

      $.ajax({
        url: 'http://localhost:5000/api/paragraph',
        data: {"q": JSON.stringify({"filters": filters})},
        dataType: "json",
        contentType: "application/json",
        success: function(data) {
          console.log(data.objects);
          wd = [];
          for (i = 0; i < data.objects.length; i++) {
            wd.push(data.objects[i].word_count);
          }
          console.log("wd " + wd);

          console.log("histogram_ " + utils.histogram_(wd));
          // d = {table: data.objects};
          d = {table: utils.histogram_(wd)};
          console.log("d " + d);
          parse_details("static/vincent_details.json", d);
          detailsData = d;
        }
      });

      view.update({
        props: "update",
        items: item.cousin(1),
        // duration: 250,
        // ease: "linear"
        duration: 250
      });
    })
    .update();
  //   })
  });
}

// parse("{{ url_for('static', filename='vincent.json') }}");

var indexData = 0;

var order_by = [{"field": "year", "direction": "asc"}];
$.ajax({
  url: 'http://localhost:5000/api/work',
  data: {"q": JSON.stringify({"order_by": order_by})},
  dataType: "json",
  contentType: "application/json",
  success: function(data) {
    // console.log(data.objects); 
    d = {table: data.objects};
    parse2("static/vincent2.json", d);
    indexData = d;
  }
});