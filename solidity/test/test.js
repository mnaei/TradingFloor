const TradingFloor = artifacts.require("TradingFloor");
const TradingFloorFactory = artifacts.require("TradingFloorFactory");
const NFT = artifacts.require("NFT");

var tradingFloor
var nft

contract("TradingFloor", async accounts => {

  before("Setup", async function () {

    nft = await NFT.new("VITNFT", "Vitality NFT")
    factory = await TradingFloorFactory.new()

    await factory.createTradingFloor("VIT", "Vitality Floor", nft.address)
    tradingFloorStruct = await factory.Floors(0)
    tradingFloorAddress = tradingFloorStruct.floor
    tradingFloor = await TradingFloor.at(tradingFloorAddress)

    for (let i = 0; i < 5; i++) {
      await nft.mint(accounts[0], i)
    }
  });

  it("Deposit", async () => {
    await nft.safeTransferFrom(accounts[0], tradingFloor.address, 1)
    balanceERC20 = await tradingFloor.balanceOf(accounts[0])
    assert.equal(String(10**18), balanceERC20.toString())
    balanceERC721 = await nft.balanceOf(accounts[0])
    assert.equal(String(4), balanceERC721.toString())
  });

  it("Withdraw", async () => {
    await tradingFloor.withdraw()
    balanceERC20 = await tradingFloor.balanceOf(accounts[0])
    assert.equal(String(0), balanceERC20.toString())
    balanceERC721 = await nft.balanceOf(accounts[0])
    assert.equal(String(5), balanceERC721.toString())
  });

  it("Withdraw fail with no erc20 tokens", async () => {
    // https://ethereum.stackexchange.com/a/56535
    try {
        await tradingFloor.withdraw()
        assert.fail("The transaction should have thrown an error");
    }
    catch (err) {
        assert.include(err.message, "revert", "The error message should contain 'revert'");
    }
  });

});