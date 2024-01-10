import 'package:fiesta/CustomWidgets/box_switch_tile.dart';
import 'package:fiesta/CustomWidgets/gradient_containers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';

class AppUIPage extends StatefulWidget {
  final Function? callback;
  const AppUIPage({this.callback});

  @override
  State<AppUIPage> createState() => _AppUIPageState();
}

class _AppUIPageState extends State<AppUIPage> {
  final Box settingsBox = Hive.box('settings');
  List blacklistedHomeSections = Hive.box('settings')
      .get('blacklistedHomeSections', defaultValue: []) as List;
  List miniButtonsOrder = Hive.box('settings').get(
    'miniButtonsOrder',
    defaultValue: ['Like', 'Previous', 'Play/Pause', 'Next', 'Download'],
  ) as List;
  List preferredMiniButtons = Hive.box('settings').get(
    'preferredMiniButtons',
    defaultValue: ['Like', 'Play/Pause', 'Next'],
  )?.toList() as List;
  List<int> preferredCompactNotificationButtons = Hive.box('settings').get(
    'preferredCompactNotificationButtons',
    defaultValue: [1, 2, 3],
  ) as List<int>;
  List sectionsToShow = Hive.box('settings').get(
    'sectionsToShow',
    defaultValue: ['Home', 'YouTube', 'Library'],
  ) as List;
  final List sectionsAvailableToShow = Hive.box('settings').get(
    'sectionsAvailableToShow',
    defaultValue: ['YouTube', 'Library', 'Settings'],
  ) as List;

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
                .ui,
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
          padding: const EdgeInsets.all(10.0),
          physics: const BouncingScrollPhysics(),
          children: [
            // BoxSwitchTile(
            //   title: Text(
            //     AppLocalizations.of(
            //       context,
            //     )!
            //         .useBlurForNowPlaying,
            //   ),
            //   subtitle: Text(
            //     AppLocalizations.of(
            //       context,
            //     )!
            //         .useBlurForNowPlayingSub,
            //   ),
            //   keyName: 'useBlurForNowPlaying',
            //   defaultValue: true,
            //   isThreeLine: true,
            // ),

            BoxSwitchTile(
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .showPlaylists,
              ),
              keyName: 'showPlaylist',
              defaultValue: true,
            ),

            BoxSwitchTile(
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .showLast,
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .showLastSub,
              ),
              keyName: 'showRecent',
              defaultValue: true,
            ),
            // BoxSwitchTile(
            //   title: Text(
            //     AppLocalizations.of(
            //       context,
            //     )!
            //         .showHistory,
            //   ),
            //   subtitle: Text(
            //     AppLocalizations.of(
            //       context,
            //     )!
            //         .showHistorySub,
            //   ),
            //   keyName: 'showHistory',
            //   defaultValue: true,
            // ),
            ListTile(
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .navTabs,
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .navTabsSub,
              ),
              dense: true,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    final List checked = List.from(sectionsToShow);
                    sectionsAvailableToShow.removeWhere(
                      (element) => element == 'Home',
                    );
                    return StatefulBuilder(
                      builder: (
                        BuildContext context,
                        StateSetter setStt,
                      ) {
                        const Set persist = {'Home', 'Library'};
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              15.0,
                            ),
                          ),
                          content: SizedBox(
                            width: 500,
                            child: ReorderableListView(
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              padding: const EdgeInsets.fromLTRB(
                                0,
                                10,
                                0,
                                10,
                              ),
                              onReorder: (int oldIndex, int newIndex) {
                                if (oldIndex < newIndex) {
                                  newIndex--;
                                }
                                final temp = sectionsAvailableToShow.removeAt(
                                  oldIndex,
                                );
                                sectionsAvailableToShow.insert(newIndex, temp);
                                setStt(
                                  () {},
                                );
                              },
                              header: Column(
                                children: [
                                  Center(
                                    child: Text(
                                      '${AppLocalizations.of(
                                        context,
                                      )!.navTabs}\n(${AppLocalizations.of(
                                        context,
                                      )!.minFourRequired})',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  CheckboxListTile(
                                    dense: true,
                                    contentPadding: const EdgeInsets.only(
                                      left: 16.0,
                                    ),
                                    activeColor:
                                        Theme.of(context).colorScheme.secondary,
                                    checkColor: Theme.of(
                                              context,
                                            ).colorScheme.secondary ==
                                            Colors.white
                                        ? Colors.black
                                        : null,
                                    value: true,
                                    title: const Text('Home'),
                                    onChanged: null,
                                  ),
                                ],
                              ),
                              children: sectionsAvailableToShow.map((e) {
                                return Row(
                                  key: Key(e.toString()),
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ReorderableDragStartListener(
                                      index: sectionsAvailableToShow.indexOf(e),
                                      child: const Icon(
                                        Icons.drag_handle_rounded,
                                      ),
                                    ),
                                    Expanded(
                                      child: SizedBox(
                                        child: CheckboxListTile(
                                          dense: true,
                                          contentPadding: const EdgeInsets.only(
                                            left: 16.0,
                                          ),
                                          activeColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          checkColor: Theme.of(
                                                    context,
                                                  ).colorScheme.secondary ==
                                                  Colors.white
                                              ? Colors.black
                                              : null,
                                          value: checked.contains(e),
                                          title: Text(e.toString()),
                                          onChanged: persist.contains(e)
                                              ? null
                                              : (bool? value) {
                                                  setStt(
                                                    () {
                                                      if (value!) {
                                                        while (checked.length >=
                                                            5) {
                                                          checked.remove(
                                                            checked.last,
                                                          );
                                                        }

                                                        checked.add(e);
                                                      } else {
                                                        checked.remove(e);
                                                      }
                                                    },
                                                  );
                                                },
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
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
                                final List newSectionsToShow = ['Home'];
                                int remaining = 4 - checked.length;
                                for (int i = 0;
                                    i < sectionsAvailableToShow.length;
                                    i++) {
                                  if (checked
                                      .contains(sectionsAvailableToShow[i])) {
                                    newSectionsToShow
                                        .add(sectionsAvailableToShow[i]);
                                  } else {
                                    if (remaining > 0) {
                                      newSectionsToShow
                                          .add(sectionsAvailableToShow[i]);
                                      remaining--;
                                    }
                                  }
                                }
                                sectionsToShow = newSectionsToShow;
                                Navigator.pop(context);
                                Hive.box('settings').put(
                                  'sectionsToShow',
                                  sectionsToShow,
                                );
                                Hive.box('settings').put(
                                  'sectionsAvailableToShow',
                                  sectionsAvailableToShow,
                                );
                                widget.callback!();
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
