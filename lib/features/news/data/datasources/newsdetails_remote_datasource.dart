import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/news_model.dart';
import '../models/news_category_model.dart';

abstract class NewsdetailsRemoteDataSource {
  Future<List<NewsModel>> getNews({
    int limit = 50,
    int offset = 0,
    int? categoryId,
    String? status,
    bool onlyPublished = true,
  });

  Future<NewsModel?> getNewsById(String id);

  Future<List<NewsCategoryModel>> getNewsCategories({bool onlyActive = true});

  Future<List<NewsModel>> getNewsByCategory(
    int categoryId, {
    int limit = 50,
    int offset = 0,
  });

  Future<List<NewsModel>> getFeaturedNews({int limit = 10});

  Future<void> incrementNewsViewCount(String newsId);
}

class NewsdetailsRemoteDataSourceImpl implements NewsdetailsRemoteDataSource {
  final SupabaseClient supabaseClient;

  NewsdetailsRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<NewsModel>> getNews({
    int limit = 50,
    int offset = 0,
    int? categoryId,
    String? status,
    bool onlyPublished = true,
  }) async {
    try {
      print('🔍 Starting getNews query...');
      print(
        '🔍 Parameters: limit=$limit, offset=$offset, categoryId=$categoryId, status=$status, onlyPublished=$onlyPublished',
      );

      // بناء الكويري مع join للفئة
      var query = supabaseClient.from('news_articles').select('''
            *,
            category:category_id(
              id,
              name,
              name_ar
            )
          ''');

      // إضافة الشروط
      if (onlyPublished) {
        query = query.eq('is_published', true);
      }

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      if (status != null) {
        query = query.eq('status', status);
      }

      print(
        '🔍 Applied filters: onlyPublished=$onlyPublished, categoryId=$categoryId, status=$status',
      );

      // إضافة الترتيب والحد
      final response = await query
          .order('published_at', ascending: false)
          .range(offset, offset + limit - 1);

      print('📊 Raw response length: ${response.length}');
      print('📊 Response type: ${response.runtimeType}');

      if (response.isEmpty) {
        print('⚠️ No articles found with current filters');

        // اختبار إذا كان الجدول فارغ تماماً
        final totalArticles = await supabaseClient
            .from('news_articles')
            .select('id')
            .limit(1);
        print('📊 Total articles check: ${totalArticles.length} found');

        // إذا لم نجد أي مقالات، جرب بدون فلاتر
        if (totalArticles.isEmpty) {
          print('❌ No articles found in database at all!');
          return [];
        }

        // إذا كان هناك بيانات لكن الفلاتر تمنعها، جرب بدون فلاتر
        if (onlyPublished) {
          print('🔄 Trying without published filter...');
          final fallbackResponse = await supabaseClient
              .from('news_articles')
              .select('''
                *,
                category:category_id(
                  id,
                  name,
                  name_ar
                )
              ''')
              .order('published_at', ascending: false)
              .range(offset, offset + limit - 1);

          if (fallbackResponse.isNotEmpty) {
            print(
              '✅ Found ${fallbackResponse.length} articles without published filter',
            );
            final fallbackResult =
                fallbackResponse.map((json) {
                  if (json['category'] != null) {
                    json['category_name'] = json['category']['name_ar'];
                    json['category_name_en'] = json['category']['name'];
                  }
                  return NewsModel.fromJson(json);
                }).toList();
            return fallbackResult;
          }
        }

        return [];
      }

      print('✅ Found ${response.length} articles');
      if (response.isNotEmpty) {
        print('🔍 First article keys: ${response.first.keys.toList()}');
        print('🔍 First article sample: ${response.first}');
      }

      final result =
          response.map((json) {
            try {
              // تسطيح بيانات الفئة
              if (json['category'] != null) {
                json['category_name'] = json['category']['name_ar'];
                json['category_name_en'] = json['category']['name'];
              }

              print('🔄 Converting article: ${json['id']} - ${json['title']}');
              return NewsModel.fromJson(json);
            } catch (e) {
              print('❌ Error converting article ${json['id']}: $e');
              rethrow;
            }
          }).toList();

      print('✅ Successfully converted ${result.length} news models');
      return result;
    } catch (e, stackTrace) {
      print('❌ ERROR in getNews: $e');
      print('📍 Stack trace: $stackTrace');
      throw Exception('Failed to fetch news: $e');
    }
  }

