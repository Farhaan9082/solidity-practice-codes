// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract KidsBank {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    struct kid {
        string firstName;
        string lastName;
        uint256 amount;
        bool canWithdrawMoney;
        uint256 allowWithdrawTime;
        bool kidExists;
    }

    mapping(address => kid) public kids;

    modifier isOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    modifier ifKidExists(address _walletAddress) {
        require(kids[_walletAddress].kidExists, "Kid does not exist");
        _;
    }

    function addKid(
        address _walletAddress,
        string memory _firstName,
        string memory _lastName,
        bool _canWithdrawMoney,
        uint256 _allowWithdrawTime
    ) public isOwner {
        uint256 _kidsWithdrawAmount = 0;
        bool _kidExists = true;

        kids[_walletAddress] = kid(
            _firstName,
            _lastName,
            _kidsWithdrawAmount,
            _canWithdrawMoney,
            _allowWithdrawTime,
            _kidExists
        );
    }

    function addAmountToKid(address _walletAddress)
        public
        payable
        isOwner
        ifKidExists(_walletAddress)
    {
        kids[_walletAddress].amount += msg.value;
    }

    function checkIfKidCanWithdraw(address _walletAddress) private {
        require(
            block.timestamp > kids[_walletAddress].allowWithdrawTime,
            "You are not able to withdraw at this time"
        );
        if (kids[_walletAddress].canWithdrawMoney == false) {
            kids[_walletAddress].canWithdrawMoney = true;
        }
    }

    function withdrawAmount(address payable _walletAddress)
        public
        payable
        ifKidExists(_walletAddress)
    {
        require(
            msg.sender == _walletAddress,
            "You must be the kid to withdraw"
        );
        require(
            kids[_walletAddress].amount > 0,
            "You dont have money in your wallet"
        );
        checkIfKidCanWithdraw(_walletAddress);
        _walletAddress.transfer(kids[_walletAddress].amount);
        kids[_walletAddress].amount = 0;
    }
}
