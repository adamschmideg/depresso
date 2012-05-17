{resolve} = require '../depresso'
{data} = require './data'

deps = [
  target: '/user/birthDate'
  depends: 
    age: '/user/age'
  calculate: (args) ->
    d = new Date()
    d.getYear() - args.age
,
  target: '/friends/*/birthDate'
  depends: 
    parent: (x) -> x.parent()
  calculate: (args) ->
    d = new Date()
    d.getYear() - args.parent.age
]

result = resolve data, deps, '//birthDate'
console.log result
