pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "../src/AccountTwoTransactionValidationVerifier.sol";


//Deploy contract: forge script script/AccountTwoTransactionValidationVerifierDeployment.s.sol AccountTwoTransactionValidationVerifierDeployment --broadcast --verify --rpc-url amoy --legacy
/*
    ✅ Hash: 0xdf48693ae3e81124e5830c6dbfbb1279c39674750bad31704a31d9a1d1bd0915
Contract Address: 0x3e588b7fcb3d66c48e108230dcb1db25dd0f5f3c
Block: 12598604

 */

contract AccountTwoTransactionValidationVerifierDeployment is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
       
        AccountTwoTransactionValidationVerifier pv = new AccountTwoTransactionValidationVerifier();
        
        vm.stopBroadcast();
    }
}

