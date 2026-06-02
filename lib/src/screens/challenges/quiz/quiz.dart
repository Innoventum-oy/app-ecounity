import 'dart:async';
import 'dart:developer';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:ecounity/src/objects/pathway.dart';
import 'package:core/core.dart' as core;
import 'package:ecounity/src/widgets/screenscaffold.dart';
import '../../../widgets/completion_page.dart';
import '../../../widgets/webpage_screen.dart';
import 'components/checkbox_question.dart';
import 'components/question.dart';
import 'components/textarea_question.dart';

/// Quiz widget
class Quiz extends WebpageScreen {
  const Quiz({
    super.key,
    required super.navIndex,
    required super.webPage,
    super.openIntroduction = false,
    super.pathways,
  });
  @override
  State<StatefulWidget> createState() => QuizState();
}

class QuizState extends WebpageScreenState<Quiz> {
  List<dynamic> userAnswersets = [];
  List<dynamic> features = [];

  bool loading = false;
  bool clearingAnswers = false;
  bool answersLoaded = false;
  bool featuresLoaded = false;
  // late core.FormProvider formProvider;
  core.Form? form;
  final _pageViewController = PageController(initialPage: 0);
  final formKey = GlobalKey<FormState>();
  Map<int, core.FormElementData> selectedOptions = {};
  int? answersetKey;
  Map<int, dynamic> formData = {};
  final core.ApiClient _apiClient = core.ApiClient();
  int _quizResetCount = 0;

  @override
  void initState() {
    /// Load form. The app only makes use of one form with commonname assessment
    //formProvider = core.FormProvider();
    if (kDebugMode) {
      log('Loading assessment form and answers');
    }
    loadQuiz();
    super.initState();
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    super.dispose();
  }

  void loadQuiz() async {
    // Load the form related to the quiz page
    form = await widget.webPage.form;
    if (form != null) {
      answersetKey = await getAnswersetKey(form!.id);
      formData = await getLocalAnswers(form!.id);
      if (mounted) {
        setState(() {
          answersLoaded = true;
          _quizResetCount++;
        });
      }
      loadElements(form!);
      loadGroups(form!);
    } else if (mounted) {
      setState(() {
        answersLoaded = true;
      });
    }
  }

  Future<int?> getAnswersetKey(int? formId) async {
    if (formId == null) return null;
    dynamic data = await fileStorage.getObject(
      'formAnswersetKey$formId',
      boxName: 'userData',
    );
    return data != null ? (data is int ? data : int.parse(data)) : null;
  }

  Future<Map<int, dynamic>> getLocalAnswers(int? formId) async {
    if (formId == null) return {};
    dynamic data = await fileStorage.getObject(
      'formAnswers$formId',
      boxName: 'userData',
    );
    if (data is! Map) return {};

    final Map<int, dynamic> answers = {};
    data.forEach((key, value) {
      final int? elementId = key is int ? key : int.tryParse(key.toString());
      if (elementId != null) {
        answers[elementId] = value;
      }
    });
    return answers;
  }

  Future<void> setLocalAnswers(int? formId, Map<int, dynamic> answers) async {
    if (formId == null) return;
    return await fileStorage.setObject(
      'formAnswers$formId',
      answers,
      boxName: 'userData',
    );
  }

  Future<void> clearLocalAnswerset(int formId) async {
    final box = await fileStorage.init('userData');
    if (box == null) {
      throw StateError('Unable to open userData storage');
    }
    await box.delete('formAnswers$formId');
    await box.delete('formAnswersetKey$formId');
    await setLocalAnswers(formId, {});
  }

  Future<void> retryQuiz() async {
    final int? formId = form?.id;
    if (formId == null || clearingAnswers) return;

    setState(() {
      clearingAnswers = true;
    });

    try {
      await clearLocalAnswerset(formId);
      if (!mounted) return;
      formKey.currentState?.reset();
      setState(() {
        answersetKey = null;
        formData = {};
        userAnswersets = [];
        answersLoaded = true;
        _quizResetCount++;
      });
      if (_pageViewController.hasClients) {
        var animationLength = 250 * (_pageViewController.page?.toInt() ?? 0);
        await _pageViewController.animateToPage(
          0,
          duration: Duration(milliseconds: animationLength),
          curve: Curves.linear,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        log('Error clearing quiz answers: $e');
      }
      if (mounted) {
        Flushbar(
          title: context.l10n.saving_data_failed,
          message: e.toString(),
          duration: const Duration(seconds: 10),
        ).show(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          clearingAnswers = false;
        });
      }
    }
  }

