import { expect } from "chai";
import { ethers } from "hardhat";
import { SportsBetting } from "../typechain-types";

describe("SportsBetting", function () {
  let sportsBetting: SportsBetting;
  let owner: any;
  let bettor1: any;
  const minimumBet = ethers.utils.parseEther("0.01"); // 0.01 ETH

  before(async () => {
    [owner, bettor1] = await ethers.getSigners();
    const sportsBettingFactory = await ethers.getContractFactory("SportsBetting");
    sportsBetting = (await sportsBettingFactory.deploy(minimumBet)) as SportsBetting;
    await sportsBetting.deployed();
  });

  it("should allow the owner to add an event", async () => {
    await sportsBetting.connect(owner).addEvent("Soccer Match 1");
    const event = await sportsBetting.events(0);
    expect(event.name).to.equal("Soccer Match 1");
  });

  it("should allow users to place bets", async () => {
    await sportsBetting.connect(owner).addEvent("Soccer Match 2");
    await sportsBetting.connect(bettor1).placeBet(1, 1, { value: minimumBet });
    const betData = await sportsBetting.getBetData(1, bettor1.address);
    expect(betData.amount).to.equal(minimumBet);
  });

  it("should correctly calculate odds", async () => {
    await sportsBetting.connect(owner).addEvent("Soccer Match 3");
    await sportsBetting.connect(bettor1).placeBet(2, 1, { value: minimumBet });
    const betData = await sportsBetting.getBetData(2, bettor1.address);
    expect(betData.odds).to.equal(100);
  });

  it("should settle bets correctly", async () => {
    await sportsBetting.connect(owner).addEvent("Soccer Match 4");
    await sportsBetting.connect(bettor1).placeBet(3, 1, { value: minimumBet });
    await sportsBetting.connect(owner).settleEvent(3, 1);

    const eventData = await sportsBetting.getEventData(3);
    expect(eventData.isFinished).to.be.true;
  });
});
