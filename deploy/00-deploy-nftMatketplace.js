const { network } = require("hardhat")
const { developmentChains } = require("../hardhat-helperConfig")
const { verify } = require("../utils/verify")

module.exports = (async({getNamedAccounts, deployments})=>{
const {deploy, log} = deployments
const {deployer} = await getNamedAccounts()

const arguments = []

const nftMarketPlace = await deploy("NftMarketPlace", {
    from:deployer,
    log:true,
    waitConfirmations: developmentChains.includes(network.name)
        ? 1
        : 6,
    args:arguments
})

if (!developmentChains.includes(network.name)  && process.env.ETHERSCAN_API_KEY) {
    await verify(nftMarketPlace.address, arguments)
}

console.log("____________________");
})
module.exports.tags = ["all", "nftmarketplace"]


