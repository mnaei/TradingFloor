// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC721/IERC721.sol";
import "openzeppelin-solidity/contracts/token/ERC721/IERC721Receiver.sol";

contract TradingFloor is ERC20, IERC721Receiver {

    uint constant ONE = 10**18;
    IERC721 public NFT;
    uint[] public NFTs;

    constructor(
        string memory _name, 
        string memory _symbol,
        address _nft
    ) 
    ERC20(_name, _symbol) 
    {
        NFT = IERC721(_nft);
    }

    function withdraw() external {
        uint256 tokenId = pop();
        address sender = _msgSender();
        NFT.safeTransferFrom(address(this), sender, tokenId);
        _burn(sender, ONE);
    }

    function pop() internal returns (uint256) {
        uint256 tokenIndex = block.timestamp % NFTs.length;
        uint256 tokenId = NFTs[tokenIndex];
        NFTs[tokenIndex] = NFTs[NFTs.length-1];
        NFTs.pop();
        return tokenId;
    }

    function onERC721Received(
        address,
        address _from,
        uint256 _tokenId,
        bytes calldata 
    ) external returns (bytes4) {
        require(_msgSender() == address(NFT));
        NFTs.push(_tokenId);
        _mint(_from, ONE);
        return 0x150b7a02;
    }

}
