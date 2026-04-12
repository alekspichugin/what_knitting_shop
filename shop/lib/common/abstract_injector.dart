import 'dart:io' as io;

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:mpcoordinator/common/abstract_http_client_config_manager.dart';
import 'package:mpcoordinator/common/exceptions_manager.dart';
import 'package:mpcoordinator/domain/service/custom_fields_update/custom_fields_update_sync_service.dart';
import 'package:mpcoordinator/domain/service/forced_sync/forced_sync_service.dart';
import 'package:mpcoordinator/domain/service/security/security_service.dart';
import 'package:mpcoordinator/domain/service/track/active_track_service.dart';

import '/domain/managers/jobs/abstract_jobs_manager.dart';
import '/domain/managers/push/abstract_push_manager.dart';
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
import 'api_entry_provider.dart';
import 'app_configuration_data.dart';
import 'certificate_pinning_provider.dart';
import 'log_level_provider.dart';

abstract class AbstractInjector {
  /// Использовать операцию compute для проведения конвертации данных в API в
  /// изоляте.
  final bool useCompute;

  /// Конфигурация сборки приложения.
  final AppConfigurationData appConfigurationData;

  /// Директория, где хранятся все аттачи приложение.
  late final io.Directory? attachmentsDir;

  /// Менеджеры приложения.
  late final ApiEntriesManager apiEntriesManager;
  late final AbstractTokenManager tokenManager;
  late final CertificatePinningManager certificatePinningManager;
  late final AbstractJobsManager jobsManager;
  late final AbstractPushManager pushManager;
  late final LogLevelManager logLevelManager;
  /// Менеджер, занимающийся ошибками при аутентификации
  late final AbstractExceptionsManager authExceptionsManager;
  /// Менеджер, занимающийся ошибками из авторизованной части прилаги
  late final AbstractExceptionsManager exceptionsManager;

  /// Репозитории приложения.
  late final AbstractSessionRepository sessionRepository;
  late final AbstractServiceSettingsRepository serviceSettingsRepository;
  late final AbstractPreferencesRepository preferencesRepository;
  late final AbstractStatusesRepository statusesRepository;
  late final AbstractActiveStatusRepository activeStatusRepository;
  late final AbstractTracksRepository tracksRepository;
  late final AbstractLocationsRepository locationsRepository;
  late final AbstractFeedbackRepository feedbackRepository;
  late final AbstractLogsRepository logsRepository;
  late final AbstractMessagesRepository messagesRepository;
  late final AbstractMessageDescriptionsRepository messageDescriptionsRepository;
  late final AbstractMessageReadMarkRepository messageReadMarkRepository;
  late final AbstractMessageAttachmentRepository messageAttachmentRepository;
  late final AbstractTasksRepository tasksRepository;
  late final AbstractTaskDescriptionRepository taskDescriptionRepository;
  late final AbstractTaskExchangeRepository taskExchangeRepository;
  late final AbstractTaskTypeRepository taskTypeRepository;
  late final AbstractTaskCustomStatusRepository taskCustomStatusRepository;
  late final AbstractTaskCustomStatusReasonRepository taskCustomStatusReasonRepository;
  late final AbstractTaskCustomStatusTransitionRepository taskCustomStatusTransitionRepository;
  late final AbstractTaskTeamRepository taskTeamRepository;
  late final AbstractTaskMetadataRepository taskMetadataRepository;
  late final AbstractTaskHistoriesRepository taskHistoriesRepository;
  late final AbstractTaskUpdateRepository taskUpdateRepository;
  late final AbstractTaskUpdateAttachmentsRepository taskUpdateAttachmentsRepository;
  late final AbstractTaskUpdateDescriptionRepository taskUpdateDescriptionRepository;
  late final AbstractMapObjectsRepository mapObjectsRepository;
  late final AbstractCustomFieldsUpdateRepository customFieldsUpdateRepository;
  late final AbstractFormTemplatesRepository formTemplatesRepository;
  late final AbstractFormTemplateDescriptionsRepository formTemplateDescriptionsRepository;
  late final AbstractFormRepository formRepository;
  late final AbstractFormDescriptionRepository formDescriptionRepository;
  late final AbstractFormSnapshotRepository formSnapshotRepository;
  late final AbstractFormUpdateRepository formUpdateRepository;
  late final AbstractFormUpdateItemAttachmentRepository formUpdateItemAttachmentRepository;
  late final AbstractFormItemAttachmentsRepository formItemAttachmentsRepository;
  late final AbstractFormItemAttachmentsRepository formSnapshotItemAttachmentsRepository;
  late final AbstractChecklistRepository checklistRepository;
  late final AbstractChecklistDescriptionRepository checklistDescriptionRepository;
  late final AbstractChecklistUpdateRepository checklistUpdateRepository;
  late final AbstractChecklistUpdateItemAttachmentRepository checklistUpdateItemAttachmentRepository;
  late final AbstractPushLogRepository pushLogRepository;
  late final AbstractQuickCommentsRepository quickCommentsRepository;
  late final AbstractMessageTemplateRepository messageTemplateRepository;
  late final AbstractCheckinRepository checkinRepository;
  late final AbstractCheckinAttachmentsRepository checkinAttachmentsRepository;
  late final AbstractCheckinDescriptionRepository checkinDescriptionRepository;
  late final AbstractTaskReadMarkRepository taskReadMarkRepository;
  late final AbstractRouteRepository routeRepository;
  late final AbstractRouteDescriptionRepository routeDescriptionRepository;
  late final AbstractTaskCommentUpdateRepository taskCommentUpdateRepository;
  late final AbstractApplicationRepository applicationRepository;
  late final AbstractAppStateUpdateRepository appStateUpdateRepository;
  late final AbstractAppStateRepository appStateRepository;
  late final AbstractLocalAuthenticationDataRepository localAuthenticationRepository;
  late final AbstractInitialApiEntryRepository initialApiEntryRepository;
  late final AbstractSecurityRepository securityRepository;
  late final AbstractGeocodingRepository geocodingRepository;
  late final AbstractSubscriberRepository subscriberRepository;
  late final AbstractWorkScheduleRepository workScheduleRepository;

  /// Сервисы приложения.
  late final SessionService sessionService;
  late final TaskNotificationService tasksNotificationService;
  late final TaskSyncService tasksSyncService;
  late final LocationSyncService locationSyncService;
  late final MapObjectSyncService mapObjectSyncService;
  late final RouteSyncService routeSyncService;
  late final RouteDescriptionSyncService routeDescriptionSyncService;
  late final FormTemplateSyncService formTemplateSyncService;
  late final LogsSyncService logsSyncService;
  late final StatusesSyncService statusesSyncService;
  late final ServiceSettingsSyncService serviceSettingsSyncService;
  late final ForcedSyncService forcedSyncService;
  late final CacheClearService cacheClearService;
  late final SecurityService securityService;
  late final ActiveTrackService activeTrackService;

  AbstractInjector(this.useCompute, this.appConfigurationData);

  /// Инициализация.
  Future<void> init();
}

class Injector extends InheritedWidget {
  const Injector({
    Key? key,
    required this.injector,
    required Widget child,
  }) : super(key: key, child: child);

  final AbstractInjector injector;

  static AbstractInjector of(BuildContext c) {
    return c.dependOnInheritedWidgetOfExactType<Injector>()!.injector;
  }

  @override
  bool updateShouldNotify(Injector oldWidget) => injector != oldWidget.injector;
}
