// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;
contract SponsorFunding {
    uint defultPercentage = 25;
    uint contributedSum = 0;
    mapping (address => uint) balance;
    address initiator;

    struct Sponsor {
        address sponsorAddress;
        bool processed;
        uint percentage;
        uint sumContributed;
    }

    Sponsor[] sponsors;
    Sponsor[] sponsorsThatSponsored;

    enum Stages{
        BeforeSponsoring,
        AfterSponsoring
    }

    Stages currentStage;

    constructor (uint chosenPercentage) payable {
        Sponsor memory new_sponsor = Sponsor({sponsorAddress: msg.sender, processed:false, percentage:chosenPercentage, sumContributed: 0});
        sponsors.push(new_sponsor);
        defultPercentage = chosenPercentage;
        currentStage = Stages.BeforeSponsoring;
        balance[msg.sender] += msg.value;
        initiator = msg.sender;
    }

    function exist (address address_) private view returns (bool){
        for (uint i; i< sponsors.length;i++){
            if (sponsors[i].sponsorAddress==address_)
            return true;
        }
        return false;
    }

    function getAccountIndex (address address_) private view returns(uint){
        for (uint i; i< sponsors.length;i++){
            if (sponsors[i].sponsorAddress==address_)
                return i;
        }
        return sponsors.length;
    }

    function getPersonalPercentage() external view returns(uint) {
        require(exist(msg.sender)==true, "you do not have an account");
        uint index = getAccountIndex(msg.sender);
        return sponsors[index].percentage;
    }

    function getPersonalContributedSum() external view returns(uint) {
        require(exist(msg.sender)==true, "you do not have an account");
        uint index = getAccountIndex(msg.sender);
        return sponsors[index].sumContributed;
    }

    function getPersonalBalance() external view returns(uint) {
        require(exist(msg.sender)==true, "you do not have an account");
        return balance[msg.sender];
    }

    function getPersonalProcessed() external view returns(bool) {
        require(exist(msg.sender)==true, "you do not have an account");
        uint index = getAccountIndex(msg.sender);
        return sponsors[index].processed;
    }

    function deposit() public payable {
        require(currentStage==Stages.BeforeSponsoring, "operation not available at this point");
        if(exist(msg.sender)==true) 
            balance[msg.sender] += msg.value;
        else {
            Sponsor memory new_sponsor = Sponsor({sponsorAddress: msg.sender, processed:false, percentage:defultPercentage, sumContributed:0});
            sponsors.push(new_sponsor);
            balance[msg.sender] += msg.value;
        }
    }

    function changePersonalPercentage(uint chosenPercentage) public {
        require(currentStage==Stages.BeforeSponsoring, "operation not available at this point");
        require(exist(msg.sender)==true, "you do not have an account");
        uint index = getAccountIndex(msg.sender);
        sponsors[index].percentage = chosenPercentage;
    }

    function singleSponsorization(uint index, uint256 needed_sum) private returns(bool){
        require(currentStage==Stages.BeforeSponsoring, "operation not available at this point");
        if(balance[sponsors[index].sponsorAddress] <  needed_sum)
            return false;
        balance[sponsors[index].sponsorAddress] = balance[sponsors[index].sponsorAddress] - needed_sum;
        sponsors[index].sumContributed = needed_sum;
        sponsorsThatSponsored.push(sponsors[index]);
        return true;
    }

    function getSponsorsThatSponsored() public view returns(address[] memory, uint[] memory, uint[]memory) {
        require(currentStage==Stages.AfterSponsoring, "operation not available at this point");
        address[] memory sponsorsAddress = new address[](sponsorsThatSponsored.length);
        uint[] memory sponsorPercentage = new uint[](sponsorsThatSponsored.length);
        uint[] memory sponsorSumContributed = new uint[](sponsorsThatSponsored.length);
        for(uint index; index<sponsorsThatSponsored.length; index++)
        {
            sponsorsAddress[index] = sponsorsThatSponsored[index].sponsorAddress;
            sponsorPercentage[index] = sponsorsThatSponsored[index].percentage;
            sponsorSumContributed[index] = sponsorsThatSponsored[index].sumContributed;
        }
        return(sponsorsAddress, sponsorPercentage, sponsorSumContributed);
    }

    function sponsor(uint crowFundingSum) public payable{
        require(msg.sender==initiator, "you don't have the right to call this function");
        require(currentStage==Stages.BeforeSponsoring, "operation not available at this point");
        for (uint i; i< sponsors.length;i++){
            uint256 needed_sum;
            needed_sum = crowFundingSum * sponsors[i].percentage / 100;
            sponsors[i].processed = true;
            if(singleSponsorization(i, needed_sum)==true) {
                contributedSum += needed_sum;
            }
        }
        address payable contract_address = payable(msg.sender);
        currentStage = Stages.AfterSponsoring;
        contract_address.transfer(contributedSum);
        // withTransfer(destination, contributedSum);
    }

    function calculateSum(uint256 totalSum,uint percentage) public pure returns(uint256) {
        uint256 needed_sum;
        needed_sum = totalSum * percentage / 100;
        return(needed_sum);
    }

    function getDefaultPercentage() external view returns(uint) {
        return defultPercentage;
    }

    function getContractBalance() external view returns(uint) {
        return address(this).balance;
    }

    fallback () external {
        revert("");
    }
}