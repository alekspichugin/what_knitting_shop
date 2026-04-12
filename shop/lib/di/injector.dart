import 'dart:io' as io;

import 'package:built_collection/built_collection.dart';
import 'package:certificate_pinning/certificate_pinning.dart';
import 'package:coordinator_awa_data_source/coordinator_awa_data_source.dart';
import 'package:coordinator_fwa_data_source/coordinator_fwa_data_source.dart';
import 'package:cwa_data_source/cwa_data_source.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_aurora/flutter_secure_storage_aurora.dart';
import 'package:gwa_geocoding_data_source/gwa_geocoding_data_source.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:mp_core_bloc/mp_core_bloc.dart';
import 'package:mp_device/mp_device.dart';
import 'package:mp_forms/mp_forms.dart' as mp_forms;
import 'package:mp_table/mp_table.dart' as mp_table;
import 'package:mp_core_bloc/mp_core_bloc.dart' as mp_core_bloc;
import 'package:mp_task_editor/mp_task_editor_global.dart' as mp_task_editor;
import 'package:mpcoordinator/app_localizations.dart';
import 'package:mpcoordinator/common/abstract_http_client_config_manager.dart';
import 'package:mpcoordinator/common/awa_data_source_logger.dart';
import 'package:mpcoordinator/common/cwa_data_source_logger.dart';
import 'package:mpcoordinator/common/dio_base_url_injector.dart';
import 'package:mpcoordinator/common/dio_token_injector.dart';
import 'package:mpcoordinator/common/exceptions_manager.dart';
import 'package:mpcoordinator/common/fwa_data_source_logger.dart';
import 'package:mpcoordinator/common/global_http_override.dart';
import 'package:mpcoordinator/common/http_client_config_manager.dart';
import 'package:mpcoordinator/common/mp_core_bloc_logger.dart';
import 'package:mpcoordinator/common/mp_forms_utils.dart';
import 'package:mpcoordinator/common/mp_table_utils.dart';
import 'package:mpcoordinator/common/mp_task_editor_utils.dart';
import 'package:mpcoordinator/data/data_sources/local/floor/checkin_attachments/floor_checkin_attachments_data_source.dart';
import 'package:mpcoordinator/data/data_sources/local/floor/checklist_update/floor_checklist_update_data_source.dart';
import 'package:mpcoordinator/data/data_sources/local/floor/checklist_update_item_attachments/floor_checklist_update_item_attachment_data_source.dart';
import 'package:mpcoordinator/data/data_sources/local/floor/custom_fields_set/floor_custom_fields_data_source.dart';
import 'package:mpcoordinator/data/data_sources/local/floor/custom_fields_update/floor_custom_fields_update_data_source.dart';
import 'package:mpcoordinator/data/data_sources/local/floor/custom_fields_update_item_attachments/floor_custom_fields_update_item_attachment_data_source.dart';
import 'package:mpcoordinator/data/data_sources/local/floor/form_item_attachments/floor_form_item_attachment_data_source.dart';
import 'package:mpcoordinator/data/data_sources/local/floor/form_snapshot_item_attachments/floor_form_snapshot_item_attachment_data_source.dart';
import 'package:mpcoordinator/data/data_sources/local/floor/form_update/floor_form_update_data_source.dart';
import 'package:mpcoordinator/data/data_sources/local/floor/form_update_item_attachments/floor_form_update_item_attachment_data_source.dart';
import 'package:mpcoordinator/data/data_sources/local/floor/forms_common/forms/floor_checklist_data_source.dart';
import 'package:mpcoordinator/data/data_sources/local/floor/forms_common/forms/floor_checklist_description_data_source.dart';
import 'package:mpcoordinator/data/data_sources/local/floor/messages/floor_message_descriptions_data_source.dart';
import 'package:mpcoordinator/data/data_sources/local/floor/task_custom_status/floor_task_custom_status_data_source.dart';
import 'package:mpcoordinator/data/data_sources/local/floor/task_custom_status_reason/floor_task_custom_status_reason_data_source.dart';
import 'package:mpcoordinator/data/data_sources/local/floor/task_custom_status_transition/floor_task_custom_status_transition_data_source.dart';
import 'package:mpcoordinator/data/data_sources/local/floor/task_team/floor_task_team_data_source.dart';
import 'package:mpcoordinator/data/data_sources/local/floor/task_type/floor_task_type_data_source.dart';
import 'package:mpcoordinator/data/data_sources/local/floor/task_update/floor_task_update_description_data_source.dart';
import 'package:mpcoordinator/data/data_sources/local/floor/task_update_attachments/floor_task_update_attachments_data_source.dart';
import 'package:mpcoordinator/data/data_sources/local/secure/local_authentication_data/local_local_authentication_data_data_source.dart';
import 'package:mpcoordinator/data/data_sources/local/secure/security/security_data_source.dart';
import 'package:mpcoordinator/data/data_sources/local/secure/session_secure_data_source/session_secure_data_source.dart';
import 'package:mpcoordinator/data/data_sources/local/shared_preferences/initial_api_entry/local_initial_api_entry_data_source.dart';
import 'package:mpcoordinator/data/data_sources/local/shared_preferences/service_settings_data_source/local_service_settings_data_source.dart';
import 'package:mpcoordinator/data/data_sources/local/shared_preferences/shared_preferences_data_source/shared_preferences_data_source.dart';
import 'package:mpcoordinator/data/data_sources/local/shared_preferences/work_schedule/shared_preferences_work_schedule_data_source.dart';
import 'package:mpcoordinator/data/data_sources/local/temporary/task_exchange_data_source.dart';
import 'package:mpcoordinator/data/repositories/checkin_attachments_repository.dart';
import 'package:mpcoordinator/data/repositories/checklist_description_repository.dart';
import 'package:mpcoordinator/data/repositories/checklist_update_item_attachment_repository.dart';
import 'package:mpcoordinator/data/repositories/checklist_update_repositroy.dart';
import 'package:mpcoordinator/data/repositories/custom_fields_update_repositroy.dart';
import 'package:mpcoordinator/data/repositories/form_item_attachments_repository.dart';
import 'package:mpcoordinator/data/repositories/form_update_item_attachment_repository.dart';
import 'package:mpcoordinator/data/repositories/form_update_repositroy.dart';
import 'package:mpcoordinator/data/repositories/initial_api_entry_repository.dart';
import 'package:mpcoordinator/data/repositories/message_descriptions_repository.dart';
import 'package:mpcoordinator/data/repositories/message_read_mark_repository.dart';
import 'package:mpcoordinator/data/repositories/security_repository.dart';
import 'package:mpcoordinator/data/repositories/subscriber_repository.dart';
import 'package:mpcoordinator/data/repositories/task_custom_status_reason_repository.dart';
import 'package:mpcoordinator/data/repositories/task_custom_status_repository.dart';
import 'package:mpcoordinator/data/repositories/task_custom_status_transition_repository.dart';
import 'package:mpcoordinator/data/repositories/task_exchange_repository.dart';
import 'package:mpcoordinator/data/repositories/task_metadata_repository.dart';
import 'package:mpcoordinator/data/repositories/task_team_repository.dart';
import 'package:mpcoordinator/data/repositories/task_type_repository.dart';
import 'package:mpcoordinator/data/repositories/task_update_attachments_repository.dart';
import 'package:mpcoordinator/data/repositories/task_update_description_repositroy.dart';
import 'package:mpcoordinator/data/repositories/work_schedule_repository.dart';
import 'package:mpcoordinator/domain/blocs/camera/camera_cubit.dart';
import 'package:mpcoordinator/domain/blocs/permissions/permissions_cubit.dart';
import 'package:mpcoordinator/domain/service/custom_fields_update/custom_fields_update_sync_service.dart';
import 'package:mpcoordinator/domain/service/forced_sync/forced_sync_service.dart';
import 'package:mpcoordinator/domain/service/security/security_service.dart';
import 'package:mpcoordinator/domain/service/track/active_track_service.dart';
import 'package:mpcoordinator/features/common/widgets/permissions_utils.dart';
import 'package:mpcoordinator/routes.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:retrofit_giswebapi/retrofit_giswebapi.dart' as retrofit_gwa;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';
import 'package:chc_coordinatorwebapi/chc_coordinatorwebapi.dart' as chc_cwa;
import 'package:retrofit_assetwebapi/retrofit_assetwebapi.dart' as retrofit_awa;
import 'package:retrofit_formwebapi/retrofit_formwebapi.dart' as retrofit_fwa;

