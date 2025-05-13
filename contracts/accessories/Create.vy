event DeploymentFromBlueprint:
    deployment: indexed(address)
    blueprint: indexed(address)
    salt: indexed(bytes32)
    args: Bytes[65535]


@external
def create(
    initcode_or_args: Bytes[65535] = b"",
    blueprint: address = empty(address),
    salt: bytes32 = empty(bytes32),
    forwarded_value: uint256 = 0,
) -> address:
    deployment: address = empty(address)

    if blueprint != empty(address):
        if salt != empty(bytes32):
            deployment = create_from_blueprint(
                blueprint,
                initcode_or_args,
                raw_args=True,
                value=forwarded_value,
                salt=salt,
            )

        else:
            deployment = create_from_blueprint(
                blueprint,
                initcode_or_args,
                raw_args=True,
                value=forwarded_value,
            )

        log DeploymentFromBlueprint(
            deployment=deployment,
            blueprint=blueprint,
            salt=salt,
            args=initcode_or_args,
        )

    # TODO: Support `raw_create`?
    # else:
    #     if salt != empty(bytes32):
    #         deployment = raw_create(
    #             initcode_or_args,
    #             value=forwarded_value,
    #             salt=salt,
    #         )
    #     else:
    #         deployment = raw_create(
    #             initcode_or_args,
    #             value=forwarded_value,
    #         )
    #
    #     log Deployment(
    #         deployment=deployment,
    #         salt=salt,
    #         initcode=initcode_or_args,
    #     )

    assert deployment != empty(address), "Create:!deployment"
    return deployment
