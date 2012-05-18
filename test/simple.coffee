{resolve} = require '../depresso'
{data} = require './data'
_ = require 'underscore'

deps = [
  target: '/products//price'
  depends: 
    netPrice: '../netPrice'
    tax: '../tax'
  calculate: ->
    @netPrice * (1 + @tax)
,
  target: '/general/price'
  depends:
    prices: '/products//price'
  calculate: ->
    _.reduce(
      @prices
      (x,y) -> x+y
      0)
]

result = resolve data, deps, '/general/price'
console.log result.general.price is 34, result
