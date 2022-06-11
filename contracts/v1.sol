// SPDX-License-Identifier: MIT

//Version C subversion 5
//Chaning token URI to always be the same <--- need to check this 
//Whitelist overrides if set multiple times so only 1 transaction with all addres 
//Crossmint working fully  

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract FonzV1c5 is ERC721, ERC721Enumerable, Ownable {
    bool public saleIsActive = false;
    //string private _baseURIextended;

    bool public isAllowListActive = false;
    uint256 public constant MAX_SUPPLY = 5000;
    uint256 public constant MAX_PUBLIC_MINT = 2;
    uint256 public constant PRICE_PER_TOKEN = 100000000000000000; //in Wei

    mapping(address => uint8) private _allowList;

    constructor() ERC721("FTV1c5", "FV1c5") {
    }

    function setIsAllowListActive(bool _isAllowListActive) external onlyOwner {
        isAllowListActive = _isAllowListActive;
    }

    function setAllowList(address[] calldata addresses, uint8 numAllowedToMint) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            _allowList[addresses[i]] = numAllowedToMint;
        }
    }

    function numAvailableToMint(address addr) external view returns (uint8) {
        return _allowList[addr];
    }

    function mintAllowList(uint8 numberOfTokens) external payable {
        uint256 ts = totalSupply();
        require(isAllowListActive, "Allow list is not active");
        require(_allowList[msg.sender] > 0, "User is not on Whitelist");
        require(numberOfTokens <= _allowList[msg.sender], "Exceeded max available to purchase");
        require(ts + numberOfTokens <= MAX_SUPPLY, "Purchase would exceed max tokens");
        require(PRICE_PER_TOKEN * numberOfTokens <= msg.value, "Ether value sent is not correct");

        _allowList[msg.sender] -= numberOfTokens;
        for (uint256 i = 0; i < numberOfTokens; i++) {
            _safeMint(msg.sender, ts + i);
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    //New function all NFT share same 
       function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        return "ipfs://QmekvbsCsnTYsNhmCohiih8oNFNkw7vyFVGwWz1iaN835R"; //need to change to actual nft 
    }
    
    function reserve(uint256 n) public onlyOwner {
      uint ts = totalSupply();
      require(ts + n <= MAX_SUPPLY, "Purchase would exceed max possible tokens.");
      uint i;
      for (i = 0; i < n; i++) {
          _safeMint(msg.sender, ts + i);
      }
    }

    function setSaleState(bool newState) public onlyOwner {
        saleIsActive = newState;
    }

    function creditCardMint(address to, uint numberOfTokens) external payable {
        uint256 ts = totalSupply();
        address crossmint_eth = 0xdAb1a1854214684acE522439684a145E62505233;
        require(ts + numberOfTokens <= MAX_SUPPLY, "Purchase would exceed max possible tokens. You can get a BCNFT on secondary market!");
        require ( msg.sender == crossmint_eth, "Only crosssmint address can call this function");
        require(saleIsActive, "Sale must be active to mint tokens");
        require(PRICE_PER_TOKEN * numberOfTokens <= msg.value, "Ether value sent is not correct");

        for (uint256 i = 0; i < numberOfTokens; i++) {
            _safeMint(to, ts + i);
        }
       
    }

    function mint(uint numberOfTokens) public payable {
        uint256 ts = totalSupply();
        require(saleIsActive, "Sale must be active to mint tokens");
        require(numberOfTokens <= MAX_PUBLIC_MINT, "Exceeded max token purchase");
        require(balanceOf(msg.sender) < 2,"You have reach your mint limit. Thanks!");
        require(ts + numberOfTokens <= MAX_SUPPLY, "Purchase would exceed max tokens");
        require(PRICE_PER_TOKEN * numberOfTokens <= msg.value, "Ether value sent is not correct");
        
        for (uint256 i = 0; i < numberOfTokens; i++) {
            _safeMint(msg.sender, ts + i);
        }
    }

    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

}