import '../data/repositories/geocoding_repository.dart';
import '/domain/service/cache_clear/cache_clear_service.dart';
import '/domain/service/form_template/form_template_sync_service.dart';
import '/domain/service/location/location_sync_service.dart';
import '/domain/service/logs/logs_sync_service.dart';
import '/domain/service/map_object/map_object_sync_service.dart';
import '/domain/service/route/route_sync_service.dart';
import '/domain/service/route_description/route_description_sync_service.dart';
import '/domain/service/service_settings_sync_service/service_settings_sync_service.dart';
import '/domain/service/session/session_service.dart';
import '/domain/service/statuses/statuses_sync_service.dart';
import '/domain/service/task/task_notification_service.dart';
import '/domain/service/task/task_sync_service.dart';
import '/common/api_entry_provider.dart';
import '/common/app_configuration_data.dart';
import '/common/certificate_pinning_provider.dart';
import '/common/dio_logging_interceptor.dart';
import '/common/log_level_provider.dart';
import '/common/logger.dart';
import '/common/logging_interceptor.dart';
import '/common/product_configuration_data.dart';
import '/data/data_sources/local/floor/active_status/floor_active_status_data_source.dart';
import '/data/data_sources/local/floor/app_state_update/floor_app_state_update_data_source.dart';
import '/data/data_sources/local/floor/application/floor_application_data_source.dart';
import '/data/data_sources/local/floor/attachment/message/floor_message_attachment_data_source.dart';
import '/data/data_sources/local/floor/checkin/floor_checkin_data_source.dart';
import '/data/data_sources/local/floor/checkin/floor_checkin_description_data_source.dart';
import '/data/data_sources/local/floor/floor_database.dart';
import '/data/data_sources/local/floor/form_templates/floor_form_template_descriptions_data_source.dart';
import '/data/data_sources/local/floor/form_templates/floor_form_templates_data_source.dart';
import '/data/data_sources/local/floor/forms_common/form_snapshot/floor_form_snapshot_data_source.dart';
import '/data/data_sources/local/floor/forms_common/forms/floor_form_description_data_source.dart';
import '/data/data_sources/local/floor/forms_common/forms/floor_forms_data_source.dart';
import '/data/data_sources/local/floor/map_objects/floor_map_objects_data_source.dart';
import '/data/data_sources/local/floor/message_read_mark/floor_message_read_mark_data_source.dart';
import '/data/data_sources/local/floor/message_template/floor_message_template_data_source.dart';
import '/data/data_sources/local/floor/messages/floor_messages_data_source.dart';
import '/data/data_sources/local/floor/push_log/floor_push_log_data_source.dart';
import '/data/data_sources/local/floor/quick_comments/floor_quick_comments_data_source.dart';
import '/data/data_sources/local/floor/routes_common/route_descriptions/floor_route_description_data_source.dart';
import '/data/data_sources/local/floor/routes_common/routes/floor_route_data_source.dart';
import '/data/data_sources/local/floor/statuses/floor_statuses_data_source.dart';
import '/data/data_sources/local/floor/task_comment_update/floor_task_comment_update_data_source.dart';
import '/data/data_sources/local/floor/task_histories/floor_task_histories_data_source.dart';
import '/data/data_sources/local/floor/task_read_mark/floor_task_read_mark_data_source.dart';
import '/data/data_sources/local/floor/task_update/floor_task_update_data_source.dart';
import '/data/data_sources/local/floor/tasks/floor_task_description_data_source.dart';
import '/data/data_sources/local/floor/tasks/floor_tasks_data_source.dart';
import '/data/data_sources/local/floor/tracks/floor_tracks_data_source.dart';
import '/data/repositories/active_status_repository.dart';
import '/data/repositories/app_state_repository.dart';
import '/data/repositories/app_state_update_repository.dart';
import '/data/repositories/application_repository.dart';
import '/data/repositories/checkin_description_repository.dart';
import '/data/repositories/checkin_repository.dart';
import '/data/repositories/checklist_repository.dart';
import '/data/repositories/feedback_repository.dart';
import '/data/repositories/form_description_repository.dart';
import '/data/repositories/form_repository.dart';
import '/data/repositories/form_snapshot_repository.dart';
import '/data/repositories/form_template_descriptions_repository.dart';
import '/data/repositories/form_templates_repository.dart';
import '/data/repositories/local_authentication_repository.dart';
import '/data/repositories/locations_repository.dart';
import '/data/repositories/logs_repository.dart';
import '/data/repositories/map_objects_repository.dart';
import '/data/repositories/message_attachment_repository.dart';
import '/data/repositories/message_template_repository.dart';
import '/data/repositories/messages_repository.dart';
import '/data/repositories/preferences_repository.dart';
import '/data/repositories/push_log_repository.dart';
import '/data/repositories/quick_comments_repository.dart';
import '/data/repositories/route_description_repository.dart';
import '/data/repositories/route_repository.dart';
import '/data/repositories/service_settings_repository.dart';
import '/data/repositories/session_repository.dart';
import '/data/repositories/statuses_repository.dart';
import '/data/repositories/task_comment_update_repositroy.dart';
import '/data/repositories/task_description_repository.dart';
import '/data/repositories/task_histories_repository.dart';
import '/data/repositories/task_read_mark_repository.dart';
import '/data/repositories/task_update_repositroy.dart';
import '/data/repositories/tasks_repository.dart';
import '/data/repositories/tracks_repository.dart';
import '/domain/managers/jobs/workmanager_jobs_manager.dart';
import '/domain/managers/push/abstract_push_manager.dart';
import '/domain/managers/push/firebase_push_manager.dart';
import '/domain/managers/push/huawei_push_manager.dart';
import '/domain/managers/push/none_push_manager.dart';
import '/common/abstract_injector.dart';

class RemoteInjector extends AbstractInjector {
  RemoteInjector(super.useCompute, super.appConfigurationData);

  static final _lock = Lock();
  bool _isInit = false;

  // ===========================================================================
  // AbstractInjector
  // ===========================================================================

  @override
  Future<void> init() async {
    if (_isInit) return;
    return _lock.synchronized(() async {
      if (_isInit) return;
      return _init().then((v) => _isInit = true);
    });
  }

  // ===========================================================================

