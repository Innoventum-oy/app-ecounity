import 'dart:developer';

import 'package:core/core.dart' as core;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:ecounity/src/widgets/screenscaffold.dart';

class SelfReflectionHubScreen extends StatefulWidget {
  final int navIndex;

  const SelfReflectionHubScreen({super.key, required this.navIndex});

  @override
  SelfReflectionHubScreenState createState() => SelfReflectionHubScreenState();
}

/// Creates a view with a list of self reflection questions and text fields for answers.
/// The answers are saved to application memory with dates and times.
class SelfReflectionHubScreenState extends State<SelfReflectionHubScreen> {
  Map<int, String> answers = {}; // Map of question index to answer
  core.FileStorage fileStorage = core.FileStorage();
  // initstate - load responses from storage
  @override
  initState() {
    super.initState();
    loadAnswers();
  }

  void loadAnswers() async {
    dynamic storedData = await fileStorage.getObject(
      'selfReflectionAnswers',
      boxName: 'userData',
    );
    if (storedData != null) {
      // Check if the stored data is a Map
      if (storedData is Map) {
        if (kDebugMode) {
          log('loaded answers: $storedData');
        }
        // Parse the data to Map <int,String>
        Map<int, String> parsedData = {};
        storedData.forEach((key, value) {
          if (key is int && value is String) {
            parsedData[key] = value;
          }
        });

        // update state
        setState(() {
          answers = parsedData;
        });
      }
    }
  }

  // Save answers to storage
  void saveAnswers() {
    if (kDebugMode) {
      log('saving answers: $answers');
    }
    fileStorage.setObject(
      'selfReflectionAnswers',
      answers,
      boxName: 'userData',
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> selfReflectionQuestions = [
      {
        'question': context.l10n.srh_what_was_most_impactful_for_me,
        'icon': Icons.lightbulb,
      },
      {
        'question': context.l10n.srh_what_will_i_put_into_practice,
        'icon': Icons.note_alt_outlined,
      },
      {
        'question': context.l10n.srh_what_are_my_hopes_and_fears_for_the_future,
        'icon': Icons.sentiment_satisfied_alt,
      },
    ];
    var child = Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Title
          Text(
            context.l10n.screenTitle_selfReflectionHub,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          // Description
          Text(
            context.l10n.srh_description,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          // Questions
          buildQuestions(selfReflectionQuestions),
          const SizedBox(height: 20),
        ],
      ),
    );

    return ScreenScaffold(
      title: context.l10n.screenTitle_selfReflectionHub,
      navigationIndex: widget.navIndex,
      child: child,
    );
  }

  Widget buildQuestions(List<Map<String, dynamic>> questions) {
    return Expanded(
      child: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          return buildQuestion(questions[index], index);
        },
      ),
    );
  }

  Widget buildQuestion(Map<String, dynamic> question, int index) {
    TextEditingController controller = TextEditingController(
      text: answers[index],
    );
    controller.addListener(() {
      answers[index] = controller.text;
      saveAnswers();
    });

    return Column(
      children: [
        Row(
          children: [
            Icon(question['icon']),
            Text(
              question['question'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        TextFormField(
          maxLines: null,
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: question['question'],
          ),
        ),
        // Add some spacing between questions
        const SizedBox(height: 20),
      ],
    );
  }
}
