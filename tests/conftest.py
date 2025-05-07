import pytest


@pytest.fixture(scope="session")
def owner(accounts):
    return accounts[0]


@pytest.fixture(scope="session")
def singleton(project, owner):
    return owner.deploy(project.Purse)


@pytest.fixture(scope="session")
def purse(singleton, owner):
    with owner.delegate_to(singleton) as purse:
        return purse


@pytest.fixture(scope="session")
def multicall(project, owner):
    return owner.deploy(project.Multicall)
