import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/theme.dart';
import 'package:frontend/models/wallet.dart';
import 'package:frontend/services/api_client.dart';

class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({super.key});

  @override
  ConsumerState<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage> {
  Wallet? _wallet;
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;

  static const _rechargePlans = [
    {'amount': 6, 'coins': 60},
    {'amount': 30, 'coins': 300},
    {'amount': 68, 'coins': 680},
    {'amount': 128, 'coins': 1280},
    {'amount': 328, 'coins': 3280},
    {'amount': 648, 'coins': 6480},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final api = ref.read(apiClientProvider);

      // Load wallet data
      final walletResp = await api.get('/api/v1/wallet');
      final wallet = Wallet.fromJson(walletResp.data['data']);

      // Load order history
      List<Map<String, dynamic>> orders = [];
      try {
        final ordersResp = await api.get('/api/v1/recharge/orders');
        orders = (ordersResp.data['data'] as List?)
                ?.cast<Map<String, dynamic>>() ??
            [];
      } catch (_) {
        // Orders endpoint may not exist yet
      }

      if (!mounted) return;
      setState(() {
        _wallet = wallet;
        _orders = orders;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载失败: $e')),
      );
    }
  }

  Future<void> _recharge(int amount, int coins) async {
    try {
      final api = ref.read(apiClientProvider);
      await api.post('/api/v1/recharge/mock', data: {
        'amount': amount,
        'coins': coins,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('充值$amount元成功! 获得$coins金币')),
      );
      _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('充值失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          '我的钱包',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance card
                  _BalanceCard(wallet: _wallet),
                  const SizedBox(height: 24),

                  // Recharge plans
                  const Text(
                    '充值选择',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._rechargePlans.map((plan) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _RechargePlanTile(
                        amount: plan['amount'] as int,
                        coins: plan['coins'] as int,
                        onTap: () =>
                            _recharge(plan['amount']!, plan['coins']!),
                      ),
                    );
                  }),

                  // Order history
                  if (_orders.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      '充值记录',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._orders.map((order) {
                      return Card(
                        color: AppTheme.card,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(
                            Icons.payment,
                            color: AppTheme.gold,
                          ),
                          title: Text(
                            '${order['amount'] ?? 0}元',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            order['createdAt'] ?? '',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Text(
                            '+${order['coins'] ?? 0}金币',
                            style: const TextStyle(
                              color: AppTheme.gold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final Wallet? wallet;

  const _BalanceCard({this.wallet});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              '当前余额',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on,
                    size: 32, color: AppTheme.gold),
                const SizedBox(width: 8),
                Text(
                  '${wallet?.balance ?? 0}',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '金币',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SummaryItem(
                  label: '累计充值',
                  value: '${wallet?.totalRecharged ?? 0}',
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: AppTheme.background,
                ),
                _SummaryItem(
                  label: '累计消费',
                  value: '${wallet?.totalSpent ?? 0}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _RechargePlanTile extends StatelessWidget {
  final int amount;
  final int coins;
  final VoidCallback onTap;

  const _RechargePlanTile({
    required this.amount,
    required this.coins,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        title: Text(
          '$amount元',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          '获得 $coins 金币',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        trailing: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.gold,
            foregroundColor: Colors.black,
            minimumSize: const Size(80, 36),
          ),
          child: const Text('充值', style: TextStyle(fontSize: 13)),
        ),
      ),
    );
  }
}
