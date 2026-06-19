import 'package:flutter/material.dart';
import 'package:flutter_app/core/ui/app_feedback_service.dart';
import 'package:flutter_app/features/categorias/categorias_controller.dart';
import 'package:flutter_app/features/categorias/categorias_model.dart';
import 'package:flutter_app/features/despesas/despesas_controller.dart';
import 'package:flutter_app/features/despesas/despesas_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DespesaFormScreen extends ConsumerStatefulWidget {
  final Despesa? despesa;

  const DespesaFormScreen({super.key, this.despesa});

  @override
  ConsumerState<DespesaFormScreen> createState() => _DespesaFormScreenState();
}

class _DespesaFormScreenState extends ConsumerState<DespesaFormScreen> {
  final descricaoCtrl = TextEditingController();
  final valorCtrl = TextEditingController();

  String tipo = 'saida';
  DateTime? data;

  Categoria? categoriaSelecionada;
  String categoriaTexto = '';

  bool get isEdit => widget.despesa != null;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      final d = widget.despesa!;
      descricaoCtrl.text = d.descricao;
      valorCtrl.text = d.valor.toString();
      tipo = d.tipo;
      data = d.data;
      categoriaTexto = d.categoria;
    }

    Future.microtask(() {
      ref.read(categoriasProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    descricaoCtrl.dispose();
    valorCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      final nomeCategoria = categoriaSelecionada?.nome ?? categoriaTexto;

      if (nomeCategoria.isEmpty) {
        AppFeedbackService.showError('Categoria obrigatória');
        return;
      }

      final cat = await ref
          .read(categoriasProvider.notifier)
          .getOrCreateCategoria(nomeCategoria);

      final payload = {
        'descricao': descricaoCtrl.text,
        'valor': double.tryParse(valorCtrl.text.replaceAll(',', '.')) ?? 0,
        'categoria': cat.id,
        'tipo': tipo,
        'data': (data ?? DateTime.now()).toIso8601String().split('T')[0],
      };

      final notifier = ref.read(despesasProvider.notifier);

      if (isEdit) {
        await notifier.updateDespesa(widget.despesa!.id, payload);
        AppFeedbackService.showSuccess('Despesa atualizada');
      } else {
        await notifier.addDespesa(
          descricao: descricaoCtrl.text,
          valor: double.parse(valorCtrl.text),
          categoriaNome: cat.nome,
          categoriaId: cat.id,
          tipo: tipo,
          data: data ?? DateTime.now(),
        );
        AppFeedbackService.showSuccess('Despesa criada');
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      AppFeedbackService.showError('Erro ao guardar despesa');
    }
  }

  Future<void> _delete() async {
    if (!isEdit) return;

    try {
      await ref
          .read(despesasProvider.notifier)
          .deleteDespesa(widget.despesa!.id);

      AppFeedbackService.showSuccess('Despesa removida');

      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      AppFeedbackService.showError('Erro ao apagar despesa');
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriasAsync = ref.watch(categoriasProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Despesa' : 'Nova Despesa'),
        actions: [
          if (isEdit)
            IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            child: Column(
              children: [
                DropdownButton<String>(
                  value: tipo,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'entrada', child: Text('Entrada')),
                    DropdownMenuItem(value: 'saida', child: Text('Saída')),
                  ],
                  onChanged: (v) => setState(() => tipo = v!),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          _SectionCard(
            child: categoriasAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (_, _) => TextField(
                decoration: const InputDecoration(labelText: 'Categoria'),
                onChanged: (v) => categoriaTexto = v,
              ),
              data: (list) => Autocomplete<Categoria>(
                optionsBuilder: (text) {
                  if (text.text.isEmpty) return const Iterable.empty();
                  return list.where(
                    (c) =>
                        c.nome.toLowerCase().contains(text.text.toLowerCase()),
                  );
                },
                displayStringForOption: (c) => c.nome,
                onSelected: (c) => setState(() => categoriaSelecionada = c),
                fieldViewBuilder: (context, ctrl, focus, _) {
                  ctrl.text = categoriaTexto;

                  return TextField(
                    controller: ctrl,
                    focusNode: focus,
                    decoration: const InputDecoration(labelText: 'Categoria'),
                    onChanged: (v) {
                      categoriaTexto = v;
                      categoriaSelecionada = null;
                    },
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          _SectionCard(
            child: TextField(
              controller: valorCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Valor'),
            ),
          ),

          const SizedBox(height: 12),

          _SectionCard(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    initialDate: data ?? DateTime.now(),
                  );

                  if (picked != null) {
                    setState(() => data = picked);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          data == null
                              ? 'Escolher data'
                              : data!.toIso8601String().split('T')[0],
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          _SectionCard(
            child: TextField(
              controller: descricaoCtrl,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              child: Text(isEdit ? 'Atualizar' : 'Guardar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: child,
    );
  }
}
