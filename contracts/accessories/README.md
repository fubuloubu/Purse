# Purse 1st Party Accessories

## Create

_(see [`Create.vy`](./Create.vy))_

This accessory that allows a Purse to create new contracts thru blueprints using 4 variations of `create(*args)`.
Once deployed, this contract also emits an event to keep track of contracts you've deployed.

```{notice}
Right now, this module only supports blueprints, although `raw_create` is coming in Vyper 0.4.2.
```

## Multicall

_(see [`Multicall.vy`](./Multicall.vy))_

This is a simple multicall-capable accessory that allows a purse to make calls to multiple targets at once through `execute((address,uint256,bytes))`.
This accessory functions via "all-or-nothing" multicall, although you can use it as a template for implementing more complex handling.
No delegatecalls are possible from this module, but is is executed through the normal Purse delegatecall context, so essentially it adds "multicall capabilities" to an EOA when added.

```{notice}
To make a single call via your Purse, simply use your key normally and you can make any transaction you want.
```
