import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/politician.dart';
import '../services/api_service.dart';
import 'politician_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Politician>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = ApiService().fetchPoliticians();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('国会議員 活動モニター'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '更新',
            onPressed: _load,
          ),
        ],
      ),
      body: FutureBuilder<List<Politician>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorView(error: snapshot.error.toString(), onRetry: _load);
          }

          final politicians = snapshot.data!;
          if (politicians.isEmpty) {
            return const Center(child: Text('データがありません'));
          }

          return ListView.separated(
            itemCount: politicians.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              return _PoliticianTile(
                politician: politicians[index],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PoliticianDetailScreen(
                      politician: politicians[index],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ── 議員リストタイル ─────────────────────────────────────

class _PoliticianTile extends StatelessWidget {
  final Politician politician;
  final VoidCallback onTap;

  const _PoliticianTile({required this.politician, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('M月d日 HH:mm', 'ja_JP');

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _Avatar(politician: politician),
      title: Row(
        children: [
          Text(
            politician.name,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 6),
          _Chip(
            label: politician.chamber,
            color: politician.chamber == '衆院'
                ? Colors.blue
                : Colors.green,
          ),
          const SizedBox(width: 4),
          _Chip(label: politician.party, color: Colors.grey),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (politician.constituency != null) ...[
            const SizedBox(height: 2),
            Text(
              politician.constituency!,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
          const SizedBox(height: 4),
          if (politician.latestActivityDescription != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ActivityTypeIcon(
                    type: politician.latestActivityType ?? 'other'),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    politician.latestActivityDescription!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            if (politician.latestActivityAt != null) ...[
              const SizedBox(height: 2),
              Text(
                dateFormat
                    .format(politician.latestActivityAt!.toLocal()),
                style:
                    TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ] else
            Text(
              '活動記録なし',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}

// ── アバター ────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final Politician politician;
  const _Avatar({required this.politician});

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
    final color = _partyColors[politician.party] ?? Colors.grey;
    return CircleAvatar(
      backgroundColor: color,
      child: Text(
        politician.name.substring(0, 1),
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ── バッジ ──────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 10,
            color: color.withOpacity(0.9),
            fontWeight: FontWeight.w500),
      ),
    );
  }
}

// ── 活動タイプアイコン ──────────────────────────────────

class _ActivityTypeIcon extends StatelessWidget {
  final String type;
  const _ActivityTypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      'speech'    => (Icons.record_voice_over, Colors.blue),
      'sns'       => (Icons.share, Colors.lightBlue),
      'committee' => (Icons.groups, Colors.orange),
      'vote'      => (Icons.how_to_vote, Colors.purple),
      _           => (Icons.info_outline, Colors.grey),
    };
    return Icon(icon, size: 14, color: color);
  }
}

// ── エラー表示 ──────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'データの取得に失敗しました',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style:
                  const TextStyle(color: Colors.red, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }
}
