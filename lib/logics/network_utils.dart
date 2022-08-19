import 'dart:convert' as convert show jsonDecode;

import 'package:flutter/foundation.dart' as isolate show compute;
import 'package:http/http.dart' as http show Client;
import 'package:isolate_demo/_features.dart';

//TODO refactor to make into providers of Riverpod

// -----------------------------------------------------------------------------
// Network
// -----------------------------------------------------------------------------
http.Client getClient() => http.Client();

Future<String> getResponse({
  required http.Client client,
  required String url,
}) async {
  final response = await client.get(Uri.parse(url));
  return response.body;
}

// -----------------------------------------------------------------------------
// Photos
// -----------------------------------------------------------------------------
const kUrl = 'https://jsonplaceholder.typicode.com/photos';

Future<String> getResponseForGetRequest({
  required http.Client client,
}) async {
  final response = await client.get(Uri.parse(kUrl));
  return response.body;
}

/// Without `required` to match with compute function (isolate).
/// It must be top-level function (see [compute] method).
List<Photo> parsePhotos(String responseBody) {
  final parsed = convert.jsonDecode(responseBody) as List<dynamic>;
  return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
}

List<Photo> decodePhotos({required String responseBody}) {
  final parsed = convert.jsonDecode(responseBody) as List<dynamic>;
  return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
}

Future<List<Photo>> fetchPhotos({required http.Client client}) async {
  final responseBody = await getResponseForGetRequest(client: client);
  return parsePhotos(responseBody);
}

Future<List<Photo>> fetchPhotosWithCompute({
  required http.Client client,
}) async {
  final responseBody = await getResponseForGetRequest(client: client);
  return isolate.compute<String, List<Photo>>(parsePhotos, responseBody);
}

Future<List<Photo>> fetchPhotosWithIsolate({
  required http.Client client,
}) async {
  return fetchList<Photo>(
    client: client,
    asyncResponse: getResponseForGetRequest,
    decode: decodePhotos,
  );
}
