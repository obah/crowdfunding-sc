// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract CrowdFund is Ownable, ReentrancyGuard {
    event CampaignCreated(
        uint256 indexed campaignId,
        string indexed title,
        uint256 deadline,
        address creator
    );
    event DonationReceived(
        uint256 amount,
        uint256 indexed campaignId,
        uint256 indexed timeDonated
    );
    event CampaignEnded(
        uint256 indexed timeEnded,
        bool indexed goalReached,
        uint256 indexed campaignId
    );
    event FundsWithdrawn(uint256 amount, uint256 indexed timeWithdrawn);

    /// @dev structure of a campaign
    struct Campaign {
        string title;
        string description;
        address benefactor;
        uint256 goal;
        uint256 deadline;
        uint256 amountRaised;
    }

    mapping(uint256 => Campaign) public campaigns;

    ///@dev keep track of number of campaigns
    uint256 public numOfCampaigns;

    constructor(address initialOwner) Ownable(initialOwner) {}

    receive() external payable {}

    //@dev createCampaign() allows a user to create campaign
    //@params all params needed to create a campaigns
    function createCampaign(
        string calldata _title,
        string calldata _description,
        address _benefactor,
        uint256 _goal,
        uint256 _duration
    ) external {
        require(_goal > 0, "Amount to raise must be greater than 0!");

        Campaign storage campaign = campaigns[numOfCampaigns];

        uint256 _deadline = block.timestamp + _duration;

        campaign.title = _title;
        campaign.description = _description;
        campaign.benefactor = _benefactor;
        campaign.goal = _goal;
        campaign.deadline = _deadline;

        numOfCampaigns++;

        uint256 campaignId = numOfCampaigns - 1;

        emit CampaignCreated(
            campaignId,
            campaign.title,
            campaign.deadline,
            msg.sender
        );
    }

    //@dev donateToCampaign() allows a user to donate to a campaign
    //@params - campaignId of the campaign receiving donation
    function donateToCampaign(
        uint256 campaignId
    ) external payable nonReentrant {
        Campaign storage campaign = campaigns[campaignId];

        require(
            block.timestamp < campaign.deadline,
            "This campaign has closed!"
        );

        campaign.amountRaised += msg.value;

        emit DonationReceived(msg.value, campaignId, block.timestamp);
    }

    //@dev endCampaign() ends a campaign
    //@params - campaignId of the campaign to end
    function endCampaign(uint256 campaignId) internal nonReentrant {
        Campaign storage campaign = campaigns[campaignId];

        require(
            campaign.deadline >= block.timestamp,
            "This campaign is yet to end!"
        );

        uint256 amount = campaign.amountRaised;
        address benefactor = campaign.benefactor;
        bool goalReached;

        if (amount >= campaign.goal) {
            goalReached = true;
        } else {
            goalReached = false;
        }

        (bool sent, ) = benefactor.call{value: amount}("");
        require(sent, "Failed to send ether to benefactor!");

        emit CampaignEnded(block.timestamp, goalReached, campaignId);
    }

    ///

    ///@dev checkCampaigns() automatically tries to end all campaigns by calling endCampaign()
    function checkCampaigns() public nonReentrant {
        for (uint i; i <= numOfCampaigns; i++) {
            endCampaign(i);
        }
    }

    function withdrawRefunds() external onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        (bool sent, ) = msg.sender.call{value: balance}("");
        require(sent, "Failed to withdraw ether!");

        emit FundsWithdrawn(balance, block.timestamp);
    }

    fallback() external payable {}
}
