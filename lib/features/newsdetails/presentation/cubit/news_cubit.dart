import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:netru_app/core/constants/app_assets.dart';
import 'package:netru_app/features/newsdetails/data/models/news_model.dart';
import 'package:netru_app/features/newsdetails/presentation/cubit/news_state.dart';

import '../../../../core/constants/app_assets.dart';

class NewsCubit extends Cubit<NewsState> {
  NewsCubit() : super(NewsInitial());

  final List<NewsModel> _mockNews = [
    NewsModel(
      id: '1',
      title: 'القبض على عنصر إرهابي شديد الخطورة',
      date: '15 يوليو 2024',
      image: AppAssets.newsImages,
      category: 'أمن',
      content:
          '''تمكنت وزارة الداخلية من إلقاء القبض على عنصر إرهابي شديد الخطورة مطلوب في عدة قضايا أمنية خطيرة. وقد تمت العملية بناءً على معلومات استخبارية دقيقة وبتنسيق مع الأجهزة الأمنية المختلفة.
وأشارت المصادر الأمنية إلى أن المتهم كان يخطط لتنفيذ عمليات إرهابية تستهدف المنشآت الحيوية والمدنيين الآمنين. وقد تم ضبط كمية من المواد المتفجرة والأسلحة في حوزته.
وأكدت الداخلية أن هذه العملية تأتي في إطار الجهود المستمرة لمكافحة الإرهاب والحفاظ على أمن الوطن والمواطنين، مؤكدة أن الأجهزة الأمنية ستواصل ملاحقة العناصر الإرهابية بكل حزم وقوة.
كما تم التأكيد على أهمية تعاون المواطنين مع الأجهزة الأمنية في الإبلاغ عن أي أنشطة مشبوهة، مما يساهم في الحفاظ على الأمن والاستقرار في البلاد.''',
    ),
    NewsModel(
      id: '2',
      title: 'الإستجابة لحالات التسول في الاسواق',
      date: '20 يوليو 2024',
      image: AppAssets.newsImage2,
      category: 'اجتماعي',
      content:
          '''قامت وزارة الداخلية بحملة مكثفة للاستجابة لحالات التسول في الأسواق والميادين العامة، وذلك في إطار الجهود الرامية لمكافحة هذه الظاهرة السلبية وحماية المجتمع.
وقالت المصادر الأمنية أن الحملة شملت عدة محافظات وتمكنت من ضبط عدد كبير من المتسولين، خاصة في المناطق التجارية المزدحمة والأسواق الشعبية.
وتم تحويل الحالات المضبوطة إلى الجهات المختصة لاتخاذ الإجراءات القانونية اللازمة، مع توفير الرعاية الاجتماعية للحالات التي تحتاج إلى مساعدة.
وأكدت الوزارة أن هذه الحملات ستستمر بصفة دورية للحد من انتشار ظاهرة التسول، مع التركيز على الجانب الإنساني في التعامل مع الحالات المختلفة.
كما دعت المواطنين إلى عدم التعامل مع المتسولين وإبلاغ الجهات المختصة عند مواجهة مثل هذه الحالات.''',
    ),
    NewsModel(
      id: '3',
      title: 'الداخلية تقبض على شبكة احتيال إلكتروني',
      date: '10 يوليو 2024',
      image: AppAssets.newsImage3,
      category: 'جرائم إلكترونية',
      content:
          '''تمكنت الأجهزة الأمنية بوزارة الداخلية من كشف وضبط شبكة احتيال إلكتروني كبيرة كانت تستهدف المواطنين من خلال وسائل التواصل الاجتماعي والمواقع الإلكترونية المزيفة.
وأوضحت التحقيقات أن الشبكة كانت تعمل على خداع الضحايا من خلال عروض وهمية للاستثمار والتجارة الإلكترونية، مما أدى إلى سقوط عشرات الضحايا وخسائر مالية كبيرة.
وقد تم ضبط المتهمين الرئيسيين في الشبكة، بالإضافة إلى مصادرة الأجهزة والمعدات المستخدمة في العمليات الاحتيالية، وتجميد الحسابات البنكية المرتبطة بالنشاط الإجرامي.
وحذرت وزارة الداخلية المواطنين من التعامل مع العروض المشبوهة عبر الإنترنت، ونصحت بضرورة التأكد من مصداقية المواقع والشركات قبل التعامل معها.
كما أكدت الوزارة أن الأجهزة الأمنية تواصل جهودها لمكافحة الجرائم الإلكترونية بجميع أشكالها.''',
    ),
  ];

