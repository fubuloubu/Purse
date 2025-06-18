# pragma version 0.4.3
# pragma nonreentrancy on
"""
@title Purse Smart Wallet
@license Apache 2.0
@author ApeWorX LTD
"""

# @notice Mapping of namespace hashes to module target
accessoryByMethodId: public(HashMap[bytes4, address])


event AccessoryUpdated:
    method: indexed(bytes4)
    old_accessory: indexed(address)
    new_accessory: indexed(address)


# NOTE: Cannot have constructor for EIP-7702 to work


struct AccessoryUpdate:
    method: bytes4
    accessory: address


@external
# NOTE: Reentrancy guard ensures that `__default__` module calls can't call this
def update_accessories(updates: DynArray[AccessoryUpdate, 100]):
    """
    @notice Add an accessory to this Purse
    @dev Method must be called by overriden delegate EOA
    @param updates Array of address/method ID combos to update
    """
    # NOTE: Can only work in a EIP-7702 context
    assert tx.origin == self and tx.origin == msg.sender, "Purse:!authorized"

    for update: AccessoryUpdate in updates:
        current_accessory: address = self.accessoryByMethodId[update.method]
        self.accessoryByMethodId[update.method] = update.accessory

        log AccessoryUpdated(
            method=update.method,
            old_accessory=current_accessory,
            new_accessory=update.accessory,
        )


@payable
@external
@reentrant
@raw_return
def __default__() -> Bytes[65535]:
    # NOTE: Don't bork value transfers in
    if msg.value > 0 or len(msg.data) < 4:
        return b""

    # WARNING: Any call that matches the methodId check will be forwarded, handle down-stream auth
    #          logic accordingly (e.g. add `msg.sender == tx.origin` to restrict to this account)
    accessory: address = self.accessoryByMethodId[convert(slice(msg.data, 0, 4), bytes4)]
    assert accessory != empty(address), "Purse:!no-accessory-found"

    return raw_call(accessory, msg.data, is_delegate_call=True, max_outsize=65535)
