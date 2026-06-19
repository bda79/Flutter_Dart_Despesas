import 'package:flutter/material.dart';
import 'package:flutter_app/core/ui/skeleton.dart';
import 'package:flutter_app/features/auth/auth_controller.dart';
import 'package:flutter_app/features/despesas/despesas_controller.dart';
import 'package:flutter_app/features/despesas/nova_despesa_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListaScreen extends ConsumerWidget {
  const ListaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final despesas = ref.watch(despesasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Minhas Despesas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NovaDespesaScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(despesasProvider.notifier).refresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: despesas.when(
        loading: () => ListView.builder(
          itemCount: 6,
          itemBuilder: (_, _) => const ListTile(
            title: SkeletonBox(),
            subtitle: SkeletonBox(width: 120),
          ),
        ),

        error: (err, _) => Center(child: Text("Erro: $err")),

        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text("Sem despesas"));
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final d = list[index];

              return ListTile(
                title: Text(d.descricao),
                subtitle: Text(d.categoria),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("${d.valor} €"),

                    if (d.isPending) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
