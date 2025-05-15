# pragma version 0.4.1
from snekmate.utils import eip712_domain_separator

initializes: eip712_domain_separator

SPONSOR_TYPEHASH: constant(bytes32) = keccak256("Sponsor(address target,bytes data,uint256 amount,uint256 deadline,uint8 v,bytes32 v,bytes32 s)")

# @custom:storage-location erc7201:purse.accessories.sponsor.sponsor_nonce
# keccak256(abi.encode(uint256(keccak256("purse.accessories.sponsor.sponsor_nonce")) - 1)) & ~bytes32(uint256(0xff))
sponsor_nonce: public(uint256)  # 0x53160a60

@deploy
def __init__():
    eip712_domain_separator.__init__("AccessorySponsor", "1")


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
    assert ecrecover(digest, v, r, s) == self

    self.sponsor_nonce = nonce + 1
    raw_call(target, data, value=amount)
