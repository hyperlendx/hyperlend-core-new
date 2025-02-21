// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './MarketInput.sol';

contract DefaultMarketInput is MarketInput {
  function _getMarketInput(
    address deployer
  )
    internal
    pure
    override
    returns (
      Roles memory roles,
      MarketConfig memory config,
      DeployFlags memory flags,
      MarketReport memory deployedContracts
    )
  {
    roles.marketOwner = deployer;
    roles.emergencyAdmin = deployer;
    roles.poolAdmin = deployer;

    config.marketId = 'HyperLend Market';
    config.providerId = 1;
    config.oracleDecimals = 8;
    config.flashLoanPremiumTotal = 0.0005e4;
    config.flashLoanPremiumToProtocol = 0.0004e4;

    config.networkBaseTokenPriceInUsdProxyAggregator = 0xdE8d22d022261c9Fb4b5338DA8ceFb029175D0F5; //HYPE-USD pyth adapter
    config.marketReferenceCurrencyPriceInUsdProxyAggregator = 0xdE8d22d022261c9Fb4b5338DA8ceFb029175D0F5; //HYPE-USD pyth adapter
    config.wrappedNativeToken = 0x5555555555555555555555555555555555555555;

    return (roles, config, flags, deployedContracts);
  }
}
