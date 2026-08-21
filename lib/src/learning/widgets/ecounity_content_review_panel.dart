import 'dart:async';

import 'package:core/core.dart' as core;
import 'package:ecounity/src/learning/ecounity_content_review_service.dart';
import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:ecounity/src/providers/ecounity_content_review_provider.dart';
import 'package:ecounity/src/util/ecounity_design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EcoUnityContentReviewPanel extends StatefulWidget {
  const EcoUnityContentReviewPanel({
    super.key,
    required this.scope,
    required this.objectId,
    required this.language,
    required this.fallbackStatus,
  });

  final EcoUnityReviewScope scope;
  final int objectId;
  final String language;
  final EcoUnityContentStatus fallbackStatus;

  @override
  State<EcoUnityContentReviewPanel> createState() =>
      _EcoUnityContentReviewPanelState();
}

class _EcoUnityContentReviewPanelState
    extends State<EcoUnityContentReviewPanel> {
  EcoUnityReviewStatus? _savingStatus;
  String? _requestedKey;

  @override
  void didUpdateWidget(covariant EcoUnityContentReviewPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scope != widget.scope ||
        oldWidget.objectId != widget.objectId ||
        oldWidget.language != widget.language) {
      _requestedKey = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final core.User user = Provider.of<core.UserProvider>(context).user;
    if (!_hasPotentialReviewUser(user)) {
      return const SizedBox.shrink();
    }
    final EcoUnityContentReviewProvider reviewProvider =
        Provider.of<EcoUnityContentReviewProvider>(context);
    _scheduleLoad(context, user);

    if (!reviewProvider.canReviewFor(user)) {
      return const SizedBox.shrink();
    }

    final EcoUnityContentReviewRecord? record = reviewProvider.recordFor(
      scope: widget.scope,
      objectId: widget.objectId,
      language: widget.language,
    );
    final EcoUnityReviewStatus status =
        record?.reviewStatus ??
        ecoUnityReviewStatusFromContentStatus(widget.fallbackStatus);
    final bool saving = reviewProvider.isSaving(
      scope: widget.scope,
      objectId: widget.objectId,
      language: widget.language,
    );
    final bool loading = reviewProvider.isLoading(
      scope: widget.scope,
      objectId: widget.objectId,
      language: widget.language,
    );
    final String? error = reviewProvider.errorFor(
      scope: widget.scope,
      objectId: widget.objectId,
      language: widget.language,
    );

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
                  _ReviewStatusChip(status: status, loading: loading),
                ],
              ),
              if (error != null && error.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  error,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  FilledButton.icon(
                    onPressed: saving
                        ? null
                        : () => _saveStatus(EcoUnityReviewStatus.approved),
                    icon: _savingStatus == EcoUnityReviewStatus.approved
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
                        : () => _saveStatus(EcoUnityReviewStatus.needsChanges),
                    icon: _savingStatus == EcoUnityReviewStatus.needsChanges
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

  Future<void> _saveStatus(EcoUnityReviewStatus status) async {
    final core.User user = Provider.of<core.UserProvider>(
      context,
      listen: false,
    ).user;
    final EcoUnityContentReviewProvider reviewProvider =
        Provider.of<EcoUnityContentReviewProvider>(context, listen: false);
    setState(() {
      _savingStatus = status;
    });

    try {
      await reviewProvider.updateReview(
        user: user,
        scope: widget.scope,
        objectId: widget.objectId,
        language: widget.language,
        reviewStatus: status,
      );
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

  void _scheduleLoad(BuildContext context, core.User user) {
    final String key =
        '${widget.scope.wireName}:${widget.objectId}:'
        '${widget.language}:${user.id}:${user.token}';
    if (_requestedKey == key) {
      return;
    }
    _requestedKey = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final EcoUnityContentReviewProvider reviewProvider =
          Provider.of<EcoUnityContentReviewProvider>(context, listen: false);
      unawaited(
        reviewProvider.ensureReviewAccess(user).then<void>((bool canReview) {
          if (!canReview || !mounted) {
            return;
          }
          unawaited(
            reviewProvider.loadReview(
              user: user,
              scope: widget.scope,
              objectId: widget.objectId,
              language: widget.language,
              fallbackStatus: widget.fallbackStatus,
            ),
          );
        }),
      );
    });
  }
}

class _ReviewStatusChip extends StatelessWidget {
  const _ReviewStatusChip({required this.status, required this.loading});

  final EcoUnityReviewStatus status;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (status) {
      EcoUnityReviewStatus.approved => EcoUnityColors.success,
      EcoUnityReviewStatus.published => EcoUnityColors.success,
      EcoUnityReviewStatus.needsReview => EcoUnityColors.warning,
      EcoUnityReviewStatus.needsChanges => EcoUnityColors.warmOrange,
      EcoUnityReviewStatus.notReady => EcoUnityColors.textSecondary,
      EcoUnityReviewStatus.unknown => EcoUnityColors.textSecondary,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (loading) ...<Widget>[
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(color: color, strokeWidth: 2),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              _statusLabel(status),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _statusLabel(EcoUnityReviewStatus status) {
  return switch (status) {
    EcoUnityReviewStatus.notReady => 'Not ready',
    EcoUnityReviewStatus.needsReview => 'Needs review',
    EcoUnityReviewStatus.needsChanges => 'Needs changes',
    EcoUnityReviewStatus.approved => 'Approved',
    EcoUnityReviewStatus.published => 'Published',
    EcoUnityReviewStatus.unknown => 'Unknown',
  };
}

bool _hasPotentialReviewUser(core.User user) {
  return user.id != null &&
      !user.isGuestUser &&
      (user.token?.trim().isNotEmpty ?? false);
}
