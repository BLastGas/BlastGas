// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBlast {
    function configureClaimableYield() external;
    function configureClaimableGas() external;
    function claimYield(address contractAddress, address recipientOfYield, uint256 amount) external returns (uint256);
    function claimAllYield(address contractAddress, address recipientOfYield) external returns (uint256);
    function claimAllGas(address contractAddress, address recipient) external returns (uint256);
    function claimMaxGas(address contractAddress, address recipient) external returns (uint256);

}


contract blastgas {
    mapping(address => uint256) private _points;
    mapping(address => uint256) private _lastClickTime;

    // Contract owner
    address private _owner;

    //
    event PointsUpdated(address indexed user, uint256 newPoints);

    // points per click
    uint256 public constant pointsPerClick = 100;
    // Cooldown time
    uint256 public constant clickCooldown = 1;

    // Blast Contract
    address public constant blastContract = 0x4300000000000000000000000000000000000002;

    constructor() {
        _owner = msg.sender;
        IBlast(blastContract).configureClaimableYield();
        IBlast(blastContract).configureClaimableGas();
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only contract owner can call this function");
        _;
    }


    // addpoints
    function addPoints() public {
        require(_lastClickTime[msg.sender] + clickCooldown < block.timestamp, "Cooldown period has not passed yet");
        _points[msg.sender] += pointsPerClick;
        _lastClickTime[msg.sender] = block.timestamp;
        emit PointsUpdated(msg.sender, _points[msg.sender]);
    }

    // getpoints
    function getPoints(address user) public view returns (uint256) {
        return _points[user];
    }

    // timeleft
    function timeLeftToClick(address user) public view returns (uint256) {
        if (_lastClickTime[user] + clickCooldown > block.timestamp) {
            return (_lastClickTime[user] + clickCooldown) - block.timestamp;
        } else {
            return 0;
        }
    }

    function claimAllGas() external onlyOwner {
        IBlast(blastContract).claimAllGas(address(this), msg.sender);
    }

    function claimMaxGas() external onlyOwner {
        IBlast(blastContract).claimMaxGas(address(this), msg.sender);
    }

    function claimAllYield(address recipient) external onlyOwner {
		IBlast(blastContract).claimAllYield(address(this), recipient);
  }

    function claimYield(address recipient,uint256 amount) external onlyOwner {
        IBlast(blastContract).claimYield(address(this), recipient, amount);
    }

}
