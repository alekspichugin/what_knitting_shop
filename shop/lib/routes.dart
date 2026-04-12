import 'dart:developer';

import 'package:built_collection/built_collection.dart';
import 'package:domain/domain.dart' hide Route;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:mpcoordinator/data/repositories/map_object_picker/map_object_repository.dart';
import 'package:mpcoordinator/data/repositories/task_editor/map_object_repository.dart';
import 'package:mpcoordinator/data/repositories/task_editor/subscriber_repository.dart';
import 'package:mpcoordinator/data/repositories/task_editor/task_priority_repository.dart';
import 'package:mpcoordinator/data/repositories/task_editor/task_repository.dart';
import 'package:mpcoordinator/data/repositories/task_editor/task_type_repository.dart';
import 'package:mpcoordinator/domain/blocs/auth/auth_by_local_auth/auth_by_local_auth_cubit.dart';
import 'package:mpcoordinator/domain/blocs/authentication/authentication_cubit.dart';
import 'package:mpcoordinator/domain/blocs/checkin/list/checkins_list_cubit.dart';
import 'package:mpcoordinator/domain/blocs/custom_fields_update/custom_fields_update_cubit.dart';
import 'package:mp_core_bloc/mp_core_bloc.dart' as mp_core_bloc;
import 'package:mp_forms/mp_forms.dart' as mp_forms;
import 'package:mp_table/mp_table.dart' as mp_table;
import 'package:mp_task_editor/mp_task_editor.dart' as mp_task_editor;
import 'package:mp_map_object_picker/mp_map_object_picker.dart' as mp_map_object_picker;
import 'package:mpcoordinator/domain/blocs/forms/checklist/checklist_cubit.dart';
import 'package:mpcoordinator/domain/blocs/forms/forms/forms_cubit.dart';
import 'package:mpcoordinator/domain/blocs/forms/templates/form_templates_list_cubit.dart';
import 'package:mpcoordinator/domain/blocs/mdm/knox_mdm_configure_page/knox_mdm_configure_page_cubit.dart';
import 'package:mpcoordinator/domain/blocs/lock_page/lock_page_cubit.dart';
import 'package:mpcoordinator/domain/blocs/messages/editor/message_editor_cubit.dart';
import 'package:mpcoordinator/domain/blocs/navigation/navigation_cubit.dart';
import 'package:mpcoordinator/domain/blocs/onboarding/onboarding_cubit.dart';
import 'package:mpcoordinator/domain/blocs/pin_code_setup_page/pin_code_setup_page_cubit.dart';
import 'package:mpcoordinator/domain/blocs/pin_code_validate_page/pin_code_validate_page_cubit.dart';
import 'package:mpcoordinator/domain/blocs/preferences/preferences_cubit.dart';
import 'package:mpcoordinator/domain/blocs/search/forms_list_search_cubit.dart';
import 'package:mpcoordinator/domain/blocs/search/tasks_list_search_cubit.dart';
import 'package:mpcoordinator/domain/blocs/sync/active_status_sync_cubit.dart';
import 'package:mpcoordinator/domain/blocs/sync/checkin/checkin_sync_cubit.dart';
import 'package:mpcoordinator/domain/blocs/sync/checklist_update/checklist_update_sync_cubit.dart';
import 'package:mpcoordinator/domain/blocs/sync/form_update/form_update_sync_cubit.dart';
import 'package:mpcoordinator/domain/blocs/sync/message/message_attachment_sync_cubit.dart';
import 'package:mpcoordinator/domain/blocs/sync/message/message_sync_cubit.dart';
import 'package:mpcoordinator/domain/blocs/sync/task_update/task_update_attachment_sync_cubit.dart';
import 'package:mpcoordinator/domain/blocs/sync/task_update/task_update_sync_cubit.dart';
import 'package:mpcoordinator/domain/blocs/sync/track_sync_cubit.dart';
import 'package:mpcoordinator/domain/blocs/table_viewer/table_editor_cubit.dart';
import 'package:mpcoordinator/domain/blocs/tasks/common/model/task_form_template_description.dart';
import 'package:mpcoordinator/domain/blocs/tasks/details/exchange/task_details_exchange_cubit.dart';
import 'package:mpcoordinator/domain/blocs/tasks/list/abstract_tasks_list_cubit.dart';
import 'package:mpcoordinator/domain/blocs/tasks/list/archive/tasks_list_archive_cubit.dart';
import 'package:mpcoordinator/domain/blocs/tasks/list/exchange/tasks_list_exchange_cubit.dart';
import 'package:mpcoordinator/domain/blocs/tasks/list/settings/abstract_tasks_list_settings_cubit.dart';
import 'package:mpcoordinator/domain/blocs/tasks/list/settings/tasks_list_archive_settings_cubit.dart';
import 'package:mpcoordinator/domain/blocs/tasks/list/settings/tasks_list_exchange_settings_cubit.dart';
import 'package:mpcoordinator/domain/blocs/tasks/list/routes/tasks_list_routes_cubit.dart';
import 'package:mpcoordinator/domain/blocs/tasks/list/tasks_list_cubit.dart';
import 'package:mpcoordinator/domain/blocs/tasks/prepare_to_final_state/task_prepare_to_final_state_cubit.dart';
import 'package:mpcoordinator/domain/blocs/tasks/task_comment_update/task_comment_update_cubit.dart';
import 'package:mpcoordinator/domain/blocs/tasks/task_custom_status_selector/task_custom_status_selector_cubit.dart';
import 'package:mpcoordinator/domain/blocs/tracking/map/track_map_cubit.dart';
import 'package:mpcoordinator/domain/blocs/work_schedule/work_schedule_cubit.dart';
import 'package:mpcoordinator/features/common/themes/extended_theme.dart';
import 'package:mpcoordinator/features/common/widgets/image_viewer.dart';
import 'package:mpcoordinator/features/common/widgets/pin_code/pin_code_validate_page.dart';
import 'package:mpcoordinator/features/common/widgets/web_view_page.dart';
import 'package:mpcoordinator/features/forms/form/checklist_page.dart';
import 'package:mpcoordinator/features/local_auth/local_auth_config_page.dart';
import 'package:mpcoordinator/features/local_auth/lock_page.dart';
import 'package:mpcoordinator/features/common/widgets/pin_code/pin_code_setup_page.dart';
import 'package:mpcoordinator/features/common/widgets/page_route_controller/page_route_controller.dart';
import 'package:mpcoordinator/features/mdm/knox/knox_mdm_configure_page.dart';
import 'package:mpcoordinator/features/preferences/service_settings_page.dart';
import 'package:mpcoordinator/features/tasks/details/task_details_exchange_page.dart';
import 'package:mpcoordinator/features/tasks/list/archive/tasks_list_archive_page.dart';
import 'package:mpcoordinator/features/tasks/list/exchange/tasks_exchange_page.dart';
import 'package:mpcoordinator/features/tasks/prepare_to_final_state/task_prepare_to_final_state_page.dart';
import 'package:mpcoordinator/features/tracker/map/track_map_page.dart';

