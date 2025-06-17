# pragma version 0.4.3
# pragma nonreentrancy on
from snekmate.utils import eip712_domain_separator

initializes: eip712_domain_separator

SPONSOR_TYPEHASH: constant(bytes32) = keccak256("Sponsor(address target,bytes data,uint256 amount,uint256 deadline,uint256 nonce)")

# @custom:storage-location erc7201:purse.accessories.sponsor.sponsor_nonce
# keccak256(abi.encode(uint256(keccak256("purse.accessories.sponsor.sponsor_nonce")) - 1)) & ~bytes32(uint256(0xff))
sponsor_nonce: public(uint256)  # 0x53160a60

@deploy
def __init__():
    eip712_domain_separator.__init__("Sponsor", "1")


@external
def sponsor(
    target: address,
    data: Bytes[2048],
    amount: uint256,
    deadline: uint256,
    v: uint8,
    r: bytes32,
    s: bytes32
):  # 0x92e45696
    """
    @notice Executes a pre-signed call on behalf of the Purse, optionally transferring ETH.
    @dev This function uses EIP-712 to verify a signature over the call parameters.
        If valid, it sends `amount` ETH and executes `data` on the `target` address.
        Reverts if the signature is invalid or expired.
    @param target The address to call.
    @param data ABI-encoded calldata to send to the target.
    @param amount The amount of ETH (in wei) to send along with the call.
    @param deadline A timestamp after which the signature is no longer valid.
    @param v Recovery byte of the signature.
    @param r Half of the ECDSA signature pair.
    @param s Half of the ECDSA signature pair.
    """
    assert block.timestamp <= deadline, "Sponsor:!expired-signature"

    nonce: uint256 = self.sponsor_nonce
    digest: bytes32 = eip712_domain_separator._hash_typed_data_v4(
        keccak256(
            abi_encode(
                SPONSOR_TYPEHASH,
                target,
                keccak256(data),
                amount,
                deadline,
                nonce,
            )
        )
    )
    assert ecrecover(digest, v, r, s) == self, "Sponsor:!unauthorized-signer"

    self.sponsor_nonce = nonce + 1
    raw_call(target, data, value=amount)
