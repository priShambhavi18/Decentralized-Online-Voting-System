// SPDX-License-Identifier: MIT
pragma solidity >0.6.0 <=0.8.21;
contract voting {
    uint public _deadline;
    uint public total_seats_available;

    constructor(uint dt,uint total_seats)
    {
        total_seats_available=total_seats;
        _deadline=block.timestamp+dt;
    }

	struct Voterdb{
		string voterName;
		uint age;
		string uId;
		uint mobile_number;
        bool isind;
        bool isvoted;
        address voterid;
	}
	mapping(address=>Voterdb) voterdatabase;

	struct parties {
		string party_name;
		uint age;
		string mla;
		uint no_of_votes;
		bool is_indian;
		bool is_voter;
	}
	uint public no_of_voters;
    uint public no_of_parties;
	mapping(uint=>parties) partiesDatabase;

	function voterDetails(string memory _vnm, uint _age, string memory _uid, uint _mno,bool _cznship) public
	{
		Voterdb storage newvoterdb=voterdatabase[msg.sender];
        string memory p=newvoterdb.uId;
        require(bytes(p).length==0, "You are already registered");
		newvoterdb.voterName=_vnm;
        require(_age>=18,"Age should be greater than and equal to 18");
		newvoterdb.age=_age;
		newvoterdb.uId=_uid;
		newvoterdb.mobile_number=_mno;
        newvoterdb.voterid=msg.sender;
        require(_cznship == true,"You need a citizenship of India");
		newvoterdb.isind=true;

	}
    uint public numreq=0;
	function PartymemDetails(string memory _pnm, uint _age, string memory _mla,bool _cznship, bool isvoter) public
	{
        parties storage p= partiesDatabase[numreq];
        numreq++;
		p.party_name=_pnm;
		p.mla=_mla;
		//require(_secDep==10,"You need to deposit 100 wei to become a party member");
		//p.security_deposit=_secDep;
		require(_age >= 25,"Age should be greater than equal to 25");
		p.age=_age;
        require(_cznship == true,"You need a citizenship of India");
		p.is_indian=true;
        require(isvoter == true,"You must be a voter");
        p.is_voter=true;
        no_of_parties++;
	}

	function casteVote(uint _partytovote) public
	{
        address curr_voter=msg.sender;
        require(block.timestamp<_deadline,"Date is already passed");
        require(voterdatabase[curr_voter].age >= 18,"You must have a voter id to caste a vote");
        require(voterdatabase[curr_voter].isvoted==false,"You can only cast a single vote");
        voterdatabase[curr_voter].isvoted=true;
        partiesDatabase[_partytovote].no_of_votes+=1;
        no_of_voters++;
	}	

    function winner() public view returns (string memory)
    {
        uint i;
        uint required_vote=uint((2)*total_seats_available/3);
        for(i=0;i<=no_of_parties;i++)
        {
            if(partiesDatabase[i].no_of_votes>=required_vote)
            {
                return partiesDatabase[i].party_name;
            }
        }
        return "no party gets majority";
    }
}
