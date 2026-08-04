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
  if (id == null) {
    return Future.value(null);
  }

  final int? imageId = int.tryParse(id.toString());
  if (imageId == null) {
    return Future.value(null);
  }

  return core.ApiClient().getDetails('image', imageId).then((dynamic data) {
    if (data is Map) {
      final Map<String, dynamic> responseData = data['data'] is Map
          ? Map<String, dynamic>.from(data['data'] as Map)
          : Map<String, dynamic>.from(data);
      return core.ImageObject.fromJson(
        responseData,
        schema: core.ImageObject.fallbackSchema,
      );
    }

    if (data is core.ImageObject) {
      return data;
    }

    return null;
  });
}

extension CoreImageObjectCompat on core.ImageObject {
  String? get imageUrl => imageurl;
  String? get externalLinks => externallinks;
  String? get filelanguage => getString('filelanguage');
}
