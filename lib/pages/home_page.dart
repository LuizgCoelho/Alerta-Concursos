import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../widgets/filter_dropdown.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  
  final ValueNotifier<String?> _areaSelecionada = ValueNotifier(null);
  final ValueNotifier<String?> _estadoSelecionado = ValueNotifier(null);
  final ValueNotifier<String?> _escolaridadeSelecionada = ValueNotifier(null);
  
  bool _aceitaNotificacoes = false;

  final List<String> _areas = ['Geral', 'Tecnologia da Informação', 'Fiscal', 'Tribunais', 'Policial', 'Administrativa', 'Saúde', 'Educação'];
  final List<String> _escolaridades = ['Nível Médio', 'Nível Técnico', 'Nível Superior'];
  
  List<String> _estados = ['Geral'];
  bool _carregandoEstados = true;

  @override
  void initState() {
    super.initState();
    _buscarEstadosIBGE();
  }

  @override
  void dispose() {
    _areaSelecionada.dispose();
    _estadoSelecionado.dispose();
    _escolaridadeSelecionada.dispose();
    super.dispose();
  }

  Future<void> _buscarEstadosIBGE() async {
    try {
      final response = await http.get(Uri.parse('https://servicodados.ibge.gov.br/api/v1/localidades/estados'));
      if (response.statusCode == 200) {
        final List<dynamic> dados = json.decode(response.body);
        List<String> ufs = dados.map((e) => e['sigla'].toString()).toList();
        ufs.sort();
        
        if (mounted) {
          setState(() {
            _estados.addAll(ufs);
            _carregandoEstados = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _estados.addAll(['AC', 'AL', 'AM', 'AP', 'BA', 'CE', 'DF', 'ES', 'GO', 'MG', 'MS', 'MT', 'PA', 'PB', 'PE', 'PI', 'PR', 'RJ', 'RN', 'RO', 'RR', 'RS', 'SC', 'SE', 'SP', 'TO']);
          _carregandoEstados = false;
        });
      }
    }
  }

  // Função que compacta as escolhas para colocar na URL do Telegram
  String _gerarPayloadTelegram(String area, String estado, String escolaridade) {
    // Junta tudo com um separador
    final rawString = '$area|$estado|$escolaridade';
    // Converte para Base64 (URL Safe) e remove os símbolos '=' do final (exigência do Telegram)
    final encoded = base64Url.encode(utf8.encode(rawString)).replaceAll('=', '');
    return encoded;
  }

  Future<void> _ativarAlertasTelegram() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_aceitaNotificacoes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Precisa de autorizar os termos antes de prosseguir.'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 1. Gera o código com as preferências
    final payload = _gerarPayloadTelegram(
      _areaSelecionada.value!, 
      _estadoSelecionado.value!, 
      _escolaridadeSelecionada.value!
    );

    // 2. Monta o Link do Bot do Telegram (Vamos criar este bot no próximo passo)
    const String usernameDoBot = 'AlertasConcursosIA_bot'; // Substituiremos em breve
    final Uri telegramUrl = Uri.parse('https://t.me/$usernameDoBot?start=$payload');

    // 3. Abre o Telegram no dispositivo do utilizador
    if (await canLaunchUrl(telegramUrl)) {
      await launchUrl(telegramUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o Telegram. Verifique se o tem instalado.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 550,
              margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome, size: 16, color: Color(0xFF2563EB)),
                              SizedBox(width: 6),
                              Text(
                                'POWERED BY IA',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2563EB),
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      const Text(
                        'Radar de Concursos',
                        style: TextStyle(
                          fontSize: 32, 
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Configure os seus filtros abaixo. Será redirecionado para o nosso Bot oficial no Telegram para concluir a ativação dos alertas automáticos.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF64748B), 
                          fontSize: 15, 
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),

                      FilterDropdown(
                        label: 'Escolaridade Exigida',
                        valueNotifier: _escolaridadeSelecionada,
                        items: _escolaridades,
                        icon: Icons.school_rounded,
                      ),
                      const SizedBox(height: 20),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: FilterDropdown(
                              label: 'Área de Interesse',
                              valueNotifier: _areaSelecionada,
                              items: _areas,
                              icon: Icons.work_rounded,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: _carregandoEstados
                                ? Container(
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 24, 
                                        height: 24, 
                                        child: CircularProgressIndicator(strokeWidth: 2)
                                      )
                                    ),
                                  )
                                : FilterDropdown(
                                    label: 'Estado',
                                    valueNotifier: _estadoSelecionado,
                                    items: _estados,
                                    icon: Icons.map_rounded,
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      Container(
                        decoration: BoxDecoration(
                          color: _aceitaNotificacoes ? const Color(0xFFEFF6FF) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _aceitaNotificacoes ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0)
                          ),
                        ),
                        child: CheckboxListTile(
                          title: const Text(
                            'Autorizo o registo do meu ID do Telegram para receber alertas automáticos de editais.',
                            style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                          ),
                          value: _aceitaNotificacoes,
                          activeColor: const Color(0xFF2563EB),
                          onChanged: (val) => setState(() => _aceitaNotificacoes = val ?? false),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Botão Atualizado para o Telegram
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0088cc), Color(0xFF005f8f)], // Cores Oficiais do Telegram
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0088cc).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () async => await _ativarAlertasTelegram(),
                          icon: const FaIcon(FontAwesomeIcons.telegram, color: Colors.white),
                          label: const Text(
                            'ATIVAR NO TELEGRAM',
                            style: TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.bold, 
                              letterSpacing: 1.2
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}