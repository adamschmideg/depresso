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


@resolve = (data, dependencies, wantedExpressions) ->
  db = spahql.db data
  # glob expressions
  nodeDeps = []
  for dep in dependencies
    for nodePath in glob(dep.target, db)
      dependNodes = {}
      for name,path of dep.depends
        dependNodes[name] = glob(path, db.select nodePath)
      nodeDep =
        target: nodePath
        depends: dependNodes
        calculate: dep.calculate
      nodeDeps.push nodeDep
  # get dependency resolution order
  graph = new DepGraph
  for dep in nodeDeps
    for required in _.values dep.depends
      graph.add dep.target, required
  graph

@testing =
  glob: glob
