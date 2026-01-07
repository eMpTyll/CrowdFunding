// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {

    address public immutable owner; 
    uint public immutable goal;      
    uint public immutable deadline;  
    uint public totalMoney;         
    uint public totalContributors;   
    bool public isCanceled = false; 

    mapping(address => uint) public contribution; 

    constructor(uint _goal, uint _duration) {
        owner = msg.sender;
        goal = _goal; 
        deadline = block.timestamp + _duration;
    }


    function contribute() public payable {
        require(!isCanceled, "Du an da bi huy, khong the gop tien");
        require(block.timestamp < deadline, "Da het thoi han dong gop");
        require(msg.value > 0, "So ETH dong gop phai > 0");
        
        if (contribution[msg.sender] == 0) {
            totalContributors++;
        }

        contribution[msg.sender] += msg.value;
        totalMoney += msg.value;            
    }

    function cancelFunding() public {
        require(msg.sender == owner, "Chi chu du an moi duoc huy");
        require(block.timestamp < deadline, "Da qua thoi gian gay quy, khong the huy");
        require(!isCanceled, "Du an da bi huy");
        isCanceled = true;
    }

    function withdraw() public {
        require(msg.sender == owner, "Khong phai nguoi gay quy");
        require(!isCanceled, "Du an da bi huy, khong the rut tien");
        require(totalMoney >= goal, "Quy chua dat du muc tieu");
        require(block.timestamp >= deadline, "Chua het thoi gian gay quy, vui long cho");
        uint balance = address(this).balance;
        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "Chuyen tien that bai");
    }

    function refund() public {
        bool fundFail = (block.timestamp >= deadline && totalMoney < goal);
        require(isCanceled || fundFail, "Chua du dieu kien hoan tien");
        uint amount = contribution[msg.sender];
        require(amount > 0, "Ban chua dong gop cho quy");
        contribution[msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{value: amount}("");    
        require(success, "Chuyen tien that bai");  
    }
}