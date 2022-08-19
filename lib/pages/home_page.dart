import 'package:cached_network_image/cached_network_image.dart' as cache
    show CachedNetworkImage;
import 'package:flutter/material.dart';
import 'package:isolate_demo/_features.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    String? title,
  }) : _title = title ?? '';

  final String _title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: FutureBuilder(
        future: fetchPhotos(client: getClient()),
        //future: fetchPhotosWithCompute(client: getClient()),
        //future: fetchPhotosWithIsolate(client: getClient()),
        builder: (_, snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? _PhotosList(photos: snapshot.data! as List<Photo>)
              : const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _PhotosList extends StatelessWidget {
  const _PhotosList({required this.photos});

  final List<Photo> photos;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return Center(
        child: Text('No data'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 8.0),
      physics: const BouncingScrollPhysics(),
      itemCount: photos.length,
      itemBuilder: (_, index) {
        final photo = photos[index];

        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ListTile(
            leading: SizedBox.square(
              dimension: 60.0,
              child: Center(
                child: ClipOval(
                  child: cache.CachedNetworkImage(
                    placeholder: (_, __) => const CircularProgressIndicator(),
                    errorWidget: (_, __, ___) => Icon(Icons.error),
                    imageUrl: photos[index].thumbnailUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            title: Text(
              photo.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }
}
