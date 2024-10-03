// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface IOneUserOpPolicyVerifier {
    function verifyProof(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[8] memory input
    ) external view returns (bool);
}

interface ITwoUserOpPolicyVerifier {
    function verifyProof(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[12] memory input
    ) external view returns (bool);
}



