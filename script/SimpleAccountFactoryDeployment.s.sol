pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "../src/SimpleAccountFactory.sol";
import "../src/IPolicyVerifier.sol";

//Deploy contract: forge script script/SimpleAccountFactoryDeployment.s.sol SimpleAccountFactoryDeployment --broadcast --verify --rpc-url amoy --legacy

//V6:0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789;
//V7:0x0000000071727De22E5E9d8BAf0edAc6f37da032;

/*
 Hash: 0x857f12cc92317a157f8f1518e17fa11c82eaec51f386f001162259f35f1d5c59
Contract Address: 0xf8ef1786987e574b729304d4a1cf68bb69e91623
Block: 12721894
8


 */
contract SimpleAccountFactoryDeployment is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        address entryPointAddress = 0x0000000071727De22E5E9d8BAf0edAc6f37da032;
        address oneUserOperationVerifier = 0x9F9c4684bb8EBa2C1aCb06a64cAfd1C779DEC816;
        address twoUserOperationVerifier = 0x3e588b7fcb3d66C48E108230dCb1db25dd0f5F3c;

        SimpleAccountFactory pv = new SimpleAccountFactory(IEntryPoint(entryPointAddress), IOneUserOpPolicyVerifier(oneUserOperationVerifier), ITwoUserOpPolicyVerifier(twoUserOperationVerifier));
        
        vm.stopBroadcast();
    }
}

