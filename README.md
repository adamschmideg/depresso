[![depresso API Documentation](https://www.omniref.com/js/npm/depresso.png)](https://www.omniref.com/js/npm/depresso)

You have a deeply nested object with some missing values.
You also have some rules how to calculate a value from other values.
`Depresso` takes an object and the calculation rules,
 and does a **dep**endency **res**olution.
Let's see an example.

We have an object with a placeholder for missing values:
```coffeescript

    MISSING = -1

    inventory =
      general:
        discount: 0.1
        price: MISSING
      products: [
        name: 'Bag'
        netPrice: 20
        tax: 0.1
        price: MISSING
      ,
        name: 'Beer'
        netPrice: 10
        tax: 0.2
        price: 12
      ] 
```

There are two rules

  - A product price can be calculated by adding tax to the net price.
  - The total price is the sum of all product prices.

Here is the code describing these rules:
```coffeescript

    rules = [
      target: '/products//price'
      depends: 
        netPrice: '../netPrice'
        tax: '../tax'
      calculate: ->
        @netPrice * (1 + @tax)
    ,
      target: '/general/price'
      depends:
        prices: '/products//price'
      calculate: ->
        _.reduce(
          @prices
          (x,y) -> x+y
          0)
    ]
```
A rule consists of

  - A target pointing to one or more nodes in the object.
  - Dependencies, mapping a name to an xpath-like expression.
  - A calculation which has access to the values defined in the dependencies,
    and returns a value that will be written into the underlying object.

Circular rules should be avoided.

Finally, we specify which node(s) should be calculated:
```coffeescript

    {resolve} = require 'depresso'
    resolve inventory, rules, '/general/price'
    console.log inventory.general.price # prints 34
```

The xpath-like expressions used throughout the examples are provided by [SpahQL][spahql],
 the order of dependency resolution is calculated with [DepGraph][dep-graph].

[spahql]: http://github.com/danski/spahql
[dep-graph]: http://github.com/TrevorBurnham/dep-graph
