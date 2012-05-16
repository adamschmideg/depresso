_ = require 'underscore'
spahql = require 'spahql'

# Concepts:
#  - path: A unique string
#  - expression: A string that can be resolved to one or more paths
#  - path resolution: Generation of paths from an expression
#  - dependency: A description how a path can be given a value
#    (resolution), and what paths it needs as a prerequisite.

notImplemented = -> throw new Error 'Not implemented'

class Value

class Path extends String

class Expression extends String

class Node
  value: -> /*Value*/
  setValue: (/*Value*/value)  -> /*Value*/
  path: -> /*Path*/

globExpression = (/*Expression*/expression, /*Node*/node) -> /*Array[Path]*/

Globbable = Expression | (Node) -> Array[Path]

class NodeDependency
  constructor: (/*Node*/targetNode, /*Array[Node]*/ requiredNodes, /*Map[String,Node]->Value*/ calculateFn) ->

globNodeDependency = (/*Node*/rootNode, /*Expression*/target, /*Array[Globbable]*/requirements, calculateFn) -> /*Array[NodeDependency]*/

resolveNodes = (/*Node*/rootNode, /*Array[NodeDependency]*/ nodeDependencies, /*Array[Node]*/ emptyNodes) -> /*Node*/


class Globber
  glob: (expressions, context=null) ->
    if _.isArray expressions
      [@glob(exp, context) for exp in expressions]
    else if _.isString expressions
      @globString expressions, context
    else if _.isFunction expressions
      @globFunction expressions, context

  globString: (str) -> notImplemented()
  globFunction: (fun) -> notImplemented()
  setValue: (path, value) -> notImplemented()

class SpahqlGlobber
  constructor: (data) ->
    @db = spahql.db data

  globString: (str, context) ->
    @db.select(str).paths()

  globFunction: (fun, context) ->
    fun @db

  setValue: (path, value) ->
    @db.select(path).replace(value)

class Dependency
  # Parameters:
  #  - target: 
  constructor: (@targetExpression, @globbables, @resolveFn) ->

class Resolver
  constructor: (data, dependencies) ->
    @db = spahql.db data
    @nodeDependencies = []
    for dep in dependencies
      targetNodes = globExpression dep.targetExpression
      for node in targetNodes
        nodeDep = _globNodeDependency node, dep.globbables, dep.resolveFn

  # Return an array of `PathDependency` instances
  globPaths: ->
    result = []
    for dep in @dependencies
      targetPaths = @globber.glob dep.target
      for path in targetPaths
        #...
