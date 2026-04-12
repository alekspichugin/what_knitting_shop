import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:mpcoordinator/di/gpb/gpb_tracker_store_remote.dart';
import 'package:mpcoordinator/di/rcity/rcity_coordinator_prod_remote.dart';
import 'package:mpcoordinator/di/rcity/rcity_coordinator_store_remote.dart';
import 'package:mpcoordinator/di/rcity/rcity_coordinator_test_remote.dart';
import 'package:mpcoordinator/di/skai/skai_coordinator_prod_remote.dart';
import 'package:mpcoordinator/di/skai/skai_coordinator_store_remote.dart';
import 'package:mpcoordinator/di/skai/skai_coordinator_test_remote.dart';

import '../common/abstract_injector.dart';
import '../common/app_configuration_data.dart';

import 'gpb/gpb_coordinator_prod_remote.dart';
import 'gpb/gpb_coordinator_store_remote.dart';
import 'gpb/gpb_tracker_prod_remote.dart';
import 'mts/mts_coordinator_test_remote.dart';
import 'mts/mts_coordinator_prod_remote.dart';
import 'mts/mts_coordinator_store_remote.dart';

import 'mts/mts_tracker_test_remote.dart';
import 'mts/mts_tracker_prod_remote.dart';
import 'mts/mts_tracker_store_remote.dart';

import 'remote_injector.dart';
import 'rentatrack/rentatrack_coordinator_test_remote.dart';
import 'rentatrack/rentatrack_coordinator_prod_remote.dart';
import 'rentatrack/rentatrack_coordinator_store_remote.dart';

import 'rostelecom/rostelecom_coordinator_test_remote.dart';
import 'rostelecom/rostelecom_coordinator_prod_remote.dart';
import 'rostelecom/rostelecom_coordinator_store_remote.dart';

import 'rostelecom/rostelecom_tracker_test_remote.dart';
import 'rostelecom/rostelecom_tracker_prod_remote.dart';
import 'rostelecom/rostelecom_tracker_store_remote.dart';

import 'tele2/tele2_coordinator_test_remote.dart';
import 'tele2/tele2_coordinator_prod_remote.dart';
import 'tele2/tele2_coordinator_store_remote.dart';

import 'tele2/tele2_tracker_test_remote.dart';
import 'tele2/tele2_tracker_prod_remote.dart';
import 'tele2/tele2_tracker_store_remote.dart';

import 'beeline/beeline_coordinator_test_remote.dart';
import 'beeline/beeline_coordinator_prod_remote.dart';
import 'beeline/beeline_coordinator_store_remote.dart';

import 'beeline/beeline_tracker_test_remote.dart';
import 'beeline/beeline_tracker_prod_remote.dart';
import 'beeline/beeline_tracker_store_remote.dart';

// adel / 555444 - MTS prod
// vera / 555444 - MTS prod
// 79777113291 / 555444 - TT
// 79967196665 / 555444 - GPB
// 79967102204 / 123456 - GPB

/// Доверять всем SSL сертификатам.
/// Это обход проблемы для старых устройств Android.
// const bool kTrustAllSSLCertificates = true;
const bool kTrustAllCertificates = false;

/// Тип пуша для приложения.
// const PushVariant kPushVariant = PushVariant.none;
// const PushVariant kPushVariant = PushVariant.huawei;
const PushVariant kPushVariant = PushVariant.google;

// enum AppConfigType {
//   base, tracker
// }

// FIXME: временная затычка пока нет нормального DI.
class Di {
  Di._();

  factory Di() => _instance;

  static final Di _instance = Di._();

  late final uiInjector = _createInjector(true);

  late final bgInjector = _createInjector(false);

  // late final bgTrackerInjector = _createInjector(false);

  // late final appConfigUi = _createAppConfigurationData(/* AppConfigType.base,  */ true);

  // late final appConfigBg = _createAppConfigurationData(/* AppConfigType.base,  */ false);

  // late final appConfigBgTracker = _createAppConfigurationData(/* AppConfigType.tracker,  */ false);

  // ===========================================================================

