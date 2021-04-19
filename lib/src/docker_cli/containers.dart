import 'package:dcli/dcli.dart';

import 'container.dart';
import 'image.dart';
import 'images.dart';

/// Provides methods to obtain a list of docker containers.
class Containers {
  /// Factory instance of Containers.
  factory Containers() => _self;

  Containers._internal();

  static final _self = Containers._internal();

  final _containerCache = <Container>[];

  /// returns a list of containers.
  /// The list is cached in memory so if you create a new
  /// container you need to call [flushCache].
  List<Container> containers({bool excludeStopped = false}) {
    if (_containerCache.isEmpty) {
      var cmd =
          // ignore: lines_longer_than_80_chars
          'docker container ls --format "table {{.ID}}|{{.Image}}|{{.CreatedAt}}|{{.Status}}|{{.Ports}}|{{.Names}}"';
      if (!excludeStopped) {
        cmd += ' --all';
      }
      final lines = cmd.toList(skipLines: 1);

      for (final line in lines) {
        final parts = line.split('|');
        final containerid = parts[0];
        var imageid = parts[1];
        final created = parts[2];
        final status = parts[3];
        final ports = parts[4];
        final names = parts[5];

        // sometimes the imageid is actually the image name.
        final image = Images().findByFullname(imageid);
        if (image != null) {
          /// the imageid that we parsed actually contained an image name
          /// so lets replace that with the actual id.
          imageid = image.imageid!;
        }

        final container = Container(
            containerid: containerid,
            imageid: imageid,
            created: created,
            status: status,
            ports: ports,
            names: names);
        _containerCache.add(container);
      }
    }
    return _containerCache;
  }

  /// Flush the list of containers that we have cached
  void flushCache() {
    _containerCache.clear();
  }

  /// True if a container with the given [containerid] exists.
  /// By default we include stopped containers.
  /// Set [excludeStopped] to true to ignore stopped containers.
  bool existsByContainerId(String containerid, {bool excludeStopped = false}) =>
      findByContainerId(containerid, excludeStopped: excludeStopped) != null;

  /// True if a container with the given [name] exists.
  /// By default we include stopped containers.
  /// Set [excludeStopped] to true to ignore stopped containers.
  bool existsByName({required String name, bool excludeStopped = false}) =>
      findByName(name, excludeStopped: excludeStopped) != null;

  /// Returns the container with the given [containerid] or null if
  /// it doesn't exist.
  /// By default we include stopped containers.
  /// Set [excludeStopped] to true to ignore stopped containers.
  Container? findByContainerId(String containerid,
      {bool excludeStopped = false}) {
    final list = containers(excludeStopped: excludeStopped);

    for (final container in list) {
      if (containerid == container.containerid) {
        return container;
      }
    }
    return null;
  }

  /// Returns a list of containers that were created with the given [imageid].
  /// If no containers match then an empty list is returned.
  /// By default we include stopped containers.
  /// Set [excludeStopped] to true to ignore stopped containers.
  List<Container> findByImageid(String? imageid,
      {bool excludeStopped = false}) {
    final list = containers(excludeStopped: excludeStopped);
    final matches = <Container>[];

    for (final container in list) {
      if (imageid == container.imageid) {
        matches.add(container);
      }
    }
    return matches;
  }

  /// Finds and returns the container with given name.
  /// Returns null if the container doesn't exist.
  /// assumes that a container only has one name :)
  /// if [excludeStopped] is true then exclude containers that are not running.
  Container? findByName(String name, {bool excludeStopped = false}) {
    final list = containers(excludeStopped: excludeStopped);

    for (final container in list) {
      if (name == container.names) {
        return container;
      }
    }
    return null;
  }

  /// Finds the list of containers that where created from the image
  /// given by [image].
  /// By default we include stopped containers.
  // if [excludeStopped] is true then exclude containers that are not running.
  List<Container> findByImage(Image image, {bool excludeStopped = false}) =>
      findByImageid(image.imageid, excludeStopped: excludeStopped);
}
