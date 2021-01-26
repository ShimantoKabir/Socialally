import 'dart:convert';

import 'package:client/constants.dart';
import 'package:dio/dio.dart';

class HttpHandler{

  Dio _dio;
  String cookie = '';

  final BaseOptions options = new BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: 15000,
    receiveTimeout: 13000,
  );
  static final HttpHandler _instance = HttpHandler._internal();

  factory HttpHandler() => _instance;

  HttpHandler._internal() {
    _dio = Dio(options);
    _dio.interceptors.add(InterceptorsWrapper(
        onRequest:(Options options) async {
          _dio.interceptors.requestLock.lock();
          options.headers["cookie"] = cookie;
          _dio.interceptors.requestLock.unlock();
          return options;
        }
    ));
  }

  Future createPost(String url,var data) {
    return _dio.post(url, data: jsonEncode(data));
  }

  Future createPut(String url,var data) {
    return _dio.put(url, data: jsonEncode(data));
  }

  Future createGet(String url) {
    return _dio.get(url);
  }

}