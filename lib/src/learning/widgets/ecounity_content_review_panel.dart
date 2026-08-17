import 'package:core/core.dart' as core;
import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:ecounity/src/learning/ecounity_review_permissions.dart';
import 'package:ecounity/src/util/ecounity_design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EcoUnityContentReviewPanel extends StatefulWidget {
  const EcoUnityContentReviewPanel({
    super.key,
    required this.status,
    required this.onStatusChanged,
  });

  final EcoUnityContentStatus status;
  final Future<void> Function(EcoUnityContentStatus status) onStatusChanged;

  @override
  State<EcoUnityContentReviewPanel> createState() =>
      _EcoUnityContentReviewPanelState();
}

class _EcoUnityContentReviewPanelState
    extends State<EcoUnityContentReviewPanel> {
  EcoUnityContentStatus? _savingStatus;

  @override
  Widget build(BuildContext context) {
    final core.User user = Provider.of<core.UserProvider>(context).user;
    if (!ecoUnityCanReviewContent(user)) {
      return const SizedBox.shrink();
    }

    final bool saving = _savingStatus != null;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: EcoUnityColors.warmOrange),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(Icons.rate_review, color: EcoUnityColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Partner review',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: EcoUnityColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _ReviewStatusChip(status: widget.status),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  FilledButton.icon(
                    onPressed: saving
                        ? null
                        : () => _saveStatus(EcoUnityContentStatus.approved),
                    icon: _savingStatus == EcoUnityContentStatus.approved
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: const Text('Mark reviewed'),
                  ),
                  OutlinedButton.icon(
                    onPressed: saving
                        ? null
                        : () => _saveStatus(EcoUnityContentStatus.draft),
                    icon: _savingStatus == EcoUnityContentStatus.draft
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.edit_note),
                    label: const Text('Needs changes'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveStatus(EcoUnityContentStatus status) async {
    setState(() {
      _savingStatus = status;
    });

    try {
      await widget.onStatusChanged(status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Review status saved: ${_statusLabel(status)}'),
          ),
        );
      }
    } catch (exception) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to save review status: $exception')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _savingStatus = null;
        });
      }
    }
  }
}

class _ReviewStatusChip extends StatelessWidget {
  const _ReviewStatusChip({required this.status});

  final EcoUnityContentStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (status) {
      EcoUnityContentStatus.approved => EcoUnityColors.success,
      EcoUnityContentStatus.published => EcoUnityColors.success,
      EcoUnityContentStatus.review => EcoUnityColors.warning,
      EcoUnityContentStatus.draft => EcoUnityColors.textSecondary,
      EcoUnityContentStatus.archived => EcoUnityColors.textSecondary,
      EcoUnityContentStatus.unknown => EcoUnityColors.textSecondary,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          _statusLabel(status),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

String _statusLabel(EcoUnityContentStatus status) {
  return switch (status) {
    EcoUnityContentStatus.draft => 'Needs changes',
    EcoUnityContentStatus.review => 'In review',
    EcoUnityContentStatus.approved => 'Reviewed',
    EcoUnityContentStatus.published => 'Published',
    EcoUnityContentStatus.archived => 'Archived',
    EcoUnityContentStatus.unknown => 'Unknown',
  };
}
