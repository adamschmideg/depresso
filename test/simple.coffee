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
    age: '../age'
  calculate: (args) ->
    d = new Date()
    d.getYear() - args.age
]

result = resolve data, deps, '//birthDate'
console.log result