  Future<void> _init() async {
    // FIXME: Надо подумать куда это приткнуть потом.
    // #for_aurora_support
    // Добавлено для ОС Аврора.
    FlutterSecureStorageAurora.setSecret('5872747ed1ceda363808efb8b2b18b33');

    final cacheTrackDatabase = await AppDatabase.createBgTrackInstance();

    // final cacheDatabase = type == AppConfigType.base ? await AppDatabase.createInstance() : cacheTrackDatabase;
    final cacheDatabase = await AppDatabase.createInstance();

    final appRuntimeInfo = await _appRuntimeInfo();

    // final testTrackDb = await TestTrackDB().createDb();
    final tknManager = TokenManager();

    attachmentsDir = await attachmentsDirectory();

    apiEntriesManager = ApiEntriesManager(appConfigurationData.apiInitialEntry);
    tokenManager = tknManager;
    certificatePinningManager = CertificatePinningManager(
      appConfigurationData.allowedRootCertificatesFingerprints,
      appConfigurationData.allowedDomainCommonNames,
    );
    jobsManager = WorkmanagerJobsManager();
    // late AbstractPushManager pushManager;
    if (appConfigurationData.pushVariant == PushVariant.google) {
      pushManager = FirebasePushManager();
    } else if (appConfigurationData.pushVariant == PushVariant.huawei) {
      pushManager = HuaweiPushManager();
    } else {
      pushManager = NonePushManager();
    }
    logLevelManager = LogLevelManager();

    authExceptionsManager = ExceptionsManager();
    exceptionsManager = ExceptionsManager();

    final cwaDSLogger = CwaDataSourceLogger();
    final fwaDSLogger = FwaDataSourceLogger();
    final awaDSLogger = AwaDataSourceLogger();

    mp_core_bloc.MpCoreBloc.logger = MpCoreBlocLogger();

    mp_forms.MpForms.logger = MpFormsLogger();
    mp_forms.MpForms.showMessage = MpFormsUtils.showMessage;
    mp_forms.MpForms.checkStoragePermission = MpFormsUtils.checkStoragePermission;

    mp_forms.MpForms.scanCode = MpFormsUtils.scanCode;
    mp_forms.MpForms.recognizeImageText = MpFormsUtils.recognizeImageText;

    mp_forms.MpForms.takePhoto = MpFormsUtils.takePhoto;
    mp_forms.MpForms.recordVideo = MpFormsUtils.recordVideo;
    mp_forms.MpForms.takeSignature = MpFormsUtils.takeSignature;
    mp_forms.MpForms.pickAudioFile = MpFormsUtils.pickAudioFile;
    mp_forms.MpForms.pickVideoFile = MpFormsUtils.pickVideoFile;
    mp_forms.MpForms.pickImageFile = MpFormsUtils.pickImageFile;
    mp_forms.MpForms.pickFile = MpFormsUtils.pickFile;

    mp_forms.MpForms.pickDate = MpFormsUtils.pickDate;
    mp_forms.MpForms.pickTime = MpFormsUtils.pickTime;
    mp_forms.MpForms.pickPlace = MpFormsUtils.pickPlace;

    mp_forms.MpForms.viewTable = MpFormsUtils.viewTable;
    mp_forms.MpForms.editTable = MpFormsUtils.editTable;
    mp_table.MpTable.addTableRow = MpTableUtils.addTableRow;
    mp_table.MpTable.editTableRow = MpTableUtils.editTableRow;

    mp_forms.MpForms.viewQRCode = MpFormsUtils.viewQRCode;

    mp_task_editor.MpTaskEditor.logger = MpTaskEditorLogger();
    mp_task_editor.MpTaskEditor.showMessage = MpTaskEditorUtils.showMessage;
    mp_task_editor.MpTaskEditor.pickMapObject = MpTaskEditorUtils.pickMapObject;
    mp_task_editor.MpTaskEditor.pickDate = MpTaskEditorUtils.pickDate;
    mp_task_editor.MpTaskEditor.pickTime = MpTaskEditorUtils.pickTime;
    mp_task_editor.MpTaskEditor.pickPlace = MpTaskEditorUtils.pickPlace;

    overrideCreateHttpClient(appConfigurationData.trustAllSSLCertificates);

    final floorFormsDataSource = FloorFormsDataSource(
      cacheDatabase.formDao,
      cacheDatabase.formItemDataDao,
    );

    final floorFormItemAttachmentDataSource = FloorFormItemAttachmentDataSource(cacheDatabase.formItemFileDao);

    final sharedPreferences = await SharedPreferences.getInstance();
    const secureStorage = FlutterSecureStorage();
    const secureStorageIOSOptions = IOSOptions(accessibility: KeychainAccessibility.first_unlock);
    final sharedPreferencesDataSource = SharedPreferencesDataSource(sharedPreferences);

    final cwaAuthHttpClient = chc_cwa.DioHttpClient(
        dio: _createDio(
            certificatePinningManager.certificatePinning, tknManager.token, logLevelManager.logLevelProvider,
            interceptors: [DioBaseUrlInjector(apiEntriesManager.coordinator)]));

    final cwaHttpAuthHttpClient = chc_cwa.DioHttpClient(
        dio: _createDio(
            certificatePinningManager.certificatePinning, tknManager.token, logLevelManager.logLevelProvider,
            interceptors: [DioBaseUrlInjector(apiEntriesManager.httpAuth)]));

    final cwaJwtHttpClient = chc_cwa.DioHttpClient(
        dio: _createDio(certificatePinningManager.certificatePinning, tknManager.jwt, logLevelManager.logLevelProvider,
            interceptors: [DioBaseUrlInjector(apiEntriesManager.coordinator)]));

    final fwaDio = _createDio(
        certificatePinningManager.certificatePinning, tknManager.jwt, logLevelManager.logLevelProvider,
        interceptors: [DioBaseUrlInjector(apiEntriesManager.formWebApi)]);

    final awaDio = _createDio(
        certificatePinningManager.certificatePinning, tknManager.jwt, logLevelManager.logLevelProvider,
        interceptors: [DioBaseUrlInjector(apiEntriesManager.assetWebApi)]);

    final gwaDio = _createDio(
      certificatePinningManager.certificatePinning,
      tknManager.jwt,
      logLevelManager.logLevelProvider,
      interceptors: [DioBaseUrlInjector(apiEntriesManager.gisWebApi)],
    );

    final accountApi = chc_cwa.JsRestAccountApi(cwaAuthHttpClient, cwaJwtHttpClient);
    final captchaApi = chc_cwa.JsCwaCaptchaApi(cwaAuthHttpClient);
    final userApi = chc_cwa.JsRestUserApi(cwaAuthHttpClient);
    final authApi = chc_cwa.JsRestAuthApi(cwaAuthHttpClient);
    final httpAuthApi = chc_cwa.JsRestHttpAuthApi(cwaHttpAuthHttpClient);
    final appsApi = chc_cwa.JsRestAppsApi(cwaJwtHttpClient);
    final locationsApi = chc_cwa.JsRestLocationsApi(cwaJwtHttpClient);
    final trackLocationsApi = chc_cwa.JsRestTrackLocationsApi(cwaJwtHttpClient);
    final statusesApi = chc_cwa.JsRestStatusesApi(cwaJwtHttpClient);
    final subscriberApi = chc_cwa.JsCwaSubscriberApi(cwaJwtHttpClient);
    final workScheduleApi = chc_cwa.JsCwaWorkScheduleApi(cwaJwtHttpClient);


    final feedbackApi = chc_cwa.JsRestFeedbackApi(cwaJwtHttpClient);
    final checkinsApi = chc_cwa.JsRestCheckinsApi(cwaJwtHttpClient);
    final messagesApi = chc_cwa.JsRestMessagesApi(cwaJwtHttpClient);
    final messageTemplatesApi = chc_cwa.JsRestMessageTemplatesApi(cwaJwtHttpClient);
    final mapObjectsApi = chc_cwa.JsRestObjectsApi(cwaJwtHttpClient);
    final tasksApi = chc_cwa.JsRestTasksApi(cwaJwtHttpClient);
    final routesApi = chc_cwa.JsRestRoutesApi(cwaJwtHttpClient);
    final formCommonApi = chc_cwa.JsCwaFormCommonApi(cwaJwtHttpClient);
    final formsApi = chc_cwa.JsCwaFormApi(cwaJwtHttpClient);
    final checklistApi = chc_cwa.JsCwaChecklistApi(cwaJwtHttpClient);
    final customFieldsUpdateApi = chc_cwa.JsCwaCustomFieldsUpdateApi(cwaJwtHttpClient);

    final fwaFormsApi = retrofit_fwa.RetrofitFwaFormsApi(fwaDio);
    final fwaFormTemplatesApi = retrofit_fwa.RetrofitFwaFormTemplatesApi(fwaDio);
    final awaChecklistsApi = retrofit_awa.RetrofitAwaChecklistsApi(awaDio);

    final restFormsDataSource = CwaFormsDataSource(formCommonApi, formsApi, checklistApi, cwaDSLogger);

    final gisApi = retrofit_gwa.RetrofitGisGeocodingApi(gwaDio);

    // Отсюда получаем сгенерированные формы(те, что не были заполнены пользователем в приложении):
    // Предзаполненная форма
    final fwaGeneratedFormDataSource = FwaGeneratedFormsDataSource(fwaFormsApi, fwaDSLogger);

    final fwaFormTemplatesDataSource = FwaFormTemplatesDataSource(fwaFormTemplatesApi, fwaDSLogger);

    final fwaFormTemplateDescriptionsDataSource =
        FwaFormTemplateDescriptionsDataSource(fwaFormTemplatesApi, fwaDSLogger);

    final awaChecklistTemplateDataSource = AwaChecklistTemplateDataSource(awaChecklistsApi, awaDSLogger);

    final floorFormTemplateDescriptionsDataSource =
        FloorFormTemplateDescriptionsDataSource(cacheDatabase.formTemplatesDao, cacheDatabase.formTemplateItemsDao);

    final floorCheckinAttachmentsDataSource = FloorCheckinAttachmentsDataSource(cacheDatabase.checkinFileDao);
    final floorTaskUpdateAttachmentsDataSource = FloorTaskUpdateAttachmentsDataSource(
      cacheDatabase.taskUpdateFileDao,
    );

    final floorTaskDescriptionDataSource = FloorTaskDescriptionDataSource(
      cacheDatabase.tasksDao, cacheDatabase.taskToTagDao, cacheDatabase.taskTagDao
    );

    final cwaTaskExchangeDataSource = CwaTaskExchangeDataSource(tasksApi, cwaDSLogger);

    final floorCustomFieldsSetDataSource = FloorCustomFieldsSetDataSource(
        cacheDatabase.customFieldsSetDao, cacheDatabase.customFieldDao, cacheDatabase.customFieldAttachmentDao);

    final localServiceSettingsDataSource =
        LocalServiceSettingsDataSource(sharedPreferences, secureStorage, secureStorageIOSOptions);

    sessionRepository = SessionRepository(
      SessionSecureDataSource(secureStorage, secureStorageIOSOptions),
      CwaSessionDataSource(
          accountApi,
          captchaApi,
          authApi,
          httpAuthApi,
          userApi,
          appConfigurationData.productConfigurationData.appCodeName,
          appConfigurationData.productConfigurationData.usePhoneNumberMasking,
          cwaDSLogger),
    );

    serviceSettingsRepository = ServiceSettingsRepository(
      CwaServiceSettingsDataSource(accountApi, cwaDSLogger
          // RemoteJsonServiceSettingsApi(httpClient, apiEntriesManager.coordinator, useCompute),
          // appCodeName,
          ),
      localServiceSettingsDataSource,
    );

    preferencesRepository = PreferencesRepository(sharedPreferencesDataSource);

    statusesRepository = StatusesRepository(
      CwaStatusesDataSource(statusesApi, cwaDSLogger),
      FloorStatusesDataSource(
        cacheDatabase.statusDao,
      ),
    );

    activeStatusRepository = ActiveStatusRepository(
      CwaActiveStatusDataSource(statusesApi, cwaDSLogger),
      FloorActiveStatusDataSource(
        cacheDatabase.activeStatusDao,
      ),
    );

    tracksRepository = TracksRepository(
      FloorTracksDataSource(
        cacheTrackDatabase.trackDao,
        cacheTrackDatabase.trackPointDao,
      ),
      CwaTracksDataSource(trackLocationsApi, cwaDSLogger),
    );

    locationsRepository = LocationsRepository(
      CwaLocationsDataSource(locationsApi, cwaDSLogger),
    );

    feedbackRepository = FeedbackRepository(CwaFeedbackDataSource(feedbackApi, attachmentsDir, cwaDSLogger));

    logsRepository = LogsRepository(CwaLogsDataSource(feedbackApi, attachmentsDir, cwaDSLogger));

    messagesRepository = MessagesRepository(
      CwaMessagesDataSource(messagesApi, attachmentsDir, cwaDSLogger),
      FloorMessagesDataSource(cacheDatabase.messageDao),
      FloorMessageAttachmentDataSource(
        cacheDatabase.messageAttachmentDao,
      ),
    );

    messageDescriptionsRepository = MessageDescriptionsRepository(
      FloorMessageDescriptionsDataSource(cacheDatabase.messageDao),
    );

    messageReadMarkRepository = MessageReadMarkRepository(CwaMessageReadMarkDataSource(messagesApi, cwaDSLogger),
        FloorMessageReadMarkDataSource(cacheDatabase.messageReadMarkDao));

    messageAttachmentRepository = MessageAttachmentRepository(
        CwaMessageAttachmentsDataSource(messagesApi, attachmentsDir, cwaDSLogger),
        FloorMessageAttachmentDataSource(
          cacheDatabase.messageAttachmentDao,
        ));

    tasksRepository = TasksRepository(
        FloorTasksDataSource(
          cacheDatabase.tasksDao,
          cacheDatabase.taskAttachmentDao,
          cacheDatabase.taskStatusFormTemplateDao,
          cacheDatabase.taskClientInfoDao,
          cacheDatabase.taskWorkOrderDao,
          cacheDatabase.checklistDescriptorDao,
          cacheDatabase.taskToTagDao,
          cacheDatabase.taskTagDao
        ),
        floorTaskDescriptionDataSource,
        // MockCwaTasksDataSource(cwaDSLogger),
        CwaTasksDataSource(tasksApi, cwaDSLogger),
        floorCustomFieldsSetDataSource,
        // JsonTasksDataSource(
        //   RemoteJsonTasksApi(httpClient, apiEntriesManager.coordinator, useCompute),
        // ),
        sharedPreferences);

    taskDescriptionRepository = TaskDescriptionRepository(
      FloorTaskDescriptionDataSource(
          cacheDatabase.tasksDao,
          cacheDatabase.taskToTagDao,
          cacheDatabase.taskTagDao
      ),
    );

    taskExchangeRepository = TaskExchangeRepository(
        TemporaryTaskExchangeDataSource(),
        cwaTaskExchangeDataSource,
        sharedPreferences
    );

    taskTypeRepository = TaskTypeRepository(
        // MockCwaTaskTypeDataSource(cwaDSLogger),
        CwaTaskTypeDataSource(tasksApi, cwaDSLogger),
        FloorTaskTypeDataSource(cacheDatabase.taskTypeDao));

    taskCustomStatusRepository = TaskCustomStatusRepository(
        // MockCwaTaskCustomStatusDataSource(cwaDSLogger),
        CwaTaskCustomStatusDataSource(tasksApi, cwaDSLogger),
        FloorTaskCustomStatusDataSource(cacheDatabase.taskCustomStatusDao));

    taskCustomStatusReasonRepository = TaskCustomStatusReasonRepository(
        // MockCwaTaskCustomStatusReasonDataSource(cwaDSLogger),
        CwaTaskCustomStatusReasonDataSource(tasksApi, cwaDSLogger),
        FloorTaskCustomStatusReasonDataSource(cacheDatabase.taskCustomStatusReasonDao));

    taskCustomStatusTransitionRepository = TaskCustomStatusTransitionRepository(
        // MockCwaTaskCustomStatusTransitionDataSource(cwaDSLogger),
        CwaTaskCustomStatusTransitionDataSource(tasksApi, cwaDSLogger),
        FloorTaskCustomStatusTransitionDataSource(cacheDatabase.taskCustomStatusTransitionDao));

    taskTeamRepository = TaskTeamRepository(
        CwaTaskTeamDataSource(tasksApi, cwaDSLogger),
        FloorTaskTeamDataSource(
          cacheDatabase.floorTaskTeamDao,
          cacheDatabase.floorTaskTeamAllocationDao,
          cacheDatabase.floorSubscriberDao,
          cacheDatabase.floorTaskTeamAllocationSubscriberDao,
        )
    );

    taskMetadataRepository = TaskMetadataRepository(
      CwaTaskMetadataDataSource(tasksApi, cwaDSLogger)
    );

    taskHistoriesRepository = TaskHistoriesRepository(
        FloorTaskHistoriesDataSource(
            cacheDatabase.taskHistoryDao, cacheDatabase.taskHistoryFileDao, cacheDatabase.taskHistoryFormInfoDao),
        CwaTaskHistoryDataSource(tasksApi, cwaDSLogger));

    taskUpdateRepository = TaskUpdateRepository(
        FloorTaskUpdateDataSource(
          cacheDatabase.taskUpdateDao,
        ),
        floorTaskUpdateAttachmentsDataSource,
        CwaTaskUpdateDataSource(tasksApi, attachmentsDir, cwaDSLogger));

    taskUpdateAttachmentsRepository = TaskUpdateAttachmentsRepository(
        CwaTaskUpdateAttachmentsDataSource(tasksApi, attachmentsDir, cwaDSLogger),
        floorTaskUpdateAttachmentsDataSource);

    taskUpdateDescriptionRepository = TaskUpdateDescriptionRepository(FloorTaskUpdateDescriptionDataSource(
      cacheDatabase.taskUpdateDao,
    ));

    mapObjectsRepository = MapObjectsRepository(
        FloorMapObjectsDataSource(
          cacheDatabase.mapObjectDao,
        ),
        CwaMapObjectsDataSource(mapObjectsApi, cwaDSLogger),
        floorCustomFieldsSetDataSource);

    customFieldsUpdateRepository = CustomFieldsUpdateRepository(
        FloorCustomFieldsUpdateDataSource(
          cacheDatabase.customFieldsUpdateDao,
          cacheDatabase.customFieldsUpdateItemDao,
        ),
        FloorCustomFieldsUpdateItemAttachmentDataSource(cacheDatabase.customFieldsUpdateItemAttachmentDao),
        CwaCustomFieldsUpdateDataSource(customFieldsUpdateApi));

    formTemplatesRepository = FormTemplatesRepository(
        FloorFormTemplatesDataSource(
          cacheDatabase.formTemplatesDao,
          cacheDatabase.formTemplateItemsDao,
          cacheDatabase.formTemplateItemConditionsDao,
        ),
        fwaFormTemplatesDataSource,
        floorFormTemplateDescriptionsDataSource,
        fwaFormTemplateDescriptionsDataSource,
        awaChecklistTemplateDataSource);

    formTemplateDescriptionsRepository = FormTemplateDescriptionsRepository(
        FloorFormTemplatesDataSource(
          cacheDatabase.formTemplatesDao,
          cacheDatabase.formTemplateItemsDao,
          cacheDatabase.formTemplateItemConditionsDao,
        ),
        fwaFormTemplatesDataSource,
        floorFormTemplateDescriptionsDataSource);

    formRepository = FormRepository(
        floorFormsDataSource, restFormsDataSource, fwaGeneratedFormDataSource, floorFormItemAttachmentDataSource);

    formDescriptionRepository = FormDescriptionRepository(
        floorFormsDataSource,
        restFormsDataSource,
        FloorFormDescriptionDataSource(
          cacheDatabase.formDao,
        ),
        floorFormItemAttachmentDataSource);

    formSnapshotRepository = FormSnapshotRepository(
        FloorFormsSnapshotDataSource(
          cacheDatabase.formSnapshotDao,
          cacheDatabase.formSnapshotItemDataDao,
          // cacheDatabase.formSnapshotItemFileDao
        ),
        restFormsDataSource,
        FloorFormSnapshotItemAttachmentDataSource(cacheDatabase.formSnapshotItemFileDao));

    /// Аттачи для форм
    formItemAttachmentsRepository = FormItemAttachmentsRepository(
        CwaFormItemAttachmentsDataSource(formsApi, attachmentsDir, cwaDSLogger),
        floorFormItemAttachmentDataSource,
        CwaChecklistItemAttachmentsDataSource(checklistApi, attachmentsDir, cwaDSLogger));

    /// Аттачи для форм снэпшотов
    formSnapshotItemAttachmentsRepository = FormItemAttachmentsRepository(
        CwaFormItemAttachmentsDataSource(formsApi, attachmentsDir, cwaDSLogger),
        FloorFormSnapshotItemAttachmentDataSource(cacheDatabase.formSnapshotItemFileDao),
        CwaChecklistItemAttachmentsDataSource(checklistApi, attachmentsDir, cwaDSLogger));

    /// Апдейты форм
    formUpdateRepository = FormUpdateRepository(
        FloorFormUpdateDataSource(
            cacheDatabase.formUpdateDao, cacheDatabase.formUpdateItemDataDao, cacheDatabase.formUpdateItemStateDao),
        FloorFormUpdateItemAttachmentDataSource(cacheDatabase.formUpdateItemAttachmentDao),
        CwaFormUpdateDataSource(formsApi, cwaDSLogger));

    /// Аттачи для апдейтов форм
    formUpdateItemAttachmentRepository = FormUpdateItemAttachmentRepository(
      CwaFormUpdateItemAttachmentDataSource(formsApi, attachmentsDir, cwaDSLogger),
      FloorFormUpdateItemAttachmentDataSource(cacheDatabase.formUpdateItemAttachmentDao),
    );

    checklistRepository = ChecklistRepository(
        FloorChecklistDataSource(cacheDatabase.formDao, cacheDatabase.formItemDataDao),
        floorFormItemAttachmentDataSource);

    checklistDescriptionRepository = ChecklistDescriptionRepository(
        floorFormsDataSource,
        FloorChecklistDescriptionDataSource(cacheDatabase.formDao),
        fwaGeneratedFormDataSource,
        floorFormItemAttachmentDataSource);

    /// Апдейты форм
    checklistUpdateRepository = ChecklistUpdateRepository(
        FloorChecklistUpdateDataSource(cacheDatabase.checklistUpdateDao, cacheDatabase.checklistUpdateItemDataDao,
            cacheDatabase.checklistUpdateItemStateDao),
        FloorChecklistUpdateItemAttachmentDataSource(cacheDatabase.checklistUpdateItemAttachmentDao),
        CwaChecklistUpdateDataSource(checklistApi, cwaDSLogger));

    /// Аттачи для апдейтов чек-листов
    checklistUpdateItemAttachmentRepository = ChecklistUpdateItemAttachmentRepository(
      CwaChecklistUpdateItemAttachmentDataSource(checklistApi, attachmentsDir, cwaDSLogger),
      FloorChecklistUpdateItemAttachmentDataSource(cacheDatabase.checklistUpdateItemAttachmentDao),
    );

    pushLogRepository = PushLogRepository(
      FloorPushLogDataSource(cacheDatabase.pushLogDao),
    );

    quickCommentsRepository = QuickCommentsRepository(
      FloorQuickCommentsDataSource(
        cacheDatabase.quickCommentsDao,
      ),
    );

    messageTemplateRepository = MessageTemplateRepository(
        FloorMessageTemplateDataSource(
          cacheDatabase.messageTemplatesDao,
        ),
        CwaMessageTemplatesDataSource(messageTemplatesApi, cwaDSLogger));

    checkinRepository = CheckinRepository(FloorCheckinDataSource(cacheDatabase.checkinDao),
        floorCheckinAttachmentsDataSource, CwaCheckinDataSource(checkinsApi, attachmentsDir, cwaDSLogger));

    checkinAttachmentsRepository = CheckinAttachmentsRepository(
        CwaCheckinAttachmentsDataSource(checkinsApi, attachmentsDir, cwaDSLogger), floorCheckinAttachmentsDataSource);

    checkinDescriptionRepository = CheckinDescriptionRepository(
      FloorCheckinDescriptionDataSource(cacheDatabase.checkinDao),
    );

    taskReadMarkRepository = TaskReadMarkRepository(
        FloorTaskReadMarkDataSource(cacheDatabase.taskReadMarksDao), CwaTaskReadMarkDataSource(tasksApi, cwaDSLogger));

    routeRepository = RouteRepository(
      CwaRouteDataSource(routesApi, cwaDSLogger),
      FloorRouteDataSource(
        cacheDatabase.routeDao,
        cacheDatabase.visitDao,
        cacheDatabase.pathPointDao,
      ),
    );

    routeDescriptionRepository = RouteDescriptionRepository(
      CwaRouteDescriptionDataSource(routesApi, cwaDSLogger),
      FloorRouteDescriptionDataSource(
        cacheDatabase.routeDao,
        cacheDatabase.visitDao,
      ),
    );

    taskCommentUpdateRepository = TaskCommentUpdateRepository(
        FloorTaskCommentUpdateDataSource(cacheDatabase.taskCommentUpdateDao),
        CwaTaskCommentUpdateDataSource(tasksApi, cwaDSLogger));

    applicationRepository = ApplicationRepository(
      FloorApplicationDataSource(cacheDatabase.applicationDao),
    );

    appStateUpdateRepository = AppStateUpdateRepository(
      FloorAppStateUpdateDataSource(cacheDatabase.appStateUpdateDao),
      CwaAppStateUpdateDataSource(appsApi, cwaDSLogger),
    );

    appStateRepository = AppStateRepository(
      CwaAppStateDataSource(appsApi, cwaDSLogger),
    );

    localAuthenticationRepository = LocalAuthenticationDataRepository(
      LocalLocalAuthenticationDataDataSource(secureStorage, secureStorageIOSOptions),
      sharedPreferencesDataSource,
    );

    initialApiEntryRepository =
        InitialApiEntryRepository(sharedPreferencesDataSource, LocalInitialApiEntryDataSource(sharedPreferences));

    securityRepository =
        SecurityRepository(sharedPreferencesDataSource, SecurityDataSource(secureStorage, secureStorageIOSOptions));

    geocodingRepository = GeocodingRepository(GwaRemoteGeocodingRepository(gisApi));

    subscriberRepository = SubscriberRepository(
        CwaSubscriberDataSource(subscriberApi, cwaDSLogger)
    );

    workScheduleRepository = WorkScheduleRepository(
        SharedPreferencesWorkScheduleDataSource(sharedPreferences),
        CwaWorkScheduleDataSource(workScheduleApi, cwaDSLogger)
    );

    // Создаем сервисы.

    sessionService = SessionService(
      sessionRepository,
      serviceSettingsRepository,
      apiEntriesManager,
      tokenManager,
      appConfigurationData.productConfigurationData.brandId,
    );

    tasksNotificationService = TaskNotificationService(
      preferencesRepository,
      appConfigurationData.productConfigurationData.localizationsDelegate,
    );

    tasksSyncService = TaskSyncService(
      tasksNotificationService,
      tasksRepository,
      taskTypeRepository,
      taskCustomStatusRepository,
      taskCustomStatusTransitionRepository,
      mapObjectsRepository,
      formTemplatesRepository,
    );

    locationSyncService = LocationSyncService(locationsRepository);

    mapObjectSyncService = MapObjectSyncService(mapObjectsRepository, formTemplatesRepository);

    routeSyncService = RouteSyncService(routeRepository);

    routeDescriptionSyncService = RouteDescriptionSyncService(routeDescriptionRepository);

    formTemplateSyncService = FormTemplateSyncService(formTemplateDescriptionsRepository, formTemplatesRepository);

    logsSyncService = LogsSyncService(logsRepository);

    statusesSyncService = StatusesSyncService(statusesRepository);

    serviceSettingsSyncService = ServiceSettingsSyncService(serviceSettingsRepository);

    forcedSyncService = ForcedSyncService();

    cacheClearService = CacheClearService(
      activeStatusRepository,
      appStateUpdateRepository,
      applicationRepository,
      checkinRepository,
      formTemplatesRepository,
      formRepository,
      formSnapshotRepository,
      mapObjectsRepository,
      messageTemplateRepository,
      messagesRepository,
      quickCommentsRepository,
      routeRepository,
      statusesRepository,
      taskCommentUpdateRepository,
      taskHistoriesRepository,
      taskReadMarkRepository,
      taskUpdateRepository,
      tasksRepository,
      tracksRepository,
      preferencesRepository,
    );

    securityService = SecurityService(securityRepository);

    activeTrackService = ActiveTrackService(tracksRepository);
  }

