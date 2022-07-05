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
        bytes32 name; 
        uint voteCount; 
    }

    address public chairperson;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    /*
        Example of proposal names for the constructor to deploy the contract (A, B, C):

        ["0x50726f706f73616c204100000000000000000000000000000000000000000000", 
         "0x50726f706f73616c204200000000000000000000000000000000000000000000",
         "0x50726f706f73616c204300000000000000000000000000000000000000000000"]
    */ 

    constructor(bytes32[] memory proposalNames) {
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

    function giveRightToVote(address[] memory votersList) external {

        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote."
        );

        for (uint i = 0; i < votersList.length; i++) {
            require(
                !voters[votersList[i]].voted,
                "The voter already voted."
            );
            require(voters[votersList[i]].weight == 0);
            voters[votersList[i]].weight = 1;
        }
    }

    
    function delegate(address to) external {

        // assigns reference
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "You have no right to vote!");
        require(!sender.voted, "You already voted!");

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

        // Voters cannot delegate to accounts that cannot vote.
        require(delegate_.weight >= 1);

        // Since 'sender' is a reference, this modifies 'voters[msg.sender]'.
        sender.voted = true;
        sender.delegate = to;

        if (delegate_.voted) {
            // If the delegate already voted, directly add to the number of votes
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            // If the delegate did not vote yet, add to her weight.
            delegate_.weight += sender.weight;
        }
    }

    // Give your vote (including votes delegated to you)
    // to proposal 'proposals[proposal].name'
    function vote(uint proposal) external {

        Voter storage sender = voters[msg.sender];

        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");

        sender.voted = true;
        sender.vote = proposal;

        // If 'proposal' is out of the range of the array,
        // this will throw automatically and revert all changes.
        proposals[proposal].voteCount += sender.weight;
    }

    // @dev Computes the winning proposal taking all
    // previous votes into account.
    function winningProposal() public view returns (uint winningProposal_) {

        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
            
        }
    }

    // Calls winningProposal() function to get the index
    // of the winner contained in the proposals array and then
    // returns the name of the winner
    function winnerName() external view returns (bytes32 winnerName_) {
        winnerName_ = proposals[winningProposal()].name;
    }
}