  AbstractInjector _createInjector(bool useCompute) {
    final regExp = RegExp(r'^(.+?)(test|prod|store)(Google|Huawei)$');
    final match = regExp.firstMatch(appFlavor ?? '');

    if (match == null || match.groupCount != 3) {
      throw Exception('Incorrect flavor: $appFlavor');
    }

    final strProductVariant = match.group(1) ?? '';
    final strBuildVariant = match.group(2) ?? '';
    final strPushVariant = (match.group(3) ?? '').toLowerCase();

    // final isStoreBuild = const bool.fromEnvironment('STORE_BUILD', defaultValue: false);
    // final strPushVariant = const String.fromEnvironment('PUSH_VARIANT');
    final trustAllCertificates = const bool.fromEnvironment('TRUST_ALL_CERT', defaultValue: kTrustAllCertificates);

    late final pushVariant;
    try {
      pushVariant = PushVariant.values.byName(strPushVariant);
    } catch (_) {
      throw Exception('Unsupported push variant $strPushVariant');
    }

    late final buildVariant;
    try {
      buildVariant = BuildVariant.values.byName(strBuildVariant);
    } catch (_) {
      throw Exception('Unsupported build variant $strBuildVariant');
    }

    log('FLUTTER_APP_FLAVOR: $appFlavor');
    log('PRODUCT_VARIANT: $strProductVariant');
    log('BUILD_VARIANT: $buildVariant');
    log('PUSH_VARIANT: $pushVariant');
    log('TRUST_ALL_CERT: $trustAllCertificates');

    late final AppConfigurationData config;

    // TODO: productName надо тоже пропарсить и использовать enum?

    // Конфигурации для МТС Россия.
    if (strProductVariant == 'mtsc' && buildVariant == BuildVariant.test) {
      config = MtsCoordinatorTestRemote(trustAllCertificates, useCompute, pushVariant);
    } else if (strProductVariant == 'mtsc' && buildVariant == BuildVariant.prod) {
      config = MtsCoordinatorProdRemote(trustAllCertificates, useCompute, pushVariant);
    } else if (strProductVariant == 'mtsc' && buildVariant == BuildVariant.store) {
      config = MtsCoordinatorStoreRemote(trustAllCertificates, useCompute, pushVariant);
    } else if (strProductVariant == 'mtst' && buildVariant == BuildVariant.test) {
      config = MtsTrackerTestRemote(trustAllCertificates, useCompute, pushVariant);
    } else if (strProductVariant == 'mtst' && buildVariant == BuildVariant.prod) {
      config = MtsTrackerProdRemote(trustAllCertificates, useCompute, pushVariant);
    } else if (strProductVariant == 'mtst' && buildVariant == BuildVariant.store) {
      config = MtsTrackerStoreRemote(trustAllCertificates, useCompute, pushVariant);
    }
    // Конфигурации для Билайн Россия.
    else if (strProductVariant == 'blnc' && buildVariant == BuildVariant.test) {
      config = BeelineCoordinatorTestRemote(trustAllCertificates, useCompute, pushVariant);
    } else if (strProductVariant == 'blnc' && buildVariant == BuildVariant.prod) {
      config = BeelineCoordinatorProdRemote(trustAllCertificates, useCompute, pushVariant);
    } else if (strProductVariant == 'blnc' && buildVariant == BuildVariant.store) {
      config = BeelineCoordinatorStoreRemote(trustAllCertificates, useCompute, pushVariant);
    } else if (strProductVariant == 'blnt' && buildVariant == BuildVariant.test) {
      config = BeelineTrackerTestRemote(trustAllCertificates, useCompute, pushVariant);
    } else if (strProductVariant == 'blnt' && buildVariant == BuildVariant.prod) {
      config = BeelineTrackerProdRemote(trustAllCertificates, useCompute, pushVariant);
    } else if (strProductVariant == 'blnt' && buildVariant == BuildVariant.store) {
      config = BeelineTrackerStoreRemote(trustAllCertificates, useCompute, pushVariant);
    }
    // Конфигурации для ГПБ Мобайл.
    // else if (strProductVariant == 'gpbc' && buildVariant == BuildVariant.test) {
    //   config = GPBCoordinatorTestRemote(trustAllCertificates, useCompute, pushVariant);
    // }
    else if (strProductVariant == 'gpbc' && buildVariant == BuildVariant.prod) {
      config = GPBCoordinatorProdRemote(trustAllCertificates, useCompute, pushVariant);
    } else if (strProductVariant == 'gpbc' && buildVariant == BuildVariant.store) {
      config = GPBCoordinatorStoreRemote(trustAllCertificates, useCompute, pushVariant);
    }
    // else if (strProductVariant == 'gpbt' && buildVariant == BuildVariant.test) {
    //   config = GPBTrackerTestRemote(trustAllCertificates, useCompute, pushVariant);
    // }
    else if (strProductVariant == 'gpbt' && buildVariant == BuildVariant.prod) {
      config = GPBTrackerProdRemote(trustAllCertificates, useCompute, pushVariant);
    } else if (strProductVariant == 'gpbt' && buildVariant == BuildVariant.store) {
      config = GPBTrackerStoreRemote(trustAllCertificates, useCompute, pushVariant);
    }
    // Конфигурации для Рентатрэк.
    else if (strProductVariant == 'rtc' && buildVariant == BuildVariant.test) {
      config = RentatrackCoordinatorTestRemote(trustAllCertificates, useCompute, pushVariant);
    } else if (strProductVariant == 'rtc' && buildVariant == BuildVariant.prod) {
      config = RentatrackCoordinatorProdRemote(trustAllCertificates, useCompute, pushVariant);
    } else if (strProductVariant == 'rtc' && buildVariant == BuildVariant.store) {
      config = RentatrackCoordinatorStoreRemote(trustAllCertificates, useCompute, pushVariant);
    }
    // Конфигурации для Ростелеком.
    else if (strProductVariant == 'rostelc' && buildVariant == BuildVariant.test) {
      config = RostelecomCoordinatorTestRemote(trustAllCertificates, useCompute, pushVariant);
    } else if (strProductVariant == 'rostelc' && buildVariant == BuildVariant.prod) {
      config = RostelecomCoordinatorProdRemote(trustAllCertificates, useCompute, pushVariant);
    } else if (strProductVariant == 'rostelc' && buildVariant == BuildVariant.store) {
      config = RostelecomCoordinatorStoreRemote(trustAllCertificates, useCompute, pushVariant);
    } else if (strProductVariant == 'rostelt' && buildVariant == BuildVariant.test) {
      config = RostelecomTrackerTestRemote(trustAllCertificates, useCompute, pushVariant);
    } else if (strProductVariant == 'rostelt' && buildVariant == BuildVariant.prod) {
      config = RostelecomTrackerProdRemote(trustAllCertificates, useCompute, pushVariant);
    } else if (strProductVariant == 'rostelt' && buildVariant == BuildVariant.store) {
      config = RostelecomTrackerStoreRemote(trustAllCertificates, useCompute, pushVariant);
    }
    // Конфигурации для СКАИ.
    else if (strProductVariant == 'skaic' && buildVariant == BuildVariant.test) {
      config = SkaiCoordinatorTestRemote(trustAllCertificates, useCompute, pushVariant);
    } else if (strProductVariant == 'skaic' && buildVariant == BuildVariant.prod) {
      config = SkaiCoordinatorProdRemote(trustAllCertificates, useCompute, pushVariant);
    } else if (strProductVariant == 'skaic' && buildVariant == BuildVariant.store) {
      config = SkaiCoordinatorStoreRemote(trustAllCertificates, useCompute, pushVariant);
    }
    // Конфигурации для TELE2.
    else if (strProductVariant == 't2c' && buildVariant == BuildVariant.test) {
      config = Tele2CoordinatorTestRemote(trustAllCertificates, useCompute, pushVariant);
    } else if (strProductVariant == 't2c' && buildVariant == BuildVariant.prod) {
      config = Tele2CoordinatorProdRemote(trustAllCertificates, useCompute, pushVariant);
    } else if (strProductVariant == 't2c' && buildVariant == BuildVariant.store) {
      config = Tele2CoordinatorStoreRemote(trustAllCertificates, useCompute, pushVariant);
    } else if (strProductVariant == 't2t' && buildVariant == BuildVariant.test) {
      config = Tele2TrackerTestRemote(trustAllCertificates, useCompute, pushVariant);
    } else if (strProductVariant == 't2t' && buildVariant == BuildVariant.prod) {
      config = Tele2TrackerProdRemote(trustAllCertificates, useCompute, pushVariant);
    } else if (strProductVariant == 't2t' && buildVariant == BuildVariant.store) {
      config = Tele2TrackerStoreRemote(trustAllCertificates, useCompute, pushVariant);
    }
    // Конфигурации для РегионСити.
    else if (strProductVariant == 'rcityc' && buildVariant == BuildVariant.test) {
      config = RCityCoordinatorTestRemote(trustAllCertificates, useCompute, pushVariant);
    } else if (strProductVariant == 'rcityc' && buildVariant == BuildVariant.prod) {
      config = RCityCoordinatorProdRemote(trustAllCertificates, useCompute, pushVariant);
    } else if (strProductVariant == 'rcityc' && buildVariant == BuildVariant.store) {
      config = RCityCoordinatorStoreRemote(trustAllCertificates, useCompute, pushVariant);
    }  else {
      throw Exception('Unsupported flavor: $appFlavor');
    }

    return RemoteInjector(useCompute, config);
  }

