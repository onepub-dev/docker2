/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';

import 'image.dart';

/// Used to parse and hold the components of a docker image name.
class ImageName {
  /// The registry where this image is located.
  String? registry;

  /// The repository name of this image.
  String? repository;

  /// The simple name of this image.
  late String name;

  /// the tag name of this image. Defaults to 'latest' if an tag
  /// is not supplied.
  String? tag;

  /// construct an image name from it sparts.
  ImageName(this.registry, this.repository, this.name, this.tag);

  /// constructs an image name from a full docker image name of the form
  /// registry/repo/name:tag
  /// Any of the parts may be missing except for the [name].
  ImageName.fromName(String fullname) {
    final parsed = _parseName(fullname);
    name = parsed.name;
    repository = parsed.repository;
    registry = parsed.registry;
    tag = parsed.tag;
  }

  /// Constructs an [ImageName] from just its repo/name with an optional
  /// tag.
  ImageName.fromRepositoryAndName(String repositoryAndName, {String? tag}) {
    var repositoryAndName0 = repositoryAndName;

    if (tag != null) {
      repositoryAndName0 += ':$tag';
    }

    final parsed = _parseName(repositoryAndName0);

    name = parsed.name;
    repository = parsed.repository;
    registry = parsed.registry;
    this.tag = parsed.tag;
  }

  /// Returns the full name of the image.
  /// Any parts that we don't have are excluded.
  String get fullname {
    var fname = '';
    if (registry != null) {
      fname += '$registry/';
    }

    if (repository != null) {
      fname += '$repository/';
    }

    fname += name;

    if (tag != null) {
      fname += ':$tag';
    }
    return fname;
  }

  /// Returns true if the passed [image] has the same
  /// name as this image.
  bool isSameFullname(Image image) =>
      repository == image.repository && name == image.name && tag == image.tag;

  /// Takes a docker repo/name:tag string and splits it into
  /// three components.
  /// The repo and tag are optional.
  /// If no tag is provided then 'latest' is assumed.
  /// e.g.
  /// repo/name:tag
  /// repo/name
  /// name
  /// name:tag
  // ignore: prefer_constructors_over_static_methods
  static ImageName _parseName(String fullname) {
    String? registry;
    String? repository;
    String name;
    String? tag;

    verbose(() => fullname);

    if (fullname.contains('/')) {
      var parts = fullname.split('/');
      if (parts.length == 3) {
        // we have registry/repo/name
        registry = parts[0];
        parts.removeAt(0);
      }
      final repoOrRegistry = parts[0];
      // If the part contains a dot then it must be
      // a domain name which is only valid for the
      // registry.
      if (repoOrRegistry.contains('.')) {
        // We should only see this if the no.
        // of parts is true as the user passed
        // registry/name
        assert(registry == null, 'The regsitry should not be null');
        registry = repoOrRegistry;
        // repository = null;
      } else {
        repository = repoOrRegistry;
        // registry = null;
      }
      if (parts[1].contains(':')) {
        parts = parts[1].split(':');
        name = parts[0];
        tag = parts[1];
      } else {
        name = parts[1];
      }
    } else {
      if (fullname.contains(':')) {
        final parts = fullname.split(':');
        name = parts[0];
        tag = parts[1];
      } else {
        name = fullname;
      }
    }

    if (name.isEmpty) {
      throw ArgumentError(
          'The name component may not be empty. Invalid fullname: $fullname');
    }
    return ImageName(registry, repository, name, tag);
  }
}
