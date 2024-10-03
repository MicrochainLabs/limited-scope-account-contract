// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.23;

/* solhint-disable avoid-low-level-calls */
/* solhint-disable no-inline-assembly */
/* solhint-disable reason-string */


import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "account-abstraction/core/BaseAccount.sol";
import "account-abstraction/core/Helpers.sol";
import "account-abstraction/samples/callback/TokenCallbackHandler.sol";
import "./IPolicyVerifier.sol";
import "./BytesLib.sol";



contract SimpleAccount is BaseAccount, TokenCallbackHandler, UUPSUpgradeable, Initializable {

    using BytesLib for bytes;

    address public owner;

    /*Using Merkle trees and ZK circuits(state), we can build any complex business logic around an account at scale and low cost 
    that ensure trust-minimization(proof system protocol: proving and verifying time, verifying gas cost, proof size, 
    trusted setup, etc)
    In this experimentation, we limit the on-chain protocols that the account can interact with.
    */
    uint256 internal accountTreeRoot;

    struct SignatureAndProof {
        uint256[2] a;
        uint256[2][2] b;
        uint256[2] c;
        uint256 opProof;
        bytes signature;
        }

    uint256 immutable SNARK_SCALAR_FIELD = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    // execute(address,uint256,bytes)
    bytes4 public constant EXECUTE_SELECTOR = 0xb61d27f6;
    // executeBatch(address[],uint256[],bytes[])
    bytes4 public constant EXECUTE_BATCH_SELECTOR = 0x47e1da2a;

    IOneUserOpPolicyVerifier private immutable _oneUserOpPolicyVerifier;

    ITwoUserOpPolicyVerifier private immutable _twoUserOpPolicyVerifier;

    IEntryPoint private immutable _entryPoint;

    event SimpleAccountInitialized(IEntryPoint indexed entryPoint, IOneUserOpPolicyVerifier oneUserOpPolicyVerifier, ITwoUserOpPolicyVerifier twoUserOpPolicyVerifier, address indexed owner);

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    /// @inheritdoc BaseAccount
    function entryPoint() public view virtual override returns (IEntryPoint) {
        return _entryPoint;
    }

    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}

    constructor(IEntryPoint anEntryPoint, IOneUserOpPolicyVerifier aOneUserOpPolicyVerifier, ITwoUserOpPolicyVerifier aTwoUserOpPolicyVerifier) {
        _entryPoint = anEntryPoint;
        _oneUserOpPolicyVerifier = aOneUserOpPolicyVerifier;
        _twoUserOpPolicyVerifier = aTwoUserOpPolicyVerifier;
        _disableInitializers();
    }

    function _onlyOwner() internal view {
        //directly from EOA owner, or through the account itself (which gets redirected through execute())
        require(msg.sender == owner || msg.sender == address(this), "only owner");
    }

    /**
     * execute a transaction (called directly from owner, or by entryPoint)
     * @param dest destination address to call
     * @param value the value to pass in this call
     * @param func the calldata to pass in this call
     */
    function execute(address dest, uint256 value, bytes calldata func) external {
        _requireFromEntryPointOrOwner();
        _call(dest, value, func);
    }

    /**
     * execute a sequence of transactions
     * @dev to reduce gas consumption for trivial case (no value), use a zero-length array to mean zero value
     * @param dest an array of destination addresses
     * @param value an array of values to pass to each call. can be zero-length for no-value calls
     * @param func an array of calldata to pass to each call
     */
    function executeBatch(address[] calldata dest, uint256[] calldata value, bytes[] calldata func) external {
        _requireFromEntryPointOrOwner();
        require(dest.length == func.length && (value.length == 0 || value.length == func.length), "wrong array lengths");
        if (value.length == 0) {
            for (uint256 i = 0; i < dest.length; i++) {
                _call(dest[i], 0, func[i]);
            }
        } else {
            for (uint256 i = 0; i < dest.length; i++) {
                _call(dest[i], value[i], func[i]);
            }
        }
    }

    function updateAccountMerkleTreeRoot(uint256 newAccountTreeRoot) external returns (bool){
        _requireFromEntryPoint();
        accountTreeRoot = newAccountTreeRoot;
        return true;
    }

    /**
     * @dev The _entryPoint member is immutable, to reduce gas consumption.  To upgrade EntryPoint,
     * a new implementation of SimpleAccount must be deployed with the new EntryPoint address, then upgrading
      * the implementation by calling `upgradeTo()`
      * @param anOwner the owner (signer) of this account
     */
    function initialize(address anOwner) public virtual initializer {
        _initialize(anOwner);
    }

    function _initialize(address anOwner) internal virtual {
        owner = anOwner;
        emit SimpleAccountInitialized(_entryPoint, _oneUserOpPolicyVerifier, _twoUserOpPolicyVerifier, owner);
    }

    // Require the function call went through EntryPoint or owner
    function _requireFromEntryPointOrOwner() internal view {
        require(msg.sender == address(entryPoint()) || msg.sender == owner, "account: not Owner or EntryPoint");
    }

    function _validateSignature(PackedUserOperation calldata userOp, bytes32 userOpHash)
    internal override virtual returns (uint256 validationData) {
        bytes32 hash = MessageHashUtils.toEthSignedMessageHash(userOpHash);
        if(bytes4(userOp.callData[:4]) == EXECUTE_SELECTOR || bytes4(userOp.callData[:4]) == EXECUTE_BATCH_SELECTOR){
            SignatureAndProof memory signatureAndProof = _decodeSignatureProofCalldata(userOp.signature);
            if(!_verifyProof(userOp.callData, signatureAndProof, uint256(userOpHash))){
                return SIG_VALIDATION_FAILED;
            }
            if (owner != ECDSA.recover(MessageHashUtils.toEthSignedMessageHash(userOpHash), signatureAndProof.signature))
                return SIG_VALIDATION_FAILED;
            return SIG_VALIDATION_SUCCESS;
        }else if(bytes4(userOp.callData[:4]) == 0xe4f4b913){
            if (owner != ECDSA.recover(hash, userOp.signature))
                return SIG_VALIDATION_FAILED;
            return SIG_VALIDATION_SUCCESS;
        }
        return SIG_VALIDATION_FAILED;
    }

    function _verifyProof(bytes calldata userOpCalldata, SignatureAndProof memory signatureAndProof, uint256 opHash) internal returns (bool) {
        opHash %= SNARK_SCALAR_FIELD;
        if(bytes4(userOpCalldata[:4]) == EXECUTE_SELECTOR){
            address dest =  abi.decode(userOpCalldata[4:36],(address));
            uint256 value =  abi.decode(userOpCalldata[36:68],(uint256));
            uint256 length = abi.decode(userOpCalldata[100:132],(uint256));
            uint256 functionSelector;
            uint256 to;
            if(length > 0){
                bytes memory fnSelector = userOpCalldata[132:136];
                functionSelector = uint256(uint32(bytes4(fnSelector)));
                if( bytes4(userOpCalldata[132:136]) == bytes4(0xa9059cbb)){
                    address toAddress =abi.decode(userOpCalldata[136:168],(address));
                    to = uint256(uint160(toAddress));
                    //uint256 amount = abi.decode(userOpCalldata[168:200],(uint256));
                }else{
                    to = 0;
                }
            }else{
                functionSelector = 0;
                to = 0;
            }
            uint256[8] memory input = [accountTreeRoot, signatureAndProof.opProof, uint256(uint160(address(this))), opHash, uint256(uint160(dest)), value, functionSelector, to];
            return _oneUserOpPolicyVerifier.verifyProof(signatureAndProof.a, signatureAndProof.b, signatureAndProof.c, input);
        }else if(bytes4(userOpCalldata[:4]) == EXECUTE_BATCH_SELECTOR){
            (address[] memory dest, uint256[] memory value, bytes[] memory func) = abi.decode(userOpCalldata[4:],(address[],uint256[], bytes[]));
             if(!(dest.length == func.length && (value.length == 0 || value.length == func.length))){
                return false;
            }
            //uint256[] memory userOperationCallsinputs = new uint256[](4+(4*dest.length));//In this experimentation, we fix dest.length = 2
            uint256[] memory userOperationCallsinputs = new uint256[](12);
            for(uint i = 0; i < dest.length; i++){
                uint256 valueIndex= 4 + dest.length; 
                uint256 functionSelectorIndex= 4 + dest.length * 2;
                uint256 toIndex= 4 + dest.length * 3;

                userOperationCallsinputs[4+i] = uint256(uint160(dest[i]));
                if(value.length == 0){
                    userOperationCallsinputs[valueIndex+i] = 0;
                }else{
                    userOperationCallsinputs[valueIndex+i] = value[i];
                }
                if(func[i].length>0){
                    userOperationCallsinputs[functionSelectorIndex+i] = uint256(uint32(bytes4(func[i])));
                    if(bytes4(func[i]) == bytes4(0xa9059cbb)){
                        bytes memory parameters= func[i].slice(4, func[i].length-4);
                        (address to, uint amount) = abi.decode(parameters,(address,uint256));
                        userOperationCallsinputs[toIndex+i] = uint256(uint160(to));
                        //amounts[i] = amount;
                    }else{
                        userOperationCallsinputs[toIndex+i] = 0;
                        //amounts[i] = 0;
                    }
                }else{
                    userOperationCallsinputs[functionSelectorIndex+i] = 0;
                    userOperationCallsinputs[toIndex+i] = 0;
                }
            }
            /*if(dest.length == 1){
                userOperationCallsinputs[5] = 0;
                userOperationCallsinputs[7] = 0;
                userOperationCallsinputs[9] = 0;
                userOperationCallsinputs[11] = 0;
            }
            //for only two operations
            */
            uint256[12] memory input;
            input[0] = accountTreeRoot;
            input[1] = signatureAndProof.opProof;
            input[2] = uint256(uint160(address(this)));
            input[3] = opHash;
            for(uint256 i = 4; i<userOperationCallsinputs.length; i++){
                input[i] = userOperationCallsinputs[i];
            }
            return _twoUserOpPolicyVerifier.verifyProof(signatureAndProof.a, signatureAndProof.b, signatureAndProof.c, input);
        }else{
            return false;
        }
    }

    function _decodeSignatureProofCalldata(bytes calldata proof) public pure returns(SignatureAndProof memory decodedProof ) {
        {
            (
                uint256 proof0,
                uint256 proof1,
                uint256 proof2,
                uint256 proof3,
                uint256 proof4,
                uint256 proof5,
                uint256 proof6,
                uint256 proof7,
                uint256 opProof,
                bytes memory signature
            ) = abi.decode(proof, (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, bytes));
            decodedProof = SignatureAndProof([proof0, proof1],[[proof2, proof3], [proof4, proof5]], [proof6, proof7], opProof, signature);
        }
    }

    function _call(address target, uint256 value, bytes memory data) internal {
        (bool success, bytes memory result) = target.call{value: value}(data);
        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }

    /**
     * check current account deposit in the entryPoint
     */
    function getDeposit() public view returns (uint256) {
        return entryPoint().balanceOf(address(this));
    }

    /**
     * deposit more funds for this account in the entryPoint
     */
    function addDeposit() public payable {
        entryPoint().depositTo{value: msg.value}(address(this));
    }

    /**
     * withdraw value from the account's deposit
     * @param withdrawAddress target to send to
     * @param amount to withdraw
     */
    function withdrawDepositTo(address payable withdrawAddress, uint256 amount) public onlyOwner {
        entryPoint().withdrawTo(withdrawAddress, amount);
    }

    function _authorizeUpgrade(address newImplementation) internal view override {
        (newImplementation);
        _onlyOwner();
    }
}
