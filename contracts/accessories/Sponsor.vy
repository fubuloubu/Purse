# pragma version 0.4.1
from snekmate.utils import eip712_domain_separator

initializes: eip712_domain_separator

# @custom:storage-location erc7201:purse.accessories.sponsor.sponsor_nonce
# keccak256(abi.encode(uint256(keccak256("purse.accessories.sponsor.sponsor_nonce")) - 1)) & ~bytes32(uint256(0xff))
sponsor_nonce: public(uint256)

@deploy
def __init__():
    eip712_domain_separator.__init__("AccessorySponsor", "1")


@external
def sponsor(data: Bytes[2048], deadline: uint256, nonce: uint256, v: uint8, r: bytes32, s: bytes32):
    assert len(data) >= 4, "Sponsor:!invalid-data"
    assert block.timestamp <= deadline, "Sponsor:!expired-signature"
    assert nonce == self.sponsor_nonce, "Sponsor:!invalid-nonce"

    digest: bytes32 = eip712_domain_separator._hash_typed_data_v4(
        keccak256(
            abi_encode(
                keccak256("Sponsor(bytes data,uint256 deadline,uint256 nonce)"),
                keccak256(data),
                deadline,
                nonce,
            )
        )
    )
    assert ecrecover(digest, v, r, s) == self

    self.sponsor_nonce += 1
    raw_call(self, data)
