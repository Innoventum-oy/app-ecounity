import 'package:core/core.dart' as core;
import 'package:ecounity/src/util/ecounity_design_tokens.dart';
import 'package:flutter/material.dart';

class AppBarUserIdentity extends StatelessWidget {
  const AppBarUserIdentity({super.key, required this.user});

  final core.User user;

  @override
  Widget build(BuildContext context) {
    final _UserIdentity identity = _userIdentity(user);
    if (!identity.shouldShow) {
      return const SizedBox.shrink();
    }

    final bool showDetails = MediaQuery.sizeOf(context).width >= 720;
    final Widget content = showDetails
        ? _IdentityPill(identity: identity)
        : _IdentityAvatar(identity: identity);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Tooltip(
        message: identity.tooltip,
        child: Semantics(
          label: identity.tooltip,
          child: ExcludeSemantics(child: content),
        ),
      ),
    );
  }
}

class _IdentityPill extends StatelessWidget {
  const _IdentityPill({required this.identity});

  final _UserIdentity identity;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: EcoUnityColors.surfaceContainer,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: EcoUnityColors.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 5, 10, 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _IdentityAvatar(identity: identity, compact: true),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      identity.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: EcoUnityColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    if (identity.detail.isNotEmpty)
                      Text(
                        identity.detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: EcoUnityColors.textSecondary,
                          height: 1.05,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IdentityAvatar extends StatelessWidget {
  const _IdentityAvatar({required this.identity, this.compact = false});

  final _UserIdentity identity;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double size = compact ? 30 : 40;
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: EcoUnityColors.deepTeal,
          borderRadius: BorderRadius.circular(compact ? 12 : 16),
        ),
        child: Center(
          child: Text(
            identity.initials,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _UserIdentity {
  const _UserIdentity({
    required this.shouldShow,
    required this.name,
    required this.detail,
    required this.initials,
  });

  final bool shouldShow;
  final String name;
  final String detail;
  final String initials;

  String get tooltip {
    if (detail.isEmpty || detail == name) {
      return name;
    }
    return '$name, $detail';
  }
}

_UserIdentity _userIdentity(core.User user) {
  if (user.id == null || user.isGuestUser) {
    return const _UserIdentity(
      shouldShow: false,
      name: '',
      detail: '',
      initials: '',
    );
  }

  final String fullName = <String>[
    user.firstname?.trim() ?? '',
    user.lastname?.trim() ?? '',
  ].where((String part) => part.isNotEmpty).join(' ');
  final String email = user.email?.trim() ?? '';
  final String type = user.type?.trim() ?? '';
  final String name = fullName.isNotEmpty
      ? fullName
      : email.isNotEmpty
      ? email
      : 'User ${user.id}';
  final String detail = email.isNotEmpty && email != name
      ? email
      : type.isNotEmpty
      ? type
      : '';

  return _UserIdentity(
    shouldShow: true,
    name: name,
    detail: detail,
    initials: _initialsFor(name),
  );
}

String _initialsFor(String value) {
  final List<String> words = _splitWords(value);
  if (words.isEmpty) {
    return '?';
  }
  if (words.length == 1) {
    return words.first.characters.take(2).toString().toUpperCase();
  }
  return '${words.first.characters.first}${words.last.characters.first}'
      .toUpperCase();
}

List<String> _splitWords(String value) {
  final List<String> words = <String>[];
  final StringBuffer current = StringBuffer();
  for (final int codeUnit in value.trim().codeUnits) {
    if (codeUnit <= 32) {
      if (current.isNotEmpty) {
        words.add(current.toString());
        current.clear();
      }
    } else {
      current.writeCharCode(codeUnit);
    }
  }
  if (current.isNotEmpty) {
    words.add(current.toString());
  }
  return words;
}
