// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// Interface for Aave Pool contract
interface IPool {
    struct ReserveData {
        uint256 unbacked;
        uint256 accruedToTreasuryScaled;
        uint256 totalAToken;
        uint256 totalStableDebt;
        uint256 totalVariableDebt;
        uint256 liquidityRate;
        uint256 variableBorrowRate;
        uint256 stableBorrowRate;
        uint256 lastUpdateTimestamp;
        address aTokenAddress;
        address stableDebtTokenAddress;
        address variableDebtTokenAddress;
        address interestRateStrategyAddress;
        uint8 id;
    }
    
    function getUserReservesData(address provider, address user) external view returns (
        address[] memory reserves,
        uint256[] memory collaterals,
        uint256[] memory borrows,
        uint256[] memory supplies,
        ReserveData[] memory reservesData
    );
}

contract FetchAaveUserReserves is Script {
    using Strings for uint256;
    using Strings for address;
    
    // Aave Pool contract address
    address public constant AAVE_POOL = 0x036Ad31A37b747e39322878eD851711507f13b1b;
    
    function run() external {
        // Set up the RPC URL - use Ethereum mainnet
        string memory rpcUrl = vm.envString("https://hl-archive-node.xyz/");
        vm.createSelectFork(rpcUrl);
        
        // Address to query - can be passed as an environment variable
        address userAddress = vm.envAddress("0x1B7a7d51eE86e1d9776986AEFD2675312CF0C9Da");
        
        // Fetch data from Aave
        IPool pool = IPool(AAVE_POOL);
        (
            address[] memory reserves,
            uint256[] memory collaterals,
            uint256[] memory borrows,
            uint256[] memory supplies,
            IPool.ReserveData[] memory reservesData
        ) = pool.getUserReservesData(address(0), userAddress); // 0 address for provider means Aave
        
        // Create JSON output
        string memory json = "{";
        
        // User address info
        json = string(abi.encodePacked(json, '"userAddress": "', vm.toString(userAddress), '",'));
        
        // Reserves array
        json = string(abi.encodePacked(json, '"reserves": ['));
        for (uint i = 0; i < reserves.length; i++) {
            json = string(abi.encodePacked(json, '"', vm.toString(reserves[i]), '"'));
            if (i < reserves.length - 1) {
                json = string(abi.encodePacked(json, ","));
            }
        }
        json = string(abi.encodePacked(json, "],"));
        
        // Collaterals array
        json = string(abi.encodePacked(json, '"collaterals": ['));
        for (uint i = 0; i < collaterals.length; i++) {
            json = string(abi.encodePacked(json, collaterals[i].toString()));
            if (i < collaterals.length - 1) {
                json = string(abi.encodePacked(json, ","));
            }
        }
        json = string(abi.encodePacked(json, "],"));
        
        // Borrows array
        json = string(abi.encodePacked(json, '"borrows": ['));
        for (uint i = 0; i < borrows.length; i++) {
            json = string(abi.encodePacked(json, borrows[i].toString()));
            if (i < borrows.length - 1) {
                json = string(abi.encodePacked(json, ","));
            }
        }
        json = string(abi.encodePacked(json, "],"));
        
        // Supplies array
        json = string(abi.encodePacked(json, '"supplies": ['));
        for (uint i = 0; i < supplies.length; i++) {
            json = string(abi.encodePacked(json, supplies[i].toString()));
            if (i < supplies.length - 1) {
                json = string(abi.encodePacked(json, ","));
            }
        }
        json = string(abi.encodePacked(json, "],"));
        
        // Reserve data
        json = string(abi.encodePacked(json, '"reservesData": ['));
        for (uint i = 0; i < reservesData.length; i++) {
            IPool.ReserveData memory data = reservesData[i];
            
            json = string(abi.encodePacked(json, '{'));
            json = string(abi.encodePacked(json, '"unbacked": "', data.unbacked.toString(), '",'));
            json = string(abi.encodePacked(json, '"accruedToTreasuryScaled": "', data.accruedToTreasuryScaled.toString(), '",'));
            json = string(abi.encodePacked(json, '"totalAToken": "', data.totalAToken.toString(), '",'));
            json = string(abi.encodePacked(json, '"totalStableDebt": "', data.totalStableDebt.toString(), '",'));
            json = string(abi.encodePacked(json, '"totalVariableDebt": "', data.totalVariableDebt.toString(), '",'));
            json = string(abi.encodePacked(json, '"liquidityRate": "', data.liquidityRate.toString(), '",'));
            json = string(abi.encodePacked(json, '"variableBorrowRate": "', data.variableBorrowRate.toString(), '",'));
            json = string(abi.encodePacked(json, '"stableBorrowRate": "', data.stableBorrowRate.toString(), '",'));
            json = string(abi.encodePacked(json, '"lastUpdateTimestamp": "', data.lastUpdateTimestamp.toString(), '",'));
            json = string(abi.encodePacked(json, '"aTokenAddress": "', vm.toString(data.aTokenAddress), '",'));
            json = string(abi.encodePacked(json, '"stableDebtTokenAddress": "', vm.toString(data.stableDebtTokenAddress), '",'));
            json = string(abi.encodePacked(json, '"variableDebtTokenAddress": "', vm.toString(data.variableDebtTokenAddress), '",'));
            json = string(abi.encodePacked(json, '"interestRateStrategyAddress": "', vm.toString(data.interestRateStrategyAddress), '",'));
            json = string(abi.encodePacked(json, '"id": ', uint256(data.id).toString()));
            json = string(abi.encodePacked(json, '}'));
            
            if (i < reservesData.length - 1) {
                json = string(abi.encodePacked(json, ","));
            }
        }
        json = string(abi.encodePacked(json, "]"));
        
        // Close the JSON object
        json = string(abi.encodePacked(json, "}"));
        
        // Write to file
        string memory fileName = string(abi.encodePacked("aave_user_reserves_", vm.toString(userAddress), ".json"));
        vm.writeFile(fileName, json);
        
        console.log("Data successfully written to %s", fileName);
    }
}