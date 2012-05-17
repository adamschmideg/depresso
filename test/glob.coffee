{testing} = require '../depresso'
{data} = require './data'
spahql = require 'spahql'

db = spahql.db data
console.log testing.glob('/user/age', db).select
console.log testing.glob('/user/birthDate', db).select
