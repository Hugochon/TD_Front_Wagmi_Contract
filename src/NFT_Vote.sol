// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract NFT_Vote is ERC721 {

    uint256 public totalVote = 0;

    // Base URI for metadata
    struct NFTattribue{
        uint256 VoteID;
        address publisher_address;
        uint256 counter_vote_A;
        uint256 counter_vote_B;
        string answer_A;
        string answer_B;
        string desc;
        uint256 starting_time;
        uint256 ending_time;
    }

    // Mapping from token ID to specific information
    mapping(uint256 => NFTattribue) public nftattribues;
    mapping(address => mapping(uint256 => bool)) public alreadyVoted;
    mapping(address => uint256[]) public userVotes;

	constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        
	}
	
	function initialize_vote(string memory answer_a,string memory answer_b, string memory desc, uint256 ending_time) external {
    totalVote++;
    _mint(address(this), totalVote);

    require(ending_time > block.timestamp, "Ending time must be in the future");
    nftattribues[totalVote] = NFTattribue(totalVote,msg.sender,0,0,answer_a,answer_b,desc,block.timestamp,ending_time) ;

    }

    function increase_vote(uint256 VoteID, bool a_or_b) external {

        require(!alreadyVoted[msg.sender][VoteID], "You have already voted");
        if(a_or_b){
            nftattribues[VoteID].counter_vote_A++;
        }else{
            nftattribues[VoteID].counter_vote_B++;
        }
        userVotes[msg.sender].push(VoteID);
        alreadyVoted[msg.sender][VoteID] = true;
    }

    
    function get_Vote_Infos(uint256 VoteID) public view returns (uint256,address, uint256 , uint256 ,  string memory , string memory , string memory, uint256 , uint256) 
    {     
        NFTattribue memory attrib = nftattribues[VoteID];     
        return (attrib.VoteID,attrib.publisher_address, attrib.counter_vote_A, attrib.counter_vote_B, attrib.answer_A,attrib.answer_B, attrib.desc,attrib.starting_time,attrib.ending_time); 
    }

    function get_All_Votes_from_User(address user) public view returns (uint256[] memory) 
    {     
        return userVotes[user]; 
    }

    function update_Active_Vote() public view returns (uint256[] memory) {
    uint256[] memory activeVotes = new uint256[](totalVote); // Allocate memory for the array

    uint256 count = 0; // Counter for active votes

    for (uint256 i = 1; i <= totalVote; i++) {
        if (nftattribues[i].ending_time > block.timestamp) {
            activeVotes[count] = i;
            count++;
        }
    }

    if (count == 0) {
        // If no active votes, return an array with a placeholder (0)
        return new uint256[](1);
    }

    // Resize the array to remove unused slots
    assembly {
        mstore(activeVotes, count)
    }

    return activeVotes;
}



}