import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/politician.dart';
import '../models/activity.dart';
import '../services/api_service.dart';

class PoliticianDetailScreen extends StatefulWidget {
  final Politician politician;
  const PoliticianDetailScreen({super.key, required this.politician});

  @override
  State<PoliticianDetailScreen> createState() =>
      _PoliticianDetailScreenState();
}

class _PoliticianDetailScreenState extends State<PoliticianDetailScreen> {
  late Future<PoliticianDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService().fetchPoliticianDetail(widget.politician.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.politician.name),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<PoliticianDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                '読み込みエラー: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final detail = snapshot.data!;

          return CustomScrollView(
            slivers: [
              // プロフィールヘッダー
              SliverToBoxAdapter(
                child: _ProfileHeader(detail: detail),
              ),
              // 活動件数ラベル
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    '活動記録 （${detail.totalCount}件）',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // 活動リスト
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _ActivityCard(activity: detail.activities[index]),
                  childCount: detail.activities.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }
}

// ── プロフィールヘッダー ────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final PoliticianDetail detail;
  const _ProfileHeader({required this.detail});

  static const _partyColors = <String, Color>{
    '自民党':        Color(0xFFCC0000),
    '立憲民主党':    Color(0xFF004B9A),
    '公明党':        Color(0xFF009B48),
    '日本維新の会':  Color(0xFFE85E18),
    '国民民主党':    Color(0xFF00A0D2),
    '共産党':        Color(0xFFAA0000),
    'れいわ新選組':  Color(0xFFE0007B),
  };

  @override
  Widget build(BuildContext context) {
    final color = _partyColors[detail.party] ?? Colors.grey;
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: color,
            child: Text(
              detail.name.substring(0, 1),
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  detail.nameKana,
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _InfoChip(label: detail.party),
                    _InfoChip(label: detail.chamber),
                    if (detail.constituency != null)
                      _InfoChip(label: detail.constituency!),
                  ],
                ),
                if (detail.twitterHandle != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.alternate_email,
                          size: 14, color: Colors.lightBlue),
                      const SizedBox(width: 4),
                      Text(
                        '@${detail.twitterHandle}',
                        style: const TextStyle(
                            color: Colors.lightBlue, fontSize: 13),
                      ),
                    ],
                  ),
                ],
                if (detail.homepageUrl != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.language,
                          size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          detail.homepageUrl!,
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}

// ── 活動カード ──────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  final Activity activity;
  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy年M月d日 HH:mm', 'ja_JP');
    final (icon, color, label) = _typeInfo(activity.activityType);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タイプアイコン
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // タイプラベル + 日時
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        dateFormat
                            .format(activity.occurredAt.toLocal()),
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // 活動内容
                  Text(
                    activity.description,
                    style:
                        const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static (IconData, Color, String) _typeInfo(String type) {
    return switch (type) {
      'speech'    => (Icons.record_voice_over, Colors.blue,   '本会議・発言'),
      'sns'       => (Icons.share,             Colors.lightBlue, 'SNS'),
      'committee' => (Icons.groups,            Colors.orange, '委員会'),
      'vote'      => (Icons.how_to_vote,       Colors.purple, '投票'),
      _           => (Icons.info_outline,      Colors.grey,   'その他'),
    };
  }
}
