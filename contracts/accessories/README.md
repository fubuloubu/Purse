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

## Flashloan

_(see [`Flashloan.vy`](./Flashloan.vy))_

This accessory implements ERC3156's "Flash Borrower" callback interface, which responds by approving the flash loan target for the amount it needs (if not already approved), and then calls back to the Purse via a normal call using the callback's `data` parameter.
It finishes off by returning the appropiate `bytes32` return value per the spec.

```{notice}
For most flashloans to work, typically the call forwarded to the Purse via `data` must do *something* with the tokens in order to repay them, or else the flashloan will fail.
```

## Sponsor

*(see [`Sponsor.vy`](./Sponsor.vy))*

This accessory enables *meta-transaction-like* behavior by allowing a Purse to execute transactions that have been pre-signed off-chain by the owner. This can be used for gas sponsorship, relaying, or offloading signing to a different system.

The `sponsor()` function takes a `target`, arbitrary call `data`, `value`, along with a deadline, and an EIP-712 signature over those parameters. If the signature is valid and the deadline has not passed, the accessory will `raw_call` the `target` with the provided `data` and `value`.

Unlike `Multicall`, which facilitates batch execution, the `Sponsor` accessory focuses on *delegated intent* — letting a relayer or contract sponsor execute a pre-approved operation on behalf of the Purse, as long as it has been authorized by signature.

```{warning}
This accessory uses `raw_call` to invoke calls. Make sure that the `target` and encoded `data` are safe and perform as intended, since there is no internal validation of the payload.
```

To construct a valid sponsor call:

1. Sign the EIP-712-encoded struct off-chain:

```
Sponsor(address target,bytes data,uint256 amount,uint256 deadline,uint256 nonce,uint8 v,bytes32 r,bytes32 s)
```

2. Pass the signed `v, r, s` components along with the original `target`, `data`, `amount`, and `deadline` to `sponsor()`.

```{note}
The `nonce` can be fetched and MUST match the current `sponsor_nonce()` value or the transaction will revert. This prevents replay attacks.
```
