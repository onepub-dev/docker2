/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:meta/meta.dart';

import 'container.dart';
import 'containers.dart';
import 'docker.dart';
import 'exceptions.dart';
import 'image_name.dart';

/// Represents a docker image.
@immutable
class Image {
  final ImageName _imageName;

  /// The id of this image. We use the short 12 char verison.
  final String? imageid;

  /// The date time this image was created.
  final String? created;

  /// The size on disk of this image in bytes.
  final String? size;

  /// Creates an image with the given properties.
  /// Note: this doesn't create a docker image just
  /// an in memory representation of one.
  /// Use [Docker().create] to create an image.
  Image(
      {required String repositoryAndName,
      required String tag,
      required this.imageid,
      required this.created,
      required this.size})
      : _imageName =
            ImageName.fromRepositoryAndName(repositoryAndName, tag: tag);

  /// Creates an image with the given [imageName].
  /// Note: this doesn't create a docker image just
  /// an in memory representation of one.
  Image.fromName(String imageName)
      : imageid = null,
        created = null,
        size = null,
        _imageName = ImageName.fromName(imageName);

  /// Returns the full name of the image
  String get fullname => _imageName.fullname;

  /// simple name of this image.
  String get name => _imageName.name;

  /// regsitry where this image is located.
  String? get registry => _imageName.registry;

  /// repository name of this image.
  String? get repository => _imageName.repository;

  /// The tag of this image. If one wasn't supplied then 'latest' is returned.
  String? get tag => _imageName.tag ?? 'latest';

  /// Delete the docker image.
  ///
  ///
  void delete({bool force = false}) {
    if (force) {
      dockerRun('image', 'rm -f ${_imageName.fullname}');
    } else {
      dockerRun('image', 'rm ${_imageName.fullname}');
    }
  }

  /// Returns true if the image exists locally.
  bool existsLocally() {
    try {
      final result = dockerRun('image', 'inspect ${_imageName.fullname}');

      // If dockerRun returns any lines, the image exists.
      return result.isNotEmpty;
    } on DockerCommandFailed catch (e, _) {
      // dockerRun will throw an exception if the image does not exist.
      return false;
    }
  }

  /// Pulls a docker image from a remote repository using the
  /// images [fullname]
  void pull() {
    dockerRun('pull', fullname);
  }

  /// creates a container with the name [containerName] using
  /// this image.
  /// Returns the newly created [Container].
  /// Throws a [ContainerExistsException] if a container with
  /// the passed [containerName] already exists.
  /// The [args] and [argString] are appended to the command
  /// and allow you to add abitrary arguments.
  /// The [args] list is added before the [argString].
  Container create(String containerName,
      {List<String>? args, String? argString}) {
    if (Containers().findByName(containerName) != null) {
      throw ContainerExistsException(containerName);
    }

    var cmdArgs = '--name $containerName $fullname';

    if (args != null) {
      cmdArgs += ' ${args.join(' ')}';
    }
    if (argString != null) {
      cmdArgs += ' $argString';
    }

    final lines = dockerRun('create', cmdArgs);

    final containerid = lines[0];

    final container = Containers().findByContainerId(containerid);

    if (container == null) {
      throw ContainerNotFoundException();
    }
    return container;
  }

  // return a list of containers created from this image
  List<Container> containers() => Containers().findByImage(this);

  /// Returns true if the pass name components match
  /// this image.
  /// This method allows you to do a partial match by
  /// passing only the components you want to match on.
  /// The [name] must be passed.
  bool isSame(
      {required String name,
      String? registry,
      String? repository,
      String? tag}) {
    if (registry != null) {
      if (this.registry != registry) {
        return false;
      }
    }

    if (repository != null) {
      if (this.repository != repository) {
        return false;
      }
    }

    if (this.name != name) {
      return false;
    }

    if (tag != null && this.tag != tag) {
      return false;
    }

    return true;
  }

  @override
  bool operator ==(covariant Image other) =>
      (identical(this, other)) || imageid == other.imageid;

  @override
  int get hashCode => imageid.hashCode;
}
