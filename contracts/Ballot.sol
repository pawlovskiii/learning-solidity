// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Ballot {

    struct Voter {
        uint weight;
        bool voted; 
        address delegate; 
        uint vote; 
    }

    struct Proposal {
        string name; 
        uint voteCount; 
    }

    address public chairperson;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    modifier onlyChairperson {
        require(msg.sender == chairperson, "Only chairperson can give right to vote.");
        _;
    }

    modifier voteCheck {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "You have no right to vote!");
        require(!sender.voted, "You already voted!");
        _;
    }

    /*
        Example of proposal names for the constructor to deploy the contract (A, B, C):

        ["proposal_A", "proposal_B", "proposal_C"]
    */ 

    constructor(string[] memory proposalNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        for (uint i = 0; i < proposalNames.length; i++) {
            
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }

    /*
        Example of account addresses from remix IDE to give the right to vote by the chairperson:

        ["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", 
         "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db",
         "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB"]
    */ 

    function giveRightToVote(address[] memory votersList) onlyChairperson external {

        for (uint i = 0; i < votersList.length; i++) {
            require(
                !voters[votersList[i]].voted,
                "The voter already voted."
            );
            require(voters[votersList[i]].weight == 0);
            voters[votersList[i]].weight = 1;
        }
    }

    
    function delegate(address to) voteCheck external {

        require(to != msg.sender, "Self-delegation is disallowed!");

        // Forward the delegation as long as 'to' also delegated.
        // In general, such loops are very dengerous, because if they run too long,
        // they might need more gas that is available in a block.
        // In this case, the delegation will no be executed, but in other situations, such
        // loops might cause a contract to get "stuck" completely.

        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;

            // We found a loop in the delegation, not allowed.
            require(to != msg.sender, "Found loop in delegation.");
        }

        Voter storage delegate_ = voters[to];

        require(delegate_.weight >= 1);

        Voter storage sender = voters[msg.sender];
        sender.voted = true;
        sender.delegate = to;

        if (delegate_.voted) {
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            delegate_.weight += sender.weight;
        }
    }


    function vote(uint proposal) voteCheck external {

        Voter storage sender = voters[msg.sender];

        sender.voted = true;
        sender.vote = proposal;

        proposals[proposal].voteCount += sender.weight;
    }


    function winningProposal() public view returns (uint winningProposal_) {

        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
            
        }
    }

    
    function winnerName() external view returns (string memory winnerName_) {
        winnerName_ = proposals[winningProposal()].name;
    }
}