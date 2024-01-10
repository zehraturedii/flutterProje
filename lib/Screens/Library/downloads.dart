import 'dart:io';

import 'package:audiotagger/audiotagger.dart';
import 'package:fiesta/CustomWidgets/custom_physics.dart';
import 'package:fiesta/CustomWidgets/data_search.dart';
import 'package:fiesta/CustomWidgets/empty_screen.dart';
import 'package:fiesta/CustomWidgets/gradient_containers.dart';
import 'package:fiesta/CustomWidgets/image_card.dart';
import 'package:fiesta/CustomWidgets/playlist_head.dart';
import 'package:fiesta/CustomWidgets/snackbar.dart';
import 'package:fiesta/Services/player_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:logging/logging.dart';

class Downloads extends StatefulWidget {
  const Downloads({super.key});
  @override
  _DownloadsState createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads>
    with SingleTickerProviderStateMixin {
  Box downloadsBox = Hive.box('downloads');
  bool added = false;
  List _songs = [];
  final Map<String, List<Map>> _albums = {};
  final Map<String, List<Map>> _artists = {};
  List _sortedAlbumKeysList = [];
  List _sortedArtistKeysList = [];
  TabController? _tcontroller;
  int _currentTabIndex = 0;
  // int currentIndex = 0;
  // String? tempPath = Hive.box('settings').get('tempDirPath')?.toString();
  int sortValue = Hive.box('settings').get('sortValue', defaultValue: 1) as int;
  int orderValue =
      Hive.box('settings').get('orderValue', defaultValue: 1) as int;
  int albumSortValue =
      Hive.box('settings').get('albumSortValue', defaultValue: 2) as int;
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _showShuffle = ValueNotifier<bool>(true);

  @override
  void initState() {
    _tcontroller = TabController(length: 4, vsync: this);
    _tcontroller!.addListener(() {
      if ((_tcontroller!.previousIndex != 0 && _tcontroller!.index == 0) ||
          (_tcontroller!.previousIndex == 0)) {
        setState(() => _currentTabIndex = _tcontroller!.index);
      }
    });
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        _showShuffle.value = false;
      } else {
        _showShuffle.value = true;
      }
    });

    getDownloads();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tcontroller!.dispose();
    _scrollController.dispose();
  }

  Future<void> getDownloads() async {
    _songs = downloadsBox.values.toList();
    setArtistAlbum();
  }

  void setArtistAlbum() {
    for (final element in _songs) {
      try {
        if (_albums.containsKey(element['album'])) {
          final List<Map> tempAlbum = _albums[element['album']]!;
          tempAlbum.add(element as Map);
          _albums
              .addEntries([MapEntry(element['album'].toString(), tempAlbum)]);
        } else {
          _albums.addEntries([
            MapEntry(element['album'].toString(), [element as Map]),
          ]);
        }

        if (_artists.containsKey(element['artist'])) {
          final List<Map> tempArtist = _artists[element['artist']]!;
          tempArtist.add(element);
          _artists
              .addEntries([MapEntry(element['artist'].toString(), tempArtist)]);
        } else {
          _artists.addEntries([
            MapEntry(element['artist'].toString(), [element]),
          ]);
        }
      } catch (e) {
        // ShowSnackBar().showSnackBar(
        //   context,
        //   'Error: $e',
        // );
        Logger.root.severe('Error while setting artist and album: $e');
      }
    }

    added = true;
    setState(() {});
  }

  Future<void> deleteSong(Map song) async {
    await downloadsBox.delete(song['id']);
    final audioFile = File(song['path'].toString());
    final imageFile = File(song['image'].toString());
    if (_albums[song['album']]!.length == 1) {
      _sortedAlbumKeysList.remove(song['album']);
    }
    _albums[song['album']]!.remove(song);

    if (_artists[song['artist']]!.length == 1) {
      _sortedArtistKeysList.remove(song['artist']);
    }
    _artists[song['artist']]!.remove(song);

    _songs.remove(song);
    try {
      await audioFile.delete();
      if (await imageFile.exists()) {
        imageFile.delete();
      }
      ShowSnackBar().showSnackBar(
        context,
        '${AppLocalizations.of(context)!.deleted} ${song['title']}',
      );
    } catch (e) {
      Logger.root.severe('Failed to delete $audioFile.path', e);
      ShowSnackBar().showSnackBar(
        context,
        '${AppLocalizations.of(context)!.failedDelete}: ${audioFile.path}\nError: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.downs),
            centerTitle: true,
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.transparent
                : Theme.of(context).colorScheme.secondary,
            elevation: 0,
            bottom: TabBar(
              controller: _tcontroller,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                Tab(
                  text: AppLocalizations.of(context)!.songs,
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(CupertinoIcons.search),
                tooltip: AppLocalizations.of(context)!.search,
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: DownloadsSearch(
                      data: _songs,
                      isDowns: true,
                    ),
                  );
                },
              ),
            ],
          ),
          body: !added
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : TabBarView(
                  physics: const CustomPhysics(),
                  controller: _tcontroller,
                  children: [
                    DownSongsTab(
                      onDelete: (Map item) {
                        deleteSong(item);
                      },
                      songs: _songs,
                      scrollController: _scrollController,
                    ),
                  ],
                ),
          floatingActionButton: ValueListenableBuilder(
            valueListenable: _showShuffle,
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).cardColor,
              child: Icon(
                Icons.shuffle_rounded,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                size: 24.0,
              ),
              onPressed: () {
                if (_songs.isNotEmpty) {
                  PlayerInvoke.init(
                    songsList: _songs,
                    index: 0,
                    isOffline: true,
                    fromDownloads: true,
                    recommend: false,
                    shuffle: true,
                  );
                }
              },
            ),
            builder: (
              BuildContext context,
              bool showShuffle,
              Widget? child,
            ) {
              return AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                offset: showShuffle ? Offset.zero : const Offset(0, 2),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: showShuffle ? 1 : 0,
                  child: child,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class DownSongsTab extends StatefulWidget {
  final List songs;
  final Function(Map item) onDelete;
  final ScrollController scrollController;
  const DownSongsTab({
    super.key,
    required this.songs,
    required this.onDelete,
    required this.scrollController,
  });

  @override
  State<DownSongsTab> createState() => _DownSongsTabState();
}

class _DownSongsTabState extends State<DownSongsTab>
    with AutomaticKeepAliveClientMixin {
  Future<void> downImage(
    String imageFilePath,
    String songFilePath,
    String url,
  ) async {
    final File file = File(imageFilePath);

    try {
      await file.create();
      final image = await Audiotagger().readArtwork(path: songFilePath);
      if (image != null) {
        file.writeAsBytesSync(image);
      }
    } catch (e) {
      final HttpClientRequest request2 =
          await HttpClient().getUrl(Uri.parse(url));
      final HttpClientResponse response2 = await request2.close();
      final bytes2 = await consolidateHttpClientResponseBytes(response2);
      await file.writeAsBytes(bytes2);
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return (widget.songs.isEmpty)
        ? emptyScreen(
            context,
            3,
            AppLocalizations.of(context)!.nothingTo,
            15.0,
            AppLocalizations.of(context)!.showHere,
            50,
            AppLocalizations.of(context)!.addSomething,
            23.0,
          )
        : Column(
            children: [
              PlaylistHead(
                songsList: widget.songs,
                offline: true,
                fromDownloads: true,
              ),
              Expanded(
                child: ListView.builder(
                  controller: widget.scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 10),
                  shrinkWrap: true,
                  itemCount: widget.songs.length,
                  itemExtent: 70.0,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: imageCard(
                        imageUrl: widget.songs[index]['image'].toString(),
                        localImage: true,
                        localErrorFunction: (_, __) {
                          if (widget.songs[index]['image'] != null &&
                              widget.songs[index]['image_url'] != null) {
                            downImage(
                              widget.songs[index]['image'].toString(),
                              widget.songs[index]['path'].toString(),
                              widget.songs[index]['image_url'].toString(),
                            );
                          }
                        },
                      ),
                      onTap: () {
                        PlayerInvoke.init(
                          songsList: widget.songs,
                          index: index,
                          isOffline: true,
                          fromDownloads: true,
                          recommend: false,
                        );
                      },
                      title: Text(
                        '${widget.songs[index]['title']}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${widget.songs[index]['artist'] ?? 'Artist name'}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PopupMenuButton(
                            icon: const Icon(
                              Icons.more_vert_rounded,
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15.0),
                              ),
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 1,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.delete_rounded,
                                    ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      )!
                                          .delete,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (int? value) async {
                              if (value == 1) {
                                setState(() {
                                  widget.onDelete(widget.songs[index] as Map);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
  }
}
