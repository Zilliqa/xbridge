// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract BridgedTokenV2 is ERC20, ERC20Burnable, Ownable {
    uint8 private immutable _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) ERC20(name_, symbol_) Ownable(_msgSender()) {
        _decimals = decimals_;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function circulatingSupply() external view returns (uint256 amount) {
        return totalSupply();
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(uint256 value) public override onlyOwner {
        super.burn(value);
    }

    function burnFrom(
        address account,
        uint256 value
    ) public override onlyOwner {
        super.burnFrom(account, value);
    }

    function transfer(
        address to,
        uint256 value
    ) public override returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override returns (bool) {
        return super.transferFrom(from, to, value);
    }
}
