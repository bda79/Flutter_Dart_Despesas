import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import 'despesas_controller.dart';

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
        loading: () => const Center(child: CircularProgressIndicator()),

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
                trailing: Text("${d.valor} €"),
              );
            },
          );
        },
      ),
    );
  }
}
