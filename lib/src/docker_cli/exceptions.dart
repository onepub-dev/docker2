/// Base exception for all exceptions thrown by Docker2.
class DockerCliException implements Exception {}

/// Thrown if the given container does not exist.
class ContainerNotFoundException extends DockerCliException {}

/// The docker container is not running.
class ContainerNotRunning extends DockerCliException {}

/// The docker container is already running.
class ContainerAlreadyRunning extends DockerCliException {}

/// Thrown if the given container already exists.
class ContainerExistsException extends DockerCliException {
  /// Thrown if the given container already exists.
  ContainerExistsException(this.containerName);

  /// The container  that already exits.
  String containerName;
}

/// Throw if a docker command failed when we tried to execute it.
class DockerCommandFailed extends DockerCliException {
  /// Throw if a docker command failed when we tried to execute it.
  DockerCommandFailed(this.command, this.args, this.exitCode, this.error);

  /// the docker command that was being run.
  String command;

  /// the args we passed to the docker command.
  String args;

  /// the exit code returned from docker.
  int exitCode;

  /// The error message returned by docker.
  String error;

  @override
  String toString() => '''
Error running docker command: $command $args
Exit code: $exitCode
Error: 
$error
''';
}

/// Throw if the given image can't be found on the local system.
class ImageNotFoundException extends DockerCliException {
  /// Throw if the given image can't be found on the local system.
  ImageNotFoundException(this.fullName);

  /// the fullname of the image we were looking for.
  String fullName;
}
