import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

BaseOptions options = new BaseOptions(
    baseUrl: dotenv.env['BACKEND_URL'],
    // connectTimeout: 5000,
    // receiveTimeout: 3000,
);

Dio dio = new Dio(options);