  Dio _createDio(AbstractCertificatePinningProvider certificatePinningProvider, AbstractToken token,
      AbstractLogLevelProvider logLevelProvider,
      {AbstractApiEntryProvider? baseUrlProvider, List<Interceptor> interceptors = const <Interceptor>[]}) {
    final dio = Dio()
      ..options.connectTimeout = Duration(seconds: appConfigurationData.apiRequestTimeout)
      ..options.receiveTimeout = Duration(seconds: appConfigurationData.apiRequestTimeout)
      ..options.sendTimeout = Duration(seconds: appConfigurationData.apiRequestTimeout)
      ..interceptors.addAll([
        ...interceptors,
        DioTokenInjector(token),
        DioLoggingInterceptor(
            logLevelProvider: logLevelProvider,
            overrideLogLevel: appConfigurationData.buildVariant != BuildVariant.store,
            compact: true,
            logPrint: (o) => Logger.i('MPC', 'DioHttpClient', '$o')),
        if (appConfigurationData.productConfigurationData.productFeatures.contains(ProductFeature.certificatePinning))
          DioCertificatePinningInterceptor(certificatePinningProvider),
      ]);

    if (baseUrlProvider != null) {
      dio.options.baseUrl = baseUrlProvider.apiEntry;
    }

    return dio;
  }

