spahql = require 'spahql'

@MISSING = -1

@data =
  general:
    discount: 0.1
    price: @MISSING
  products: [
    name: 'Bag'
    netPrice: 25
    tax: 0.1
    price: @MISSING
  ,
    name: 'Beer'
    netPrice: 10
    tax: 0.2
    price: 12
  ] 

@db = spahql.db @data
