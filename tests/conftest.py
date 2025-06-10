import pytest
from ape.contracts import ContractInstance, ContractMethodHandler


@pytest.fixture(scope="session")
def owner(accounts):
    return accounts[0]


@pytest.fixture(scope="session")
def other(accounts):
    return accounts[-1]


@pytest.fixture(scope="session")
def singleton(project, owner):
    return owner.deploy(project.Purse)


@pytest.fixture()
def purse(singleton, owner):
    with owner.delegate_to(singleton) as purse:
        yield purse


@pytest.fixture(scope="session")
def multicall(project, owner):
    return owner.deploy(project.Multicall)


@pytest.fixture(scope="session")
def sponsor(project, owner):
    return owner.deploy(project.Sponsor)


@pytest.fixture(scope="session")
def encode_accessory_data():
    def encode_accessory_data(
        accessory: ContractInstance, *methods: str | ContractMethodHandler
    ) -> list[dict]:
        selectors = []

        for method in methods:
            if isinstance(method, ContractMethodHandler):
                selectors.extend(abi.selector for abi in method.abis)
            else:
                selectors.append(method)

        return [
            dict(
                accessory=accessory,
                method=accessory.contract_type.method_identifiers.get(method_id),
            )
            for method_id in selectors
        ]

    return encode_accessory_data
