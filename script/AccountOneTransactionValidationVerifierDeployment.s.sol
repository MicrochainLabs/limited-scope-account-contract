pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "../src/AccountOneTransactionValidationVerifier.sol";


//Deploy contract: forge script script/AccountOneTransactionValidationVerifierDeployment.s.sol AccountOneTransactionValidationVerifierDeployment --broadcast --verify --rpc-url amoy --legacy
/*
✅ Hash: 0x88ca7c31df201c4c726e431347f4529a6b4595f6288be15e26777cf20c6873da
Contract Address: 0x9f9c4684bb8eba2c1acb06a64cafd1c779dec816
Block: 12598573

 */

contract AccountOneTransactionValidationVerifierDeployment is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
       
        AccountOneTransactionValidationVerifier pv = new AccountOneTransactionValidationVerifier();
        
        vm.stopBroadcast();
    }
}

