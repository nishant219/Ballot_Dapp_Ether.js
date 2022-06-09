// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract Ballot {
    struct Voter {
        uint256 weight;
        bool voted;
        address delegate;
        uint256 vote;
    }
    struct Proposal {
        string name;
        uint256 voteCount;
    }

    address public chairPerson;

    mapping(address => Voter) public voters;

    Proposal[] public proposals;

    //constructor() public{
    constructor(){
        string[3] memory proposalNames = ["Mangoes", "Apples", "Grapes"];
        chairPerson = msg.sender;
        voters[chairPerson].weight = 1;
        for (uint256 i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({name: proposalNames[i], voteCount: 0}));
        }
    }

    function giveRightToVote(address voter) public {
        require(msg.sender == chairPerson, "Only chairPerson can give vote");
        require(!voters[voter].voted, "The Voter already voted");
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    function delegate(address to) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "you already voted");
        require(to != msg.sender, "self delegation is not allowed");

        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            require(to != msg.sender, "found loop in the delegation");
        }

        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];
        if (delegate_.voted) {
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            delegate_.weight += sender.weight;
        }
    }

    function vote(uint256 proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "No right to vote");
        require(!sender.voted, "Already Voted");
        sender.voted = true;
        proposals[proposal].voteCount += sender.weight;
    }

    function winningProposal() public view returns (uint256 winningProposal_) {
        uint256 winningVoteCount = 0;
        for (uint256 p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    function winnername() public view returns (string memory winnername_) {
        winnername_ = proposals[winningProposal()].name;
    }
}
