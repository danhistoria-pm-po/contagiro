import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/widgets/app_header.dart';
import '../../dashboard/views/dashboard_page.dart';
import 'history_page.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();

  final _dateController = TextEditingController();
  final _odometerController = TextEditingController();
  final _valueController = TextEditingController();
  final _litersController = TextEditingController();
  final _observationController = TextEditingController();

  String _selectedExpenseType = 'Abastecimento';
  final List<String> _expenseTypes = ['Abastecimento', 'Manutenção', 'Outros'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateController.text = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
  }

  @override
  void dispose() {
    _dateController.dispose();
    _odometerController.dispose();
    _valueController.dispose();
    _litersController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userId = Supabase.instance.client.auth.currentUser!.id;

        await Supabase.instance.client.from('vehicle_expenses').insert({
          'user_id': userId,
          'date': _dateController.text,
          'expense_type': _selectedExpenseType,
          'odometer': int.parse(_odometerController.text),
          'value': double.parse(_valueController.text.replaceAll(',', '.')),
          'liters': _selectedExpenseType == 'Abastecimento' && _litersController.text.isNotEmpty
              ? double.parse(_litersController.text.replaceAll(',', '.'))
              : null,
          'observation': _observationController.text.isNotEmpty ? _observationController.text : null,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lançamento salvo com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        _odometerController.clear();
        _valueController.clear();
        _litersController.clear();
        _observationController.clear();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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
            onPressed: () {},
            icon: const Icon(Icons.add_circle_outline, size: 18, color: Colors.green),
            label: const Text('Lançamentos', style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 4),
          TextButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HistoryPage()),
              );
            },
            icon: const Icon(Icons.history, size: 20, color: Colors.orange),
            label: const Text('Histórico', style: TextStyle(color: Colors.black87, fontSize: 14)),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Data da Despesa',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Informe a data' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedExpenseType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Despesa',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _expenseTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedExpenseType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _odometerController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Quilometragem Atual (KM)',
                  prefixIcon: Icon(Icons.speed),
                  hintText: 'Ex: 45200',
                ),
                validator: (value) => value == null || value.isEmpty ? 'Informe a quilometragem' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valueController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Valor Total (R\$)',
                  prefixIcon: Icon(Icons.attach_money),
                  hintText: 'Ex: 150.50',
                ),
                validator: (value) => value == null || value.isEmpty ? 'Informe o valor pago' : null,
              ),
              const SizedBox(height: 16),
              if (_selectedExpenseType == 'Abastecimento') ...[
                TextFormField(
                  controller: _litersController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Quantidade de Litros',
                    prefixIcon: Icon(Icons.local_gas_station),
                    hintText: 'Ex: 32.5',
                  ),
                  validator: (value) => (_selectedExpenseType == 'Abastecimento' && (value == null || value.isEmpty))
                      ? 'Informe os litros'
                      : null,
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _observationController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: _selectedExpenseType == 'Manutenção'
                      ? 'O que foi feito? (Ex: Troca de óleo, pastilhas...)'
                      : _selectedExpenseType == 'Outros'
                          ? 'Descrição do gasto (Ex: Estacionamento, pedágio...)'
                          : 'Observação (Opcional)',
                  prefixIcon: const Icon(Icons.note),
                  hintText: 'Detalhes adicionais...',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.check),
                label: const Text('Salvar Lançamento', style: TextStyle(fontSize: 16)),
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