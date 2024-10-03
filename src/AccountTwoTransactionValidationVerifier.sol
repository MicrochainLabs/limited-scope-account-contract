// SPDX-License-Identifier: GPL-3.0
/*
    Copyright 2021 0KIMS association.

    This file is generated with [snarkJS](https://github.com/iden3/snarkjs).

    snarkJS is a free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    snarkJS is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
    License for more details.

    You should have received a copy of the GNU General Public License
    along with snarkJS. If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity >=0.7.0 <0.9.0;

contract AccountTwoTransactionValidationVerifier {
    // Scalar field size
    uint256 constant r    = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    // Base field size
    uint256 constant q   = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // Verification Key data
    uint256 constant alphax  = 18411124172882802491892278415029729826567721839247145820787755230845769562672;
    uint256 constant alphay  = 4020333826053078241011372262483194976079139012492385586769008774800923141457;
    uint256 constant betax1  = 20008454745391030474587200744181620148237871647839898607026415141329139505210;
    uint256 constant betax2  = 16642981632941063337320247396987309831816261195147678467056062500860674488938;
    uint256 constant betay1  = 19103979322830820605109918644968485309896534991779152626115789946662781930823;
    uint256 constant betay2  = 13965014506824404526138587302438394499395919329610138888745858191181649083497;
    uint256 constant gammax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gammax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gammay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gammay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 constant deltax1 = 9758739331331044437762855826682795442673981239142561048211522495868513525967;
    uint256 constant deltax2 = 13287035060825480225516517487565339673619688439982980435912123532221725829831;
    uint256 constant deltay1 = 19629358287151890124229184620648374348957362580504781408755886542656946032950;
    uint256 constant deltay2 = 13704811125798539655919200792723819290751742535605933078765505069287878335165;

    
    uint256 constant IC0x = 16520617600172303732176323510227113909961432141036438957845997000137613717549;
    uint256 constant IC0y = 4055828183485716422591200048159571183680642050906080162733513020965030586515;
    
    uint256 constant IC1x = 3571737767259166621493511104427568307034347933812900036437422540061661861180;
    uint256 constant IC1y = 3850604974120247584443399574654606655178932625895525605668789351896227817595;
    
    uint256 constant IC2x = 6051840414664007112888015429656857939691727038218683351238351398122291640618;
    uint256 constant IC2y = 3254116381523350088772531550835757161597585838062902594846465927223294634456;
    
    uint256 constant IC3x = 1934118202185303801873554328739604240704554250036899403587799889116291886880;
    uint256 constant IC3y = 2940666836675281054641454683326542512397001018521705571184306722455289139821;
    
    uint256 constant IC4x = 3063796553900576582184250046437404165467326563735948461534089083768587026488;
    uint256 constant IC4y = 14913189060737968629170959043470048891322836097867519993001348833281721198278;
    
    uint256 constant IC5x = 11671773050603215276094489652058733624859501433156829400729741817040367447059;
    uint256 constant IC5y = 19198606135666147887751835098403812154722861965717005128515299915708295710416;
    
    uint256 constant IC6x = 5974551987001370113143623483308215826892029290902347783866431635760363215755;
    uint256 constant IC6y = 12320552035666682645424951004097999810013424016040342351102767464634822410349;
    
    uint256 constant IC7x = 21374166948770093458762983736200405082477639806654856636596674628465386216068;
    uint256 constant IC7y = 8812894234023277580408087179835028585584734613606485818447815723195921156128;
    
    uint256 constant IC8x = 6408198703398326866056708734088714228131773986767668645016497003887065743585;
    uint256 constant IC8y = 4833384062571215016267974565613871624278729206169608858029808189186158803496;
    
    uint256 constant IC9x = 4370020216962757720575250098022092905562910839692976244657253210589049346156;
    uint256 constant IC9y = 15506727090755188347192471316074425845947985652508009964325965784716333444328;
    
    uint256 constant IC10x = 10652576517529373069672098761403780537237676474765549655678897112586165528377;
    uint256 constant IC10y = 428415672851983707664235907329293708376890612518228775126834054404749993488;
    
    uint256 constant IC11x = 12206604377586394397469907389813062969863531050570495233861073504094973397312;
    uint256 constant IC11y = 13566727519915070965043600350360252557152813162262943575806790691568919655621;
    
    uint256 constant IC12x = 5218036924555785902523975908003056602242768083742886089562755066873138248789;
    uint256 constant IC12y = 4273553474633489986065762527051133143881155365509134525717786021189467414018;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[12] calldata _pubSignals) public view returns (bool) {
        assembly {
            function checkField(v) {
                if iszero(lt(v, r)) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }
            
            // G1 function to multiply a G1 value(x,y) to value in an address
            function g1_mulAccC(pR, x, y, s) {
                let success
                let mIn := mload(0x40)
                mstore(mIn, x)
                mstore(add(mIn, 32), y)
                mstore(add(mIn, 64), s)

                success := staticcall(sub(gas(), 2000), 7, mIn, 96, mIn, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }

                mstore(add(mIn, 64), mload(pR))
                mstore(add(mIn, 96), mload(add(pR, 32)))

                success := staticcall(sub(gas(), 2000), 6, mIn, 128, pR, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            function checkPairing(pA, pB, pC, pubSignals, pMem) -> isOk {
                let _pPairing := add(pMem, pPairing)
                let _pVk := add(pMem, pVk)

                mstore(_pVk, IC0x)
                mstore(add(_pVk, 32), IC0y)

                // Compute the linear combination vk_x
                
                g1_mulAccC(_pVk, IC1x, IC1y, calldataload(add(pubSignals, 0)))
                
                g1_mulAccC(_pVk, IC2x, IC2y, calldataload(add(pubSignals, 32)))
                
                g1_mulAccC(_pVk, IC3x, IC3y, calldataload(add(pubSignals, 64)))
                
                g1_mulAccC(_pVk, IC4x, IC4y, calldataload(add(pubSignals, 96)))
                
                g1_mulAccC(_pVk, IC5x, IC5y, calldataload(add(pubSignals, 128)))
                
                g1_mulAccC(_pVk, IC6x, IC6y, calldataload(add(pubSignals, 160)))
                
                g1_mulAccC(_pVk, IC7x, IC7y, calldataload(add(pubSignals, 192)))
                
                g1_mulAccC(_pVk, IC8x, IC8y, calldataload(add(pubSignals, 224)))
                
                g1_mulAccC(_pVk, IC9x, IC9y, calldataload(add(pubSignals, 256)))
                
                g1_mulAccC(_pVk, IC10x, IC10y, calldataload(add(pubSignals, 288)))
                
                g1_mulAccC(_pVk, IC11x, IC11y, calldataload(add(pubSignals, 320)))
                
                g1_mulAccC(_pVk, IC12x, IC12y, calldataload(add(pubSignals, 352)))
                

                // -A
                mstore(_pPairing, calldataload(pA))
                mstore(add(_pPairing, 32), mod(sub(q, calldataload(add(pA, 32))), q))

                // B
                mstore(add(_pPairing, 64), calldataload(pB))
                mstore(add(_pPairing, 96), calldataload(add(pB, 32)))
                mstore(add(_pPairing, 128), calldataload(add(pB, 64)))
                mstore(add(_pPairing, 160), calldataload(add(pB, 96)))

                // alpha1
                mstore(add(_pPairing, 192), alphax)
                mstore(add(_pPairing, 224), alphay)

                // beta2
                mstore(add(_pPairing, 256), betax1)
                mstore(add(_pPairing, 288), betax2)
                mstore(add(_pPairing, 320), betay1)
                mstore(add(_pPairing, 352), betay2)

                // vk_x
                mstore(add(_pPairing, 384), mload(add(pMem, pVk)))
                mstore(add(_pPairing, 416), mload(add(pMem, add(pVk, 32))))


                // gamma2
                mstore(add(_pPairing, 448), gammax1)
                mstore(add(_pPairing, 480), gammax2)
                mstore(add(_pPairing, 512), gammay1)
                mstore(add(_pPairing, 544), gammay2)

                // C
                mstore(add(_pPairing, 576), calldataload(pC))
                mstore(add(_pPairing, 608), calldataload(add(pC, 32)))

                // delta2
                mstore(add(_pPairing, 640), deltax1)
                mstore(add(_pPairing, 672), deltax2)
                mstore(add(_pPairing, 704), deltay1)
                mstore(add(_pPairing, 736), deltay2)


                let success := staticcall(sub(gas(), 2000), 8, _pPairing, 768, _pPairing, 0x20)

                isOk := and(success, mload(_pPairing))
            }

            let pMem := mload(0x40)
            mstore(0x40, add(pMem, pLastMem))

            // Validate that all evaluations ∈ F
            
            checkField(calldataload(add(_pubSignals, 0)))
            
            checkField(calldataload(add(_pubSignals, 32)))
            
            checkField(calldataload(add(_pubSignals, 64)))
            
            checkField(calldataload(add(_pubSignals, 96)))
            
            checkField(calldataload(add(_pubSignals, 128)))
            
            checkField(calldataload(add(_pubSignals, 160)))
            
            checkField(calldataload(add(_pubSignals, 192)))
            
            checkField(calldataload(add(_pubSignals, 224)))
            
            checkField(calldataload(add(_pubSignals, 256)))
            
            checkField(calldataload(add(_pubSignals, 288)))
            
            checkField(calldataload(add(_pubSignals, 320)))
            
            checkField(calldataload(add(_pubSignals, 352)))
            
            checkField(calldataload(add(_pubSignals, 384)))
            

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }
