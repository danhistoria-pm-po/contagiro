import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/widgets/app_header.dart';
import '../../dashboard/views/dashboard_page.dart';
import 'add_expense_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _expenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('vehicle_expenses')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        _expenses = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar histórico: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteExpense(String id) async {
    try {
      await supabase.from('vehicle_expenses').delete().eq('id', id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lançamento excluído com sucesso!'), backgroundColor: Colors.orange),
      );
      _fetchExpenses();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DashboardPage()),
              );
            },
            icon: const Icon(Icons.dashboard, size: 18, color: Colors.blueAccent),
            label: const Text('Visão Geral', style: TextStyle(color: Colors.black87, fontSize: 13)),
          ),
          const SizedBox(width: 4),
          TextButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AddExpensePage()),
              );
            },
            icon: const Icon(Icons.add_circle_outline, size: 18, color: Colors.green),
            label: const Text('Lançamentos', style: TextStyle(color: Colors.black87, fontSize: 13)),
          ),
          const SizedBox(width: 4),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.history, size: 20, color: Colors.orange),
            label: const Text('Histórico', style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Atualizar',
            onPressed: _fetchExpenses,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _expenses.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum lançamento registrado ainda.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _expenses.length,
                  itemBuilder: (context, index) {
                    final item = _expenses[index];
                    final type = item['expense_type'] ?? 'Outros';
                    final date = item['date'] ?? '';
                    final value = item['value'] ?? 0.0;
                    final odometer = item['odometer'] ?? 0;
                    final liters = item['liters'];
                    final observation = item['observation'];

                    IconData iconData = Icons.receipt;
                    Color iconColor = Colors.blue;

                    if (type == 'Abastecimento') {
                      iconData = Icons.local_gas_station;
                      iconColor = Colors.green;
                    } else if (type == 'Manutenção') {
                      iconData = Icons.build;
                      iconColor = Colors.orange;
                    }

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: iconColor.withOpacity(0.1),
                          child: Icon(iconData, color: iconColor),
                        ),
                        title: Text(
                          '$type - R\$ ${value.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Data: $date | KM: $odometer ${liters != null ? '| ${liters}L' : ''}'),
                            if (observation != null && observation.toString().isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Obs: $observation',
                                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87),
                              ),
                            ],
                          ],
                        ),
                        isThreeLine: observation != null && observation.toString().isNotEmpty,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteExpense(item['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}