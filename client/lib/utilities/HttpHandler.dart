import 'dart:convert';
import 'dart:io';
import 'package:client/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class HttpHandler{

  Dio dio;
  String cookie = '';

  final BaseOptions options = new BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: 15000,
    receiveTimeout: 13000,
  );
  static final HttpHandler _instance = HttpHandler._internal();

  factory HttpHandler() => _instance;

  HttpHandler._internal() {
    dio = Dio(options);
    dio.interceptors.add(InterceptorsWrapper(
        onRequest:(Options options) async {
          dio.interceptors.requestLock.lock();
          options.headers["cookie"] = cookie;
          dio.interceptors.requestLock.unlock();
          return options;
        }
    ));
  }

  Future createPost(String url,var data) {
    return dio.post(url, data: jsonEncode(data));
  }

  Future createPut(String url,var data) {
    return dio.put(url, data: jsonEncode(data));
  }

  Future createGet(String url) {
    return dio.get(url);
  }

}