  /// Loads form element groups
  Future<void> loadGroups(core.Form form) async {
    if (kDebugMode) {
      log('loading groups for form ${form.id}');
    }
    Map<String, dynamic> params = {
      'formid': form.id.toString(),
      'action': 'loadelementgroups',
      'method': 'json',
    };

    apiClient.loadFormData(params).then((responseData) {
      setState(() {
        featuresLoaded = true;
        log("RESPONSE:: ${responseData?['data']}");
        features = responseData?['data'] ?? [];
      });
      return features;
    });
  }

  /// Loads form elements
  Future<void> loadElements(core.Form form) async {
    if (kDebugMode) {
      log('loading elements for form ${form.id}');
    }
    String formId = form.id.toString();
    Map<String, dynamic> params = {'formid': formId};

    List<core.FormElement>? result = await core.FormElementProvider()
        .getElements(params);

    log("${result.length} elements loaded");
    setState(() {
      form.loadingStatus = core.LoadingStatus.ready;

      form.elements?.clear();
      for (var i in result) {
        form.elements?.add(i);
      }
    });
  }

  // todo: change this to get local answerset
  Future<void> loadAnswerset(int? answersetKey) async {
    if (answersetKey == null) return;

    Map<String, dynamic> params = {
      'answersetid': answersetKey,
      'action': 'loadanswers',
      'method': 'json',
    };

    apiClient.loadFormData(params).then((responseData) {
      setState(() {
        answersLoaded = true;
        userAnswersets = responseData?['data'] ?? [];
      });
      return userAnswersets;
    });
  }

