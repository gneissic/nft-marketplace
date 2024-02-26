const { network } = require("hardhat")





module.exports = (async({deployments, getNamedAccounts})=>{
  const {deploy, log} = deployments
  const {deployer} = await getNamedAccounts()

  const arguments  = []

  const basicNft =  await deploy("BasicNft", {from:deployer, log:true, args:arguments, waitConfirmations:1})
 
})



module.exports.tags = ["all", "basicnft"]