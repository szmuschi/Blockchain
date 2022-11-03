// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract DistributeFunding{
    struct recipient{
        string name;
        int share;
        bool withdrawn;
        bool registered;
    }
    uint256 receivedBalance;
    address payable owner;
    int totalPercentage;
    int recipientPercentage;
    address payable[] recipientAdresses;
    mapping (address => recipient) recipientInfo;

    bool readyToDistribute;

    constructor() {
        totalPercentage = 0;
        receivedBalance = 0;
        readyToDistribute = false;
        recipientPercentage = 20;
    }

    function addRecipient(string memory recipientName) public {
        require(readyToDistribute == false, "Recipients can not be registered once funding has finished");
        require(recipientInfo[msg.sender].registered == false, "Recipient already registered");
        require(verifyPercentage(recipientPercentage) == true, "Maximum number of beneficiaries has been reached");
        recipientAdresses.push(payable(msg.sender));
        recipientInfo[msg.sender] = recipient({
            name: recipientName,
            share: recipientPercentage,
            withdrawn: false,
            registered: true
        });
    }

    function getAmount() public view returns (uint256) {
        return address(this).balance;
    }

    function getAddresses() public view returns (address payable[] memory) {
        return recipientAdresses;
    }

    function verifyPercentage(int percent) private returns (bool) {
        if(totalPercentage + percent <= 100){
            totalPercentage += percent;
            return true;
        }
        return false;
    }

    function withdrawAmount() public payable{
        require(readyToDistribute == true, "Must wait until funding finished before funds can be withdrawn");
        require(recipientInfo[msg.sender].withdrawn == false, "You can withdraw funds only once");
        require(recipientInfo[msg.sender].registered == true, "Recipient must be registered in order to withdraw");
        uint256 sharedSum;
        sharedSum = uint256((int(receivedBalance) * recipientInfo[msg.sender].share) / 100);
        address payable user = payable(msg.sender);
        user.transfer(sharedSum);
        recipientInfo[msg.sender].withdrawn = true;
    }

    function notifyFundingFinish() public {
        receivedBalance = getAmount();
        readyToDistribute = true;
    }

    receive() external payable {}
}