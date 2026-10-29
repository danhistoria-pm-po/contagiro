import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/widgets/app_header.dart';
import '../../expenses/views/add_expense_page.dart';
import '../../expenses/views/history_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final supabase = Supabase.instance.client;
  
  bool _isLoading = true;
  double _totalMonthExpense = 0.0;
  double _averageKmPerLiter = 0.0;
  int _totalExpensesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('vehicle_expenses')
          .select()
          .eq('user_id', userId)
          .order('odometer', ascending: true);

      final List<Map<String, dynamic>> expenses = List<Map<String, dynamic>>.from(response);

      double totalExpense = 0.0;
      List<Map<String, dynamic>> refuels = [];

      for (var item in expenses) {
        final value = (item['value'] as num?)?.toDouble() ?? 0.0;
        totalExpense += value;

        if (item['expense_type'] == 'Abastecimento') {
          refuels.add(item);
        }
      }

      double totalKmDriven = 0;
      double totalLitersUsed = 0;

      if (refuels.length >= 2) {
        for (int i = 1; i < refuels.length; i++) {
          final prevOdometer = (refuels[i - 1]['odometer'] as num).toDouble();
          final currOdometer = (refuels[i]['odometer'] as num).toDouble();
          final liters = (refuels[i]['liters'] as num?)?.toDouble() ?? 0.0;

          if (liters > 0 && currOdometer > prevOdometer) {
            totalKmDriven += (currOdometer - prevOdometer);
            totalLitersUsed += liters;
          }
        }
      }

      double avgConsumption = 0.0;
      if (totalLitersUsed > 0) {
        avgConsumption = totalKmDriven / totalLitersUsed;
      }

      setState(() {
        _totalMonthExpense = totalExpense;
        _averageKmPerLiter = avgConsumption;
        _totalExpensesCount = expenses.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dashboard: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        actions: [
          TextButton.icon(
            onPressed: _loadDashboardData,
            icon: const Icon(Icons.dashboard, size: 18, color: Colors.blueAccent),
            label: const Text('Visão Geral', style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 4),
          TextButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddExpensePage()),
              );
              _loadDashboardData();
            },
            icon: const Icon(Icons.add_circle_outline, size: 18, color: Colors.green),
            label: const Text('Lançamentos', style: TextStyle(color: Colors.black87, fontSize: 13)),
          ),
          const SizedBox(width: 4),
          TextButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryPage()),
              );
              _loadDashboardData();
            },
            icon: const Icon(Icons.history, size: 20, color: Colors.orange),
            label: const Text('Histórico', style: TextStyle(color: Colors.black87, fontSize: 14)),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Atualizar dados',
            onPressed: _loadDashboardData,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.account_balance_wallet, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Gastos Totais Registrados', style: TextStyle(fontSize: 16, color: Colors.black54)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'R\$ ${_totalMonthExpense.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                            ),
                            const SizedBox(height: 4),
                            Text('Total de lançamentos: $_totalExpensesCount', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.speed, color: Colors.green),
                                SizedBox(width: 8),
                                Text('Média de Consumo', style: TextStyle(fontSize: 16, color: Colors.black54)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _averageKmPerLiter > 0 ? '${_averageKmPerLiter.toStringAsFixed(2)} KM/L' : 'Insuficiente',
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                            const SizedBox(height: 4),
                            const Text('Calculado com base nos abastecimentos', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddExpensePage()),
                        );
                        _loadDashboardData();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Novo Lançamento', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}