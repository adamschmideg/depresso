_ = require 'underscore'
_s = require 'underscore.string'
spahql = require 'spahql'
DepGraph = require 'dep-graph'

# Concepts:
#  - path: A unique string
#  - expression: A string that can be resolved to one or more paths
#  - path resolution: Generation of paths from an expression
#  - dependency: A description how a path can be given a value
#    (resolution), and what paths it needs as a prerequisite.

notImplemented = -> throw new Error 'Not implemented'
pr = (x...) -> console.log x[0], JSON.stringify(x[1], null, 2)


_root = (node) ->
  root = node
  while root.parent()
    root = root.parent()
  root

# Supported expressions:
#  - '/foo' starts at the root
#  - '../foo' start from parent
#  - './foo' and 'foo' start from current
glob = (expression, contextNode) ->
  result = null
  if _.isString expression
    if _s.startsWith expression, '/'
      result = _root(contextNode).select(expression).paths()
    else if _s.startsWith expression, '../'
      result = glob expression[3...expression.length], contextNode.parent()
    else if _s.startsWith expression, './'
      result = glob expression[2...expression.length], contextNode
    else
      result = contextNode.select('/' + expression).paths()
  else if _.isFunction expression
    result = expression(contextNode)
  else
    throw new Error "What #{expression}"
  result

isAtomic = (expression) ->
  not (_s.include expression, '//' or _s.include expression, '*')

# Get a value or values on path
value = (db, paths, atomic) ->
  values = []
  for p in paths
    values = values.concat db.select(p).values()
  if atomic
    if values.length > 1
      throw new Error "Expected atomic for #{ paths }"
    values[0]
  else
    values
  
@resolve = (data, dependencies, wantedExpressions...) ->
  db = spahql.db data
  # glob expressions
  nodeDeps = {}
  for dep in dependencies
    for nodePath in glob(dep.target, db)
      dependNodes = {}
      for name,path of dep.depends
        dependNodes[name] =
          atom: isAtomic path
          paths: glob(path, db.select nodePath)
      nodeDeps[nodePath] =
        depends: dependNodes
        calculate: dep.calculate
  wanted = []
  for exp in wantedExpressions
    wanted = wanted.concat glob(exp, db)
  # get dependency resolution order
  graph = new DepGraph
  for path,dep of nodeDeps
    for depends in _.values dep.depends
      for depend in depends.paths
        graph.add path, depend
  shouldCalculate = []
  for w in wanted
    for required in graph.getChain w
      unless required in shouldCalculate
        shouldCalculate.push required
    unless w in shouldCalculate
      shouldCalculate.push w
  # perform calculation
  for path in shouldCalculate
    dep = nodeDeps[path]
    if dep
      calculation = {}
      calculation.calculate = dep.calculate
      for name,depends of dep.depends
        calculation[name] = value db, depends.paths, depends.atom
      result = calculation.calculate()
      db.select(path).replace result
    else
      if _.isUndefined db.select(path).value()
        throw new Error "Expected dependency #{ path } not met"
  db.value()

@testing =
  glob: glob