  Future<AppRuntimeInfo> _appRuntimeInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final appVer = '${packageInfo.version}.${packageInfo.buildNumber}';

    String mcc = await MpDevice.instance.mcc; // '250'
    String mnc = await MpDevice.instance.mnc; // '01' - MTS, 99 - BeeLine

    if (io.Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      final deviceId = await MpDevice.instance.deviceId;

      return AppRuntimeInfo(
        'Android',
        info.version.release,
        info.manufacturer,
        info.model,
        appConfigurationData.productConfigurationData.appCodeName,
        appVer,
        mcc,
        mnc,
        deviceId, // info.androidId
      );
    }

    if (io.Platform.isIOS) {
      final info = await DeviceInfoPlugin().iosInfo;
      return AppRuntimeInfo(
        'iOS',
        info.systemVersion,
        info.name,
        info.model,
        appConfigurationData.productConfigurationData.appCodeName,
        appVer,
        mcc,
        mnc,
        info.identifierForVendor ?? 'N/A',
      );
    }

    // FIXME: возможно надо будет как-то исправить потом.
    // #for_aurora_support
    // Добавленно для поддержки ОС Аврора. На уровне кода приложения
    // я стараюсь не добавлять явную зависимость к ОС Аврора.
    if (io.Platform.isLinux) {
      final info = await DeviceInfoPlugin().linuxInfo;
      return AppRuntimeInfo(
        'Linux', // 'Aurora',
        info.version ?? 'N/A',
        info.name,
        '1.0', // info.model,
        appConfigurationData.productConfigurationData.appCodeName,
        appVer,
        mcc,
        mnc,
        info.machineId ?? 'N/A',
      );
    }

    throw UnsupportedPlatformException();
  }
}

