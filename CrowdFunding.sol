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

    // --- GÓP TIỀN ---
    function contribute() public payable {
        // THÊM: Nếu dự án đã hủy thì không được góp nữa
        require(!isCanceled, "Du an da bi huy, khong the gop tien");
        require(block.timestamp < deadline, "Da het thoi han dong gop");
        require(msg.value > 0, "So ETH dong gop phai > 0");
        
        if (contribution[msg.sender] == 0) {
            totalContributors++;
        }

        contribution[msg.sender] += msg.value;
        totalMoney += msg.value;            
    }

    // --- HỦY GÂY QUỸ ---
    function cancelFunding() public {
        require(msg.sender == owner, "Chi chu du an moi duoc huy");
        require(block.timestamp < deadline, "Da qua thoi gian gay quy, khong the huy");
        require(!isCanceled, "Du an da bi huy");
        
        // Đặt trạng thái là Đã hủy
        isCanceled = true;
    }

    // --- RÚT TIỀN ---
    function withdraw() public {
        // Logic rút tiền xảy ra khi:
        // 1. Là người gây quỹ
        // 2. Dự án gây quỹ ch bị chủ sở hữu huỷ
        // 3. Quỹ đã đạt mục tiêu
        // 4. Đã qua thời gian gây quỹ
        require(msg.sender == owner, "Khong phai nguoi gay quy");
        require(!isCanceled, "Du an da bi huy, khong the rut tien");
        require(totalMoney >= goal, "Quy chua dat du muc tieu");
        require(block.timestamp >= deadline, "Chua het thoi gian gay quy, vui long cho");
    
        uint balance = address(this).balance;
        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "Chuyen tien that bai");
    }

    // --- HOÀN TIỀN (SỬA LOGIC) ---
    function refund() public {
        // Logic hoàn tiền xảy ra trong 2 trường hợp:
        // 1. Dự án bị Chủ sở hữu HỦY (isCanceled == true)
        // 2. Hoặc: Đã hết giờ (timestamp >= deadline) MÀ không đủ tiền (totalMoney < goal)
        
        bool duAnThatBai = (block.timestamp >= deadline && totalMoney < goal);
        require(isCanceled || duAnThatBai, "Chua du dieu kien hoan tien");

        uint amount = contribution[msg.sender];
        require(amount > 0, "Ban chua dong gop cho quy");

        contribution[msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{value: amount}("");    
        require(success, "Chuyen tien that bai");  
    }
}