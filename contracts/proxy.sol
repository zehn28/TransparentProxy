// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


contract Proxy {
    bytes32 private constant IMPLEMENTATION_SLOT =
        bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
    bytes32 private constant ADMIN_SLOT =
        bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

    constructor() {
        _setAdmin(msg.sender);
    }

    // User interface //
    function _delegate(address _implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(
                gas(),
                _implementation,
                0,
                calldatasize(),
                0,
                0
            )

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    fallback() external payable {
        _delegate(_getImplementation());
    }

    receive() external payable {
        _delegate(_getImplementation());
    }

    function upgradeTo(address _implementation) external {
        require(msg.sender == _getAdmin(), "not Admin");
        _setImplementation(_implementation);
    }

    function _getAdmin() private view returns (address) {
        return StorageSlot.getAddressSlot(ADMIN_SLOT).value;
    }

    function _setAdmin(address _admin) private {
        require(_admin != address(0), "Address ZERO");
        StorageSlot.getAddressSlot(ADMIN_SLOT).value = _admin;
    }

    function _getImplementation() private view returns (address) {
        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address _implementation) private {
        require(_implementation.code.length > 0, "Address ZERO");
        StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = _implementation;
    }

    function getAdmin() external view returns(address) {
        return _getAdmin();
    }

    function getImplementation() external view returns(address) {
        return _getImplementation();
    }
}

library StorageSlot {
    struct AddressSlot {
        address value;
    }

    function getAddressSlot(bytes32 slot)
        internal
        pure
        returns (AddressSlot storage r)
    {
        assembly {
            r.slot := slot
        }
    }
}

contract TestSlot {
    bytes32 public constant SLOT = keccak256("TEST_SLOT");

    function getSlot() external view returns (address) {
        return StorageSlot.getAddressSlot(SLOT).value;
    }

    function writeSlot(address addr) external {
        StorageSlot.getAddressSlot(SLOT).value = addr;
    }
}
