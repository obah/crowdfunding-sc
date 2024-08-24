# Week 3 Assessment 2 - Crowdfunding smart contract

This project was created using hardhat.

Ownable and ReentracyGuard contracts were imported from openzeppelin.

Functions - createCampaign() - creates a campaigns
donateToCampaign() - for donations
endCampaign() - to automatically end campaigns and transfer amount raised to benefactor wallet
withdrawRefunds() - a refund mechanism for contract owner to withdraw excess funds and refunds

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.ts
```
