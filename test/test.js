const TradingFloor = artifacts.require("TradingFloor");
const NFT = artifacts.require("NFT");

var tradingFloor
var nft

contract("TradingFloor", async accounts => {

  before("Setup", async function () {
    nft = await NFT.new("VITNFT", "Vitality NFT")
    tradingFloor = await TradingFloor.new("VIT", "Vitality", nft.address)
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

  it("Deposit and withdraw the same NFT", async () => {
    await nft.safeTransferFrom(accounts[0], tradingFloor.address, 2)
    await nft.safeTransferFrom(accounts[0], tradingFloor.address, 4)
    await nft.safeTransferFrom(accounts[0], tradingFloor.address, 3)
    await tradingFloor.withdraw(2)
  });

});