from ape import convert, reverts
from ape.utils import ZERO_ADDRESS


def test_init(singleton, purse, owner):
    # assert owner.delegate == singleton
    assert purse.address == owner.address
    assert purse.contract_type == singleton.contract_type


def test_can_transfer(purse, accounts):
    # NOTE: Make sure reentrancy doesn't lock us out of sending ether
    balance = purse.balance
    accounts[-1].transfer(purse, "1 ether")
    assert purse.balance - balance == convert("1 ether", int)


def test_change_accessories(purse, multicall):
    # TODO: Add `.method_id(args_str)` to `ContractMethodHandler`
    method_id = multicall.execute.encode_input([])[:4]
    assert purse.accessoryByMethodId(method_id) == ZERO_ADDRESS

    purse.add_accessory(multicall, sender=purse)
    assert purse.accessoryByMethodId(method_id) == multicall

    purse.remove_accessory(multicall, sender=purse)
    assert purse.accessoryByMethodId(method_id) == ZERO_ADDRESS


def test_cant_call_arbitrary(purse):
    with reverts(message="Purse:!no-accessory-found"):
        purse(sender=purse)

    with reverts(message="Purse:!no-accessory-found"):
        purse(data="0xa1b2c3d", sender=purse)
