import ape
import pytest
from ape import compilers


@pytest.fixture(scope="module")
def mallory(accounts):
    yield accounts[-1]


@pytest.fixture(scope="module")
def purse(singleton, owner, multicall):
    with owner.delegate_to(
        singleton,
        # NOTE: Add multicall as an accessory at the same time
        data=singleton.update_accessories.encode_input(
            [("0x92e45696", sponsor), ("0x53160a60", sponsor)]
        ),
    ) as purse:
        return purse


@pytest.fixture(scope="module")
def dummy(owner):
    SRC = """# pragma version 0.4.1
digest: public(bytes32)

@external
@payable
def __default__():
    self.digest = keccak256(msg.data)
    """
    container = compilers.compile_source("vyper", SRC, contractName="Dummy")
    return container.deploy(sender=owner)


def test_sponsor_plain_eth_transfer():
    # fuzz
    # validate the sponsor call can function
    # with data being b"" and value > 0 with the target being the dummy fixture
    pass


def test_sponsor_eth_attached_to_call():
    # fuzz
    # validate the sponsor call can function
    # with data being ANY and value > 0 with the target being the dummy fixture
    pass


def test_sponsor_target_is_purse_self():
    # validate the sponsor call target can be the Purse itself
    # also validates reentrancy of __default__
    pass


def test_sponsor_reverts_if_signature_expired():
    # validate the sponsor call target can be the Purse itself
    # also validates reentrancy of __default__
    pass


def test_sponsor_reverts_if_nonce_used_is_incorrect():
    # validate the sponsor call but use sponsor_nonce() -1 and +1
    pass


def test_sponsor_reverts_signer_is_unauthorized():
    # validate the sponsor call but have non-owner sign the message (mallory)
    pass
