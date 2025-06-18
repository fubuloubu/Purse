# pragma version 0.4.3
# pragma nonreentrancy on
from ethereum.ercs import IERC20

interface IERC3156FlashBorrower:
    def onFlashLoan(
        initiator: address,
        token: IERC20,
        amount: uint256,
        fee: uint256,
        data: Bytes[65535],
    ) -> bytes32: nonpayable


implements: IERC3156FlashBorrower


@external
def onFlashLoan(
    initiator: address,
    token: IERC20,
    amount: uint256,
    fee: uint256,
    data: Bytes[65535],
) -> bytes32:
    # NOTE: Only trusted context allowed
    assert initiator == self, "Flashloan:!authorized"

    # NOTE: Ensure that appropriate amount of allowance is given to caller
    if staticcall token.allowance(tx.origin, msg.sender) < amount + fee:
        extcall token.approve(msg.sender, amount + fee)

    # NOTE: Forward whatever we specified to follow-up with back to ourselves
    raw_call(tx.origin, data)

    # NOTE: Magic value per ERC-3156
    return keccak256("ERC3156FlashBorrower.onFlashLoan")
