from .. import IAccessory
implements: IAccessory


@pure
@external
def getMethodIds() -> DynArray[bytes4, 100]:
    return [0x3f707e6b]


struct Call:
    target: address
    value: uint256
    data: Bytes[2048]


@external
def execute(calls: DynArray[Call, 100]):
    # NOTE: Can only work in a EIP-7702 context from Purse
    assert tx.origin == self, "Multicall:!authorized"

    for call: Call in calls:
        raw_call(call.target, call.data, value=call.value)