import 'common/abstract_injector.dart';
import 'common/app_configuration_data.dart';
import 'common/product_configuration_data.dart';
import 'domain/blocs/camera/camera_cubit.dart';
import 'domain/blocs/active_statuses_history/active_statuses_history_cubit.dart';
import 'domain/blocs/auth/auth_by_http/auth_by_http_cubit.dart';
import 'domain/blocs/auth/auth_by_password/auth_by_password_cubit.dart';
import 'domain/blocs/auth/auth_by_sms/auth_by_sms_cubit.dart';
import 'domain/blocs/auth/auth_by_websso/auth_by_websso_cubit.dart';
import 'domain/blocs/checkin/current/checkin_on_current_cubit.dart';
import 'domain/blocs/checkin/editor/checkin_editor_cubit.dart';
import 'domain/blocs/checkin/history_details/checkin_history_details_cubit.dart';
import 'domain/blocs/common_sync_status/common_sync_status_cubit.dart';
import 'domain/blocs/forms/form/form_cubit.dart';
import 'domain/blocs/forms/form/models/view_form_item.dart';
import 'domain/blocs/forms/forms_templates_picker/forms_templates_picker_cubit.dart';
import 'domain/blocs/image_recognition/image_recognition_cubit.dart';
import 'domain/blocs/map/map_cubit.dart';
import 'domain/blocs/message_templates/message_templates_cubit.dart';
import 'domain/blocs/messages/list/messages_cubit.dart';
import 'domain/blocs/policy_page/policy_page_cubit.dart';
import 'domain/blocs/push_log/push_log_cubit.dart';
import 'domain/blocs/sync_items_list/sync_items_list_cubit.dart';
import 'domain/blocs/table_viewer/table_viewer_cubit.dart';
import 'domain/blocs/tasks/details/task_details_cubit.dart';
import 'domain/blocs/tasks/comment_editor/task_comment_editor_cubit.dart';
import 'domain/blocs/tasks/history/task_history_cubit.dart';
import 'domain/blocs/tasks/list/settings/tasks_list_settings_cubit.dart';
import 'domain/blocs/tracking/list/tracks_list_cubit.dart';
import 'domain/blocs/support/support_cubit.dart';
import 'domain/blocs/map_object/details/map_object_details_cubit.dart';
import 'domain/blocs/map_object/list/map_objects_list_cubit.dart';
import 'domain/blocs/registration/registration_cubit.dart';
import 'domain/blocs/checkin/history/checkins_history_cubit.dart';
import 'domain/blocs/webview/webview_cubit.dart';
import 'features/common/pages/image_recognition/image_recognition_page.dart';
import 'features/common/pages/signature_pad_page.dart';
import 'features/common/pages/camera/camera_page.dart';
import 'features/common/widgets/code_scanner_page.dart';
import 'features/checkins/current/checkin_on_current_page.dart';
import 'features/checkins/details/checkin_details_page.dart';
import 'features/checkins/history/checkins_history_page.dart';
import 'features/checkins/history_details/checkin_history_details_page.dart';
import 'features/checkins/list/checkins_list_page.dart';
import 'features/common/widgets/policy/policy_page.dart';
import 'features/forms/form/form_page.dart';
import 'features/forms/picker/form_templates_picker_page.dart';
import 'features/forms/templates/form_templates_page.dart';
import 'features/main/main_page.dart';
import 'features/more/push_log/push_log_page.dart';
import 'features/preferences/preferences_page.dart';
import 'features/status/history/statuses_history_page.dart';
import 'features/support/support_page.dart';
import 'features/sync_items_list/sync_items_list_page.dart';
import 'features/table/table_viewer_page.dart' as table_viewer_page;
import 'features/table/table_editor_page.dart' as table_editor_page;
import 'features/tasks/details/task_details_page.dart';
import 'features/tasks/history/task_history_page.dart';
import 'features/tracker/list/tracks_list_page.dart';
import 'features/main/about/about_app_page.dart';
import 'features/main/registration/registration_page.dart';
import 'features/quick_comments/quick_comments_page.dart';
import 'features/message_templates/message_templates_page.dart';

const kSplashScreenRoute = '/splash';
const kStartUpRoute = '/startup';
const kMainRoute = '/main';
const kRegistrationRoute = '/registration';
const kStatusesRoute = '/statuses';
const kStatusesHistoryRoute = '/statuses/history';
const kSettingsRoute = '/settings';
const kSupportRoute = '/support';
const kPolicyRoute = '/policy';
// const kPolicyLocationsRoute = '/policy/locations';
// const kPolicyBgLocationsRoute = '/policy/bg_locations';
// const kPolicyNotificationsRoute = '/policy/notifications';
const kSettingsPushLogRoute = '/settings/push/log';
const kTracksListRoute = '/tracks/list';
const kTasksArchiveRoute = '/tasks/archive';
const kTaskDetailsRoute = '/tasks/details';
const kTaskDetailsRouteAnimated = '/tasks/details_animated';
const kTaskDetailsExchangeRoute = '/tasks_exchange/details';
const kTaskDetailsExchangeRouteAnimated = '/tasks_exchange/details_animated';
const kTasksExchangeRoute = '/tasks/exchange';
const kTaskHistoryRoute = '/tasks/details/history';
const kTaskPrepareToFinalStateRoute = '/tasks/switch_to_final_state';
const kCheckinsListRoute = '/checkins/list';
const kCheckinsDetailsRoute = '/checkins/details';
const kCheckinsCurrentRoute = '/checkins/current';
const kCheckinsHistoryListRoute = '/checkins/history';
const kCheckinHistoryDetailsRoute = '/checkins/history/details';
const kFormTemplatesRoute = '/forms/templates';
const kFormsTemplatesPickerRoute = '/forms/picker';
const kFormRoute = '/forms/form';
const kChecklistRoute = '/forms/checklist';
const kFormTableRowRoute = '/forms/form/table_row';
const kCustomFieldsEditorRoute = '/forms/custom_fields_editor';
const kAboutRoute = '/about';
const kQuickCommentsRoute = '/quick_comments';
const kMessageTemplatesRoute = '/message/templates';
const kCodeScannerRoute = '/code_scanner';
const kPhotoCameraRoute = '/camera/photo';
const kVideoCameraRoute = '/camera/video';
const kSignaturePadRoute = '/signature_pad';
const kImageRecognitionRoute = '/image_recognition';
const kServiceSettingsRoute = '/service_settings';
const kKnoxMDMConfigureRoute = '/knox_mdm_configure';
const kLocalAuthConfigureRoute = '/local_auth_config';
const kPinCodeSetupRoute = '/pin_code_setup';
const kPinCodeValidateRoute = '/pin_code_validate';
const kLocalAuthRoute = '/local_auth';
const kImageViewerRoute = '/image_viewer';
const kWebViewRoute = '/web_view';
const kQRCodeViewerRoute = '/qr_code_viewer';
const kSyncItemsListRoute = '/sync_items_list';
const kTrackMapRoute = '/track/map';
const kTableViewerRoute = '/table_viewer';
const kTableEditorRoute = '/table_editor';
const kTaskEditorRoute = '/task_editor';
const kMapObjectPickerRoute = '/map_object_picker';

// =============================================================================

class TaskHistoryRouteArgs {
  const TaskHistoryRouteArgs(
      this.task,
      this.newTaskStatus,
      // this.remoteFormTemplateIds,
      this.isNeedComment,
      this.isNeedForm,
      );

  /// Идентификатор задачи к которой надо указать коментарий.
  final Task task;

  /// Новый статус задачи при указании комментария.
  /// Новый статус может равняться старому, если просто указывается комментарий.
  final TaskStatus newTaskStatus;

  // /// Идентификаторы шаблонов форм, которые надо заполинть.
  // final List<int> remoteFormTemplateIds;

  /// Обязательно требуется написать комментарий (только аттачи не прокатят).
  final bool isNeedComment;

  /// Обязательно требуется прицепить форму.
  final bool isNeedForm;
}