  // AppConfigurationData _createAppConfigurationData(/* AppConfigType type,  */ bool useCompute) {
  //   const trustAllSSLCertificates = bool.fromEnvironment(
  //     'TRUST_ALL_CERT',
  //     defaultValue: kTrustAllSSLCertificates,
  //   );

  //   final pushVariant = pushVariantFromEnvironment(
  //     'PUSH_TYPE',
  //     defaultValue: kPushVariant,
  //   );

  //   log('TRUST_ALL_CERT: $trustAllSSLCertificates; PUSH_TYPE: $pushVariant');

  //   // === TELE2 ===

  //   // return Tele2CoordinatorTestRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);
  //   // return Tele2CoordinatorProdRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);
  //   // return Tele2CoordinatorStoreRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);

  //   // return Tele2TrackerTestRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);
  //   // return Tele2TrackerProdRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);
  //   // return Tele2TrackerStoreRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);

  //   // === MTS ===

  //   return MtsCoordinatorTestRemote(trustAllSSLCertificates, useCompute, kPushVariant /* , type */);
  //   // return MtsCoordinatorProdRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);
  //   // return MtsCoordinatorStoreRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);

  //   // return MtsTrackerTestRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);
  //   // return MtsTrackerProdRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);
  //   // return MtsTrackerStoreRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);