// class RemoteAppConfigurationData extends AppConfigurationData {
//   RemoteAppConfigurationData(
//       AppConfigType type,
//       BuildVariant buildVariant,
//       CompanyVariant companyVariant,
//       ProductVariant productVariant,
//       PushVariant pushVariant,
//       List<ProductFeature> productFeatures,
//       int apiRequestTimeout,
//       String initialApiEntry,
//       ThemeData theme,
//       ExtendedThemeData themeExtension,
//       ThemeData darkTheme,
//       ExtendedThemeData darkThemeExtension,
//       String appName,
//       String appCodeName,
//       String mapboxAccessToken,
//       String appMetricaApiKey,
//       String userRegistrySmsNumber,
//       String userRegistryCommandForSms,
//       String mobileOperatorName,
//       String phoneFormatterMask,
//       String iosAppStoreId,
//       String androidApplicationId,
//       bool trustAllSSLCertificates,
//       bool useCompute,
//       OnboardingConfig onboardingConfig,
//       AbstractDatePicker datePicker,
//       ProductConfigurationData productConfigurationData,
//       AppLocalizationsDelegate localizationsDelegate,
//       bool usePhoneNumberMasking, {
//         List<String>? allowedRootCertificatesFingerprints,
//         List<String>? allowedDomainCommonNames,
//         String? captchaKey
//       }
//       ) : super(
//       type,
//       buildVariant,
//       companyVariant,
//       productVariant,
//       pushVariant,
//       productFeatures,
//       apiRequestTimeout,
//       initialApiEntry,
//       theme,
//       themeExtension,
//       darkTheme,
//       darkThemeExtension,
//       appName,
//       appCodeName,
//       mapboxAccessToken,
//       appMetricaApiKey,
//       userRegistrySmsNumber,
//       userRegistryCommandForSms,
//       mobileOperatorName,
//       phoneFormatterMask,
//       iosAppStoreId,
//       androidApplicationId,
//       trustAllSSLCertificates,
//       useCompute,
//       onboardingConfig,
//       datePicker,
//       productConfigurationData,
//       localizationsDelegate,
//       usePhoneNumberMasking,
//       allowedRootCertificatesFingerprints: allowedRootCertificatesFingerprints,
//       allowedDomainCommonNames: allowedDomainCommonNames,
//       captchaKey: captchaKey
//   );
//
//   // ===========================================================================
//   // AppConfigurationData
//   // ===========================================================================
//
//   @override
//   Future<Providers> buildRepositories(AppConfigType type) async {
//     // FIXME: Надо подумать куда это приткнуть потом.
//     // #for_aurora_support
//     // Добавлено для ОС Аврора.
//     FlutterSecureStorageAurora.setSecret('5872747ed1ceda363808efb8b2b18b33');
//
//     final cacheTrackDatabase = await AppDatabase.createBgTrackInstance();
//
//     final cacheDatabase = type == AppConfigType.base ? await AppDatabase.createInstance() : cacheTrackDatabase;
//
//     final appRuntimeInfo = await _appRuntimeInfo();
//
//     final sharedPreferences = await SharedPreferences.getInstance();
//     const secureStorage = FlutterSecureStorage();
//     const secureStorageIOSOptions = IOSOptions(accessibility: KeychainAccessibility.first_unlock);
//
//     final logLevelManager = LogLevelManager();
//
//     final certificatePinningManager = CertificatePinningManager(
//       allowedRootCertificatesFingerprints,
//       allowedDomainCommonNames,
//     );
//
//     overrideCreateHttpClient(trustAllSSLCertificates);
//
//     final cwaDSLogger = CwaDataSourceLogger();
//     final fwaDSLogger = FwaDataSourceLogger();
//     final awaDSLogger = AwaDataSourceLogger();
//
//     final apiEntriesManager = ApiEntriesManager(
//         apiInitialEntry
//     );
//
//     final floorFormsDataSource = FloorFormsDataSource(
//       cacheDatabase.formDao,
//       cacheDatabase.formItemDataDao,
//       // cacheDatabase.formItemFileDao,
//     );
//
//     final floorFormItemAttachmentDataSource = FloorFormItemAttachmentDataSource(
//         cacheDatabase.formItemFileDao
//     );
//
//     final sharedPreferencesDataSource = SharedPreferencesDataSource(sharedPreferences);
//
//     late AbstractPushManager pushManager;
//     if (pushVariant == PushVariant.firebase) {
//       pushManager = FirebasePushManager();
//     } else if (pushVariant == PushVariant.huawei) {
//       pushManager = HuaweiPushManager();
//     } else {
//       pushManager = NonePushManager();
//     }
//
//     final attachmentsDir = await attachmentsDirectory();
//
//     // =========================================================================
//     // NEW API
//     // =========================================================================
//
//     final tokenManager = TokenManager();
//
//     final cwaAuthHttpClient = chc_cwa.DioHttpClient(
//         dio: _createDio(
//             certificatePinningManager.certificatePinning,
//             tokenManager.token,
//             logLevelManager.logLevelProvider,
//             interceptors: [
//               DioBaseUrlInjector(apiEntriesManager.coordinator)
//             ]
//         )
//     );
//
//     final cwaHttpAuthHttpClient = chc_cwa.DioHttpClient(
//         dio: _createDio(
//             certificatePinningManager.certificatePinning,
//             tokenManager.token,
//             logLevelManager.logLevelProvider,
//             interceptors: [
//               DioBaseUrlInjector(apiEntriesManager.httpAuth)
//             ]
//         )
//     );
//
//     final cwaJwtHttpClient = chc_cwa.DioHttpClient(
//         dio: _createDio(
//             certificatePinningManager.certificatePinning,
//             tokenManager.jwt,
//             logLevelManager.logLevelProvider,
//             interceptors: [
//               DioBaseUrlInjector(apiEntriesManager.coordinator)
//             ]
//         )
//     );
//
//     final fwaDio = _createDio(
//         certificatePinningManager.certificatePinning,
//         tokenManager.jwt,
//         logLevelManager.logLevelProvider,
//         interceptors: [
//           DioBaseUrlInjector(apiEntriesManager.formWebApi)
//         ]
//     );
//
//     final awaDio = _createDio(
//         certificatePinningManager.certificatePinning,
//         tokenManager.jwt,
//         logLevelManager.logLevelProvider,
//         interceptors: [
//           DioBaseUrlInjector(apiEntriesManager.assetWebApi)
//         ]
//     );
//
//     final accountApi = chc_cwa.JsCwaAccountApi(
//         cwaAuthHttpClient, cwaJwtHttpClient
//     );
//     final captchaApi = chc_cwa.JsCwaCaptchaApi(cwaAuthHttpClient);
//     final userApi = chc_cwa.JsCwaUserApi(cwaAuthHttpClient);
//     final authApi = chc_cwa.JsCwaAuthApi(cwaAuthHttpClient);
//     final httpAuthApi = chc_cwa.JsCwaHttpAuthApi(cwaHttpAuthHttpClient);
//     final appsApi = chc_cwa.JsCwaAppsApi(cwaJwtHttpClient);
//     final locationsApi = chc_cwa.JsCwaLocationsApi(cwaJwtHttpClient);
//     final trackLocationsApi = chc_cwa.JsCwaTrackLocationsApi(cwaJwtHttpClient);
//
//     final feedbackApi = chc_cwa.JsCwaFeedbackApi(cwaJwtHttpClient);
//     final checkinsApi = chc_cwa.JsCwaCheckinsApi(cwaJwtHttpClient);
//     final messagesApi = chc_cwa.JsCwaMessagesApi(cwaJwtHttpClient);
//     final messageTemplatesApi = chc_cwa.JsCwaMessageTemplatesApi(cwaJwtHttpClient);
//     final mapObjectsApi = chc_cwa.JsCwaObjectsApi(cwaJwtHttpClient);
//     final tasksApi = chc_cwa.JsCwaTasksApi(cwaJwtHttpClient);
//     final formsApi = chc_cwa.JsCwaFormsApi(cwaJwtHttpClient);
//     final checklistsApi = chc_cwa.JsCwaChecklistsApi(cwaJwtHttpClient);
//
//     final fwaFormsApi = fwa.RetrofitFwaFormsApi(fwaDio);
//     final fwaFormTemplatesApi = fwa.RetrofitFwaFormTemplatesApi(fwaDio);
//     final awaChecklistsApi = awa.RetrofitAwaChecklistsApi(awaDio);
//
//     // =========================================================================
//     // NEW API
//     // =========================================================================
//
//     final restFormsDataSource = CwaFormsDataSource(
//         formsApi, cwaDSLogger
//     );
//
//     // Отсюда получаем сгенерированные формы:
//     // Предзаполненная форма
//     final fwaGeneratedFormDataSource = FwaGeneratedFormsDataSource(
//         fwaFormsApi,
//         fwaDSLogger
//     );
//
//     final fwaFormTemplatesDataSource = FwaFormTemplatesDataSource(
//         fwaFormTemplatesApi,
//         fwaDSLogger
//     );
//
//     final fwaFormTemplateDescriptionsDataSource = FwaFormTemplateDescriptionsDataSource(
//         fwaFormTemplatesApi,
//         fwaDSLogger
//     );
//
//     final awaChecklistTemplateDataSource = AwaChecklistTemplateDataSource(
//         awaChecklistsApi, awaDSLogger
//     );
//
//     final mapObjectsRepository = MapObjectsRepository(
//         FloorMapObjectsDataSource(
//             cacheDatabase.mapObjectDao,
//             cacheDatabase.customFieldDao,
//             cacheDatabase.customFieldAttachmentDao,
//             cacheDatabase.technicalDescriptionLabelDao,
//             cacheDatabase.technicalDescriptionStringDao
//         ),
//         CwaMapObjectsDataSource(
//             mapObjectsApi, cwaDSLogger
//         )
//       // JsonMapObjectsDataSource(
//       //   RemoteJsonMapObjectsApi(httpClient, apiEntriesManager.coordinator, useCompute),
//       // ),
//     );
//
//     final floorFormTemplateDescriptionsDataSource = FloorFormTemplateDescriptionsDataSource(
//         cacheDatabase.formTemplatesDao,
//         cacheDatabase.formTemplateItemsDao
//     );
//
//     final floorCheckinAttachmentsDataSource = FloorCheckinAttachmentsDataSource(
//         cacheDatabase.checkinFileDao
//     );
//     final floorTaskUpdateAttachmentsDataSource = FloorTaskUpdateAttachmentsDataSource(
//       cacheDatabase.taskUpdateFileDao,
//     );
//
//     final localServiceSettingsDataSource = LocalServiceSettingsDataSource(
//         sharedPreferences,
//         secureStorage,
//         secureStorageIOSOptions
//     );
//
//     return Providers(
//         apiEntriesManager,
//
//         tokenManager,
//
//         certificatePinningManager,
//         WorkmanagerJobsManager(),
//         pushManager,
//         SessionRepository(
//           SessionSecureDataSource(secureStorage, secureStorageIOSOptions),
//           CwaSessionDataSource(
//               accountApi, captchaApi, authApi, httpAuthApi, userApi,
//               appCodeName, usePhoneNumberMasking, cwaDSLogger
//           ),
//         ),
//
//         ServiceSettingsRepository(
//           CwaServiceSettingsDataSource(
//               accountApi, cwaDSLogger
//             // RemoteJsonServiceSettingsApi(httpClient, apiEntriesManager.coordinator, useCompute),
//             // appCodeName,
//           ),
//           localServiceSettingsDataSource,
//         ),
//         PreferencesRepository(
//           sharedPreferencesDataSource,
//         ),
//
//         StatusesRepository(
//           CwaStatusesDataSource(
//             chc_cwa.JsCwaStatusesApi(cwaJwtHttpClient),
//             cwaDSLogger
//           ),
//           FloorStatusesDataSource(
//             cacheDatabase.statusDao,
//           ),
//         ),
//         ActiveStatusRepository(
//           CwaActiveStatusDataSource(
//             chc_cwa.JsCwaStatusesApi(cwaJwtHttpClient),
//             cwaDSLogger
//           ),
//           FloorActiveStatusDataSource(
//             cacheDatabase.activeStatusDao,
//           ),
//         ),
//         TracksRepository(
//           FloorTracksDataSource(
//             cacheTrackDatabase.trackDao,
//             cacheTrackDatabase.trackPointDao,
//           ),
//           CwaTracksDataSource(
//             trackLocationsApi, cwaDSLogger
//           ),
//         ),
//
//
//
//         LocationsRepository(
//           CwaLocationsDataSource(
//             locationsApi, cwaDSLogger
//           ),
//         ),
//         FeedbackRepository(
//             CwaFeedbackDataSource(feedbackApi, attachmentsDir, cwaDSLogger)
//         ),
//         LogsRepository(
//             CwaLogsDataSource(feedbackApi, attachmentsDir, cwaDSLogger)
//         ),
//         MessagesRepository(
//           CwaMessagesDataSource(
//               messagesApi, attachmentsDir, cwaDSLogger
//           ),
//
//           FloorMessagesDataSource(cacheDatabase.messageDao),
//           FloorMessageAttachmentDataSource(
//             cacheDatabase.messageAttachmentDao,
//           ),
//         ),
//
//
//
//         MessageDescriptionsRepository(
//           FloorMessageDescriptionsDataSource(
//               cacheDatabase.messageDao
//           ),
//         ),
//
//         MessageReadMarkRepository(
//             CwaMessageReadMarkDataSource(messagesApi, cwaDSLogger),
//             FloorMessageReadMarkDataSource(cacheDatabase.messageReadMarkDao)
//         ),
//
//
//
//         MessageAttachmentRepository(
//           // MultipartMessageAttachmentDataSource(
//           //     attachmentExpApi,
//           // ),
//             CwaMessageAttachmentsDataSource(
//                 messagesApi, attachmentsDir, cwaDSLogger
//             ),
//             FloorMessageAttachmentDataSource(
//               cacheDatabase.messageAttachmentDao,
//             )),
//         TasksRepository(
//             FloorTasksDataSource(
//               cacheDatabase.tasksDao,
//               cacheDatabase.taskAttachmentDao,
//               cacheDatabase.customFieldDao,
//               cacheDatabase.customFieldAttachmentDao,
//               cacheDatabase.technicalDescriptionLabelDao,
//               cacheDatabase.technicalDescriptionStringDao,
//               cacheDatabase.taskStatusFormTemplateDao,
//               cacheDatabase.checklistDescriptorDao,
//             ),
//             CwaTasksDataSource(tasksApi, cwaDSLogger),
//             sharedPreferences
//         ),
//         TaskDescriptionRepository(
//           FloorTaskDescriptionDataSource(
//             cacheDatabase.tasksDao,
//           ),
//         ),
//         TaskHistoriesRepository(
//             FloorTaskHistoriesDataSource(
//                 cacheDatabase.taskHistoryDao,
//                 cacheDatabase.taskHistoryFileDao,
//                 cacheDatabase.taskHistoryFormInfoDao
//             ),
//             // JsonTaskHistoriesDataSource(
//             //   RemoteJsonTaskHistoriesApi(httpClient, apiEntriesManager.coordinator, useCompute,
//             // ),
//             CwaTaskHistoryDataSource(tasksApi, cwaDSLogger)
//         ),
//
//
//
//         TaskUpdateDescriptionRepository(
//             FloorTaskUpdateDescriptionDataSource(
//               cacheDatabase.taskUpdateDao,
//             )
//         ),
//         TaskUpdateRepository(
//             FloorTaskUpdateDataSource(
//               cacheDatabase.taskUpdateDao,
//             ),
//             floorTaskUpdateAttachmentsDataSource,
//             CwaTaskUpdateDataSource(
//                 tasksApi, attachmentsDir, cwaDSLogger
//             )
//         ),
//
//         TaskUpdateAttachmentsRepository(
//             CwaTaskUpdateAttachmentsDataSource(
//                 tasksApi, attachmentsDir, cwaDSLogger
//             ),
//             floorTaskUpdateAttachmentsDataSource
//         ),
//         mapObjectsRepository,
//
//
//
//         FormTemplatesRepository(
//             FloorFormTemplatesDataSource(
//               cacheDatabase.formTemplatesDao,
//               cacheDatabase.formTemplateItemsDao,
//               cacheDatabase.formTemplateItemConditionsDao,
//             ),
//             // JsonFormTemplatesDataSource(
//             //   formTemplatesApi
//             //   // RemoteJsonFormTemplatesApi(httpClient, apiEntriesManager.coordinator, useCompute),
//             // ),
//             // CwaFormTemplatesDataSource(
//             //     formTemplatesApi, checklistTemplatesApi, cwaDSLogger
//             // ),
//             fwaFormTemplatesDataSource,
//             floorFormTemplateDescriptionsDataSource,
//             fwaFormTemplateDescriptionsDataSource,
//             awaChecklistTemplateDataSource
//         ),
//
//         FormTemplateDescriptionsRepository(
//             FloorFormTemplatesDataSource(
//               cacheDatabase.formTemplatesDao,
//               cacheDatabase.formTemplateItemsDao,
//               cacheDatabase.formTemplateItemConditionsDao,
//             ),
//             // CwaFormTemplatesDataSource(
//             //     formTemplatesApi, checklistTemplatesApi, cwaDSLogger
//             // ),
//             fwaFormTemplatesDataSource,
//             floorFormTemplateDescriptionsDataSource
//         ),
//         FormRepository(
//             floorFormsDataSource,
//             restFormsDataSource,
//             fwaGeneratedFormDataSource,
//             floorFormItemAttachmentDataSource
//         ),
//         FormSnapshotRepository(
//             FloorFormsSnapshotDataSource(
//               cacheDatabase.formSnapshotDao,
//               cacheDatabase.formSnapshotItemDataDao,
//               // cacheDatabase.formSnapshotItemFileDao
//             ),
//             restFormsDataSource,
//             FloorFormSnapshotItemAttachmentDataSource(cacheDatabase.formSnapshotItemFileDao)
//         ),
//
//         /// Аттачи для форм
//         FormItemAttachmentsRepository(
//             CwaFormItemAttachmentsDataSource(
//                 formsApi, attachmentsDir, cwaDSLogger
//             ),
//             floorFormItemAttachmentDataSource,
//             CwaChecklistItemAttachmentsDataSource(
//                 checklistsApi, attachmentsDir, cwaDSLogger
//             )
//         ),
//
//         /// Аттачи для форм снэпшотов
//         FormItemAttachmentsRepository(
//             CwaFormItemAttachmentsDataSource(
//                 formsApi, attachmentsDir, cwaDSLogger
//             ),
//             FloorFormSnapshotItemAttachmentDataSource(
//                 cacheDatabase.formSnapshotItemFileDao
//             ),
//             CwaChecklistItemAttachmentsDataSource(
//                 checklistsApi, attachmentsDir, cwaDSLogger
//             )
//         ),
//         ChecklistRepository(
//             FloorChecklistDataSource(
//                 cacheDatabase.formDao, cacheDatabase.formItemDataDao
//             ),
//             floorFormItemAttachmentDataSource
//         ),
//
//         ChecklistDescriptionRepository(
//             floorFormsDataSource,
//             FloorChecklistDescriptionDataSource(
//                 cacheDatabase.formDao
//             ),
//             fwaGeneratedFormDataSource,
//             floorFormItemAttachmentDataSource
//         ),
//         FormDescriptionRepository(
//             floorFormsDataSource,
//             restFormsDataSource,
//             FloorFormDescriptionDataSource(cacheDatabase.formDao,),
//             floorFormItemAttachmentDataSource
//         ),
//
//         PushLogRepository(
//           FloorPushLogDataSource(cacheDatabase.pushLogDao),
//         ),
//         QuickCommentsRepository(
//           FloorQuickCommentsDataSource(
//             cacheDatabase.quickCommentsDao,
//           ),
//         ),
//         MessageTemplateRepository(
//             FloorMessageTemplateDataSource(cacheDatabase.messageTemplatesDao,),
//             CwaMessageTemplatesDataSource(
//                 messageTemplatesApi, cwaDSLogger
//             )
//           // JsonMessageTemplateDataSource(
//           //   RemoteJsonMessageTemplateApi(httpClient, apiEntriesManager.coordinator, useCompute),
//           // ),
//         ),
//         CheckinRepository(
//             FloorCheckinDataSource(cacheDatabase.checkinDao),
//             floorCheckinAttachmentsDataSource,
//             CwaCheckinDataSource(checkinsApi, attachmentsDir, cwaDSLogger)
//         ),
//
//         CheckinAttachmentsRepository(
//             CwaCheckinAttachmentsDataSource(checkinsApi, attachmentsDir, cwaDSLogger),
//             floorCheckinAttachmentsDataSource
//         ),
//         CheckinDescriptionRepository(
//           FloorCheckinDescriptionDataSource(cacheDatabase.checkinDao),
//         ),
//
//
//         TaskReadMarkRepository(
//             FloorTaskReadMarkDataSource(cacheDatabase.taskReadMarksDao),
//             // JsonTaskReadMarkDataSource(
//             //   RemoteJsonTaskReadMarkApi(httpClient, apiEntriesManager.coordinator, useCompute),
//             // ),
//             CwaTaskReadMarkDataSource(tasksApi, cwaDSLogger)
//         ),
//         RouteRepository(
//           CwaRouteDataSource(
//               chc_cwa.JsCwaRoutesApi(cwaJwtHttpClient),
//               cwaDSLogger),
//           // JsonRouteDataSource(
//           //     RemoteJsonRoutesApi(httpClient, apiEntriesManager.coordinator, useCompute)
//           // ),
//           FloorRouteDataSource(
//             cacheDatabase.routeDao,
//             cacheDatabase.visitDao,
//             cacheDatabase.pathPointDao,
//           ),
//         ),
//         RouteDescriptionRepository(
//           CwaRouteDescriptionDataSource(
//               chc_cwa.JsCwaRoutesApi(cwaJwtHttpClient),
//               cwaDSLogger
//           ),
//           FloorRouteDescriptionDataSource(
//             cacheDatabase.routeDao,
//             cacheDatabase.visitDao,
//           ),
//         ),
//         TaskCommentUpdateRepository(
//             FloorTaskCommentUpdateDataSource(cacheDatabase.taskCommentUpdateDao),
//             CwaTaskCommentUpdateDataSource(tasksApi, cwaDSLogger)
//           // JsonTaskCommentUpdateDataSource(
//           //   RemoteJsonTaskCommentUpdateApi(httpClient, apiEntriesManager.coordinator, useCompute,
//           // ),),
//         ),
//         ApplicationRepository(
//           FloorApplicationDataSource(cacheDatabase.applicationDao),
//           //JsonApplicationDataSource(
//           //  RemoteJsonTaskCommentUpdateApi(httpClient, apiEntriesManager.coordinator, useCompute,),
//           //),
//         ),
//         AppStateUpdateRepository(
//           FloorAppStateUpdateDataSource(cacheDatabase.appStateUpdateDao),
//           CwaAppStateUpdateDataSource(
//             appsApi,
//             cwaDSLogger
//           ),
//         ),
//         AppStateRepository(
//           CwaAppStateDataSource(
//             appsApi,
//             cwaDSLogger
//           ),
//         ),
//         LocalAuthenticationDataRepository(
//           LocalLocalAuthenticationDataDataSource(
//               secureStorage, secureStorageIOSOptions
//           ),
//           sharedPreferencesDataSource,
//         ),
//
//         logLevelManager,
//
//         InitialApiEntryRepository(
//             sharedPreferencesDataSource,
//             LocalInitialApiEntryDataSource(sharedPreferences)
//         ),
//
//         SecurityRepository(
//             sharedPreferencesDataSource,
//             SecurityDataSource(secureStorage, secureStorageIOSOptions)
//         )
//     );
//   }
//
//   @override
//   Future<Services> buildServices(Providers providers) async {
//     final sessionService = SessionService(
//       providers.sessionRepository,
//       providers.serviceSettingsRepository,
//       providers.apiEntriesManager,
//       providers.tokenManager,
//       appCodeName,
//       productConfigurationData.brandId,
//     );
//
//     final tasksNotificationService = TaskNotificationService(
//       sessionService,
//       providers.preferencesRepository,
//       localizationsDelegate,
//     );
//
//     return Services(
//         sessionService,
//         tasksNotificationService,
//         TaskSyncService(
//           sessionService,
//           tasksNotificationService,
//           providers.tasksRepository,
//           providers.mapObjectsRepository,
//           providers.formTemplatesRepository,
//         ),
//         LocationSyncService(
//           sessionService,
//           providers.locationsRepository,
//         ),
//         MapObjectSyncService(
//           sessionService,
//           providers.mapObjectsRepository,
//           providers.formTemplatesRepository,
//         ),
//         RouteSyncService(
//           sessionService,
//           providers.routeRepository,
//         ),
//         RouteDescriptionSyncService(
//           sessionService,
//           providers.routeDescriptionRepository,
//         ),
//         FormTemplateSyncService(
//             sessionService,
//             providers.formTemplateDescriptionsRepository,
//             providers.formTemplatesRepository
//         ),
//         LogsSyncService(
//           sessionService,
//           providers.logsRepository,
//         ),
//         StatusesSyncService(
//           sessionService,
//           providers.statusesRepository,
//         ),
//         ServiceSettingsSyncService(
//           sessionService,
//           providers.serviceSettingsRepository,
//         ),
//         ForcedSyncService(),
//         CacheClearService(
//           providers.activeStatusRepository,
//           providers.appStateUpdateRepository,
//           providers.applicationRepository,
//           providers.checkinRepository,
//           providers.formTemplatesRepository,
//           providers.formRepository,
//           providers.formSnapshotRepository,
//           providers.mapObjectsRepository,
//           providers.messageTemplateRepository,
//           providers.messagesRepository,
//           providers.quickCommentsRepository,
//           providers.routeRepository,
//           providers.statusesRepository,
//           providers.taskCommentUpdateRepository,
//           providers.taskHistoriesRepository,
//           providers.taskReadMarkRepository,
//           providers.taskUpdateRepository,
//           providers.tasksRepository,
//           providers.tracksRepository,
//           providers.preferencesRepository,
//         ),
//         SecurityService(providers.securityRepository),
//         ActiveTrackService(providers.tracksRepository)
//     );
//   }
//
//   Dio _createDio(
//       AbstractCertificatePinningProvider certificatePinningProvider,
//       AbstractToken token,
//       AbstractLogLevelProvider logLevelProvider, {
//         AbstractApiEntryProvider? baseUrlProvider,
//         List<Interceptor> interceptors = const <Interceptor>[]
//       }
//       ) {
//
//     final dio = Dio()
//       ..options.connectTimeout = Duration(seconds: apiRequestTimeout)
//       ..options.receiveTimeout = Duration(seconds: apiRequestTimeout)
//       ..options.sendTimeout = Duration(seconds: apiRequestTimeout)
//       ..interceptors.addAll([
//         ...interceptors,
//         DioTokenInjector(token),
//         DioLoggingInterceptor(
//             logLevelProvider: logLevelProvider,
//             overrideLogLevel: buildVariant != BuildVariant.store,
//             compact: true,
//             logPrint: (o) => Logger.i('MPC', 'DioHttpClient', '$o')
//         ),
//         if (productFeatures.contains(ProductFeature.certificatePinning))
//           DioCertificatePinningInterceptor(
//               certificatePinningProvider
//           ),
//       ]);
//
//     if (baseUrlProvider != null) {
//       dio.options.baseUrl = baseUrlProvider.apiEntry;
//     }
//
//     return dio;
//   }
//
//   Future<AppRuntimeInfo> _appRuntimeInfo() async {
//     final packageInfo = await PackageInfo.fromPlatform();
//     final appVer = '${packageInfo.version}.${packageInfo.buildNumber}';
//
//     String mcc = await MpDevice.instance.mcc; // '250'
//     String mnc = await MpDevice.instance.mnc; // '01' - MTS, 99 - BeeLine
//
//     if (Platform.isAndroid) {
//       final info = await DeviceInfoPlugin().androidInfo;
//       final deviceId = await MpDevice.instance.deviceId;
//
//       return AppRuntimeInfo(
//         'Android',
//         info.version.release,
//         info.manufacturer,
//         info.model,
//         appCodeName,
//         appVer,
//         mcc,
//         mnc,
//         deviceId, // info.androidId
//       );
//     }
//
//     if (Platform.isIOS) {
//       final info = await DeviceInfoPlugin().iosInfo;
//       return AppRuntimeInfo(
//         'iOS',
//         info.systemVersion,
//         info.name,
//         info.model,
//         appCodeName,
//         appVer,
//         mcc,
//         mnc,
//         info.identifierForVendor ?? 'N/A',
//       );
//     }
//
//     // FIXME: возможно надо будет как-то исправить потом.
//     // #for_aurora_support
//     // Добавленно для поддержки ОС Аврора. На уровне кода приложения
//     // я стараюсь не добавлять явную зависимость к ОС Аврора.
//     if (Platform.isLinux) {
//       final info = await DeviceInfoPlugin().linuxInfo;
//       return AppRuntimeInfo(
//         'Linux', // 'Aurora',
//         info.version ?? 'N/A',
//         info.name,
//         '1.0', // info.model,
//         appCodeName,
//         appVer,
//         mcc,
//         mnc,
//         info.machineId ?? 'N/A',
//       );
//     }
//
//     throw UnsupportedPlatformException();
//   }
// }
