import 'package:http/http.dart';
import 'dart:convert';

const URL = 'http://localhost:8080/';

Future<Response> postData(endpoint, json) async {
  Response response = await post(URL + endpoint,
      headers: {"Content-type": "application/json"}, body: jsonEncode(json));
  return response;
}

Future<Response> getData(endpoint, json) async {
  Response response = await get(URL + endpoint,
      headers: {"Content-type": "application/json"});
  return response;
}

decodeBody(body) {
  return jsonDecode(body);
}