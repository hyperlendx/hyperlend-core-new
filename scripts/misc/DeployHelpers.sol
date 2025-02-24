// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Script} from 'forge-std/Script.sol';
import 'forge-std/console.sol';
import '../../src/deployments/interfaces/IMarketReportTypes.sol';
import {AaveV3LibrariesBatch2} from '../../src/deployments/projects/aave-v3-libraries/AaveV3LibrariesBatch2.sol';
import {FfiUtils} from '../../src/deployments/contracts/utilities/FfiUtils.sol';
import {IMetadataReporter} from '../../src/deployments/interfaces/IMetadataReporter.sol';
import {DeployUtils} from '../../src/deployments/contracts/utilities/DeployUtils.sol';

import {Create2Utils} from '../../src/deployments/contracts/utilities/Create2Utils.sol';
import {ConfigEngineReport} from '../../src/deployments/interfaces/IMarketReportTypes.sol';

import {AaveV3ConfigEngine, IAaveV3ConfigEngine, CapsEngine, BorrowEngine, CollateralEngine, RateEngine, PriceFeedEngine, EModeEngine, ListingEngine} from '../../src/contracts/extensions/v3-config-engine/AaveV3ConfigEngine.sol';
import {IPool} from '../../src/contracts/interfaces/IPool.sol';
import {IPoolConfigurator} from '../../src/contracts/interfaces/IPoolConfigurator.sol';
import {IAaveOracle} from '../../src/contracts/interfaces/IAaveOracle.sol';

contract DepoyHelpers is FfiUtils, Script, DeployUtils {
  function run() external {
    vm.startBroadcast();
    _deployConfigEngine(
      0x036Ad31A37b747e39322878eD851711507f13b1b, //pool proxy
      0x0728d03332DD8D2758220a317BC8e154025faEdE, //pool configguarot proxy
      0x3CBaae777133eA226574f5304381E8E9d5671688, //default interest rate strategy
      0x6C6188e608809E328274f1B57C0112A41e83Cd55, //aave oracle
      0x54B6684FB066Ad8377f76fbEa2b4A9b95Db4d084, //rewards controler proxt
      0xA0Fc77365A4d1c02e7F2886200F7176f7E98544D, //collector/tyreasury
      0x9b56aCd0700497429c982294c94889c9800fCd94, //atoken
      0x8A89A03D159A987E592601c839E09F50370dd007 //vdebttoken
    );
    vm.stopBroadcast();
  }

  function _deployConfigEngine(
    address pool,
    address poolConfigurator,
    address defaultInterestRateStrategy,
    address aaveOracle,
    address rewardsController,
    address collector,
    address aTokenImpl,
    address vTokenImpl
  ) internal returns (ConfigEngineReport memory configEngineReport) {
    IAaveV3ConfigEngine.EngineLibraries memory engineLibraries = IAaveV3ConfigEngine
      .EngineLibraries({
        listingEngine: Create2Utils._create2Deploy('v1', type(ListingEngine).creationCode),
        eModeEngine: Create2Utils._create2Deploy('v1', type(EModeEngine).creationCode),
        borrowEngine: Create2Utils._create2Deploy('v1', type(BorrowEngine).creationCode),
        collateralEngine: Create2Utils._create2Deploy('v1', type(CollateralEngine).creationCode),
        priceFeedEngine: Create2Utils._create2Deploy('v1', type(PriceFeedEngine).creationCode),
        rateEngine: Create2Utils._create2Deploy('v1', type(RateEngine).creationCode),
        capsEngine: Create2Utils._create2Deploy('v1', type(CapsEngine).creationCode)
      });

    IAaveV3ConfigEngine.EngineConstants memory engineConstants = IAaveV3ConfigEngine
      .EngineConstants({
        pool: IPool(pool),
        poolConfigurator: IPoolConfigurator(poolConfigurator),
        defaultInterestRateStrategy: defaultInterestRateStrategy,
        oracle: IAaveOracle(aaveOracle),
        rewardsController: rewardsController,
        collector: collector
      });

    configEngineReport.listingEngine = engineLibraries.listingEngine;
    configEngineReport.eModeEngine = engineLibraries.eModeEngine;
    configEngineReport.borrowEngine = engineLibraries.borrowEngine;
    configEngineReport.collateralEngine = engineLibraries.collateralEngine;
    configEngineReport.priceFeedEngine = engineLibraries.priceFeedEngine;
    configEngineReport.rateEngine = engineLibraries.rateEngine;
    configEngineReport.capsEngine = engineLibraries.capsEngine;

    configEngineReport.configEngine = address(
      new AaveV3ConfigEngine(aTokenImpl, vTokenImpl, engineConstants, engineLibraries)
    );

        console.log("configEngine", configEngineReport.configEngine);

    return configEngineReport;
  }
}
