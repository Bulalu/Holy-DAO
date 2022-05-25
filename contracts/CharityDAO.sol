// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";



contract CharityDAO is ReentrancyGuard, AccessControl {
    
    using Counters for Counters.Counter;
    Counters.Counter internal numOfProposals;


    bytes32 public constant CONTRIBUTER_ROLE = keccak256("CONTRIBUTOR");
    bytes32 public constant STAKEHOLDER_ROLE = keccak256("STAKEHOLDER");
    uint32 constant minimumVotingPeriod = 1 weeks;
    

    struct CharityProposal {
        uint256 id;
        uint256 amount;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 livePeriod;
        string description;
        bool votingPassed;
        bool paid;
        address payable charityAddress;
        address proposer;
        address paidBy;
        
    }

    mapping(uint256 => CharityProposal) private charityProposals;
    mapping(address => uint256[]) private stakeholderVotes;
    mapping(address => uint256) private contributors;
    mapping(address => uint256) private stakeHolders;

    event ContributionReceived(address indexed fromAddress, uint256 amount);
    event NewCharityProposal(address indexed proposer, uint256 amount);
    event PaymentTransfered(
        address indexed stakeholder,
        address indexed charityAddress,
        uint256 amount
    );


    modifier onlyStakeholder(string memory message) {
        require(hasRole(STAKEHOLDER_ROLE, msg.sender), message);
        _;
    }

    modifier onlyContributor(string memory message) {
        require(hasRole(CONTRIBUTER_ROLE, msg.sender), message);
        _;
    }

    function createProposal(
        string calldata description,
        address charityAddress,
        uint256 amount
    ) 
        external
        onlyStakeholder("Sorry Louis, only stakeHolders can create proposals, giggity!")
        {   

            numOfProposals.increment();
            uint256 proposalId = numOfProposals.current();
            
            CharityProposal storage proposal = charityProposals[proposalId];
            proposal.id = proposalId;
            proposal.description = description;
            proposal.charityAddress = payable(charityAddress);
            proposal.proposer = payable(msg.sender);
            proposal.livePeriod = block.timestamp + minimumVotingPeriod;

            emit NewCharityProposal(msg.sender, amount);

        }

    function vote(uint256 proposalId, bool supportProposal) external onlyStakeholder("Only stake holders are allowed to vote") {
        
        CharityProposal storage charityProposal = charityProposals[proposalId];
        
        votable(charityProposal);

        if (supportProposal) charityProposal.votesFor++;
        else charityProposal.votesAgainst++;

        stakeholderVotes[msg.sender].push(charityProposal.id);

    }

    function votable(CharityProposal storage charityProposal) private {
        if(
            charityProposal.votingPassed || charityProposal.livePeriod <= block.timestamp
        ) {
            charityProposal.votingPassed = true;
            revert("Voting period has passed on this proposal");
        }

        uint256[] memory Votes = stakeholderVotes[msg.sender];
        for(uint256 index=0; index < Votes.length; index++) {
            if(charityProposal.id == Votes[index]) {
                revert("You have already voted on this proposal");
            }
        }
    }

    // must it be after the voting period has ended?
    // one time thing?
    // only admin?
    function payCharity(uint256 proposalId) external onlyStakeholder("Only stakeholders are allowed to make payments") {

        CharityProposal storage charityProposal = charityProposals[proposalId];

        if(charityProposal.paid) revert("Payment has already been made to this charity");

        if( charityProposal.votesFor <= charityProposal.votesAgainst) 
            revert("The proposal does not enough votes to be paid for");

        charityProposal.paid = true;
        charityProposal.paidBy = msg.sender;

        emit PaymentTransfered(msg.sender, charityProposal.charityAddress, charityProposal.amount);


        return charityProposal.charityAddress.transfer(charityProposal.amount);

    }

    receive() external payable {
        emit ContributionReceived(msg.sender, msg.value);
    }

    function makeStakeholder(uint256 amount) external {
        address account = msg.sender;
        uint256 amountContributed = amount;

        // think more 
        if (!hasRole(STAKEHOLDER_ROLE, account)) {
            uint256 totalContributed = contributors[account] + amountContributed;

            if (totalContributed >= 5 ether) {
                stakeHolders[account] = totalContributed;
                contributors[account] += amountContributed;
                _setupRole(STAKEHOLDER_ROLE, account);
                _setupRole(CONTRIBUTER_ROLE, account);
            } else {
                contributors[account] += amountContributed;
                _setupRole(CONTRIBUTER_ROLE, account);
            }
        }
    }

    
}