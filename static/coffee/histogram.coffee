# # Assignment:
# number   = 42
# opposite = true

# # Conditions:
# number = -42 if opposite

# # Functions:
# square = (x) -> x * x

# # Arrays:
# list = [1, 2, 3, 4, 5]

# # Objects:
# math =
#   root:   Math.sqrt
#   square: square
#   cube:   (x) -> x * square x

# # Splats:
# race = (winner, runners...) ->
#   print winner, runners

# elvis = 'yes'
# # Existence:
# console.log "I knew it!" if elvis?

# # Array comprehensions:
# cubes = (math.cube num for num in list)

# console.log "Tom"

# s = "square #{ math.square(2) }"
# console.log s
# console.log "square #{ math.square(2) }"



histogram = (data, numBins=20) ->
  max = Math.max.apply(Math, data)
  min = Math.min.apply(Math, data)
  range = max - min;
  # range = max;

  bins = (0 for item in [0...numBins])
  # for item in data
  width = (range/(numBins-1))

  domain = (width*xx+min for xx in [0...numBins])

  lookup = do (width=width, min=min) ->
    (value) ->
      bin = Math.floor((value-min)/width)
      return bin

  for item in data
    binNum = lookup(item)
    bins[binNum]++;

  return {bins, domain};

x = [-10,1,1,1,3,1,1,1,1,1,1,1,1,4,4,4,4,1,1,1,1,1,9,9,9,9.6];

o = histogram(x,11) 
{bins : bins_, domain: domain_} = o
# console.log(x)
# console.log(o)
# console.log(bins_)
# console.log(domain_)

zip = () ->
  lengthArray = (arr.length for arr in arguments)
  length = Math.min(lengthArray...)
  for i in [0...length]
    arr[i] for arr in arguments

zip_ = () ->
  lengthArray = (arr.length for arr in arguments)
  length = Math.min(lengthArray...)
  # console.log "length #{length}"
  for i in [0...length]
    arr[i] = {word_count : arguments[0][i], paragraph_num : arguments[1][i].toFixed 1}
    # arr[i] for arr in arguments
  return arr

histogram_ = (data, numBins) ->
  o = histogram(data, 20) 
  {bins : bins_, domain: domain_} = o
  return zip_(bins_, domain_)

window?.histogram_ = histogram_

# create a namespace to export our public methods
utils = exports? and exports or @utils = {}
utils.histogram_ = histogram_


# console.log(zip_(bins_, domain_))
# console.log(zip_(bins_, domain_))
console.log(histogram(x, 11))

# function hist(data, numBins) {

#   x = data.sort(function(a, b) { return a - b });
#   max = Math.max.apply(Math,x)
#   min = Math.min.apply(Math,x)
#   range = max - min;

#   // bins = new Array(numBins);
#   bins = [];
#   temp = numBins;
#   while(temp--) bins.push(0);  
#   width = Math.round(range/numBins);

#   start = 0;
#   for (i = 0; i < numBins; i++) {
#      end = (i+1) * width;
#      for (j = start; j < (x.length-width); j++) {
#          if (x[j] > end) {
#              start = j;
#              break;
#          }
#          bins[i]++;
#      }
#   }
#   return bins;

# }
