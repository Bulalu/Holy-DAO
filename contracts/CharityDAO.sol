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

    mapping(uint256 => CharityProposal) private charityProposal;
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
            
            CharityProposal storage proposal = charityProposal[proposalId];
            proposal.id = proposalId;
            proposal.description = description;
            proposal.charityAddress = payable(charityAddress);
            proposal.proposer = payable(msg.sender);
            proposal.livePeriod = block.timestamp + minimumVotingPeriod;

            emit NewCharityProposal(msg.sender, amount);

        }

    function vote(uint256 proposalId, bool supportProposal) external onlyStakeHolder("Only stake holders are allowed to vote") {
        
        CharityProposal storage charityProposal = charityProposals[proposalId];
        
        votable(charityProposal)
    
}