# pragma version 0.4.1
from .. import IAccessory
from snekmate.utils import eip712_domain_separator

implements: IAccessory

initializes: eip712_domain_separator

# @custom:storage-location erc7201:purse.accessories.sponsor.nonce
# keccak256(abi.encode(uint256(keccak256("purse.accessories.sponsor.nonce")) - 1)) & ~bytes32(uint256(0xff))
sponsor_nonce: public(uint256)

@deploy
def __init__():
    # TODO: think about how to integrate correctly in Purse.vy
    # so additional accessories may use EIP712 functionality
    eip712_domain_separator.__init__("AccessorySponsor", "1")


@pure
@external
def getMethodIds() -> DynArray[bytes4, 100]:
    return [
        0x44210e0d, # sponsor(bytes,uint256,uint256,uint8,bytes32,bytes32)
        0x84b0196e, # eip712Domain()
    ]


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
