/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';

import 'container.dart';
import 'containers.dart';
import 'exceptions.dart';
import 'image.dart';
import 'image_name.dart';
import 'images.dart';
import 'volume.dart';
import 'volumes.dart';

/// Top level class generally used as the starting point manage
/// docker containers and images.
class Docker {
  /// Searches for and returns the image that matches
  /// [imageName].
  /// If more than one image matches then an [AmbiguousImageNameException]
  /// is thrown.
  /// If no matching image is found a null is returned.
  ///
  /// The fullName is of the form registry/repo/name:tag
  /// The registry, repo and tag are optional.
  ///
  /// e.g.
  /// dockerhub.io/canonical/ubuntu:latest
  /// canonical/ubuntu
  /// ubuntu
  /// ubuntu:latest
  Image? findImageByName(String imageName) {
    ImageName.fromName(imageName);
    return Images().findByName(imageName);
  }

  /// Returns an [Image] for the give [imageId].
  /// If the [imageId] is not found then null is returned.
  Image? findImageById(String imageId) => Images().findByImageId(imageId);

  /// Searches for a container with the given [containerId].
  /// Returns null if a container could not be found.
  Container? findContainerById(String containerId) =>
      Containers().findByContainerId(containerId);

  /// Searches for a container with the given [containerName].
  /// If more than container has the same name the first
  /// container will be returned.
  /// Use [containers] to get a complete list of containers.
  /// Returns null if a container could not be found.
  Container? findContainerByName(String containerName) =>
      Containers().findByName(containerName);

  /// Pulls an image from a remote repository.
  /// The fullName is of the form repo/name:tag
  /// The repo and tag are optional.
  ///
  /// e.g.
  /// dockerhub.io/ubuntu:latest
  /// ubuntu
  /// ubuntu:latest
  Image pull(String fullname) {
    final imageName0 = ImageName.fromName(fullname);

    Image? image = Image.fromName(imageName0.fullname)..pull();
    image = Images().findByName(imageName0.fullname);
    if (image == null) {
      throw ImageNotFoundException(fullname);
    }
    return image;
  }

  /// creates a container from the passed [image] with
  /// the given [containerName].
  /// The [args] and [argString] are appended to the command
  /// and allow you to add abitrary arguments.
  /// The [args] list is added before the [argString].
  Container create(Image image, String containerName,
          {List<String>? args, String? argString}) =>
      image.create(containerName, args: args, argString: argString);

  /// Creates and starts a docker container.
  /// If [daemon] is true (the default) then the container is started
  /// as a daemon. When [daemon] is false then we pass the interactive and
  /// attach arguments to the docker start command to allow full interaction.
  // Throws [ContainerAlreadyRunning] if the container is already running.
  /// from you existing enviornment by passing a list of environment
  /// variable names in [environmentVars].
  ///
  /// The [args] and [argString] are appended to the command
  /// and allow you to add abitrary arguments.
  /// The [args] list is added before the [argString].
  void run(Image image,
      {List<String>? args,
      String? argString,
      List<String> environmentVars = const <String>[],
      bool daemon = true}) {
    var cmdArgs = '';

    if (args != null) {
      cmdArgs += ' ${args.join(' ')}';
    }
    if (argString != null) {
      cmdArgs += ' $argString';
    }

    final envVars = StringBuffer();
    if (environmentVars.isNotEmpty) {
      for (final env in environmentVars) {
        envVars.write('-e $env ');
      }
    }

    var terminal = false;
    if (!daemon) {
      cmdArgs = '--attach --interactive $cmdArgs';
      terminal = true;
    }
    dockerRun('run', '$cmdArgs $envVars ${image.fullname}', terminal: terminal);
  }

  /// Returns a list of containers
  /// If [excludeStopped] is true (defaults to false) then
  /// only running containers will be returned.
  List<Container> containers({bool excludeStopped = false}) =>
      Containers().containers(excludeStopped: excludeStopped);

  /// Returns the list of volumes
  List<Volume> volumes() => Volumes().volumes();

  /// internal function to provide a consistent method of handling
  /// failed execution of the docker command.
  List<String> _dockerRun(String cmd, String args, {bool terminal = false}) {
    final progress = 'docker $cmd $args'
        .start(nothrow: true, terminal: terminal, progress: Progress.capture());

    if (progress.exitCode != 0) {
      throw DockerCommandFailed(
          cmd, args, progress.exitCode!, progress.lines.join('\n'));
    }
    return progress.lines;
  }
}

/// runs the passed docker command.
List<String> dockerRun(String cmd, String args, {bool terminal = false}) =>
    Docker()._dockerRun(cmd, args, terminal: terminal);
