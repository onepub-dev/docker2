# 2.1.0
- Added apis for creating/deleting list volumes.

# 2.0.3
- Fixed bug where if mulitple images had the same name then an error was being thrown when you attempt to get a containerbyname.
- improvements to documenaton.

# 2.0.2
Added docker run command as it looks like the create and run commands handle the docker ports flag differently.
Fixed bug where the docker cli command wasn't attaching as we were not running as a terminal.

# 2.0.1
Fixed a bug in the fullname. Was using the wrong slash. Added unit tests for same.


# 2.0.0
## added
- Introducted new highlevel class Docker intended as the starting point for most interactions.
- Added example and updated readme
- Improved parsing of image names to include parsing of the registry name.

## changed
- Change the Container.start command argument 'interactive' to daemon.

## deleted
We no longer cache the containers and image list. Hopefully this is the correct decision.

# 1.0.1
Added 'force' option to the delete.
Added interactive option to the start command.

# 1.0.0
A simple library for managening local docker images and containers.

