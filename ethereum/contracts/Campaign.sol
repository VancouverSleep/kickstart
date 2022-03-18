pragma solidity ^0.4.17;

contract CampaingFactory {
    address[] public deployedCampaigns;

    function createCampaign (uint minAmount) public payable {
        deployedCampaigns.push(
            new Campaign(minAmount, msg.sender)
        );
    }

    function getDeployedCampaigns () public view returns (address[]) {
        return deployedCampaigns;
    }
}

contract Campaign {
    address public manager;
    uint public minimumCOntribution;
    mapping(address => bool) public approvers;
    uint public approversCount;
    Request[] public requests;

    function Campaign (uint minimum, address creator) public {
        manager = creator;
        minimumCOntribution = minimum;
    }

    function contribute () public payable {
        require(msg.value > minimumCOntribution);
        approvers[msg.sender] = true;
        approversCount++;
    }

    function createRequest(string description, uint value, address recipient)
        public restricted {
            requests.push( Request({
                description: description,
                value: value,
                recipient: recipient,
                complete: false,
                approvalCount: 0
            }));
    }

    function approveRequest(uint index) public  {
        Request storage request = requests[index];

        require(approvers[msg.sender]);
        require(!request.votes[msg.sender]);
        request.votes[msg.sender] = true;
        request.approvalCount++;
        
    }

    function finalizeRequest (uint index) public restricted {
        Request storage request = requests[index];
        require(!request.complete);
        require(request.approvalCount > (approversCount / 2));

        request.recipient.transfer(request.value);
        request.complete = true;
    }

    modifier restricted {
        require(msg.sender == manager);
        _;
    }
    

    struct Request {
        string description;
        address recipient;
        uint value;
        bool complete;
        mapping(address => bool) votes;
        uint approvalCount;
    }

}