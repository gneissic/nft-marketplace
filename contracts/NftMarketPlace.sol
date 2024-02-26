// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
error NftMarketPlace__PriceMustBeAboveZero();
error NftMarketPlace__NotApprovedForMarketPlace();
error NftMarketPlace__alreadyListed(address nftAddress, uint256 tokenId);
error NftMarketPlace__notOwner();
error NftMarketPlace__notListed(address nftAddress,uint256 tokenId);
error priceNotMet( address nftAddress, uint256 tokenId, uint256 listedItemPrice, uint256 walletBalance);
 error noProceeds();

contract NftMarketPlace is ReentrancyGuard {
  struct Listing {
    uint256 price;
    address seller;
  }
  mapping(address => mapping(uint256 => Listing)) private s_listings;
  mapping(address=> uint256) private s_proceeds;

  event itemListed(
    address indexed seller,
    address indexed nftAddress,
    uint256 indexed tokenId,
    uint256  price
  );

  event NftDeleted(address indexed nftAddress, uint256 indexed tokenId, address indexed nftOnwer);

  event itemBought(address indexed buyer, address indexed nftAddress,uint256 price, uint256 indexed tokenId);
   modifier notListed(address nftAddress, uint256 tokenId, address owner){
    Listing memory listing  = s_listings[nftAddress][tokenId];
    if(listing.price > 0 ){
        revert  NftMarketPlace__alreadyListed(nftAddress, tokenId);
    }
    _;
   }
   modifier isListed(address nftAddress, uint256 tokenId){
    Listing memory listing  = s_listings[nftAddress][tokenId];
    if(listing.price < 0 ){
        revert  NftMarketPlace__notListed(nftAddress, tokenId);
    }
    _;
   }

   modifier onlyOwner(address nftAddress, uint256 tokenId, address spender) {
     IERC721 nft  = IERC721(nftAddress);
     address owner  = nft.ownerOf(tokenId);
     if (spender != owner) {
        revert  NftMarketPlace__notOwner();
     }
     _;
   }
//  / @notice Shows methods for listing your NFT
//  / @param Documents Token id: The id of the NFT
//  / @return Documents price: Sale price of the NFT 
//  / @return Documents ntfAddress: shows the address of the nft
 
  function listItem(
    address nftAddress,
    uint256 tokenId,
    uint256 price
  ) external notListed(nftAddress, tokenId, msg.sender) onlyOwner(nftAddress, tokenId, msg.sender) {
    if (price <= 0) {
      revert NftMarketPlace__PriceMustBeAboveZero();
    }
    IERC721 nft = IERC721(nftAddress);
    if (nft.getApproved(tokenId) != address(this)) {
      revert NftMarketPlace__NotApprovedForMarketPlace();
    }
    s_listings[nftAddress][tokenId] = Listing(price, msg.sender);

    emit itemListed(msg.sender, nftAddress, tokenId, price);
  }
function buyItem(address nftAddress, uint256 tokenId)

 external payable
 isListed(nftAddress, tokenId) nonReentrant(){
  Listing memory listedItem  = s_listings[nftAddress][tokenId];
  if(msg.value < listedItem.price){

  revert  priceNotMet(nftAddress, tokenId, listedItem.price, msg.value);
  }
  s_proceeds[listedItem.seller] = s_proceeds[listedItem.seller] + msg.value;
  delete(s_listings[nftAddress][tokenId]);
  IERC721(nftAddress).transferFrom(listedItem.seller, msg.sender, tokenId);
  emit itemBought(msg.sender, nftAddress, listedItem.price, tokenId);
 
}
function cancelListing(address nftAddress,uint256 tokenId)
 onlyOwner(nftAddress, tokenId, msg.sender) isListed(nftAddress, tokenId) external {
    delete(s_listings[nftAddress][tokenId]);
    emit NftDeleted(nftAddress, tokenId, msg.sender);

}
function updateListing(address nftAddress, uint256 tokenId, uint256 newPrice)
isListed(nftAddress, tokenId)  onlyOwner(nftAddress, tokenId, msg.sender)  external{
    
s_listings[nftAddress][tokenId].price  = newPrice;
emit itemListed(msg.sender, nftAddress, tokenId, newPrice);

}
function withdrawProceeds() external {
    uint256 proceeds  = s_proceeds[msg.sender];
    if(proceeds < 0){
      revert noProceeds();
    }
    s_proceeds[msg.sender]  = 0;
    (bool success, ) = payable(msg.sender).call{value:proceeds}("");
    require(success, "transfer failed");
}


//getter functions

function getListings(address nftAddress, uint256 tokenId) external view returns(Listing memory) {
  return s_listings[nftAddress][tokenId];
}
function getProceeds(address seller)external view returns (uint256) {
 return s_proceeds[seller];
}

}
