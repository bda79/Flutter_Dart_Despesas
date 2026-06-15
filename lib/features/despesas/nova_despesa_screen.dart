import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../categorias/categorias_controller.dart';
import '../categorias/categorias_model.dart';
import 'despesas_controller.dart';

class NovaDespesaScreen extends ConsumerStatefulWidget {
  const NovaDespesaScreen({super.key});

  @override
  ConsumerState<NovaDespesaScreen> createState() => _NovaDespesaScreenState();
}

class _NovaDespesaScreenState extends ConsumerState<NovaDespesaScreen> {
  final descricaoCtrl = TextEditingController();
  final valorCtrl = TextEditingController();

  String tipo = "saida";
  DateTime? data;

  Categoria? categoriaSelecionada;
  String categoriaTexto = "";

  @override
  void dispose() {
    descricaoCtrl.dispose();
    valorCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarDespesa() async {
    try {
      final nomeCategoria = categoriaSelecionada?.nome ?? categoriaTexto;

      if (nomeCategoria.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Escolhe ou escreve uma categoria")),
        );
        return;
      }

      final categoriasController = ref.read(categoriasProvider.notifier);

      final categoria = await categoriasController.getOrCreateCategoria(
        nomeCategoria,
      );

      await ref
          .read(despesasProvider.notifier)
          .addDespesa(
            descricao: descricaoCtrl.text,
            valor: double.parse(valorCtrl.text),
            categoriaNome: categoria.nome,
            categoriaId: categoria.id,
            tipo: tipo,
            data: data ?? DateTime.now(),
          );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Erro ao guardar despesa")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriasAsync = ref.watch(categoriasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Nova Despesa")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // TIPO
            DropdownButton<String>(
              value: tipo,
              items: const [
                DropdownMenuItem(value: "entrada", child: Text("Entrada")),
                DropdownMenuItem(value: "saida", child: Text("Saída")),
              ],
              onChanged: (v) => setState(() => tipo = v!),
            ),

            const SizedBox(height: 10),

            // CATEGORIA
            categoriasAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => TextField(
                decoration: const InputDecoration(labelText: "Categoria"),
                onChanged: (v) => categoriaTexto = v,
              ),
              data: (list) {
                return Autocomplete<Categoria>(
                  optionsBuilder: (textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<Categoria>.empty();
                    }

                    return list.where(
                      (c) => c.nome.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      ),
                    );
                  },
                  displayStringForOption: (c) => c.nome,
                  onSelected: (c) {
                    setState(() {
                      categoriaSelecionada = c;
                    });
                  },
                  fieldViewBuilder: (context, controller, focusNode, _) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(labelText: "Categoria"),
                      onChanged: (v) {
                        categoriaTexto = v;
                        categoriaSelecionada = null;
                      },
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 10),

            // VALOR
            TextField(
              controller: valorCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Valor"),
            ),

            const SizedBox(height: 10),

            // DATA
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  initialDate: DateTime.now(),
                );

                if (picked != null) {
                  setState(() => data = picked);
                }
              },
              child: Text(
                data == null
                    ? "Escolher data"
                    : data.toString().split(" ").first,
              ),
            ),

            const SizedBox(height: 10),

            // DESCRIÇÃO
            TextField(
              controller: descricaoCtrl,
              decoration: const InputDecoration(labelText: "Descrição"),
            ),

            const Spacer(),

            // BOTÃO
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardarDespesa,
                child: const Text("Guardar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
