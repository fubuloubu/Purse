import ape
import pytest


@pytest.fixture(scope="module")
def purse(singleton, owner, multicall):
    with owner.delegate_to(
        singleton,
        # NOTE: Add multicall as an accessory at the same time
        data=singleton.update_accessories.encode_input(
            [
                (
                    multicall.selector_identifiers[
                        "execute((address,uint256,bytes)[])"
                    ],
                    multicall,
                )
            ]
        ),
    ) as purse:
        return purse


def test_empty_multicall(purse, multicall):
    purse(data=multicall.execute.encode_input([]), sender=purse)


def test_single_multicall(purse, multicall, accounts):
    a = accounts[1]
    bal_a = a.balance
    purse(
        data=multicall.execute.encode_input(
            [
                dict(target=a, value="1 ether", data=b""),
            ]
        ),
        sender=purse,
    )
    assert a.balance - bal_a == ape.convert("1 ether", int)


def test_many_multicall(purse, multicall, accounts):
    a, b, c = accounts[1:4]
    bal_a = a.balance
    bal_b = b.balance
    bal_c = c.balance

    purse(
        data=multicall.execute.encode_input(
            [
                dict(target=a, value="1 ether", data=b""),
                dict(target=b, value="2 ether", data=b""),
                dict(target=c, value="3 ether", data=b""),
            ]
        ),
        sender=purse,
    )

    assert a.balance - bal_a == ape.convert("1 ether", int)
    assert b.balance - bal_b == ape.convert("2 ether", int)
    assert c.balance - bal_c == ape.convert("3 ether", int)


def test_cant_call_purse(purse, multicall):
    with ape.reverts():
        purse(
            data=multicall.execute.encode_input(
                [
                    dict(
                        target=purse,
                        value=0,
                        data=purse.remove_accessory.encode_input(multicall),
                    )
                ]
            ),
            sender=purse,
        )


def test_only_owner_can_multicall(purse, multicall, accounts):
    hacker = accounts[-1]
    assert purse.address != hacker.address

    with ape.reverts(message="Multicall:!authorize"):
        tx = purse(
            data=multicall.execute.encode_input(
                [
                    dict(target=hacker, value="1 ether", data=b""),
                ]
            ),
            sender=hacker,
        )
        tx.show_trace()
