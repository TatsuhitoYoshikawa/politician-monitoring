import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/politician.dart';
import '../models/activity.dart';

class ApiService {
  // Docker Compose: Flutter は ブラウザ経由で localhost:3000 の Rails へアクセス
  // Phase 3 (AWS): CloudFront/ALB の URL に差し替える
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  /// 議員一覧を取得する
  /// [chamber]: "衆院" or "参院" でフィルタ（省略可）
  /// [party]: 政党名でフィルタ（省略可）
  /// [q]: 名前・かな検索（省略可）
  Future<List<Politician>> fetchPoliticians({
    String? chamber,
    String? party,
    String? q,
  }) async {
    final queryParams = <String, String>{};
    if (chamber != null) queryParams['chamber'] = chamber;
    if (party != null)   queryParams['party']   = party;
    if (q != null)       queryParams['q']        = q;

    final uri = Uri.parse('$_baseUrl/politicians')
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await _client.get(uri);
    _checkResponse(response);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['data'] as List<dynamic>)
        .map((p) => Politician.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  /// 議員詳細（プロフィール + 活動履歴）を取得する
  Future<PoliticianDetail> fetchPoliticianDetail(int id, {int page = 1}) async {
    final uri = Uri.parse('$_baseUrl/politicians/$id')
        .replace(queryParameters: {'page': '$page', 'per_page': '20'});

    final response = await _client.get(uri);
    _checkResponse(response);

    return PoliticianDetail.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'API error ${response.statusCode}: ${response.body}',
      );
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => message;
}
