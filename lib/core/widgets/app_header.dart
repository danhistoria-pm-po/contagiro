import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? pageTitle; // Título opcional da página (Visão Geral, Novo Lançamento, Histórico)
  final List<Widget>? actions;

  const AppHeader({
    super.key,
    this.pageTitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- LOGOTIPO DO CONTAGIRO ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1E88E5).withOpacity(0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.speed,
                  size: 20,
                  color: Color(0xFF1E88E5),
                ),
                SizedBox(width: 6),
                Text(
                  'ContaGiro',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E88E5),
                  ),
                ),
              ],
            ),
          ),

          // Se houver título da página, exibe um divisor discreto e o título ao lado da logo
          if (pageTitle != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('|', style: TextStyle(color: Colors.grey, fontSize: 16)),
            ),
            Text(
              pageTitle!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ],
      ),
      centerTitle: false, // Mantém alinhado à esquerda/espaço inicial após o botão de voltar
      actions: actions ?? const [],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}