import 'package:flutter/material.dart';
import 'package:flutter_app/core/theme/app_theme.dart';
import 'package:flutter_app/core/ui/skeleton.dart';
import 'package:flutter_app/features/auth/auth_controller.dart';
import 'package:flutter_app/features/despesas/despesa_detail_screen.dart';
import 'package:flutter_app/features/despesas/despesas_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListaScreen extends ConsumerWidget {
  const ListaScreen({super.key});

  String _formatDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  }

  String _formatCurrency(double value) {
    return '€ ${value.toStringAsFixed(2)}';
  }

  Future<bool?> _confirmDelete(
    BuildContext context,
    String descricao,
    double valor,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: Text(
            'Tem a certeza que deseja apagar "$descricao" no valor de ${_formatCurrency(valor)}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Apagar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final despesas = ref.watch(despesasProvider);
    final notifier = ref.read(despesasProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Despesas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DespesaFormScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: notifier.refresh,
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
        error: (err, _) => Center(child: Text('Erro: $err')),
        data: (list) {
          if (list.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox, size: 72, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhuma despesa registada',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Comece a registar as suas despesas para ver o histórico aqui.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar Despesa'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DespesaFormScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }

          final totalSaidas = list.fold<double>(
            0,
            (sum, item) => item.tipo == 'saida' ? sum + item.valor : sum,
          );
          final totalEntradas = list.fold<double>(
            0,
            (sum, item) => item.tipo == 'entrada' ? sum + item.valor : sum,
          );
          final saldo = totalEntradas - totalSaidas;

          return RefreshIndicator(
            onRefresh: notifier.refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: 3 + list.length,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.pie_chart_outline, size: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Minhas Despesas',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontSize: 24),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Histórico e estatísticas das suas despesas.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }

                if (index == 1) {
                  return Column(
                    children: [
                      _StatCard(
                        label: 'Saldo Atual',
                        value: _formatCurrency(saldo),
                        color: saldo >= 0
                            ? AppColors.success
                            : AppColors.danger,
                        large: true,
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'Entradas',
                              value: _formatCurrency(totalEntradas),
                              color: AppColors.success,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: _StatCard(
                              label: 'Saídas',
                              value: _formatCurrency(totalSaidas),
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                if (index == 2) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Histórico de Despesas',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            FilledButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Nova'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DespesaFormScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                }

                final despesa = list[index - 3];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DespesaFormScreen(despesa: despesa),
                          ),
                        );
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: CircleAvatar(
                        backgroundColor:
                            (despesa.tipo == 'entrada'
                                    ? AppColors.success
                                    : AppColors.danger)
                                .withValues(alpha: 0.15),
                        child: Icon(
                          despesa.tipo == 'entrada'
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: despesa.tipo == 'entrada'
                              ? AppColors.success
                              : AppColors.danger,
                        ),
                      ),

                      title: Text(
                        despesa.categoria.isEmpty
                            ? 'Sem categoria'
                            : despesa.categoria,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),

                          Text(
                            _formatDate(despesa.data),
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            despesa.descricao.isEmpty
                                ? 'Sem descrição'
                                : despesa.descricao,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          DespesaFormScreen(despesa: despesa),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.edit_outlined,
                                        size: 18,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      const Text('Editar'),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 20),

                              InkWell(
                                onTap: () async {
                                  final confirmed = await _confirmDelete(
                                    context,
                                    despesa.descricao,
                                    despesa.valor,
                                  );

                                  if (!context.mounted) return;

                                  if (confirmed == true) {
                                    try {
                                      await notifier.deleteDespesa(despesa.id);

                                      if (!context.mounted) return;

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Despesa apagada'),
                                        ),
                                      );
                                    } catch (_) {
                                      if (!context.mounted) return;

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Erro ao apagar despesa',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Apagar',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              if (despesa.isPending) ...[
                                const SizedBox(width: 12),
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      trailing: Text(
                        _formatCurrency(despesa.valor),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool large;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(large ? 18 : 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: large
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            label,
            textAlign: large ? TextAlign.center : TextAlign.start,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.9),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            value,
            textAlign: large ? TextAlign.center : TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: large ? 22 : 18,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
