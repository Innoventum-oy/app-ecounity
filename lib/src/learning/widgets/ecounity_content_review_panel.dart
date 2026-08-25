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
                    onPressed: saving ? null : () => _saveNeedsChanges(record),
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
              if (_reviewComment(record).isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                _ReviewCommentPanel(comment: _reviewComment(record)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveNeedsChanges(EcoUnityContentReviewRecord? record) async {
    final String? comment = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return _NeedsChangesCommentDialog(
          initialComment: _reviewComment(record),
        );
      },
    );
    if (!mounted || comment == null) {
      return;
    }
    await _saveStatus(EcoUnityReviewStatus.needsChanges, comment: comment);
  }

  Future<void> _saveStatus(
    EcoUnityReviewStatus status, {
    String? comment,
  }) async {
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
        comment: comment,
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

class _NeedsChangesCommentDialog extends StatefulWidget {
  const _NeedsChangesCommentDialog({required this.initialComment});

  final String initialComment;

  @override
  State<_NeedsChangesCommentDialog> createState() =>
      _NeedsChangesCommentDialogState();
}

class _NeedsChangesCommentDialogState
    extends State<_NeedsChangesCommentDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialComment);
    _controller.addListener(_handleCommentChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleCommentChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String comment = _controller.text.trim();
    return AlertDialog(
      title: const Text('What needs to change?'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Add concise editorial feedback for the partner review workflow.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              minLines: 4,
              maxLines: 7,
              maxLength: 800,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Example: Adapt the examples for Spanish classrooms.',
                labelText: 'Review comment',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Do not include learner names, contact details, pupil IDs, or other learner personal data.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: EcoUnityColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: comment.isEmpty
              ? null
              : () => Navigator.of(context).pop(comment),
          icon: const Icon(Icons.edit_note),
          label: const Text('Save feedback'),
        ),
      ],
    );
  }

  void _handleCommentChanged() {
    setState(() {});
  }
}

class _ReviewCommentPanel extends StatelessWidget {
  const _ReviewCommentPanel({required this.comment});

  final String comment;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: EcoUnityColors.warmOrange.withValues(alpha: 0.45),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(
              Icons.notes_rounded,
              size: 18,
              color: EcoUnityColors.warmOrange,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                comment,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: EcoUnityColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
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

String _reviewComment(EcoUnityContentReviewRecord? record) {
  if (record == null) {
    return '';
  }
  for (final String key in const <String>[
    'comment',
    'reviewNotes',
    'review_notes',
    'notes',
    'comments',
    'review_comment',
    'reviewComment',
    'change_comment',
    'changeComment',
    'needs_changes_comment',
    'needsChangesComment',
  ]) {
    final String value = record.rawData[key]?.toString().trim() ?? '';
    if (value.isNotEmpty && value != 'null') {
      return value;
    }
  }
  return '';
}

bool _hasPotentialReviewUser(core.User user) {
  return user.id != null &&
      !user.isGuestUser &&
      (user.token?.trim().isNotEmpty ?? false);
}