  //   // === RENTATRACK ===

  //   // return RentatrackCoordinatorTestRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);
  //   // return RentatrackCoordinatorProdRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);
  //   // return RentatrackCoordinatorStoreRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);

  //   // === ROSTELECOM ===

  //   // return RostelecomCoordinatorTestRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);
  //   // return RostelecomCoordinatorProdRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);
  //   // return RostelecomCoordinatorStoreRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);

  //   // return RostelecomTrackerTestRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);
  //   // return RostelecomTrackerProdRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);
  //   // return RostelecomTrackerStoreRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);

  //   // === BEELINE ===

  //   // return BeelineCoordinatorTestRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);
  //   // return BeelineCoordinatorProdRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);
  //   // return BeelineCoordinatorStoreRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);

  //   // return BeelineTrackerTestRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);
  //   // return BeelineTrackerProdRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);
  //   // return BeelineTrackerStoreRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);

  //   // === GPB ===

  //   // return GPBCoordinatorProdRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);
  //   // return GPBCoordinatorStoreRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);

  //   // return GPBTrackerProdRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);
  //   // return GPBTrackerStoreRemote(trustAllSSLCertificates, useCompute, kPushVariant, type);

  //   // === SKAI ===

  //   // return SkaiCoordinatorTestRemote(trustAllSSLCertificates, useCompute, pushVariant, type);
  //   // return SkaiCoordinatorProdRemote(trustAllSSLCertificates, useCompute, pushVariant, type);
  //   // return SkaiCoordinatorStoreRemote(trustAllSSLCertificates, useCompute, pushVariant, type);
  // }
}
