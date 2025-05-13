event DeploymentFromBlueprint:
    deployment: indexed(address)
    blueprint: indexed(address)
    salt: indexed(bytes32)


@external
def create(
    initcode: Bytes[65535] = b"",
    blueprint: address = empty(address),
    salt: bytes32 = empty(bytes32),
    forwarded_value: uint256 = 0,
) -> address:
    deployment: address = empty(address)

    if blueprint != empty(address):
        deployment = create_from_blueprint(
            blueprint,
            initcode_or_args,
            raw_args=True,
            value=forwarded_value,
            salt=salt,
        )

        log DeploymentFromBlueprint(deployment=deployment, blueprint=blueprint, salt=salt)

    # TODO: Support `raw_create`?
    # deployment = raw_create(initcode, value=forwarded_value, salt=salt)

    assert deployment != empty(address), "Create:!deployment"

    return deployment
