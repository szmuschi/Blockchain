// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "./SponsorFunding.sol";
import "./DistributeFunding.sol";

contract CrowdFunding {

    // Funding information
    // address payable crowdFundingAdress; // Asta nu e necesara. Contractele au o adresa proprie si se poate depozita acolo
    fundStates state;
    int fundingGoal;

    //Contributor information
    address[] contributorAdresses;
    mapping (address => contributor) contributorDetails;

    //Instances of the other needed classes
    SponsorFunding sponsorFunding;
    DistributeFunding distributeFunding;

    constructor(int goal) {
        state = fundStates.nefinantat;
        fundingGoal = goal;
        sponsorFunding = new SponsorFunding(50);
        distributeFunding = new DistributeFunding();
    }

    struct contributor {
        string name;
        uint256 contrinutedAmount;
        bool registered;
    }

    enum fundStates{ nefinantat, prefintat, finantat }

    function getSponsorFundingAddress() public view returns(address) {
        return address(sponsorFunding);
    }

    function getFundsAmount() public view returns (uint256) {
        // return crowdFundingAdress.balance;
        return address(this).balance;
    }

    function getFundState() public view returns (fundStates) {
        return state;
    }

    function addContributor(string memory contrinutorName) public {
        contributorAdresses.push(msg.sender);
        contributorDetails[msg.sender] = contributor({name:contrinutorName, contrinutedAmount:0, registered:true});
    }

    function contribute() payable public {
        require(state == fundStates.nefinantat, "Contributions are no longer accepted");
        require(contributorDetails[msg.sender].registered == true, "You were not registered as a contributor");
        //payable(address(this)).transfer(msg.value); // Nu-i nevoie sa faci asta ca se face automat

        contributorDetails[msg.sender].contrinutedAmount += msg.value;
        // if ( int(sponsorFunding.getBalance() + this.getFundsAmount()) >= fundingGoal){
        if ( int(getSponsorFundingBalance() + this.getFundsAmount()) >= fundingGoal){
            state = fundStates.prefintat;
        }
    }

    function retrieveFunds(uint256 amount) payable public{
        require(state == fundStates.nefinantat, "Retrivals are no longer accepted");
        require(contributorDetails[msg.sender].registered == true, "You were not registered as a contributor");
        require(int(contributorDetails[msg.sender].contrinutedAmount) >= int(amount), "You can not retrive more than was deposited");
        address payable user = payable(msg.sender);
        user.transfer(amount);
    }

    function processPrefundedState() public payable {
        require(state == fundStates.prefintat, "Can't end crowdFunding before collection of funds finished");
        getSponsorization();
        state = fundStates.finantat;
    }

    function processFundedState() public payable {
        require(state == fundStates.finantat, "Can't distribute funds until sponsorization is finished");

        payable(address(getDistributeFundingAddress())).transfer(this.getFundsAmount());
        distributeFunding.notifyFundingFinish();
    }

    function getSponsorization() private{
        sponsorFunding.sponsor(getFundsAmount());
    }

    function getdistributeFundingState() public view returns (uint256) {
        return address(distributeFunding).balance;
    }

    function getSponsorFundingBalance() view public returns(uint) {
        return sponsorFunding.getContractBalance();
    }

    function getDistributeFundingAddress() public view returns(address) {
        return address(distributeFunding);
    }

    fallback () external {
        revert("");
    }

    receive() external payable {}
}
