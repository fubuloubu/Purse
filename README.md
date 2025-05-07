# Overview

Purse: A Simple(_r_) Smart Wallet

## Design

Purse is a (very) simple smart wallet for EOAs, using EIP-7702 for core functionality.
Purse only works for EOAs since it uses the SetCode transactions on supported neworks to install and uninstall it.

Out of the box, Purse has no features other than controlling a set of "accessories" that it can install (and uninstall) at will.
Through the accessories, Purse can expand it's capabilities, such as adding multicall support and enabling automation through 3rd party accounts.
The only invariant is that Purse can only add or remove accessories by directly calling itself from itself, which means it only works in a EIP-7702 context via EOA delegatecall.

Purse calls its accessories through the fallback (`__default__` method in Vyper), where the method ID of the calldata is used to load the target.
It will then forward all the calldata to that previously-approved target as it gets called via `DELEGATECALL`.
How the accessory chooses to handle the calldata is up to them, the rest of the calldata is simply passed through to it.
Also note that beyond restrictions of how accessories can be added or removed, there are no invariants maintained through 3rd party accessories unless they themsleves implement those measures.

If any accessory call has a failure, Purse's call handling will raise it and not continue processing the transaction.
This presents a nicer interface when debugging call failures without dealing with nonce management features.

Additionally, since all accessory calls are executed using `DELEGATECALL`, technically all accessories use a shared storage space.
**It is highly recommended not to use stateful accessories** without further security analysis, but stateful accessories are possible.
If designing a stateful accessory, it is highly recommended to manage the entire storage lifecycle, as well as use storage namespacing to ensure that no conflicts will exist between accessories (unless desired).
Purse makes no guarantees about storage namespacing, and it is potentially highly dangerous and could lead to **total account compromise** if implemented poorly, since this also potentially allows eliding Purse's own security invariants for accessory management.

Technically, Purse can probably work with Threshold or MPC technology, but it is not advised at this time without a security review.
In fact, using Purse at all is probably not advised as it is an un-audited experiment based on a half-baked idea I had from seeing 7702 in the wild.

---

Purse is inspired by [_The Diamond Standard_](https://eips.ethereum.org/EIPS/eip-2535)
and [`ds-proxy`](https://github.com/dapphub/ds-proxy).

## Contributing

This project is written in [Vyper](https://docs.vyperlang.org/en/stable/).

This project uses [`ape`](https://apeworx.io/framework) to compile, test and script it.
See [Installation Guide](https://docs.apeworx.io/ape/latest/userguides/quickstart#installation) for help installing it.
