// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import "src/Issue4/Upgradable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract IssueFourDeploy is Script {
    function run() external returns (address) {
        address proxy = deployContract();
        return proxy;
    }

    function deployContract() private returns (address) {
        ProductManager target = new ProductManager(); //implmentation contract
        ERC1967Proxy proxy = new ERC1967Proxy(address(target),""); //deploy the proxy
        return address(proxy);
    }
}
