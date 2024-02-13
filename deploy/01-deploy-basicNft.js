
module.exports = (async({deployments, getNamedAccounts})=>{
  const {deploy, log} = deployments
  const {deployer} = await getNamedAccounts()

  const arguments  = []

  await deploy("BasicNft", {from:deployer, log:true, args:arguments, waitConfirmations:1})

})
module.exports.tags = ["all", "basicnft"]