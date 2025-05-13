# pragma version 0.4.1
"""
@title Purse Smart Wallet
@license Apache 2.0
@author ApeWorX LTD
"""

from . import IAccessory


# @notice Mapping of namespace hashes to module target
accessoryByMethodId: public(HashMap[bytes4, IAccessory])


event AccessoryAdded:
    accessory: indexed(IAccessory)
    methods: DynArray[bytes4, 100]


event AccessoryRemoved:
    accessory: indexed(IAccessory)


# NOTE: Cannot have constructor for EIP-7702 to work


@external
# NOTE: Reentrancy guard ensures that `__default__` module calls can't call this
@nonreentrant
# TODO: In Vyper 0.4.2, all contract calls are non-reentrant by default
def add_accessory(accessory: IAccessory):
    """
    @notice Add an accessory to this Purse
    @dev Method must be called by overriden delegate EOA
    @param accessory The address of the new accessory that implements IAccessory
    """
    # NOTE: Can only work in a EIP-7702 context
    assert tx.origin == self, "Purse:!authorized"

    methods: DynArray[bytes4, 100] = staticcall accessory.getMethodIds()
    for method: bytes4 in methods:
        assert self.accessoryByMethodId[method].address == empty(address)
        self.accessoryByMethodId[method] = accessory

    log AccessoryAdded(accessory=accessory, methods=methods)


@external
# NOTE: Reentrancy guard ensures that `__default__` module calls can't call this
@nonreentrant
# TODO: In Vyper 0.4.2, all contract calls are non-reentrant by default
def remove_accessory(accessory: IAccessory):
    """
    @notice Remove an accessory from this Purse
    @dev Method must be called by overriden delegate EOA
    @param accessory The address of the old accessory that implements IAccessory
    """
    # NOTE: Can only work in a EIP-7702 context
    assert tx.origin == self, "Purse:!authorized"

    methods: DynArray[bytes4, 100] = staticcall accessory.getMethodIds()
    for method: bytes4 in methods:
        assert self.accessoryByMethodId[method] == accessory
        self.accessoryByMethodId[method] = IAccessory(empty(address))

    log AccessoryRemoved(accessory=accessory)


@payable
@external
# TODO: In Vyper 0.4.2, all contract calls are non-reentrant by default
@nonreentrant
def __default__():
    # NOTE: Don't bork value transfers in
    if msg.value > 0 or len(msg.data) < 4:
        return

    # WARNING: Any call that matches the methodId check will be forwarded, handle down-stream auth
    #          logic accordingly (e.g. add `msg.sender == tx.origin` to restrict to this account)
    accessory: IAccessory = self.accessoryByMethodId[convert(slice(msg.data, 0, 4), bytes4)]
    assert accessory != IAccessory(empty(address)), "Purse:!no-accessory-found"

    raw_call(accessory.address, msg.data, is_delegate_call=True)