  void loadNews() {
    emit(NewsLoading());
    try {
      Future.delayed(const Duration(milliseconds: 500), () {
        emit(NewsLoaded(newsList: _mockNews));
      });
    } catch (e) {
      emit(const NewsError(message: 'حدث خطأ في تحميل الأخبار'));
      Future.delayed(
        const Duration(milliseconds: 500),
        () {
          emit(NewsLoaded(newsList: _mockNews));
        },
      );
    } catch (e) {
      emit(
        const NewsError(
          message: 'حدث خطأ في تحميل الأخبار',
        ),
      );
    }
  }

  void selectNews(String newsId) {
    final currentState = state;
    if (currentState is NewsLoaded) {
      final selectedNews = currentState.newsList.firstWhere(
        (news) => news.id == newsId,
        orElse: () => currentState.newsList.first,
      );
      emit(currentState.copyWith(selectedNews: selectedNews));

      final selectedNews = currentState.newsList
          .firstWhere(
            (news) => news.id == newsId,
            orElse:
                () => currentState.newsList.first,
          );
      emit(
        currentState.copyWith(
          selectedNews: selectedNews,
        ),
      );
    }
  }

  // البحث في الأخبار
  void searchNews(String query) {
    final currentState = state;
    if (currentState is NewsLoaded) {
      if (query.isEmpty) {
        emit(
          NewsLoaded(
            newsList: _mockNews,
            selectedNews: currentState.selectedNews,

            selectedNews:
                currentState.selectedNews,
          ),
        );
      } else {
        final filteredNews =
            _mockNews
                .where(
                  (news) =>
                      news.title.contains(query) ||
                      news.content.contains(query),
                      news.title.contains(
                        query,
                      ) ||
                      news.content.contains(
                        query,
                      ),
                )
                .toList();
        emit(
          NewsLoaded(
            newsList: filteredNews,
            selectedNews: currentState.selectedNews,
            selectedNews:
                currentState.selectedNews,
          ),
        );
      }
    }
  }

  // تصفية الأخبار بالتصنيف
  void filterByCategory(String category) {
    if (category.isEmpty) {
      emit(NewsLoaded(newsList: _mockNews));
    } else {
      final filteredNews =
          _mockNews.where((news) => news.category == category).toList();

          _mockNews
              .where(
                (news) =>
                    news.category == category,
              )
              .toList();
      emit(NewsLoaded(newsList: filteredNews));
    }
  }

  // الحصول على الأخبار للـ Carousel
  List<Map<String, String>> getCarouselData() {
    final currentState = state;
    if (currentState is NewsLoaded) {
      return currentState.newsList
          .map(
            (news) => {
              'id': news.id,
              'image': news.image,
              'title': news.title,
              'date': news.date,
            },
          )
          .toList();
    }
    return [];
  }

  // الحصول على خبر معين بالـ ID
  NewsModel? getNewsById(String id) {
    return _mockNews.firstWhere(
      (news) => news.id == id,
      orElse: () => _mockNews.first,
    );
  }

  // الحصول على الأخبار بتصنيف معين
  List<NewsModel> getNewsByCategory(String category) {
    return _mockNews.where((news) => news.category == category).toList();
  List<NewsModel> getNewsByCategory(
    String category,
  ) {
    return _mockNews
        .where(
          (news) => news.category == category,
        )
        .toList();
  }

  // الحصول على أحدث الأخبار
  List<NewsModel> getLatestNews({int limit = 3}) {
    final sortedNews = List<NewsModel>.from(_mockNews);
    final sortedNews = List<NewsModel>.from(
      _mockNews,
    );
    return sortedNews.take(limit).toList();
  }
}