  @override
  Widget buildScreen(BuildContext context, {List<Widget> buttons = const []}) {
    List<core.WebPage>? parents = Provider.of<core.WebPageProvider>(
      context,
      listen: false,
    ).findByKey('id', widget.webPage.parent);
    core.WebPage? parent = parents != null && parents.isNotEmpty
        ? parents.first
        : null;
    if (featuresLoaded &&
        answersLoaded &&
        form != null &&
        form!.loadingStatus == core.LoadingStatus.ready) {
      loaded = true;
    }
    return ScreenScaffold(
      title: widget.webPage.title,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // quiz Thumbnail in Card if available
            if (widget.webPage.thumbnail != null)
              Card(
                child: widget.webPage.imageBuilder(
                  widget.webPage.thumbnailImage,
                ),
              ),
            // Path and stage
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Expanded(
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        IntrinsicWidth(
                          child: ListTile(
                            leading: const Icon(Icons.quiz),
                            title: Text(
                              "${context.l10n.pathway}: ${parent?.title ?? context.l10n.unknown}",
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ButtonStyle(
                            foregroundColor: WidgetStateProperty.all(
                              Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          icon: clearingAnswers
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.refresh),
                          label: Text(context.l10n.clear_answers),
                          onPressed: clearingAnswers ? null : retryQuiz,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Quiz content
            quizView(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  // Previous button
                  buttons,
            ),
          ],
        ),
      ),
    );
  }

  Widget quizView() {
    sendForm() {
      final formState = formKey.currentState;
      if (formState!.validate()) {
        formState.save();
        bool hasData = false;
        Map<String, dynamic> requestData = {};
        formData.forEach((key, value) {
          if (value != null) hasData = true;
          if (value.runtimeType.toString() == 'bool' && value != false) {
            hasData = true;
          }
          if (value.runtimeType.toString() == 'String' &&
              value.isNotEmpty &&
              value != 'null') {
            hasData = true;
          }

          if (hasData) {
            requestData.putIfAbsent('element_$key', () => value);
          }
        });
        setState(() {
          loading = true;
        });
        Map<String, dynamic> params = {
          'method': 'json',
          'action': 'saveanswers',
          'formid': form!.id.toString(),
        };
        if (answersetKey != null) {
          params['answersetid'] = answersetKey.toString();
        }
        if (hasData) {
          try {
            _apiClient.saveFormData(params, requestData).then((
              var response,
            ) async {
              if (kDebugMode) {
                // log the response
                log('Response: $response');
              }
              if (response?['statusCode'] != null &&
                  response?['data'] != null) {
                response = response?['data'];
              }
              if (response?['answersetid'] is int) {
                answersetKey = response?['answersetid'];
                // save answerset key to local storage
                if (kDebugMode) {
                  log('Saving answerset id $answersetKey to local storage');
                }
                await fileStorage.setObject(
                  'formAnswersetKey${form!.id}',
                  answersetKey,
                  boxName: 'userData',
                );
                await setLocalAnswers(form!.id, formData);
              } else {
                if (kDebugMode) {
                  log(
                    'Response answersetid is not an int: ${response?['answersetid']}, type is ${response?['answersetid'].runtimeType}',
                  );
                }
              }

              switch (response?['status']) {
                case 'fail':
                case 'error':
                  if (mounted) {
                    Flushbar(
                      title: context.l10n.quiz_not_passed,
                      message: response != null
                          ? response['message'].toString()
                          : response.toString(),
                      duration: const Duration(seconds: 10),
                    ).show(context);
                  }
                  if (response?['data'] != null && kDebugMode) {
                    response?['data'].forEach((key, dataset) {
                      log('$key: $dataset');
                    });
                  }
                  break;

                case 'success':
                  // If the response contains 'testpassed' set the status to completed
                  if (response != null && response['testpassed'] == true) {
                    // set status to completed
                    if (kDebugMode) {
                      log('Setting pathway status to completed');
                    }
                    if (mounted) {
                      await widget.webPage.setStatus(
                        PathwayStatus.completed,
                        context,
                      );
                    }
                    if (mounted) {
                      // if the pathway has completion text, show completion popup

                      completionPopupDialog(
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              Text(context.l10n.pathway_completed),
                              if (form!.thankyou != null)
                                Html(
                                  data: '${form!.thankyou}',
                                  style: {
                                    'h1,h2,h3,p,strong,em': Style(
                                      fontSize: FontSize.smaller,
                                    ),
                                  },
                                ),
                            ],
                          ),
                        ),
                        CompletionPage(pathway: widget.webPage),
                        context,
                        actions: [
                          ElevatedButton(
                            child: Text(context.l10n.ok),
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                          ),
                        ],
                      );
                    }
                  } else if (mounted) {
                    String message =
                        response != null && response['testpassed'] == 'true'
                        ? context.l10n.great
                        : context.l10n.button_ok;
                    Flushbar(
                      title: context.l10n.answer_saved,
                      message: response != null
                          ? response['message'].toString()
                          : context.l10n.answer_saved,
                      duration: const Duration(seconds: 10),
                    ).show(context);

                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text(context.l10n.answer_saved),
                        content: SingleChildScrollView(
                          child: Text(
                            response != null
                                ? response['message'].toString()
                                : context.l10n.answer_saved,
                          ),
                        ),
                        actions: <Widget>[
                          ElevatedButton(
                            child: Text(message),
                            onPressed: () {
                              setState(() {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }
              }
              setState(() {
                loading = false;
              });
            });
          } catch (e) {
            if (kDebugMode) {
              log('Error saving form data: $e');
            }
            setState(() {
              loading = false;
            });
            Flushbar(
              title: context.l10n.saving_data_failed,
              message: e.toString(),
              duration: const Duration(seconds: 10),
            ).show(context);
          }
        } else {
          Flushbar(
            title: context.l10n.errors_in_form,
            message: context.l10n.please_complete_form_properly,
            duration: const Duration(seconds: 10),
          ).show(context);
          setState(() {
            loading = false;
          });
        }
      } else {
        Flushbar(
          title: context.l10n.errors_in_form,
          message: context.l10n.please_complete_form_properly,
          duration: const Duration(seconds: 10),
        ).show(context);
        setState(() {
          loading = false;
        });
      }
    }
    // pick heading, radio, checkbox and richtext elements

    Iterable<core.FormElement> pages = form != null
        ? form!.elements?.where(
                (element) => [
                  'radio',
                  'heading',
                  'checkbox',
                  'richtext',
                  'textarea',
                ].contains(element.type),
              ) ??
              []
        : [];
    if (kDebugMode) {
      log(
        'Form has ${pages.length} pages (elements: ${form?.elements?.length})',
      );
    }
    Widget loadedContent = Form(
      key: formKey,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: PageView.builder(
          controller: _pageViewController,
          itemCount: pages.length,
          itemBuilder: (context, index) {
            List<Widget> buttons = [];
            core.FormElement e = pages.elementAt(index);
            if (index > 0) {
              buttons.add(
                ElevatedButton.icon(
                  onPressed: () => _pageViewController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.linear,
                  ),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(context.l10n.previous),
                ),
              );
            }
            if (index < pages.length - 1) {
              buttons.add(
                ElevatedButton.icon(
                  onPressed: () {
                    if (_pageViewController.hasClients) {
                      _pageViewController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.linear,
                      );
                    }
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(context.l10n.next),
                ),
              );
            } else if (index == pages.length - 1) {
              buttons.add(
                ElevatedButton.icon(
                  onPressed: () => loading ? null : sendForm(),
                  icon: loading
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.send),
                  label: Text(
                    loading ? context.l10n.loading : context.l10n.sendAnswer,
                  ),
                ),
              );
            }

            switch (e.type) {
              case 'checkbox':
                List<dynamic> selectedOptions = [];
                if (formData[e.id] != null) {
                  if (formData[e.id] is List) {
                    selectedOptions = formData[e.id];
                  } else if (formData[e.id] is int) {
                    selectedOptions.add(formData[e.id]);
                  }
                }
                return CheckboxQuestion(
                  key: ValueKey('checkbox-${e.id}-$_quizResetCount'),
                  element: e,
                  onChanged: (val) {
                    setState(() {
                      formData[e.id ?? 0] = val;
                    });
                  },
                  selectedOptions: selectedOptions,
                  buttons: buttons,
                  index: index + 1,
                  pageCount: pages.length,
                );

              case 'textarea':
                String? currentValue = (formData[e.id] != null)
                    ? formData[e.id]
                    : null;
                return TextAreaQuestion(
                  key: ValueKey('textarea-${e.id}-$_quizResetCount'),
                  element: e,
                  onChanged: (val) {
                    setState(() {
                      formData[e.id ?? 0] = val;
                    });
                  },
                  currentValue: currentValue,
                  buttons: buttons,
                  index: index + 1,
                  pageCount: pages.length,
                );

              default:
                return Question(
                  key: ValueKey('question-${e.id}-$_quizResetCount'),
                  element: e,
                  onChanged: (val) {
                    bool advance = formData[e.id] == null ? true : false;
                    setState(() {
                      if (e.id != null) formData[e.id ?? 0] = val;
                    });
                    if (advance) {
                      if (index < pages.length - 1) {
                        _pageViewController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.linear,
                        );
                      } else {
                        sendForm();
                      }
                    }
                  },
                  selectedOption: e.type != 'checkbox' ? formData[e.id] : null,
                  buttons: buttons,
                  index: index + 1,
                  pageCount: pages.length,
                );
            }
          },
        ),
      ),
    );
    return defaultContent(loadedContent);
  }
}

Widget defaultContent(Widget contentChild) {
  return Padding(
    padding: const EdgeInsets.all(30),
    child: Center(child: contentChild),
  );
}

Future<void> completionPopupDialog(
  Widget titleText,
  Widget dialogContent,
  BuildContext context, {
  List<Widget>? actions,
}) async {
  return await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) => AlertDialog(
      scrollable: true,
      title: titleText,
      content: dialogContent,
      actions:
          actions ??
          <Widget>[
            ElevatedButton(
              child: Text(context.l10n.ok),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ],
    ),
  );
}
