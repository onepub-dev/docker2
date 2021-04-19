import 'package:dcli/dcli.dart';

import '../../docker2.dart';

/// Represents a docker image.
class Image {
  /// Creates an image with the given properties.
  /// Note: this doesn't create a docker image just
  /// an in memory representation of one.
  Image(
      {required String repositoryAndName,
      required this.tag,
      required this.imageid,
      required this.created,
      required this.size}) {
    final repoAndName = splitRepoAndName(repositoryAndName);
    repository = repoAndName.repo;
    name = repoAndName.name;
  }

  /// Creates an image with the given [fullname].
  /// Note: this doesn't create a docker image just
  /// an in memory representation of one.
  Image.fromName(String fullname)
      : imageid = null,
        created = null,
        size = null {
    final _fullname = splitFullname(fullname);

    repository = _fullname.repo;
    name = _fullname.name;
    tag = _fullname.tag;
  }

  /// repository name of this image.
  late final String repository;

  /// name of this image.
  late final String? name;

  /// tag name of this image.
  late final String? tag;

  /// The imageid of this image if known
  final String? imageid;

  /// The date the image was created if known
  final String? created;

  /// The size of the image if known.
  final String? size;

  /// Returns the full name of the image
  String get fullname => '$repository/$name:$tag';

  /// Takes a docker repo/name:tag string and splits it into
  /// three components.
  static _Fullname splitFullname(String fullname) {
    String repo;
    String? name;
    String? tag;

    Settings().verbose(fullname);

    if (fullname.contains('/')) {
      var parts = fullname.split('/');
      repo = parts[0];
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
        repo = parts[0];
        tag = parts[1];
      } else {
        repo = fullname;
      }
    }

    return _Fullname(repo, name, tag);
  }

  /// Takes a docker repo/name string and splits it into
  /// two components.
  static _RepoAndName splitRepoAndName(String repoAndName) {
    final parts = repoAndName.split('/');
    if (parts.length != 2) {
      return _RepoAndName(repoAndName, null);
    }
    return _RepoAndName(parts[0], parts[1]);
  }

  /// Delete the docker image.
  ///
  ///
  void delete({bool force = false}) {
    if (force) {
      'docker image rm -f $imageid'.run;
    } else {
      'docker image rm $imageid'.run;
    }
    Images().flushCache();
  }

  /// Pull the docker image.
  void pull() {
    'docker pull $imageid'.run;
    Images().flushCache();
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(covariant Image other) => imageid == other.imageid;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => 17 * 37 + imageid.hashCode;
}

class _RepoAndName {
  _RepoAndName(this.repo, this.name);
  String repo;
  String? name;
}

class _Fullname {
  _Fullname(this.repo, this.name, this.tag);

  String repo;
  String? name;
  String? tag;
}
