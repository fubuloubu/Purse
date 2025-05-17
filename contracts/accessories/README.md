# Purse 1st Party Accessories

## Multicall

_(see [`Multicall.vy`](./Multicall.vy))_

This is a simple multicall-capable accessory that allows a purse to make calls to multiple targets at once through `execute((address,uint256,bytes))`.
This accessory functions via "all-or-nothing" multicall, although you can use it as a template for implementing more complex handling.
No delegatecalls are possible from this module, but is is executed through the normal Purse delegatecall context, so essentially it adds "multicall capabilities" to an EOA when added.

```{notice}
To make a single call via your Purse, simply use your key normally and you can make any transaction you want.
```

## Flashloan

_(see [`Flashloan.vy`](./Flashloan.vy))_

This accessory implements ERC3156's "Flash Borrower" callback interface, which responds by approving the flash loan target for the amount it needs (if not already approved), and then calls back to the Purse via a normal call using the callback's `data` parameter.
It finishes off by returning the appropiate `bytes32` return value per the spec.

```{notice}
For most flashloans to work, typically the call forwarded to the Purse via `data` must do *something* with the tokens in order to repay them, or else the flashloan will fail.
```
