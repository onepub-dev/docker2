/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';

import 'docker.dart';
import 'exceptions.dart';
import 'image.dart';

/// Class used to obtain a list of images.
class Images {
  late final List<Image>? _imageCache;

  static final _self = Images._internal();

  /// Returns a factory [Images]
  factory Images() => _self;

  /// Call this version to cache the images between calls.
  Images.cached() {
    _imageCache = _loadImages();
  }

  Images._internal() : _imageCache = null;

  /// Gets a list of of docker images.
  List<Image> get images {
    if (_imageCache != null) {
      return _imageCache;
    } else {
      return _loadImages();
    }
  }

  List<Image> _loadImages() {
    final images = <Image>[];
    final lines = dockerRun('images',
            '''--format "table {{.ID}}|{{.Repository}}|{{.Tag}}|{{.CreatedAt}}|{{.Size}}"''')
        // remove the heading.
        .toList()
      ..removeAt(0);

    for (final line in lines) {
      final parts = line.split('|');
      final imageid = parts[0];
      final repositoryAndName = parts[1];
      final tag = parts[2];
      final created = parts[3];
      final size = parts[4];

      final image = Image(
          repositoryAndName: repositoryAndName,
          tag: tag,
          imageid: imageid,
          created: created,
          size: size);
      images.add(image);
    }
    // }

    return images;
  }

  /// Returns true if an image with the given id returns true.
  bool existsByImageId({required String imageid}) =>
      findByImageId(imageid) != null;

  /// Returns true an image exists with the name [fullname].
  ///
  /// The name must be in the format repo/name:tag
  bool existsByFullname({
    required String fullname,
  }) =>
      findByName(fullname) != null;

  /// Returns true an image exists with the given  name parts.
  bool existsByParts(
          {required String repository,
          required String name,
          required String tag}) =>
      findByParts(repository: repository, name: name, tag: tag).isNotEmpty;

  /// Finds an image with the given [imageid].
  ///
  /// Returns null if the image doesn't exist.
  Image? findByImageId(String imageid) {
    final list = images;

    for (final image in list) {
      if (imageid == image.imageid) {
        return image;
      }
    }
    return null;
  }

  /// Searches for and returns the image that matches
  /// [imageName].
  /// If more than one image matches then an [AmbiguousImageNameException]
  /// is thrown.
  /// If no matching image is found a null is returned.
  /// If the name component is not passed then an [ArgumentError] is thrown.
  ///
  /// The fullName is of the form registry/repo/name:tag
  /// The registry, repo and tag are optional.
  ///
  /// e.g.
  /// dockerhub.io/canonical/ubuntu:latest
  /// canonical/ubuntu
  /// ubuntu
  /// ubuntu:latest
  Image? findByName(String imageName) {
    final list = findAllByName(imageName);
    if (list.length > 1) {
      throw AmbiguousImageNameException(imageName);
    }
    if (list.isEmpty) {
      return null;
    }
    return list[0];
  }

  /// returns a list of images with the given [imageName]
  List<Image> findAllByName(String imageName) {
    final match = Image.fromName(imageName);

    verbose(() => 'Match ${match.repository} ${match.name} ${match.tag}');

    final list = findByParts(
        repository: match.repository, name: match.name, tag: match.tag);
    return list;
  }

  /// Returns a list of images that match the passed
  /// parts. The [name] part is the only compulsory part.
  /// If no matches are found then an empty list is returned
  List<Image> findByParts(
      {required String? repository,
      required String name,
      required String? tag}) {
    final list = images;
    final found = <Image>[];

    for (final image in list) {
      if (image.isSame(repository: repository, name: name, tag: tag)) {
        found.add(image);
      }
    }

    return found;
  }

  /// Runs the docker pull command to pull the
  /// image with name [fullname]
  Image? pull({required String fullname}) {
    dockerRun('pull', fullname);
    // flushCache();
    return findByName(fullname);
  }
}