class TaskPrepareToFinalStateRouteArgs {
  TaskPrepareToFinalStateRouteArgs(
      {this.remoteTaskId = 0,
        this.newTaskStatus = TaskStatus.unknown,
        BuiltList<TaskFormTemplateDescription>? requiredTaskStatusFormTemplateDescriptions,
        BuiltList<TaskFormTemplateDescription>? optionalTaskStatusFormTemplateDescriptions,
        this.isCommentRequired = false})
      : requiredTaskStatusFormTemplateDescriptions =
      requiredTaskStatusFormTemplateDescriptions ?? BuiltList<TaskFormTemplateDescription>(),
        optionalTaskStatusFormTemplateDescriptions =
            optionalTaskStatusFormTemplateDescriptions ?? BuiltList<TaskFormTemplateDescription>();

  final int remoteTaskId;

  final TaskStatus newTaskStatus;

  /// Удаленные идентификаторы обязательных к заполнению шаблонов форм.
  final BuiltList<TaskFormTemplateDescription> requiredTaskStatusFormTemplateDescriptions;

  /// Удаленные идентификаторы обязательных к заполнению шаблонов форм.
  final BuiltList<TaskFormTemplateDescription> optionalTaskStatusFormTemplateDescriptions;

  final bool isCommentRequired;
}

class FormTemplatePickerRouteArgs {
  const FormTemplatePickerRouteArgs(
      {this.remoteTaskId = 0,
        this.externalFormTemplatesIds = const <String>[],
        this.prefilledFormUrnsMap = const <String, String>{}});

  /// Удаленный идентификатор шаблона формы.
  final int remoteTaskId;

  /// Если надо отобразить только определенные форомы и шаблоны.
  /// Если значение [], то аргумент не учитывается.
  final List<String> externalFormTemplatesIds;

  /// Мапа урнов предзаполненных форм(если они есть).
  /// Ключ - externalFormTemplateId, значение - Urn предзаполненной формы.
  final Map<String, String> prefilledFormUrnsMap;
}

class FormRouteArgs {
  const FormRouteArgs({
    this.localFormId = 0,
    this.localFormUpdateId = 0,
    this.remoteFormTemplateId = 0,
    this.externalFormTemplateId = '',
    this.externalChecklistTemplateId = '',
    this.needDraft = true,
    this.remoteTaskId,
    this.newTaskStatus = TaskStatus.unknown,
    this.prefilledFormUrn = '',
    required this.templateName
  });

  /// Удаленный идентификатор шаблона формы.
  final int remoteFormTemplateId;

  /// Удаленный идентификатор шаблона формы.
  final String externalFormTemplateId;

  /// Удаленный идентификатор шаблона чек-листа.
  final String externalChecklistTemplateId;

  /// Удаленный идентификатор задачи, к которой прикладывается форма.
  final int? remoteTaskId;

  /// Статус задачи, к которому прикладывается форма.
  final TaskStatus newTaskStatus;

  /// Локальный идентификатор формы. Формы могут быть удаленные и только
  /// локальные (черновики), поэтому мы обращаемся по локальному id.
  final int localFormId;

  /// Локальный идентификатор апдейта формы.
  /// Поскольку у нас может быть форм апдейт-черновик, который создали на основе шаблона.
  /// И на экран редактора формы мы можем попасть через него.
  final int localFormUpdateId;

  /// Urn предзаполненной формы
  final String prefilledFormUrn;

  /// Флаг сигнализирует редактору формы, что не надо отправлять форму ему,
  /// а нужно вернуть ее как черновик. Так как дальше этой формой будет
  /// заниматься другая логика.
  final bool needDraft;

  /// Название формы
  final String templateName;
}

class ChecklistRouteArgs {
  const ChecklistRouteArgs({
    required this.templateName,
    this.externalChecklistId = '',
    this.localChecklistId = 0,
    this.localChecklistUpdateId = 0,
    this.remoteTaskId = 0,
    this.needDraft = true,
  });

  /// Название шаблона
  final String templateName;

  /// Удаленный идентификатор чек-листа.
  final String externalChecklistId;

  /// Локальный идентификатор апдейта формы.
  /// Поскольку у нас может быть форм апдейт-черновик, который создали на основе шаблона.
  /// И на экран редактора формы мы можем попасть через него.
  final int localChecklistUpdateId;

  /// Локальный идентификатор формы. Формы могут быть удаленные и только
  /// локальные (черновики), поэтому мы обращаемся по локальному id.
  final int localChecklistId;

  /// Удаленный идентификатор задачи, к которой прикладывается форма.
  final int remoteTaskId;

  /// Флаг сигнализирует редактору формы, что не надо отправлять форму ему,
  /// а нужно вернуть ее как черновик. Так как дальше этой формой будет
  /// заниматься другая логика.
  final bool needDraft;
}

class FormTableRowRouteArgs {
  FormTableRowRouteArgs(
      this.templateName, {
        this.items = const [],
        this.templateItems = const [],
      });

  final String templateName;
  final List<mp_forms.FormItemData> items;
  final List<mp_forms.FormTemplateItem> templateItems;
}

class CustomFieldsEditorArgs {
  CustomFieldsEditorArgs(this.templateName, this.templateDescription, this.viewItems);

  final String templateName;
  final String templateDescription;
  final List<ViewFormItem> viewItems;
}

class CheckinsCurrentRouteArgs {
  CheckinsCurrentRouteArgs(
      this.needDraft,
      this.needNfcTag,
      this.allowAttaches,
      );

  /// Флаг сигнализирует редактору отметки, что надо вернуть отметку без
  /// сохранения и отправки ее.
  final bool needDraft;

  /// Флаг сигнализирует редактору отметки, что надо считать NFC-метку.
  /// Если метку не прочитали, то отметку вернуть редактор не сможет.
  final bool needNfcTag;

  /// Флаг сигнализирует о том, разрешено ли добавлять аттачи.
  final bool allowAttaches;
}

class LocalAuthConfigureRouteArgs {
  const LocalAuthConfigureRouteArgs(
      this.canBackPress,
      this.canSkip,
      );

  /// Разрешено закрыть экран через бэк пресс + в аппбаре есть стрелка "Назад".
  final bool canBackPress;

  /// На экране есть кнопка "Пропустить".
  final bool canSkip;
}

class PinCodeValidateRouteArgs {
  PinCodeValidateRouteArgs(this.title, this.expectedCombination, this.authByBiometricEnabled);

  final String title;

  final String expectedCombination;

  final bool authByBiometricEnabled;
}

class WebViewRouteArgs {
  WebViewRouteArgs(
      this.uri, {
        this.fromAssets,
        this.title,
      });

  final String uri;
  final bool? fromAssets;
  final String? title;
}

class TableViewerRouteArgs {

  TableViewerRouteArgs(this.title, {
    this.headers = const <String>[],
    this.rows = const <List<String>>[],
  });

  final String title;
  final List<String> headers;
  final List<List<String>> rows;
}

class TableEditorRouteArgs {

  TableEditorRouteArgs(this.title, this.templateItems, {
    List<List<mp_table.CellData>>? rows,
  }) : rows = rows ?? const <List<mp_table.CellData>>[];

  final String title;
  final List<mp_table.ColumnData> templateItems;
  final List<List<mp_table.CellData>> rows;
}

class QRCodeViewerRouteArgs {
  QRCodeViewerRouteArgs(this.data, {this.color});

  final String data;

  final Color? color;
}

// =============================================================================

