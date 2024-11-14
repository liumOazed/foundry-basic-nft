// SPDX-License Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployBasicNft} from "script/DeployBasicNft.s.sol";
import {BasicNft} from "src/BasicNft.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract BasicNfttest is Test, IERC721Receiver {
    DeployBasicNft public deployer;
    BasicNft public basicNft;

    address public owner;
    address public nonOwner;

    uint256 public constant STARTING_TOKEN_ID = 0;
    string public constant TOKEN_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";

    function setUp() public {
        deployer = new DeployBasicNft();
        basicNft = deployer.run();
        owner = address(this); // Deploying contract owner
        nonOwner = address(0x123); // A non-owner address
    }

    // Implement onERC721Received to accept ERC721 tokens
    function onERC721Received(
        address /* operator */,
        address /* from */,
        uint256 /* tokenId */,
        bytes calldata /* data */
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    // Test 1: Ensure the first minted NFT has the correct token URI
    function testMintNftAndTokenURI() public {
        basicNft.mintNft(TOKEN_URI);

        assertEq(basicNft.tokenURI(STARTING_TOKEN_ID), TOKEN_URI);
    }

    // Test 2: Check the owner of a minted token
    function testOwnerOfMintedNft() public {
        basicNft.mintNft(TOKEN_URI);
        assertEq(basicNft.ownerOf(STARTING_TOKEN_ID), owner);
    }

    // Test 3: Verify that only the owner of the token can transfer it
    function testTransferNft() public {
        basicNft.mintNft(TOKEN_URI);

        // Attempting a transfer by the owner
        address receiver = address(0x456);
        basicNft.transferFrom(owner, receiver, STARTING_TOKEN_ID);

        assertEq(basicNft.ownerOf(STARTING_TOKEN_ID), receiver);
    }

    // Test 4: Non-owner cannot transfer the token
    function testNonOwnerCannotTransfer() public {
        basicNft.mintNft(TOKEN_URI);

        // Try to transfer as a non-owner
        vm.prank(nonOwner);
        vm.expectRevert();
        basicNft.transferFrom(owner, nonOwner, STARTING_TOKEN_ID);
    }

    // Test 5: Name is correct
    function testNameIsCorrect() public view {
        string memory expectedName = "Dogie";
        string memory actualName = basicNft.name();
        assert(
            keccak256(abi.encodePacked(expectedName)) ==
                keccak256(abi.encodePacked(actualName))
        );
    }
}
