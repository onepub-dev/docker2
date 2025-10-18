/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'container.dart';
import 'docker.dart';
import 'image.dart';
import 'images.dart';

/// Holds a list of Docker containers.
class Containers {
  static final _self = Containers._internal();

  /// Factory ctor
  factory Containers() => _self;

  Containers._internal();

  /// returns a list of containers.
  List<Container> containers({bool excludeStopped = false}) {
    final containerCache = <Container>[];

    //if (containerCache.isEmpty) {
    var args =
        '''ls --format "table {{.ID}}|{{.Image}}|{{.CreatedAt}}|{{.Status}}|{{.Ports}}|{{.Names}}"''';
    if (!excludeStopped) {
      args += ' --all';
    }

    final lines = dockerRun('container', args)
        // remove the heading.
        .toList()
      ..removeAt(0);

    final images = Images.cached();
    for (final line in lines) {
      final parts = line.split('|');
      final containerid = parts[0];
      var imageid = parts[1];
      final created = parts[2];
      final status = parts[3];
      final ports = parts[4];
      final name = parts[5];

      var image = images.findByImageId(imageid);
      if (image == null) {
        // sometimes the imageid is actually the image name.
        final list = images.findAllByName(imageid);
        if (list.isNotEmpty) {
          image = list.first;
        }
      }

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
          name: name);
      containerCache.add(container);
      //}
    }
    return containerCache;
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
    var containerid0 = containerid;

    if (containerid0.length > 12) {
      containerid0 = containerid0.substring(0, 12);
    }

    for (final container in list) {
      if (containerid0 == container.containerid) {
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
  /// if [excludeStopped] is true then exclude containers that are not running.
  Container? findByName(String name, {bool excludeStopped = false}) {
    final list = containers(excludeStopped: excludeStopped);

    for (final container in list) {
      if (name == container.name) {
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
