/// Base class for all DockerCli exceptions
class DockerCli implements Exception {}

/// The docker container is already running.
class ContainerAlreadyRunning extends DockerCli {}

/// The docker container is not running.
class ContainerNotRunning extends DockerCli {}
