import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:ecounity/src/analytics/ecounity_teacher_report_models.dart';
import 'package:ecounity/src/providers/teacher_mode_provider.dart';
import 'package:ecounity/src/providers/ecounity_teacher_report_provider.dart';
import 'package:ecounity/src/util/ecounity_design_tokens.dart';
import 'package:ecounity/src/util/router.dart';
import 'package:ecounity/src/widgets/screenscaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeacherView extends StatefulWidget {
  const TeacherView({super.key, required this.navIndex});

  final int navIndex;

  @override
  State<TeacherView> createState() => _TeacherViewState();
}

class _TeacherViewState extends State<TeacherView> {
  final TextEditingController _teacherTokenController = TextEditingController();

  @override
  void dispose() {
    _teacherTokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final EcoUnityTeacherReportProvider reportProvider = context
        .watch<EcoUnityTeacherReportProvider>();

    return ScreenScaffold(
      title: context.l10n.navigation_item('teacher'),
      navigationIndex: widget.navIndex,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 28),
        children: <Widget>[
          _TeacherModeCard(
            onTurnOff: () async {
              await context.read<TeacherModeProvider>().setTeacherMode(false);
              if (!context.mounted) {
                return;
              }
              AppRouter.navigate(context, 'progress', widget.navIndex);
            },
          ),
          const SizedBox(height: 16),
          _TeacherGroupReportPanel(
            controller: _teacherTokenController,
            provider: reportProvider,
            onAddToken: _addTeacherToken,
          ),
        ],
      ),
    );
  }

  Future<void> _addTeacherToken() async {
    try {
      await context.read<EcoUnityTeacherReportProvider>().addOrRefreshToken(
        _teacherTokenController.text,
      );
      if (mounted) {
        _teacherTokenController.clear();
      }
    } catch (_) {
      // The provider exposes a user-facing error message in the panel.
    }
  }
}

class _TeacherModeCard extends StatelessWidget {
  const _TeacherModeCard({required this.onTurnOff});

  final Future<void> Function() onTurnOff;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: EcoUnityColors.teacherSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: EcoUnityColors.teacherBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: EcoUnityColors.teacherSurfaceHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school_outlined,
                    color: EcoUnityColors.deepTeal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.teacher_mode_active_title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: EcoUnityColors.deepTeal,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              context.l10n.teacher_mode_active_description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: EcoUnityColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                await onTurnOff();
              },
              icon: const Icon(Icons.person_outline),
              label: Text(context.l10n.teacher_mode_turn_off),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeacherGroupReportPanel extends StatelessWidget {
  const _TeacherGroupReportPanel({
    required this.controller,
    required this.provider,
    required this.onAddToken,
  });

  final TextEditingController controller;
  final EcoUnityTeacherReportProvider provider;
  final Future<void> Function() onAddToken;

  @override
  Widget build(BuildContext context) {
    final EcoUnityTeacherGroupReport? activeReport = provider.activeReport;

    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: EcoUnityColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.groups_2_outlined,
                  color: EcoUnityColors.deepTeal,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.l10n.teacher_group_statistics_title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: EcoUnityColors.deepTeal,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (activeReport != null)
                  IconButton.filledTonal(
                    tooltip: context.l10n.teacher_refresh_active_group,
                    onPressed: provider.loading
                        ? null
                        : () async {
                            await provider.refreshActiveReport();
                          },
                    icon: const Icon(Icons.refresh_rounded),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.teacher_group_report_description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: EcoUnityColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: !provider.loading,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: context.l10n.teacher_token_label,
                      hintText: context.l10n.teacher_token_hint,
                      border: const OutlineInputBorder(),
                      counterText: '',
                    ),
                    maxLength: 24,
                    onSubmitted: (_) async {
                      if (!provider.loading) {
                        await onAddToken();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: provider.loading
                        ? null
                        : () async {
                            await onAddToken();
                          },
                    icon: provider.loading
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_rounded),
                    label: Text(context.l10n.button_add),
                  ),
                ),
              ],
            ),
            if (provider.error != null) ...<Widget>[
              const SizedBox(height: 10),
              _InlineError(message: provider.error!),
            ],
            if (!provider.loaded) ...<Widget>[
              const SizedBox(height: 16),
              const LinearProgressIndicator(minHeight: 3),
            ],
            const SizedBox(height: 16),
            if (provider.reports.isEmpty)
              _EmptyTeacherGroups(loaded: provider.loaded)
            else ...<Widget>[
              for (final EcoUnityTeacherGroupReport report in provider.reports)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TeacherReportTile(
                    report: report,
                    selected: report.teacherToken == activeReport?.teacherToken,
                    loading: provider.loading,
                    onSelected: () =>
                        provider.selectReport(report.teacherToken),
                    onRefresh: () => provider.refreshReport(report),
                    onRemove: () => provider.removeReport(report.teacherToken),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TeacherReportTile extends StatelessWidget {
  const _TeacherReportTile({
    required this.report,
    required this.selected,
    required this.loading,
    required this.onSelected,
    required this.onRefresh,
    required this.onRemove,
  });

  final EcoUnityTeacherGroupReport report;
  final bool selected;
  final bool loading;
  final Future<void> Function() onSelected;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onRemove;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFF4FBFA) : EcoUnityColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected
              ? EcoUnityColors.turquoise
              : EcoUnityColors.outlineVariant,
          width: selected ? 1.6 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: loading
            ? null
            : () async {
                await onSelected();
              },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              IconButton(
                tooltip: selected
                    ? context.l10n.teacher_active_group
                    : context.l10n.teacher_select_group,
                onPressed: loading
                    ? null
                    : () async {
                        await onSelected();
                      },
                icon: Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected
                      ? EcoUnityColors.deepTeal
                      : EcoUnityColors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      report.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: EcoUnityColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      context.l10n.teacher_token_value(report.teacherToken),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: EcoUnityColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _TeacherMetric(
                          label: context.l10n.teacher_metric_enrolled,
                          value: report.enrolledUsers.toString(),
                        ),
                        _TeacherMetric(
                          label: context.l10n.teacher_metric_active,
                          value: report.summary.activeUsers.toString(),
                        ),
                        _TeacherMetric(
                          label: context.l10n.teacher_metric_completed,
                          value: _percentLabel(
                            report.summary.activityCompletionRate,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  IconButton(
                    tooltip: context.l10n.teacher_refresh_group,
                    onPressed: loading
                        ? null
                        : () async {
                            await onRefresh();
                          },
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                  IconButton(
                    tooltip: context.l10n.teacher_remove_group,
                    onPressed: loading
                        ? null
                        : () async {
                            await onRemove();
                          },
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeacherMetric extends StatelessWidget {
  const _TeacherMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: EcoUnityColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: EcoUnityColors.deepTeal,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: EcoUnityColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTeacherGroups extends StatelessWidget {
  const _EmptyTeacherGroups({required this.loaded});

  final bool loaded;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: EcoUnityColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: <Widget>[
            const Icon(Icons.info_outline, color: EcoUnityColors.deepTeal),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                loaded
                    ? context.l10n.teacher_empty_groups
                    : context.l10n.teacher_loading_saved_groups,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: EcoUnityColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: EcoUnityColors.error.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            const Icon(Icons.error_outline, color: EcoUnityColors.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: EcoUnityColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _percentLabel(double? value) {
  if (value == null) {
    return '-';
  }
  final bool wholeNumber = value == value.roundToDouble();
  return '${value.toStringAsFixed(wholeNumber ? 0 : 1)}%';
}
