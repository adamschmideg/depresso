_ = require 'underscore'
_s = require 'underscore.string'
spahql = require 'spahql'

# Concepts:
#  - path: A unique string
#  - expression: A string that can be resolved to one or more paths
#  - path resolution: Generation of paths from an expression
#  - dependency: A description how a path can be given a value
#    (resolution), and what paths it needs as a prerequisite.

notImplemented = -> throw new Error 'Not implemented'
pr = console.log


_root = (node) ->
  root = node
  while root.parent()
    root = root.parent()
  root

glob = (expression, contextNode) ->
  result = null
  #pr 'glob', expression, contextNode
  if _.isString expression
    if _s.startsWith expression, '/'
      result = glob expression[1...expression.length], _root contextNode
    else if _s.startsWith expression, '../'
      result = glob expression[3...expression.length], contextNode.parent()
    else
      result = contextNode.select(expression).paths()
  else if _.isFunction expression
    result = expression(contextNode)
  else
    throw new Error "What #{expression}"
  result


@resolve = (data, dependencies, wantedExpressions) ->
  db = spahql.db data
  nodeDeps = []
  for dep in dependencies
    for nodePath in glob dep.target, db
      dependNodes = {}
      for name,path of dep.depends
        dependNodes[name] = glob(path, db.select nodePath)
      nodeDep =
        target: nodePath
        depends: dependNodes
        calculate: dep.calculate
      nodeDeps.push nodeDep
  nodeDeps

@testing =
  glob: glob
