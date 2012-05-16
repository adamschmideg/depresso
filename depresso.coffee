_ = require 'underscore'
spahql = require 'spahql'

# Concepts:
#  - path: A unique string
#  - expression: A string that can be resolved to one or more paths
#  - path resolution: Generation of paths from an expression
#  - dependency: A description how a path can be given a value
#    (resolution), and what paths it needs as a prerequisite.

notImplemented = -> throw new Error 'Not implemented'

class Globber
  glob: (expressions) ->
    if _.isArray expressions
      [@glob exp for exp in expressions]
    else if _.isString expressions
      @globString expressions
    else if _.isFunction expressions
      @globFunction expressions

  globString: (str) -> notImplemented()
  globFunction: (fun) -> notImplemented()
  setValue: (path, value) -> notImplemented()

class SpahqlGlobber
  constructor: (data) ->
    @db = spahql.db data

  globString: (str) ->
    @db.select(str).paths()

  globFunction: (fun) ->
    fun @db

  setValue: (path, value) ->
    @db.select(path).replace(value)

class Dependency
  # Parameters:
  #  - target: 
  constructor: (@target, @expressions, @resolve) ->

class PathDependency
  constructor: (@path, @requiredPaths, @resolve) ->

class Resolver
  constructor: (@globber, @dependencies) ->

  # Return an array of `PathDependency` instances
  globPaths: ->
    result = []
    for dep in @dependencies
      targetPaths = @globber.glob dep.target
      for path in targetPaths
        #...
