_ = require 'underscore'
spahql = require 'spahql'

# Concepts:
#  - path: A unique string
#  - expression: A string that can be resolved to one or more paths
#  - path resolution: Generation of paths from an expression
#  - dependency: A description how a path can be given a value
#    (resolution), and what paths it needs as a prerequisite.

notImplemented = -> throw new Error 'Not implemented'
pr = console.log


glob = (expression, contextNode) ->
  result = null
  if _.isString expression
    result = contextNode.select expression
  else if _.isFunction expression
    result = expression(contextNode)
  else
    throw new Error "What #{expression}"
  result.paths()


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
