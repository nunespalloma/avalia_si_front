import 'package:flutter/material.dart';
import 'evaluation_dashboard_page.dart';
import '../../widgets/error_message.dart';
import '../../services/view_evaluation_service.dart';

enum _OrdenacaoAvaliacoes {
  nenhuma,
  avaliacoesCrescente,
  avaliacoesDecrescente,
  semestreCrescente,
  semestreDecrescente,
}

class ViewEvaluationPage extends StatefulWidget {
  const ViewEvaluationPage({super.key});

  @override
  State<ViewEvaluationPage> createState() => _ViewEvaluationPageState();
}

class _ViewEvaluationPageState extends State<ViewEvaluationPage> {
  final TextEditingController _buscaController = TextEditingController();
  String _termoBusca = '';
  _OrdenacaoAvaliacoes _ordenacaoSelecionada = _OrdenacaoAvaliacoes.nenhuma;

  List<TurmaResultado> _turmasAvaliadas = [];
  bool _carregando = true;
  String? _mensagemErro;

  @override
  void initState() {
    super.initState();
    _carregarTurmas();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarTurmas() async {
    setState(() {
      _carregando = true;
      _mensagemErro = null;
    });

    try {
      final turmas = await ViewEvaluationService.listarTurmasComAvaliacoes();

      if (!mounted) return;

      setState(() {
        _turmasAvaliadas = turmas;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _mensagemErro = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  void _abrirDashboard(TurmaResultado item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EvaluationDashboardPage(
          turmaId: item.id,
          disciplina: item.disciplina,
          turma: item.turma,
          professor: item.professor,
        ),
      ),
    );
  }

  void _voltarParaHome() {
    Navigator.pop(context);
  }

  double _valorSemestre(TurmaResultado item) {
    return double.tryParse(item.semestre) ?? 0;
  }

  List<TurmaResultado> get _turmasFiltradas {
    List<TurmaResultado> resultado;

    if (_termoBusca.trim().isEmpty) {
      resultado = List.from(_turmasAvaliadas);
    } else {
      final busca = _termoBusca.toLowerCase();

      resultado = _turmasAvaliadas.where((item) {
        return item.disciplina.toLowerCase().contains(busca) ||
            item.turma.toLowerCase().contains(busca) ||
            item.professor.toLowerCase().contains(busca) ||
            item.semestre.toLowerCase().contains(busca);
      }).toList();
    }

    switch (_ordenacaoSelecionada) {
      case _OrdenacaoAvaliacoes.avaliacoesCrescente:
        resultado.sort(
          (a, b) => a.notaEstrelas.compareTo(b.notaEstrelas),
        );
        break;
      case _OrdenacaoAvaliacoes.avaliacoesDecrescente:
        resultado.sort(
          (a, b) => b.notaEstrelas.compareTo(a.notaEstrelas),
        );
        break;
      case _OrdenacaoAvaliacoes.semestreCrescente:
        resultado.sort(
          (a, b) => _valorSemestre(a).compareTo(_valorSemestre(b)),
        );
        break;
      case _OrdenacaoAvaliacoes.semestreDecrescente:
        resultado.sort(
          (a, b) => _valorSemestre(b).compareTo(_valorSemestre(a)),
        );
        break;
      case _OrdenacaoAvaliacoes.nenhuma:
        break;
    }

    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    final turmasExibidas = _turmasFiltradas;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 24,
                  color: Colors.black,
                ),
                onPressed: _voltarParaHome,
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Ver Avaliações',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Escolha uma turma já avaliada para visualizar os resultados.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _buscaController,
                onChanged: (value) {
                  setState(() {
                    _termoBusca = value;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Buscar disciplina, turma, professor ou semestre',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: Colors.black38,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.black54,
                    size: 20,
                  ),
                  suffixIcon: _termoBusca.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _buscaController.clear();
                            setState(() {
                              _termoBusca = '';
                            });
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.black54,
                            size: 20,
                          ),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.black12,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.black12,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<_OrdenacaoAvaliacoes>(
                value: _ordenacaoSelecionada,
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _ordenacaoSelecionada = value;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.black12,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.black12,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.black54,
                    ),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                ),
                dropdownColor: Colors.white,
                items: const [
                  DropdownMenuItem(
                    value: _OrdenacaoAvaliacoes.nenhuma,
                    child: Text('Ordenar por'),
                  ),
                  DropdownMenuItem(
                    value: _OrdenacaoAvaliacoes.avaliacoesCrescente,
                    child: Text('Avaliações ↑'),
                  ),
                  DropdownMenuItem(
                    value: _OrdenacaoAvaliacoes.avaliacoesDecrescente,
                    child: Text('Avaliações ↓'),
                  ),
                  DropdownMenuItem(
                    value: _OrdenacaoAvaliacoes.semestreCrescente,
                    child: Text('Semestre ↑'),
                  ),
                  DropdownMenuItem(
                    value: _OrdenacaoAvaliacoes.semestreDecrescente,
                    child: Text('Semestre ↓'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _carregando
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            if (_mensagemErro != null) ...[
                              ErrorMessage(
                                message: _mensagemErro!,
                                onClose: () {
                                  setState(() {
                                    _mensagemErro = null;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                            _buildSectionTitle(
                              'Turmas disponíveis',
                              turmasExibidas.length,
                            ),
                            const SizedBox(height: 12),
                            if (turmasExibidas.isEmpty)
                              _buildEmptyState(
                                _termoBusca.isEmpty
                                    ? 'Você ainda não possui turmas avaliadas para visualizar.'
                                    : 'Nenhuma turma encontrada para essa pesquisa.',
                              )
                            else
                              ...turmasExibidas.map(_buildTurmaCardResultado),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String titulo, int quantidade) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        Text(
          '$quantidade',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildTurmaCardResultado(TurmaResultado item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        title: Text(
          item.disciplina,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${item.turma} - ${item.professor}\nSemestre: ${item.semestre} \nAvaliação: ${item.notaEstrelas.toStringAsFixed(1)}',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () {
            _abrirDashboard(item);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Ver',
            style: TextStyle(
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String texto) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black54,
          height: 1.4,
        ),
      ),
    );
  }
}