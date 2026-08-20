import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:ecounity/src/providers/teacher_mode_provider.dart';
import 'package:ecounity/src/util/ecounity_design_tokens.dart';
import 'package:ecounity/src/util/router.dart';
import 'package:ecounity/src/widgets/screenscaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeacherView extends StatelessWidget {
  const TeacherView({super.key, required this.navIndex});

  final int navIndex;

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: context.l10n.navigation_item('teacher'),
      navigationIndex: navIndex,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 28),
        children: <Widget>[
          DecoratedBox(
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
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
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
                      await Provider.of<TeacherModeProvider>(
                        context,
                        listen: false,
                      ).setTeacherMode(false);
                      if (!context.mounted) {
                        return;
                      }
                      AppRouter.navigate(context, 'progress', navIndex);
                    },
                    icon: const Icon(Icons.person_outline),
                    label: Text(context.l10n.teacher_mode_turn_off),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
