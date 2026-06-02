import 'package:core/core.dart' as core;

typedef AppImageProvider = core.SchemaObjectProvider<core.ImageObject>;

AppImageProvider createImageProvider() {
  return core.createSchemaObjectProvider<core.ImageObject>(
    objectType: 'imageObject',
    remoteObjectType: 'image',
    factory: core.ImageObject.fromJson,
  );
}

Future<core.ImageObject?> loadCoreImage(dynamic id) {
  return core.ImageObject.fromAPI(id);
}

extension CoreImageObjectCompat on core.ImageObject {
  String? get imageUrl => imageurl;
  String? get externalLinks => externallinks;
  String? get filelanguage => getString('filelanguage');
}
