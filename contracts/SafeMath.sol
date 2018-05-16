pragma solidity ^0.4.23;

// safemath for signed and unsigned ints, divide is unnecessary because EVM already throws when dividing by 0
// change functions to public instead of internal to use as a deployed library instead of inlining bytecode
// change library to contract to inherit it

library SafeMath {

    function plus(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function plus(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        assert((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function minus(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(a >= b);
        return a - b;
    }

    function minus(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        assert((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function times(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function times(int256 a, int256 b) internal pure returns (int256) {
        if (a == 0) {
            return 0;
        }
        int256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function toInt256(uint256 a) internal pure returns (int256) {
        assert(a <= 2 ** 255);
        return int256(a);
    }

    function toUint256(int256 a) internal pure returns (uint256) {
        assert(a >= 0);
        return uint256(a);
    }

}
