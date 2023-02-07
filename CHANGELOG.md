# 3.0.0
- upgraded to dart 2.19
# 2.2.8
- Merge pull request #3 from rlsutton1/main
- change delete to use image name so it can delete tags
- move to using lint_hard.

# 2.2.7
- Added showProgress option to build function. If false we only show errors.
- added copyright notices.

# 2.2.5
- Fixed a bug where the build args passed to build where being passed incorrectly.

# 2.2.4
- Fixed a bug in build. The workingDirectory was being ignored.
- grammar.

# 2.2.3
Added optional workingDirectory to build function.


# 2.2.2
- Added a build and publish method.

# 2.2.0
- removed posix.

# 2.1.2
- Fixed bug in volume.create when a null name was passed. It resulted a volume name null rather than docker generating a uuid.

# 2.1.1
- Fixed a bug in Images().find commands. The tag wasn't being set.

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

