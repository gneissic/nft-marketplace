const { ethers } = require("hardhat");
const PRICE  = ethers.utils.parseEther("0.1")

async function mintAndList() {
    const nftMarketPalce  = await ethers.getContract("NftMarketPlace")
    const basicNft  = await ethers.getContract("BasicNft")
    console.log("minting nft....");
    const mintTx = await basicNft.mintNft()
    const mintTxReciept  = await mintTx.wait(1)
    const tokenId  = await mintTxReciept.events[0].args.tokenId.toString()
    console.log("approving...");
    const approveTx  = await basicNft.approve(nftMarketPalce.address, tokenId)
    await approveTx.wait(1)
    console.log("listing item...");
   const listTx = await nftMarketPalce.listItem(basicNft.address, tokenId, PRICE)
   await listTx.wait(1)
   console.log("item listed!");

}

mintAndList()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
