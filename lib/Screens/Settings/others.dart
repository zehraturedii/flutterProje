import 'package:fiesta/CustomWidgets/box_switch_tile.dart';
import 'package:fiesta/CustomWidgets/gradient_containers.dart';
import 'package:fiesta/constants/languagecodes.dart';
import 'package:fiesta/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';

class OthersPage extends StatefulWidget {
  const OthersPage({super.key});

  @override
  State<OthersPage> createState() => _OthersPageState();
}

class _OthersPageState extends State<OthersPage> {
  final Box settingsBox = Hive.box('settings');
  final ValueNotifier<bool> includeOrExclude = ValueNotifier<bool>(
    Hive.box('settings').get('includeOrExclude', defaultValue: false) as bool,
  );
  List includedExcludedPaths = Hive.box('settings')
      .get('includedExcludedPaths', defaultValue: []) as List;
  String lang =
      Hive.box('settings').get('lang', defaultValue: 'English') as String;
  bool useProxy =
      Hive.box('settings').get('useProxy', defaultValue: false) as bool;

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            AppLocalizations.of(
              context,
            )!
                .others,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          iconTheme: IconThemeData(
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(10.0),
          children: [
            ListTile(
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .lang,
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .langSub,
              ),
              onTap: () {},
              trailing: DropdownButton(
                value: lang,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
                underline: const SizedBox(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(
                      () {
                        lang = newValue;
                        MyApp.of(context).setLocale(
                          Locale.fromSubtags(
                            languageCode:
                                LanguageCodes.languageCodes[newValue] ?? 'en',
                          ),
                        );
                        Hive.box('settings').put('lang', newValue);
                      },
                    );
                  }
                },
                items: LanguageCodes.languageCodes.keys
                    .map<DropdownMenuItem<String>>((language) {
                  return DropdownMenuItem<String>(
                    value: language,
                    child: Text(
                      language,
                    ),
                  );
                }).toList(),
              ),
              dense: true,
            ),

            BoxSwitchTile(
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .liveSearch,
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .liveSearchSub,
              ),
              keyName: 'liveSearch',
              isThreeLine: false,
              defaultValue: true,
            ),
            BoxSwitchTile(
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .useDown,
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .useDownSub,
              ),
              keyName: 'useDown',
              isThreeLine: true,
              defaultValue: true,
            ),
            BoxSwitchTile(
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .getLyricsOnline,
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .getLyricsOnlineSub,
              ),
              keyName: 'getLyricsOnline',
              isThreeLine: true,
              defaultValue: true,
            ),
            BoxSwitchTile(
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .supportEq,
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .supportEqSub,
              ),
              keyName: 'supportEq',
              isThreeLine: true,
              defaultValue: false,
            ),
            BoxSwitchTile(
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .stopOnClose,
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .stopOnCloseSub,
              ),
              isThreeLine: true,
              keyName: 'stopForegroundService',
              defaultValue: true,
            ),
            // const BoxSwitchTile(
            //   title: Text('Remove Service from foreground when paused'),
            //   subtitle: Text(
            //       "If turned on, you can slide notification when paused to stop the service. But Service can also be stopped by android to release memory. If you don't want android to stop service while paused, turn it off\nDefault: On\n"),
            //   isThreeLine: true,
            //   keyName: 'stopServiceOnPause',
            //   defaultValue: true,
            // ),

            Visibility(
              visible: useProxy,
              child: ListTile(
                title: Text(
                  AppLocalizations.of(
                    context,
                  )!
                      .proxySet,
                ),
                subtitle: Text(
                  AppLocalizations.of(
                    context,
                  )!
                      .proxySetSub,
                ),
                dense: true,
                trailing: Text(
                  '${Hive.box('settings').get("proxyIp", defaultValue: "103.47.67.134")}:${Hive.box('settings').get("proxyPort", defaultValue: 8080)}',
                  style: const TextStyle(fontSize: 12),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      final controller = TextEditingController(
                        text: settingsBox
                            .get('proxyIp', defaultValue: '103.47.67.134')
                            .toString(),
                      );
                      final controller2 = TextEditingController(
                        text: settingsBox
                            .get('proxyPort', defaultValue: 8080)
                            .toString(),
                      );
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .ipAdd,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                            TextField(
                              autofocus: true,
                              controller: controller,
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              children: [
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .port,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                            TextField(
                              autofocus: true,
                              controller: controller2,
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.grey[700],
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!
                                  .cancel,
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.secondary ==
                                          Colors.white
                                      ? Colors.black
                                      : null,
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                            ),
                            onPressed: () {
                              settingsBox.put(
                                'proxyIp',
                                controller.text.trim(),
                              );
                              settingsBox.put(
                                'proxyPort',
                                int.parse(
                                  controller2.text.trim(),
                                ),
                              );
                              Navigator.pop(context);
                              setState(
                                () {},
                              );
                            },
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!
                                  .ok,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
