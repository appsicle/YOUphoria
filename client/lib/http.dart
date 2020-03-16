import 'package:http/http.dart';
import 'dart:convert';

// const URL = 'http://localhost:8080/';
const URL = 'http://youphoria.appspot.com/';

Future<Response> postData(endpoint, json, token) async {
  var headers = {"Content-type": "application/json"};
  if (token != null) {
    headers["Authorization"] = "Bearer " + token;
  }
  Response response =
      await post(URL + endpoint, headers: headers, body: jsonEncode(json));
  return response;
}

Future<Response> getData(endpoint, token) async {
  var headers = {"Content-type": "application/json"};
  if (token != null) {
    headers["Authorization"] = "Bearer " + token;
  }
  Response response = await get(URL + endpoint, headers: headers);
  return response;
}

decodeBody(body) {
  return jsonDecode(body);
}
