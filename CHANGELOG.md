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

