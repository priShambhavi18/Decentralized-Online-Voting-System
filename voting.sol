// SPDX-License-Identifier: MIT
pragma solidity >0.6.0 <=0.8.21;

contract onlineVotingSystem {
    address ElectionCommission;
    uint256 no_of_constituency;
    uint commencement_Date;
    uint deadline;
    uint Cndidate_dataVerification_strt;
    uint Cndidate_dataVerification_end;
    uint minm_amnt_required;

    constructor(uint256 _noOfConstituency,uint _commencement_Date, uint _deadline,uint _Cndidate_dataVerification_strt,uint _Cndidate_dataVerification_end,uint _minm_amnt_required)
    {
        ElectionCommission = msg.sender;
        no_of_constituency = _noOfConstituency;
        require(block.timestamp<_commencement_Date,"Election shoule be held in future");
        commencement_Date=_commencement_Date;
        deadline=_deadline*24*60*60 + _commencement_Date;
        require(block.timestamp<Cndidate_dataVerification_strt && _Cndidate_dataVerification_strt < _commencement_Date,"Election shoule be held in future");
        Cndidate_dataVerification_strt=_Cndidate_dataVerification_strt;
        Cndidate_dataVerification_end=_Cndidate_dataVerification_end*24*60*60 + Cndidate_dataVerification_strt ;
        minm_amnt_required=_minm_amnt_required;
    }

    struct Parties {
        string party_name;
        address party_id;
        string leader;
        string description;
        string party_motto;
    }

    mapping(address => Parties) public parties;
    mapping(string => address) public partyName;
    mapping(uint=>string) parts;
    string[] public party_array;
    uint256 public numparty;
    function registerParty(string memory _party_name,string memory _leader,string memory _description,string memory _party_motto) public {
        require(block.timestamp<commencement_Date, "Now you cant create your party");
        Parties storage newParty = parties[msg.sender];
        string memory p = newParty.party_name;
        require(bytes(p).length == 0, "You are already registered");

        
        bool nameExists = false;
        for (uint256 i = 0; i < party_array.length; i++) {
            if (keccak256(bytes(party_array[i])) == keccak256(bytes(_party_name))) {
                nameExists = true;
                break;
            }
        }

        require(!nameExists, "Party name already exists");
        newParty.party_id = msg.sender;
        newParty.leader = _leader;
        newParty.party_name = _party_name;
        newParty.description = _description;
        newParty.party_motto = _party_motto;
        partyName[_party_name] = msg.sender;
        party_array.push(_party_name);
        parts[numparty]=_party_name;
        numparty++;
    }

    function updatePartyDetails(string memory _party_name,string memory _leader,string memory _description,string memory _party_motto) public {
        require(block.timestamp<commencement_Date, "Now you cant update your party details");
        address partyOwner =partyName[_party_name];
        require(partyOwner == msg.sender, "Only the party owner can update details");
        parties[msg.sender].leader = _leader;
        parties[msg.sender].description = _description;
        parties[msg.sender].party_motto = _party_motto;
    }
    
    // Getting Constituency Details
    uint constituency_id=1;
    struct Constituency{
        string name;
        uint no_of_seats;
        bool is_exist;
        // party_name => Candidate name
        mapping(string=>string) partiesInConstituency;
        mapping(string=>uint) candidate;
        // partyname => vote
        string[] totalParties;
    }

    mapping(string=>Constituency)  ConstituencyObjects;
    //ConstituencyObjects[constituency_nm].candidate[_party_nm]++;
    mapping(uint=>string) cons;
    string[] public constituency_array;

    function createConstituency(uint noOfSeats,string memory _name) public{
        require(ElectionCommission == msg.sender,"You dont have permission");
        require(constituency_id<=no_of_constituency, "Reached maximum limit of constituency");
        Constituency storage newConstituency = ConstituencyObjects[_name];
        bool nameExists = false;
        for (uint256 i = 0; i < constituency_array.length; i++) {
            if (keccak256(bytes(constituency_array[i])) == keccak256(bytes(_name))) {
                nameExists = true;
                break;
            }
        }

        require(!nameExists, "Constituency name already exists");
        newConstituency.name=_name;
        newConstituency.no_of_seats= noOfSeats;
        constituency_array.push(_name);
        newConstituency.is_exist=true;
        cons[constituency_id] = _name;
        constituency_id++;
    }

    function candidateRegistering(string memory _constituencyName,string memory party_nm,string memory _candidateName,uint _age) public {
        require(block.timestamp<commencement_Date, "Now you cant register for election");
        require(ConstituencyObjects[_constituencyName].is_exist==true,"This Constituency doesn't exist");
        require(_age>25, "Age must be greater thean equal to 25");
        bool nameExists = false;
        for (uint256 i = 0; i < party_array.length; i++) {
            if (keccak256(bytes(party_array[i])) == keccak256(bytes(party_nm))) {
                nameExists = true;
                break;
            }
        }

        require(nameExists, "Party name does not exists");
        ConstituencyObjects[_constituencyName].partiesInConstituency[party_nm]=_candidateName;
        ConstituencyObjects[_constituencyName].totalParties.push(party_nm);
    }

    struct Voter{
        string name;
        address voterId;
        uint age; 
        string constituency_name;
        bool is_voted;
    }

    mapping(address=>Voter) votersdb;

    function createVoter(string memory _constituencyName,string memory _voterName, uint _age) public{
        require(block.timestamp<commencement_Date, "Now you cant register yourself");
        Voter storage newVoter = votersdb[msg.sender];
        require(_age>18, "Age must be greater thean equal to 18");
        require(newVoter.age ==0, "Cant create your profile twice");
        newVoter.name = _voterName;
        newVoter.age = _age;
        newVoter.constituency_name = _constituencyName;
    }
uint public x;
    function castVote(string memory _party_nm) public{
        require(commencement_Date<=block.timestamp && block.timestamp<=deadline, "you cant vote");
        Voter storage newVoter = votersdb[msg.sender];
        require(newVoter.is_voted==false,"You have already cast you vote");
        string memory constituency_nm = newVoter.constituency_name;
        string memory candidate_name = ConstituencyObjects[constituency_nm].partiesInConstituency[_party_nm];
        require(bytes(candidate_name).length != 0,"No candidate of this party participated");
        newVoter.is_voted = true;
        ConstituencyObjects[constituency_nm].candidate[_party_nm]++;
        x=ConstituencyObjects[constituency_nm].candidate[_party_nm];
    }

    //constituencyId => party_id getting max vote 
    mapping(uint=>uint) public party_won;
    //constituencyId => max vote value
    mapping(uint=>uint) public voteGain;

    function voteCountPerConstituency() public {
        require(block.timestamp>deadline, "you can access this after election");
        for(uint i=1; i<=constituency_id; i++){
            uint max_vote;
            uint max_vote_party_won_id;
            for(uint j=0; j<=numparty; j++){
                uint voteCount=ConstituencyObjects[cons[i]].candidate[parts[j]];
                if (voteCount>max_vote){
                    max_vote = voteCount;
                    max_vote_party_won_id=j;
                }
            }
            party_won[i]= max_vote_party_won_id;
            voteGain[i] = max_vote;
        }
    }

    // party_id => no of constituency won
    mapping(uint=>uint) winner;
    uint max=0;
    uint party_id;
    
    uint required_seats=uint((2)*no_of_constituency/3);
    string public winner_party;
    function winnerParty() public returns(string memory){
        require(block.timestamp>deadline, "you can access this after election");
        for(uint i=1;i<=constituency_id;i++){
            uint a =winner[party_won[i]]++;
            if(a>max){
                max=a;
                party_id = party_won[i];
                if(max >= required_seats)
                {
                    break;
                }
            }
        }
        winner_party=parts[party_id];
        return parts[party_id];
    }
}