Map<String, WidgetBuilder> createRoutes(AbstractInjector injector) {
  // final repos = appConfig.repositories;
  // final services = appConfig.services;

  return <String, WidgetBuilder>{
    kMainRoute: (c) {
      final serviceSettings = c.read<AuthenticationCubit>().state.session.serviceSettings;

      final tasksListCubitProvider = serviceSettings.taskOrderFromRoute
          ? BlocProvider<TasksListCubit>(
              key: ValueKey(serviceSettings.taskOrderFromRoute),
              create: (c) => TasksListRoutesCubit(
                injector.taskTypeRepository,
                injector.taskCustomStatusRepository,
                injector.taskCustomStatusTransitionRepository,
                injector.taskCustomStatusReasonRepository,
                injector.mapObjectsRepository,
                injector.checklistUpdateRepository,
                injector.checklistDescriptionRepository,
                injector.exceptionsManager,
                injector.formTemplatesRepository,
                c.read(),
                c.read(),
                c.read(),
                c.read<TasksListSearchCubit>(),
                injector.tasksRepository,
                injector.taskUpdateDescriptionRepository,
                injector.checkinDescriptionRepository,
                injector.tasksNotificationService,
                injector.pushManager,
                c.read(),
                c.read(),
                c.read(),
                c.read(),
                injector.routeRepository
              )
          )
          : BlocProvider<TasksListCubit>(
              key: ValueKey(serviceSettings.taskOrderFromRoute),
              create: (c) => TasksListCubit(
                injector.taskTypeRepository,
                injector.taskCustomStatusRepository,
                injector.taskCustomStatusTransitionRepository,
                injector.taskCustomStatusReasonRepository,
                injector.mapObjectsRepository,
                injector.checklistUpdateRepository,
                injector.checklistDescriptionRepository,
                injector.exceptionsManager,
                injector.formTemplatesRepository,
                c.read(),
                c.read(),
                c.read(),
                c.read<TasksListSearchCubit>(),
                injector.tasksRepository,
                injector.taskUpdateDescriptionRepository,
                injector.checkinDescriptionRepository,
                injector.tasksNotificationService,
                injector.pushManager,
                c.read(),
                c.read(),
                c.read(),
                c.read(),
              )
          );

      return MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (c) => MessageAttachmentSyncCubit(
                injector.messageAttachmentRepository,
                c.read(),
                c.read(),
              )
          ),
          BlocProvider(
              create: (c) => FormUpdateSyncCubit(
                injector.formUpdateRepository,
                c.read(),
                c.read(),
              )
          ),
          BlocProvider(
              create: (c) => MessageSyncCubit(
                injector.messagesRepository,
                c.read(),
                c.read(),
              )
          ),
          BlocProvider(
              create: (c) => TaskUpdateSyncCubit(
                injector.taskUpdateRepository,
                c.read(),
                c.read(),
              )
          ),
          BlocProvider(
              create: (c) => TasksListSearchCubit()
          ),
          BlocProvider(
              create: (c) => FormsListSearchCubit()
          ),
          BlocProvider(
            create: (c) => CommonSyncStatusCubit(
                injector.formRepository,
                injector.formDescriptionRepository,
                injector.formItemAttachmentsRepository,
                injector.messagesRepository,
                injector.messageDescriptionsRepository,
                injector.messageAttachmentRepository,
                injector.checkinRepository,
                injector.checkinDescriptionRepository,
                injector.checkinAttachmentsRepository,
                injector.taskUpdateRepository,
                injector.taskUpdateDescriptionRepository,
                injector.taskUpdateAttachmentsRepository,
                c.read(),
                c.read()
            )..init(),
          ),
          BlocProvider(
            create: (c) => AuthByPasswordCubit(
              injector.appConfigurationData,
              injector.sessionRepository,
              c.read(),
            )..init(),
          ),
          BlocProvider(
            create: (c) => AuthBySmsCubit(
              injector.sessionRepository,
              injector.authExceptionsManager,
              c.read(),
            )..init(),),
          BlocProvider(
            create: (c) => AuthByHttpCubit(
              injector.appConfigurationData,
              injector.sessionRepository,
              c.read(),
            )..init(),),
          BlocProvider(
            create: (c) => AuthByWebSSOCubit(
              injector.appConfigurationData,
              injector.sessionRepository,
              c.read(),
            ),
          ),
          BlocProvider(
            create: (c) => AuthByLocalAuthCubit(
              injector.sessionRepository,
              injector.localAuthenticationRepository,
              c.read(),
            ),
            lazy: false,
          ),
          BlocProvider(
            create: (c) => FormsCubit(
              injector.formDescriptionRepository,
              injector.formRepository,
              injector.formUpdateRepository,
              injector.formTemplateDescriptionsRepository,
              injector.taskDescriptionRepository,
              injector.exceptionsManager,
              c.read(),
              c.read(),
              c.read(),
              c.read<FormsListSearchCubit>(),
            ),
          ),
          BlocProvider(
            create: (c) => MessagesCubit(
                injector.messagesRepository,
                injector.messageReadMarkRepository,
                c.read(),
                c.read(),
                c.read(),
                c.read(),
                c.read(),
                c.read(),
                injector.jobsManager,
                injector.exceptionsManager,
                injector.pushManager
            ),
          ),
          if (injector.appConfigurationData.hasProductFeature(ProductFeature.task))
            tasksListCubitProvider,

          BlocProvider<AbstractTasksListSettingsCubit>(
            create: (c) => TasksListSettingsCubit(
              injector.taskTypeRepository,
              injector.taskCustomStatusRepository,
              c.read(),
              c.read<TasksListCubit>(),
              injector.preferencesRepository,
            ),
          ),
          BlocProvider(
            create: (c) => WorkScheduleCubit(
                injector.workScheduleRepository,
                injector.exceptionsManager,
                c.read(),
                c.read()
            ),
          ),
          BlocProvider(
            create: (context) => MapObjectsListCubit(
              injector.mapObjectsRepository,
              injector.formTemplatesRepository,
              injector.customFieldsUpdateRepository,
              injector.exceptionsManager,
              c.read(),
              c.read(),
              injector.pushManager,
            )..init(),
          ),
          BlocProvider(
            create: (c) => MapCubit(
              c.read(),
              c.read(),
              c.read(),

              c.read<TasksListCubit>(),

              c.read(),
              c.read(),
              injector.pushManager,
              injector.appConfigurationData.hasProductFeature(ProductFeature.task),
              injector.appConfigurationData.hasProductFeature(ProductFeature.checkin),
            ),
          ),
          BlocProvider(
            create: (c) => CheckinEditorCubit(
              c.read(),
              c.read(),
              true, true, true, true, true,
            )..init(),
          ),
          BlocProvider(
            create: (c) => OnboardingCubit(
              injector.preferencesRepository,
              c.read(),
              c.read(),
              injector.appConfigurationData.productConfigurationData.onboardingConfig,
            ),
            lazy: false,
          ),
          BlocProvider(
            create: (c) => MessageEditorCubit(
              c.read(),
              c.read(),
              c.read(),
            )..init(),
            lazy: false,
          ),
          BlocProvider(
              create: (c) => TaskCustomStatusSelectorCubit()
          ),
        ],
        child: PageRouteController(
          child: ScaffoldMessenger(
            child: MainPage(),
          ),
        ),
      );
    },

    kRegistrationRoute: (c) => BlocProvider(
      create: (c) => RegistrationCubit(
        injector.sessionRepository,
        injector.authExceptionsManager,
        c.read(),
      )..init(),
      child: RegistrationPage(),
    ),

    kLocalAuthConfigureRoute: (c) => LocalAuthConfigPage(),

    kPinCodeSetupRoute: (c) => BlocProvider(
      create: (c) => PinCodeSetupPageCubit(4, 2),
      child: PinCodeSetupPage(),
    ),

    kPinCodeValidateRoute: (c) {
      final args = ModalRoute.of(c)!.settings.arguments as PinCodeValidateRouteArgs;
      return BlocProvider(
        create: (c) =>
        PinCodeValidatePageCubit(c.read(), args.expectedCombination, 2, args.authByBiometricEnabled)..init(),
        child: PinCodeValidatePage(
          title: args.title,
        ),
        lazy: false,
      );
    },

    kLocalAuthRoute: (c) => BlocProvider(
      create: (c) => LockPageCubit(
        c.read(),
        c.read(),
        c.read(),
      ),
      lazy: false,
      child: LockPage(),
    ),

    kSettingsRoute: (c) => PreferencesPage(),

    //kStatusesRoute: (c) {
    //  return BlocProvider(
    //    create: (c) => StatusesCubit(
    //      c.read(),
    //      c.read(),
    //    )..load(false),
    //    child: StatusSelectPage(),
    //  );
    //},

    kStatusesHistoryRoute: (c) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (c) => ActiveStatusSyncCubit(
              injector.activeStatusRepository,
              c.read(),
              c.read(),
            ),
          ),
          BlocProvider(
            create: (c) => ActiveStatusesHistoryCubit(
              injector.activeStatusRepository,
              c.read(),
              c.read(),
            )..load(),
          )
        ],
      child: StatusesHistoryPage(),
    ),

    kSupportRoute: (c) {
      return BlocProvider(
        create: (c) => SupportCubit(
          injector.feedbackRepository,
          injector.exceptionsManager,
          c.read(),
          injector.appConfigurationData,
        )..init(),
        child: SupportPage(),
      );
    },

    kPolicyRoute: (c) => BlocProvider(
      create: (c) =>
      PolicyPageCubit(c.read(), c.read())..init(),
      child: PolicyPage(),
    ),
    // kPolicyLocationsRoute: (c) => PolicyPage.locations(),
    //
    // kPolicyBgLocationsRoute: (c) => PolicyPage.bgLocations(),
    //
    // kPolicyNotificationsRoute: (c) => PolicyPage.notifications(),

    kCheckinsListRoute: (c) => MultiBlocProvider(
      child: const CheckinsListPage(),
      providers: [
        BlocProvider(
          create: (c) => MapObjectsListCubit(
            injector.mapObjectsRepository,
            injector.formTemplatesRepository,
            injector.customFieldsUpdateRepository,
            injector.exceptionsManager,
            c.read(),
            c.read(),
            injector.pushManager,
          )..init(),
        ),
        BlocProvider(
          create: (c) => CheckinsListCubit(
            injector.exceptionsManager,
            c.read(),
            c.read(),
            c.read(),
            c.read(),
          ),
        ),
      ],
    ),

    kCheckinsCurrentRoute: (c) {
      final args = ModalRoute.of(c)!.settings.arguments as CheckinsCurrentRouteArgs;
      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (c) => CheckinEditorCubit(
              c.read(),
              c.read(),
              args.allowAttaches,
              args.allowAttaches,
              args.allowAttaches,
              args.allowAttaches,
              args.allowAttaches || args.needNfcTag,
            )..init(),
          ),
          BlocProvider(
            create: (c) => CheckinOnCurrentCubit(
              c.read(),
              c.read(),
              c.read(),
              c.read(),
              args.needDraft,
              args.needNfcTag,
            ),
          ),
        ],
        child: ScaffoldMessenger(
          child: CheckinOnCurrentPage(),
        ),
      );
    },

    kCheckinsDetailsRoute: (c) {
      final args = ModalRoute.of(c)!.settings.arguments as int;
      return MultiBlocProvider(
        child: CheckinDetailsPage(),
        providers: [
          BlocProvider(
            create: (c) => CheckinEditorCubit(
              c.read(),
              c.read(),
              true,
              true,
              true,
              true,
              true,
            )..init(),
          ),
          BlocProvider(
            create: (c) => MapObjectDetailsCubit(
              injector.mapObjectsRepository,
              injector.formTemplatesRepository,
              injector.customFieldsUpdateRepository,
              injector.exceptionsManager,
              c.read(),
              c.read(),
              c.read(),
              args,
            )..init(),
          ),
          // BlocProvider(
          //   create: (c) => DownloaderCubit(),
          // ),
        ],
      );
    },

    kCheckinsHistoryListRoute: (c) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (c) => CheckinSyncCubit(
              injector.checkinRepository,
              c.read(),
              c.read(),
            ),
          ),
          BlocProvider(
            create: (c) => CheckinsHistoryCubit(
              injector.checkinDescriptionRepository,
              c.read(),
              c.read(),
              c.read(),
            ),
          )
        ],
      child: const CheckinsHistoryPage(),
    ),

    kCheckinHistoryDetailsRoute: (c) {
      final checkinLocalId = ModalRoute.of(c)!.settings.arguments as int;
      return BlocProvider(
        create: (c) => CheckinHistoryDetailsCubit(
          injector.checkinRepository,
          c.read(),
          c.read(),
          c.read(),
          checkinLocalId,
        ),
        child: const CheckinsHistoryDetailsPage(),
      );
    },

    kTracksListRoute: (c) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (c) => TrackSyncCubit(
              injector.tracksRepository,
              c.read(),
              c.read(),
            ),
          ),
          BlocProvider(
            create: (c) => TracksListCubit(
              injector.tracksRepository,
              c.read(),
              c.read(),
            ),
          )
        ],
        child: TracksListPage(),
    ),

    kTaskDetailsRoute: (c) {
      final taskId = ModalRoute.of(c)!.settings.arguments as int;
      return MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (c) => ChecklistUpdateSyncCubit(
                injector.checklistUpdateRepository,
                c.read(),
                c.read(),
              )
          ),
          BlocProvider(
              create: (c) => FormUpdateSyncCubit(
                injector.formUpdateRepository,
                c.read(),
                c.read(),
              )
          ),
          BlocProvider(
              create: (c) => TaskUpdateSyncCubit(
                injector.taskUpdateRepository,
                c.read(),
                c.read(),
              )
          ),
          BlocProvider(
            create: (c) => TaskDetailsCubit(
              injector.taskTypeRepository,
              injector.taskCustomStatusRepository,
              injector.taskTeamRepository,
              injector.mapObjectsRepository,
              injector.formTemplatesRepository,
              injector.exceptionsManager,
              c.read(),
              c.read(),
              c.read(),
              taskId,

              injector.tasksRepository,
              injector.taskCustomStatusTransitionRepository,
              injector.taskCustomStatusReasonRepository,
              injector.taskUpdateDescriptionRepository,
              injector.checklistDescriptionRepository,
              injector.checklistUpdateRepository,
              injector.formUpdateRepository,
              injector.checkinDescriptionRepository,
              injector.taskReadMarkRepository,
              injector.messageTemplateRepository,
              injector.taskCommentUpdateRepository,
              injector.taskHistoriesRepository,
              injector.customFieldsUpdateRepository,
              injector.tasksNotificationService,
              injector.pushManager,
              c.read(),
              c.read(),
              c.read(),
              c.read(),
            )..init(),
          ),
          BlocProvider(
              create: (c) =>
                  TaskCustomStatusSelectorCubit()
          ),
          BlocProvider(
              create: (c) =>
              CustomFieldsUpdateCubit(
                injector.customFieldsUpdateRepository,
                c.read(),
                c.read(),
              )..init()
          ),
          // BlocProvider(create: (c) => DownloaderCubit(),),
        ],
        child: ScaffoldMessenger(child: TaskDetailsPage()),
      );
    },

    kTaskDetailsExchangeRoute: (c) {
      final taskId = ModalRoute.of(c)!.settings.arguments as int;

      return BlocProvider(
          create: (c) => TaskDetailsExchangeCubit(
            injector.taskTypeRepository,
            injector.taskCustomStatusRepository,
            injector.taskTeamRepository,
            injector.mapObjectsRepository,
            injector.formTemplatesRepository,
            injector.exceptionsManager,
            c.read(),
            c.read(),
            c.read(),
            taskId,

            injector.taskExchangeRepository,
            injector.checklistDescriptionRepository,
            c.read(),
            c.read()
          )..init(),
        child: ScaffoldMessenger(child: TaskDetailsExchangePage()),
      );
    },

    kTasksExchangeRoute: (c) {
      return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (c) => mp_core_bloc.SearchCubit(),
            ),
            BlocProvider(
              create: (c) => TasksListExchangeCubit(
                injector.taskTypeRepository,
                injector.taskCustomStatusRepository,
                injector.taskCustomStatusTransitionRepository,
                injector.taskCustomStatusReasonRepository,
                injector.mapObjectsRepository,
                injector.checklistUpdateRepository,
                injector.checklistDescriptionRepository,
                injector.exceptionsManager,
                injector.formTemplatesRepository,
                c.read(),
                c.read(),
                c.read(),
                c.read(),
                injector.taskExchangeRepository,
                c.read(),
                c.read(),
              ),
            ),
            BlocProvider<AbstractTasksListSettingsCubit>(
              create: (c) => TasksListExchangeSettingsCubit(
                injector.taskTypeRepository,
                injector.taskCustomStatusRepository,
                injector.preferencesRepository,
                c.read(),
                c.read<TasksListExchangeCubit>(),

              ),
            ),
            BlocProvider(
              create: (context) => MapObjectsListCubit(
                injector.mapObjectsRepository,
                injector.formTemplatesRepository,
                injector.customFieldsUpdateRepository,
                injector.exceptionsManager,
                c.read(),
                c.read(),
                injector.pushManager,
              )..init(),
            ),
            BlocProvider(
              create: (c) => MapCubit(
                c.read(),
                c.read(),
                c.read(),

                c.read<TasksListExchangeCubit>(),

                c.read(),
                c.read(),
                injector.pushManager,
                injector.appConfigurationData.hasProductFeature(ProductFeature.task),
                injector.appConfigurationData.hasProductFeature(ProductFeature.checkin),
              ),
            ),
          ],
          child: TasksExchangePage()
      );
    },

    kTaskHistoryRoute: (c) {
      // final taskId = ModalRoute.of(c)!.settings.arguments as int;
      final args = ModalRoute.of(c)!.settings.arguments as TaskHistoryRouteArgs;
      return MultiBlocProvider(
        providers: [
          // BlocProvider(create: (c) => DownloaderCubit(),),
          BlocProvider(
              create: (c) => TaskUpdateAttachmentSyncCubit(
                injector.taskUpdateAttachmentsRepository,
                c.read(),
                c.read(),
              )
          ),
          BlocProvider(
              create: (c) => TaskUpdateSyncCubit(
                injector.taskUpdateRepository,
                c.read(),
                c.read(),
              )
          ),
          BlocProvider(
            create: (c) => TaskHistoryCubit(
              injector.taskHistoriesRepository,
              injector.taskUpdateRepository,
              injector.formDescriptionRepository,
              injector.formUpdateRepository,
              injector.checkinDescriptionRepository,
              injector.taskCommentUpdateRepository,
              injector.taskCustomStatusRepository,
              injector.taskCustomStatusReasonRepository,
              injector.taskTeamRepository,
              injector.exceptionsManager,
              c.read(),
              c.read(),
              c.read(),
              c.read(),
              c.read(),
              injector.pushManager,
              args.task,
            ),
          ),
          BlocProvider(
            create: (c) => TaskCommentEditorCubit(
              c.read(),
              c.read(),
              c.read(),
              c.read(),
              args.task,
              args.newTaskStatus,
              // args.remoteFormTemplateIds,
              args.isNeedComment,
              args.isNeedForm,
            )..init(),
          ),
        ],
        child: TaskHistoryPage(),
      );
    },

    kTaskPrepareToFinalStateRoute: (c) {
      final args = ModalRoute.of(c)?.settings.arguments as TaskPrepareToFinalStateRouteArgs?;
      return BlocProvider(
        create: (c) => TaskPrepareToFinalStateCubit(
          injector.formTemplatesRepository,
          injector.formRepository,
          injector.formUpdateRepository,
          injector.exceptionsManager,
          c.read(),
          args!.remoteTaskId,
          args.newTaskStatus,
          args.requiredTaskStatusFormTemplateDescriptions,
          args.optionalTaskStatusFormTemplateDescriptions,
          args.isCommentRequired,
        ),
        child: TaskPrepareToFinalStatePage(),
      );
    },

    kFormsTemplatesPickerRoute: (c) {
      final args = ModalRoute.of(c)?.settings.arguments as FormTemplatePickerRouteArgs?;
      return BlocProvider(
        create: (c) => FormsTemplatesPickerCubit(
            injector.formDescriptionRepository,
            injector.formUpdateRepository,
            injector.formTemplateDescriptionsRepository,
            injector.exceptionsManager,
            c.read(),
            args!.remoteTaskId,
            args.externalFormTemplatesIds,
            args.prefilledFormUrnsMap
        ),
        child: FormTemplatesPickerPage(),
      );
    },

    kFormTemplatesRoute: (c) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (c) => mp_core_bloc.SearchCubit(),
          ),
          BlocProvider(
            create: (c) => FormTemplatesListCubit(
              injector.formTemplateDescriptionsRepository,
              injector.pushManager,
              injector.exceptionsManager,
              c.read(),
              c.read(),
            ),
          )
        ],
      child: FormTemplatesPage(),
    ),

    kQuickCommentsRoute: (c) => QuickCommentsPage(),

    kFormRoute: (c) {
      final args = ModalRoute.of(c)!.settings.arguments as FormRouteArgs?;
      return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (c) => mp_core_bloc.SearchCubit(),
            ),
            BlocProvider<mp_forms.FormCubit>(
              create: (c) => FormCubit(
                injector.formTemplatesRepository,
                injector.formRepository,
                injector.checklistRepository,
                injector.formSnapshotRepository,
                injector.formUpdateRepository,
                c.read(),
                c.read(),
                c.read(),
                c.read(),
                c.read(),
                c.read(),
                c.read(),
                remoteFormTemplateId: args!.remoteFormTemplateId,
                externalFormTemplateId: args.externalFormTemplateId,
                externalChecklistTemplateId: args.externalChecklistTemplateId,
                remoteTaskId: args.remoteTaskId,
                taskStatus: args.newTaskStatus,
                localFormId: args.localFormId,
                localFormUpdateId: args.localFormUpdateId,
                prefilledFormUrn: args.prefilledFormUrn,
                needDraft: args.needDraft,
                showHeader: true
              )..init(),
              lazy: false,
            )
          ],
          child: FormPage(title: args!.templateName)
      );
      // final args = ModalRoute.of(c)!.settings.arguments as FormRouteArgs?;
      // return MultiBlocProvider(
      //   providers: [
      //     BlocProvider(
      //       create: (c) => FormCubit(
      //         injector.formTemplatesRepository,
      //         injector.formRepository,
      //         injector.checklistRepository,
      //         injector.formSnapshotRepository,
      //         c.read(),
      //         c.read(),
      //         c.read(),
      //         c.read(),
      //         c.read(),
      //         c.read(),
      //         c.read(),
      //         remoteFormTemplateId: args!.remoteFormTemplateId,
      //         externalFormTemplateId: args.externalFormTemplateId,
      //         externalChecklistTemplateId: args.externalChecklistTemplateId,
      //         remoteTaskId: args.remoteTaskId,
      //         taskStatus: args.newTaskStatus,
      //         localFormId: args.localFormId,
      //         prefilledFormUrn: args.prefilledFormUrn,
      //         needDraft: args.needDraft,
      //       ),
      //     ),
      //     // BlocProvider(create: (c) => DownloaderCubit(),),
      //   ],
      //   child: FormPage(),
      // );
    },

    kChecklistRoute: (c) {
      final args = ModalRoute.of(c)!.settings.arguments as ChecklistRouteArgs?;
      return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (c) => mp_core_bloc.SearchCubit(),
            ),
            BlocProvider<mp_forms.FormCubit>(
              create: (c) => ChecklistCubit(
                injector.formTemplatesRepository,
                injector.checklistRepository,
                injector.formSnapshotRepository,
                injector.checklistUpdateRepository,
                c.read(),
                c.read(),
                c.read(),
                c.read(),
                c.read(),
                c.read(),
                externalChecklistId: args!.externalChecklistId,
                localChecklistId: args.localChecklistId,
                localChecklistUpdateId: args.localChecklistUpdateId,
                remoteTaskId: args.remoteTaskId,
                needDraft: args.needDraft,
              )..init(),
              lazy: false,
            )
          ],
          child: ChecklistPage(title: args!.templateName)
      );
    },

    kFormTableRowRoute: (c) {
      final args = ModalRoute.of(c)!.settings.arguments as FormTableRowRouteArgs;
      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (c) => mp_core_bloc.SearchCubit(),
          ),
          BlocProvider<mp_forms.FormCubit>(
            create: (c) => FormCubit(
              injector.formTemplatesRepository,
              injector.formRepository,
              injector.checklistRepository,
              injector.formSnapshotRepository,
              injector.formUpdateRepository,
              c.read(),
              c.read(),
              c.read(),
              c.read(),
              c.read(),
              c.read(),
              c.read(),
              isTableEditMode: true,
              templateItems: args.templateItems,
              formItemsData: args.items,
              templateName: args.templateName,
            ),
          ),
          // BlocProvider(create: (c) => DownloaderCubit(),),
        ],
        child: FormPage(title: args.templateName,),
      );
    },

    kCustomFieldsEditorRoute: (c) {
      final args = ModalRoute.of(c)!.settings.arguments as CustomFieldsEditorArgs;

      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (c) => mp_core_bloc.SearchCubit(),
          ),
          BlocProvider(
            create: (c) => FormCubit(
                injector.formTemplatesRepository,
                injector.formRepository,
                injector.checklistRepository,
                injector.formSnapshotRepository,
                injector.formUpdateRepository,
                c.read(),
                c.read(),
                c.read(),
                c.read(),
                c.read(),
                c.read(),
                c.read(),
                // isCustomFieldsEditMode: true,
                // viewItems: args.viewItems,
                needDraft: true,
                templateName: args.templateName,
                templateDescription: args.templateDescription
            ),
          ),
          // BlocProvider(create: (c) => DownloaderCubit(),),
        ],
        child: FormPage(title: args.templateName,),
      );
    },

    kSettingsPushLogRoute: (c) => BlocProvider(
      create: (c) => PushLogCubit(
        injector.pushLogRepository,
        c.read(),
        injector.pushManager,
      )..load(false),
      child: PushLogPage(),
    ),

    kMessageTemplatesRoute: (c) {
      final task = ModalRoute.of(c)!.settings.arguments as Task;
      return BlocProvider(
        create: (c) => MessageTemplatesCubit(
          injector.messageTemplateRepository,
          injector.exceptionsManager,
          c.read(),
        ),
        child: MessageTemplatesPage(task: task),
      );
    },

    kAboutRoute: (c) => AboutAppPage(),

    kCodeScannerRoute: (c) => CodeScannerPage(),

    kPhotoCameraRoute: (c) {
      final filesMaxCount = ModalRoute.of(c)!.settings.arguments as int;
      return BlocProvider(
        create: (c) => CameraCubit(c.read(), c.read(), filesMaxCount, CameraType.photo)..init(),
        child: CameraPage(),
      );
    },

    kVideoCameraRoute: (c) {
      final filesMaxCount = ModalRoute.of(c)!.settings.arguments as int;
      return BlocProvider(
        create: (c) => CameraCubit(c.read(), c.read(), filesMaxCount, CameraType.video)..init(),
        child: CameraPage(),
      );
    },

    kSignaturePadRoute: (c) => SignaturePadPage(),

    kImageRecognitionRoute: (c) => BlocProvider(
      create: (c) => ImageRecognitionCubit(),
      child: ImageRecognitionPage(),
    ),

    kServiceSettingsRoute: (c) => ServiceSettingsPage(),

    kTasksArchiveRoute: (c) {
      final injector = Injector.of(c);
      return MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (c) => TaskUpdateSyncCubit(
                injector.taskUpdateRepository,
                c.read(),
                c.read(),
              )
          ),
          BlocProvider(
            create: (c) => mp_core_bloc.SearchCubit(),
          ),
          BlocProvider(
              create: (c) =>
                  TasksListArchiveCubit(
                    injector.taskTypeRepository,
                    injector.taskCustomStatusRepository,
                    injector.taskCustomStatusTransitionRepository,
                    injector.taskCustomStatusReasonRepository,
                    injector.mapObjectsRepository,
                    injector.checklistUpdateRepository,
                    injector.checklistDescriptionRepository,
                    injector.exceptionsManager,
                    injector.formTemplatesRepository,
                    c.read(),
                    c.read(),
                    c.read(),
                    c.read(),
                    injector.tasksRepository,
                    injector.taskUpdateDescriptionRepository,
                    injector.checkinDescriptionRepository,
                    c.read(),
                    c.read(),
                    c.read(),
                    injector.pushManager,
                  )
          ),
          BlocProvider<AbstractTasksListSettingsCubit>(
            create: (c) =>
                TasksListArchiveSettingsCubit(
                  injector.taskTypeRepository,
                  injector.taskCustomStatusRepository,
                  c.read(),
                  c.read<TasksListArchiveCubit>(),
                  injector.preferencesRepository,
                ),
          ),
        ],
        child: const TasksListArchivePage(),
      );
    },

    kKnoxMDMConfigureRoute: (c) => BlocProvider(
      create: (c) => KnoxMDMConfigurePageCubit(
        c.read(),
      )..init(),
      lazy: false,
      child: KnoxMDMConfigurePage(),
    ),

    kImageViewerRoute: (c) {
      final imageFilePath = ModalRoute.of(c)!.settings.arguments as String;
      return ImageViewer(imageFilePath: imageFilePath);
    },

    kWebViewRoute: (c) {
      final args = ModalRoute.of(c)!.settings.arguments as WebViewRouteArgs;
      return BlocProvider(
        create: (c) => WebViewCubit(injector.certificatePinningManager),
        child: WebViewPage(
          uri: args.uri,
          fromAssets: args.fromAssets,
          title: args.title,
        ),
      );
    },

    kSyncItemsListRoute: (c) => BlocProvider(
      create: (c) => SyncItemsListCubit(
          injector.checkinDescriptionRepository,
          injector.checkinAttachmentsRepository,
          injector.messageDescriptionsRepository,
          injector.messageAttachmentRepository,
          injector.formDescriptionRepository,
          injector.formItemAttachmentsRepository,
          injector.taskUpdateDescriptionRepository,
          injector.taskUpdateAttachmentsRepository,
          injector.taskDescriptionRepository,
          c.read(),
          c.read()
      ),
      lazy: false,
      child: SyncItemsListPage(),
    ),

    kTrackMapRoute: (c) {
      final track = ModalRoute.of(c)!.settings.arguments as Track;
      return BlocProvider(
        create: (c) => TrackMapCubit(
          injector.tracksRepository,
          c.read(),
          c.read(),
          track.cacheId,
        )..load(),
        lazy: false,
        child: TrackMapPage(trackStartDateTime: track.startDateTime),
      );
    },

    kTableViewerRoute: (c) {
      final args = ModalRoute.of(c)!.settings.arguments as TableViewerRouteArgs;

      return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (c) => mp_core_bloc.SearchCubit(),
            ),
            BlocProvider(
                create: (c) => mp_table.TableViewerCubit(
                  c.read(),
                  args.title,
                  args.headers,
                  args.rows,
                )..load(),
                lazy: false,
            )
          ],
          child: mp_table.TableViewerPage()
      );
    },

    kTableEditorRoute: (c) {
      final args = ModalRoute.of(c)!.settings.arguments as TableEditorRouteArgs;

      return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (c) => mp_core_bloc.SearchCubit(),
            ),
            BlocProvider(
                create: (c) => mp_table.TableEditorCubit(
                    c.read(),
                    args.title,
                    args.templateItems,
                    args.rows
                )..init(),
                lazy: false,
            )
          ],
          child: mp_table.TableEditorPage()
      );
    },

    kTaskEditorRoute: (c) {
      final injector = Injector.of(c);
      final session = c.read<AuthenticationCubit>().state.session;

      final taskRepository = TaskEditorTaskRepository(
          injector.tasksRepository,
          session
      );
      final taskTypeRepository = TaskEditorTaskTypeRepository(
          injector.taskTypeRepository,
          session
      );
      final taskPriorityRepository = TaskEditorTaskPriorityRepository();

      final mapObjectRepository = TaskEditorMapObjectRepository(
          injector.mapObjectsRepository,
          session
      );
      final subscriberRepository = TaskEditorSubscriberRepository(
          injector.subscriberRepository,
          session
      );

      return BlocProvider(
        create: (c) => mp_task_editor.TaskEditorCubit(
            taskRepository,
            taskTypeRepository,
            taskPriorityRepository,
            mapObjectRepository,
            subscriberRepository
        )..load(),
        child: mp_task_editor.TaskEditorPage()
      );
    },

    kMapObjectPickerRoute: (c) {
      final injector = Injector.of(c);
      final session = c.read<AuthenticationCubit>().state.session;
      final mapConfig = c.read<PreferencesCubit>().state.preferences.mapConfig;

      final mapObjectRepository = MpMapObjectPickerMapObjectRepository(
          injector.mapObjectsRepository,
          session
      );

      return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (c) => mp_map_object_picker.MpMapObjectPickerCubit(),
            ),
            BlocProvider(
                create: (c) => mp_map_object_picker.MpMapObjectListCubit(
                    mapObjectRepository,
                    session.serviceSettings.mapObjectsMapRadius
                ),
            )
          ],
          child: mp_map_object_picker.MpMapObjectPickerPage(
            mapConfig: mp_map_object_picker.MapConfig(
                tileTemplateUrl: mapConfig.tileTemplateUrl,
                tileTemplateDarkUrl: mapConfig.tileTemplateDarkUrl,
                minZoom: mapConfig.minZoom,
                maxZoom: mapConfig.maxZoom
            ),
            initialCenter: LatLng(
                session.serviceSettings.homeRegionLat,
                session.serviceSettings.homeRegionLon
            ),
            initialZoom: session.serviceSettings.homeRegionZoom.toDouble(),
          )
      );
    }
  };
}

 Route<dynamic>? onGenerateRoute(RouteSettings settings, AbstractInjector injector) {

   Widget transitionsBuilder(
       BuildContext context,
       Animation<double> animation,
       Animation<double> secondaryAnimation,
       Widget child
       ) {
     const begin = Offset(0.0, 1.0);
     const end = Offset.zero;
     const curve = Curves.easeInToLinear;

     var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

     return SlideTransition(
       position: animation.drive(tween),
       child: child,
     );
   }

  switch(settings.name) {
    case kTaskDetailsRouteAnimated: {
      final taskId = settings.arguments as int;
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                  create: (c) => ChecklistUpdateSyncCubit(
                    injector.checklistUpdateRepository,
                    c.read(),
                    c.read(),
                  )
              ),
              BlocProvider(
                  create: (c) => FormUpdateSyncCubit(
                    injector.formUpdateRepository,
                    c.read(),
                    c.read(),
                  )
              ),
              BlocProvider(
                  create: (c) => TaskUpdateSyncCubit(
                    injector.taskUpdateRepository,
                    c.read(),
                    c.read(),
                  )
              ),
              BlocProvider(
                create: (c) => TaskDetailsCubit(
                  injector.taskTypeRepository,
                  injector.taskCustomStatusRepository,
                  injector.taskTeamRepository,
                  injector.mapObjectsRepository,
                  injector.formTemplatesRepository,
                  injector.exceptionsManager,
                  c.read(),
                  c.read(),
                  c.read(),
                  taskId,

                  injector.tasksRepository,
                  injector.taskCustomStatusTransitionRepository,
                  injector.taskCustomStatusReasonRepository,
                  injector.taskUpdateDescriptionRepository,
                  injector.checklistDescriptionRepository,
                  injector.checklistUpdateRepository,
                  injector.formUpdateRepository,
                  injector.checkinDescriptionRepository,
                  injector.taskReadMarkRepository,
                  injector.messageTemplateRepository,
                  injector.taskCommentUpdateRepository,
                  injector.taskHistoriesRepository,
                  injector.customFieldsUpdateRepository,
                  injector.tasksNotificationService,
                  injector.pushManager,
                  c.read(),
                  c.read(),
                  c.read(),
                  c.read(),
                )..init(),
              ),
              BlocProvider(
                  create: (c) =>
                      TaskCustomStatusSelectorCubit()
              ),
              BlocProvider(
                  create: (c) =>
                  CustomFieldsUpdateCubit(
                    injector.customFieldsUpdateRepository,
                    c.read(),
                    c.read(),
                  )..init()
              ),
              // BlocProvider(create: (c) => DownloaderCubit(),),
            ],
            child: ScaffoldMessenger(
              child: TaskDetailsPage(),
            ),
          );
        },
        transitionsBuilder: transitionsBuilder,
      );
    }

    case kTaskDetailsExchangeRouteAnimated: {
      final taskId = settings.arguments as int;

      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return BlocProvider(
            create: (c) => TaskDetailsExchangeCubit(
                injector.taskTypeRepository,
                injector.taskCustomStatusRepository,
                injector.taskTeamRepository,
                injector.mapObjectsRepository,
                injector.formTemplatesRepository,
                injector.exceptionsManager,
                c.read(),
                c.read(),
                c.read(),
                taskId,

                injector.taskExchangeRepository,
                injector.checklistDescriptionRepository,
                c.read(),
                c.read()
            )..init(),
            child: ScaffoldMessenger(child: TaskDetailsExchangePage()),
          );
        },
        transitionsBuilder: transitionsBuilder,
      );
    }

    default: return null;
  }
 }
