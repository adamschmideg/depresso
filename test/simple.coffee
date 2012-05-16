{resolve} = require './despresso'

data =
  user:
    name: 'Joe'
    age: 33
  friends: [
    name: 'Mary'
    age: 22
  ,
    name: 'Dick'
    age: 77
  ] 

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
