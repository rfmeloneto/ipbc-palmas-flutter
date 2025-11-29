import 'dart:convert';
import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;
import 'package:core_module/core_module.dart' as http;
import '../../../layout/top_bar/top_bar_widget.dart';

class DeaconCharityView extends StatefulWidget {
  const DeaconCharityView({super.key});

  @override
  State<DeaconCharityView> createState() => _DeaconCharityViewState();
}

class _DeaconCharityViewState extends State<DeaconCharityView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();
  final TextEditingController observacoesController = TextEditingController();
  final TextEditingController horarioVisitaController = TextEditingController();
  final TextEditingController diaVisitaController = TextEditingController();
  final TextEditingController motivoOracaoController = TextEditingController();

  bool isMembro = false;
  bool precisaCesta = false;
  bool precisaVisita = false;
  bool precisaOracao = false;
  bool loading = false;

  Future<void> enviarFormulario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final emailBody = '''
Novo pedido para a diaconia:

Nome: ${nomeController.text}
Telefone: ${telefoneController.text}
Endereço: ${enderecoController.text}
Membro da igreja: ${isMembro ? "Sim" : "Não"}

Pedidos:
- Cesta básica: ${precisaCesta ? "Sim" : "Não"}
- Visita: ${precisaVisita ? "Sim" : "Não"}
  Horário preferido: ${horarioVisitaController.text}
  Melhor dia: ${diaVisitaController.text}
- Oração: ${precisaOracao ? "Sim" : "Não"}
  Motivo da oração: ${motivoOracaoController.text}

Observações:
${observacoesController.text}
''';

    const sendGridApiKey = 'SUA_CHAVE_SENDGRID_AQUI';
    const emailDestino = 'rfmeloneto@gmail.com';
    final url = Uri.parse('https://api.sendgrid.com/v3/mail/send');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $sendGridApiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'personalizations': [
          {
            'to': [{'email': emailDestino}],
            'subject': 'Novo Pedido para a Diaconia'
          }
        ],
        'from': {'email': 'no-reply@suaigreja.com'},
        'content': [
          {'type': 'text/plain', 'value': emailBody}
        ]
      }),
    );

    setState(() => loading = false);

    if (response.statusCode == 202) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Formulário enviado com sucesso!')),
      );
      _formKey.currentState!.reset();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar: ${response.body}')),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon) : null,
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
               const TopBarWidget(),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              
                      const SizedBox(height: 20),
              
                      // Card de introdução
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "🌿 Sobre o serviço da Diaconia",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                "A diaconia é um ministério de amor, cuidado e serviço. "
                                "Nosso propósito é atender as necessidades espirituais e materiais "
                                "dos irmãos e da comunidade, sempre com discrição, responsabilidade "
                                "e sigilo. Cada pedido é tratado com seriedade e respeito, buscando "
                                "honrar a Cristo através do serviço ao próximo.",
                                style: TextStyle(fontSize: 16, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ),
              
                      const SizedBox(height: 28),
              
                      // Formulário
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final isWide = constraints.maxWidth > 600;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "📝 Formulário de Pedido de Auxílio",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
              
                                    Wrap(
                                      runSpacing: 16,
                                      spacing: 16,
                                      children: [
                                        SizedBox(
                                          width: isWide ? (constraints.maxWidth / 2) - 24 : double.infinity,
                                          child: _buildTextField(
                                            controller: nomeController,
                                            label: "Nome completo",
                                            icon: Icons.person,
                                            validator: (v) => v!.isEmpty ? "Informe seu nome" : null,
                                          ),
                                        ),
                                        SizedBox(
                                          width: isWide ? (constraints.maxWidth / 2) - 24 : double.infinity,
                                          child: _buildTextField(
                                            controller: telefoneController,
                                            label: "Telefone",
                                            icon: Icons.phone,
                                            validator: (v) => v!.isEmpty ? "Informe seu telefone" : null,
                                          ),
                                        ),
                                        _buildTextField(
                                          controller: enderecoController,
                                          label: "Endereço",
                                          icon: Icons.home,
                                        ),
                                      ],
                                    ),
              
                                    const SizedBox(height: 16),
                                    SwitchListTile(
                                      title: const Text("Sou membro da igreja"),
                                      value: isMembro,
                                      onChanged: (v) => setState(() => isMembro = v),
                                    ),
                                    const Divider(height: 32),
              
                                    const Text(
                                      "💒 Tipos de Auxílio",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
              
                                    CheckboxListTile(
                                      title: const Text("Preciso de cesta básica"),
                                      value: precisaCesta,
                                      onChanged: (v) => setState(() => precisaCesta = v!),
                                    ),
                                    CheckboxListTile(
                                      title: const Text("Preciso de visita"),
                                      value: precisaVisita,
                                      onChanged: (v) => setState(() => precisaVisita = v!),
                                    ),
              
                                    if (precisaVisita)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 16),
                                        child: Column(
                                          children: [
                                            _buildTextField(
                                              controller: diaVisitaController,
                                              label: "Melhor dia para visita",
                                              icon: Icons.calendar_today,
                                            ),
                                            const SizedBox(height: 12),
                                            _buildTextField(
                                              controller: horarioVisitaController,
                                              label: "Melhor horário para visita",
                                              icon: Icons.access_time,
                                            ),
                                          ],
                                        ),
                                      ),
              
                                    CheckboxListTile(
                                      title: const Text("Preciso de oração"),
                                      value: precisaOracao,
                                      onChanged: (v) => setState(() => precisaOracao = v!),
                                    ),
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 300),
                                      child: precisaOracao
                                          ? Padding(
                                              key: const ValueKey('campoOracao'),
                                              padding: const EdgeInsets.only(left: 16),
                                              child: _buildTextField(
                                                controller: motivoOracaoController,
                                                label: "Motivo da oração",
                                                icon: Icons.favorite,
                                                validator: (v) {
                                                  if (precisaOracao && (v == null || v.isEmpty)) {
                                                    return "Por favor, informe o motivo da oração";
                                                  }
                                                  return null;
                                                },
                                              ),
                                            )
                                          : const SizedBox.shrink(key: ValueKey('semCampoOracao')),
                                    ),
              
              
                                    const SizedBox(height: 20),
                                    _buildTextField(
                                      controller: observacoesController,
                                      label: "Observações adicionais",
                                      icon: Icons.notes,
                                      maxLines: 3,
                                    ),
              
                                    const SizedBox(height: 30),
                                    Center(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 32, vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: loading ? null : enviarFormulario,
                                        icon: loading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              )
                                            : const Icon(Icons.send),
                                        label: const Text(
                                          "Enviar Pedido",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
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
