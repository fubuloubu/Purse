import click
from ape import project
from ape.cli import ConnectedProviderCommand, account_option, network_option


@click.group()
def cli():
    """Commands for deploying the system."""


@cli.command(cls=ConnectedProviderCommand)
@network_option()
@account_option()
@click.option("--publish", is_flag=True, default=False)
def purse(account, publish):
    account.deploy(project.Purse, publish=publish)


@cli.command(cls=ConnectedProviderCommand)
@network_option()
@account_option()
@click.option("--publish", is_flag=True, default=False)
def multicall(account, publish):
    account.deploy(project.Multicall, publish=publish)
