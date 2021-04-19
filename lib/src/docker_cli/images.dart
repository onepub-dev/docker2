import 'package:dcli/dcli.dart';
import 'image.dart';

/// Classo used to obtain a list of images.
class Images {
  /// Returns a factory [Images]
  factory Images() => _self;
  Images._internal();

  static final _self = Images._internal();

  final _imageCache = <Image>[];

  /// Gets a list of of docker images.
  /// The list is cached to improve performance.
  /// If you create a image locally then you will need to call
  /// [flushCache] to see the new image in this list.
  List<Image> get images {
    if (_imageCache.isEmpty) {
      var lines = 'docker images'.toList(skipLines: 1);

      const cmd =
          // ignore: lines_longer_than_80_chars
          'docker images --format "table {{.ID}}|{{.Repository}}|{{.Tag}}|{{.CreatedAt}}|{{.Size}}"';
      // print(cmd);

      lines = cmd.toList(skipLines: 1);

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
        _imageCache.add(image);
      }
    }

    return _imageCache;
  }

  /// Flushes the in memory list images.
  /// You will need to call this if you create a new image.
  void flushCache() {
    _imageCache.clear();
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
      findByFullname(fullname) != null;

  /// Returns true an image exists with the given  name parts.
  bool existsByParts(
          {required String repository,
          required String name,
          required String tag}) =>
      findByParts(repository: repository, name: name, tag: tag) != null;

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

  /// full name of the format repo/name:tag
  Image? findByFullname(String fullname) {
    final match = Image.fromName(fullname);

    Settings().verbose('Match ${match.repository} ${match.name} ${match.tag}');

    return findByParts(
        repository: match.repository, name: match.name, tag: match.tag);
  }

  /// Find an image by its name parts.
  /// Returns null if it can find the image.
  Image? findByParts(
      {required String repository,
      required String? name,
      required String? tag}) {
    final list = images;

    for (final image in list) {
      if (repository == image.repository &&
          name == image.name &&
          tag == image.tag) {
        return image;
      }
    }
    return null;
  }

  /// Runs the docker pull command to pull the
  /// image with name [fullname]
  Image? pull({required String fullname}) {
    'docker pull $fullname'.run;
    flushCache();
    return findByFullname(fullname);
  }
}
