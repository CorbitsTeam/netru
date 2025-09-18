import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/news_model.dart';

abstract class NewsLocalDataSource {
  Future<List<NewsModel>> getNewsFromJson();
}

class NewsLocalDataSourceImpl implements NewsLocalDataSource {
  @override
  Future<List<NewsModel>> getNewsFromJson() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/news/news.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final List<dynamic> newsListJson = jsonData['data'] ?? [];

      return newsListJson.map((json) => NewsModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load news from JSON: $e');
    }
  }
}
