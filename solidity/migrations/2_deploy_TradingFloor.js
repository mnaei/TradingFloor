const TradingFloorFactory = artifacts.require("TradingFloorFactory");

module.exports = function (deployer) {
  deployer.deploy(TradingFloorFactory);
};