  @override
  Future<NewsModel?> getNewsById(String id) async {
    try {
      final response =
          await supabaseClient
              .from('news_articles')
              .select('''
            *,
            category:category_id(
              id,
              name,
              name_ar
            )
          ''')
              .eq('id', id)
              .single();

      // تسطيح بيانات الفئة
      if (response['category'] != null) {
        response['category_name'] = response['category']['name_ar'];
        response['category_name_en'] = response['category']['name'];
      }

      return NewsModel.fromJson(response);
    } catch (e) {
      if (e.toString().contains('No rows found')) {
        return null;
      }
      throw Exception('Failed to fetch news by id: $e');
    }
  }

  @override
  Future<List<NewsCategoryModel>> getNewsCategories({
    bool onlyActive = true,
  }) async {
    try {
      var query = supabaseClient.from('news_categories').select('*');

      if (onlyActive) {
        query = query.eq('is_active', true);
      }

      final response = await query.order('display_order', ascending: true);

      final List<dynamic> data = response as List<dynamic>;

      return data.map((json) => NewsCategoryModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch news categories: $e');
    }
  }

  @override
  Future<List<NewsModel>> getNewsByCategory(
    int categoryId, {
    int limit = 50,
    int offset = 0,
  }) async {
    return getNews(categoryId: categoryId, limit: limit, offset: offset);
  }

  @override
  Future<List<NewsModel>> getFeaturedNews({int limit = 10}) async {
    try {
      print('🔍 Starting getFeaturedNews query...');

      // جلب الأخبار المميزة مع join للفئة
      var featuredQuery = supabaseClient
          .from('news_articles')
          .select('''
            *,
            category:category_id(
              id,
              name,
              name_ar
            )
          ''')
          .eq('is_featured', true)
          .order('published_at', ascending: false)
          .limit(limit);

      final response = await featuredQuery;

      print('📊 Featured news response length: ${response.length}');

      if (response.isEmpty) {
        print('⚠️ No featured news found, fallback to latest news');

        // إذا لم توجد أخبار مميزة، جلب أحدث الأخبار
        final fallbackResponse = await supabaseClient
            .from('news_articles')
            .select('''
              *,
              category:category_id(
                id,
                name,
                name_ar
              )
            ''')
            .order('published_at', ascending: false)
            .limit(limit);

        print('📊 Fallback news response length: ${fallbackResponse.length}');

        if (fallbackResponse.isEmpty) {
          print('❌ No articles found even without filters');
          return [];
        }

        print('✅ Using fallback articles as featured news');
        return fallbackResponse.map((json) {
          // تسطيح بيانات الفئة
          if (json['category'] != null) {
            json['category_name'] = json['category']['name_ar'];
            json['category_name_en'] = json['category']['name'];
          }
          return NewsModel.fromJson(json);
        }).toList();
      }
      print('✅ Found ${response.length} featured articles');

      return response.map((json) {
        // تسطيح بيانات الفئة
        if (json['category'] != null) {
          json['category_name'] = json['category']['name_ar'];
          json['category_name_en'] = json['category']['name'];
        }
        return NewsModel.fromJson(json);
      }).toList();
    } catch (e, stackTrace) {
      print('❌ ERROR in getFeaturedNews: $e');
      print('📍 Stack trace: $stackTrace');
      throw Exception('Failed to fetch featured news: $e');
    }
  }

  @override
  Future<void> incrementNewsViewCount(String newsId) async {
    try {
      await supabaseClient.rpc(
        'increment_news_view_count',
        params: {'news_id': newsId},
      );
    } catch (e) {
      // Don't throw error for view count increment failures
      print('Failed to increment view count: $e');
    }
  }
}
