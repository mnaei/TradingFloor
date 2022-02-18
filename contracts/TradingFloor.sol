// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC721/IERC721.sol";
import "openzeppelin-solidity/contracts/token/ERC721/IERC721Receiver.sol";

contract TradingFloor is ERC20, IERC721Receiver {

    uint constant ONE = 10**18;
    IERC721 public NFT;
    uint[] public NFTs;

    struct salesRecord {
        address seller;
        uint index;
    }

    mapping(uint => salesRecord) public SalesRecord;

    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }

    constructor(
        string memory _name, 
        string memory _symbol,
        address _nft
    ) 
    ERC20(_name, _symbol) 
    {
        NFT = IERC721(_nft);
    }

    function withdraw() isHuman external {

        uint256 random = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
            block.gaslimit + 
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
            block.number
        )));

        uint256 nftIndex = random % NFTs.length;
        uint256 nftId = NFTs[nftIndex];

        _withdraw(nftIndex, nftId);
    }

    function withdraw(uint _nftId) external {

        salesRecord storage record = SalesRecord[_nftId];

        require(record.seller == _msgSender(), "Only the original seller can withdraw the NFT");
        require(NFTs[record.index] == _nftId, "NFT already sold");

        _withdraw(record.index, _nftId);
    }

    function _withdraw(uint _nftIndex, uint _nftId) internal {

        delete SalesRecord[_nftId];

        uint lastNFTId = NFTs[NFTs.length-1];
        salesRecord storage lastRecord = SalesRecord[lastNFTId];
        lastRecord.index = _nftIndex;

        NFTs[_nftIndex] = NFTs[NFTs.length-1];
        NFTs.pop();

        address sender = _msgSender();
        NFT.safeTransferFrom(address(this), sender, _nftId);
        _burn(sender, ONE);
    }

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _nftId,
        bytes calldata _data
    ) external returns (bytes4) {

        _operator;
        _data;

        require(_msgSender() == address(NFT));

        salesRecord storage record = SalesRecord[_nftId];
        record.seller = _from;
        record.index = NFTs.length;
        NFTs.push(_nftId);

        _mint(_from, ONE);

        return 0x150b7a02;
    }

}
