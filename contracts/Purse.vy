# pragma version 0.4.1
"""
@title Purse Smart Wallet
@license Apache 2.0
@author ApeWorX LTD
"""

# @notice Mapping of namespace hashes to module target
accessoryByMethodId: public(HashMap[bytes4, address])


event AccessoryMethodAdded:
    accessory: indexed(address)
    method: indexed(bytes4)


event AccessoryMethodRemoved:
    accessory: indexed(address)
    method: indexed(bytes4)


# NOTE: Cannot have constructor for EIP-7702 to work


@external
# NOTE: Reentrancy guard ensures that `__default__` module calls can't call this
@nonreentrant
# TODO: In Vyper 0.4.2, all contract calls are non-reentrant by default
def add_accessory(accessory: address, methods: DynArray[bytes4, 100]):
    """
    @notice Add an accessory to this Purse
    @dev Method must be called by overriden delegate EOA
    @param accessory The address of the new accessory to add
    @param methods The list of method IDs to enable calling through `accessory`
    """
    # NOTE: Can only work in a EIP-7702 context
    assert tx.origin == self and tx.origin == msg.sender, "Purse:!authorized"

    for method: bytes4 in methods:
        assert self.accessoryByMethodId[method] == empty(address), "Purse:!accessory-in-use"
        self.accessoryByMethodId[method] = accessory
        log AccessoryMethodAdded(accessory=accessory, method=method)


@external
# NOTE: Reentrancy guard ensures that `__default__` module calls can't call this
@nonreentrant
# TODO: In Vyper 0.4.2, all contract calls are non-reentrant by default
def remove_accessory(methods: DynArray[bytes4, 100]):
    """
    @notice Remove methods to call Accessories from this Purse
    @dev Method must be called by overriden delegate EOA
    @param methods The list of method IDs to disable calling for
    """
    # NOTE: Can only work in a EIP-7702 context
    assert tx.origin == self and tx.origin == msg.sender, "Purse:!authorized"

    for method: bytes4 in methods:
        accessory: address = self.accessoryByMethodId[method]
        assert accessory != empty(address), "Purse:!no-accessory-found"
        self.accessoryByMethodId[method] = empty(address)
        log AccessoryMethodRemoved(accessory=accessory, method=method)


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
    accessory: address = self.accessoryByMethodId[convert(slice(msg.data, 0, 4), bytes4)]
    assert accessory != empty(address), "Purse:!no-accessory-found"

    raw_call(accessory, msg.data, is_delegate_call=True)
