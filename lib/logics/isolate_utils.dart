import 'dart:isolate' show Isolate, ReceivePort, SendPort;

import 'package:http/http.dart' as http show Client;

typedef AsyncResponse = Future<String> Function({required http.Client client});
typedef Decode<T> = List<T> Function({required String responseBody});

//TODO refactor to make into providers of Riverpod

/// Fetch items of [T] with an isolate in background.
/// The parameters, called [asyncResponse] & [decode], must be
/// top-level functions.
///
/// Example:
/// ```dart
/// Future<String> getResponseForGetRequest({
///   required http.Client client,
/// }) async {
///   final response = await client.get(Uri.parse(kUrl));
///   return response.body;
/// }
///
/// List<Photo> decodePhotos({required String responseBody}) {
///   final parsed = convert.jsonDecode(responseBody) as List<dynamic>;
///   return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
/// }
///
/// Future<List<Photo>> fetchPhotosWithIsolate(http.Client client) async {
///   return fetchList<Photo>(
///     client: client,
///     asyncResponse: getResponseForGetRequest,
///     decode: decodePhotos,
///   );
/// }
/// ```
Future<List<T>> fetchList<T>({
  required http.Client client,
  required AsyncResponse asyncResponse,
  required Decode<T> decode,
}) async {
  final receivePort = ReceivePort();
  final responsePort = ReceivePort();

  Isolate.spawn<SendPort>(
    isolateFunction,
    receivePort.sendPort,
  );

  final childSendPort = await receivePort.first as SendPort;
  childSendPort.send(
    <String, dynamic>{
      'client': client,
      'asyncResponse': asyncResponse,
      'decode': decode,
      'sendPort': responsePort.sendPort,
    },
  );

  return (await responsePort.first) as List<T>;
}

Future<void> isolateFunction<T>(SendPort mainSendPort) async {
  final backReceivePort = ReceivePort();
  mainSendPort.send(backReceivePort.sendPort);

  await for (final message in backReceivePort) {
    final map = message as Map<String, dynamic>;

    final client = map['client'] as http.Client;
    final asyncResponse = map['asyncResponse'] as AsyncResponse;
    final decode = map['decode'] as Decode<T>;
    final replyPort = message['sendPort'] as SendPort;

    replyPort.send(
      decode(
        responseBody: await asyncResponse(client: client),
      ),
    );
  }
}
