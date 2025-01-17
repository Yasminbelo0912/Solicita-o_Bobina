import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Garante que o Flutter esteja inicializado

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solicitação de Bobinas',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: TelaInicial(),
    );
  }
}

class TelaInicial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flybank - Bobinas'),
        titleTextStyle: TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              padding: EdgeInsets.all(15),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Realizar solicitação de Bobinas',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TelaPrincipal(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              padding: EdgeInsets.all(15),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TelaHistoricoPedidos(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Histórico de Pedidos',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TelaPrincipal extends StatefulWidget {
  @override
  _TelaPrincipalState createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  final int quantidadeBobinas = 5;
  final int diasUteis = 7;
  final String enderecoCliente = 'Rua Exemplo, 123, Bairro, Cidade';

  DateTime? ultimaSolicitacao;

  @override
  void initState() {
    super.initState();
    _verificarUltimaSolicitacao();
  }

  Future<void> _verificarUltimaSolicitacao() async {
    final pedidos = await DatabaseHelper.instance.obterPedidos();
    if (pedidos.isNotEmpty) {
      final ultimaData = DateTime.parse(pedidos.last['data_solicitacao']);
      setState(() {
        ultimaSolicitacao = ultimaData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bobinas'),
        titleTextStyle: TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              'Após a análise de vendas, você receberá $quantidadeBobinas bobinas.',
              style: TextStyle(fontSize: 17),
            ),
          ),
          SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Endereço de entrega:',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                Text(
                  enderecoCliente,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0)
                .copyWith(bottom: 30.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _mostrarDialogoConfirmacao(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  textStyle: TextStyle(fontSize: 18),
                  backgroundColor: Color.fromARGB(255, 231, 226, 231),
                ),
                child: Text('Confirmar'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoConfirmacao(BuildContext context) {
    final dataLimite = ultimaSolicitacao != null
        ? DateTime(
            ultimaSolicitacao!.add(Duration(days: 1)).year,
            ultimaSolicitacao!.add(Duration(days: 1)).month,
            ultimaSolicitacao!.add(Duration(days: 1)).day,
          )
        : DateTime.now();

    if (DateTime.now().isBefore(dataLimite)) {
      final dataFormatada = DateFormat('dd/MM/yyyy').format(dataLimite);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Solicitação recente',
              style: TextStyle(
                fontSize: 22,
              ),
            ),
            content: Text('Nova solicitação em: $dataFormatada às 00:00'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Fechar'),
              ),
            ],
          );
        },
      );
    } else {
      _mostrarDialogoConfirmacaoReal(context);
    }
  }

  void _mostrarDialogoConfirmacaoReal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Verifique as informações para continuar com a solicitação',
            style: TextStyle(
              fontSize: 17,
              color: Colors.black,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quantidade: $quantidadeBobinas bobinas'),
              SizedBox(height: 10),
              Text('Endereço: $enderecoCliente'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _salvarPedido();
                _mostrarMensagemFinal(context);
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _salvarPedido() async {
    final resultado = await DatabaseHelper.instance.inserirPedido(
      quantidadeBobinas,
      'Pendente',
    );

    if (resultado > 0) {
      print('Pedido salvo no banco de dados.');
      ultimaSolicitacao =
          DateTime.now(); // Atualiza a data da última solicitação
    } else {
      print('Erro ao salvar pedido no banco de dados.');
    }
  }

  Future<void> _enviarMensagemSlack(String mensagem) async {
    const String webhookUrl =
        'https://hooks.slack.com/services/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';
    try {
      final response = await http.post(
        Uri.parse(webhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: '{"text": "$mensagem"}',
      );

      if (response.statusCode == 200) {
        print('Mensagem enviada ao Slack com sucesso!');
      } else {
        print('Erro ao enviar mensagem ao Slack: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro: $e');
    }
  }

  void _mostrarMensagemFinal(BuildContext context) {
    _enviarMensagemSlack(
        'Solicitação de $quantidadeBobinas bobinas confirmada. Endereço de entrega: $enderecoCliente');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Solicitação Confirmada',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          content: Text(
            'Você receberá no endereço cadastrado em até $diasUteis dias úteis.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class TelaHistoricoPedidos extends StatefulWidget {
  @override
  _TelaHistoricoPedidosState createState() => _TelaHistoricoPedidosState();
}

class _TelaHistoricoPedidosState extends State<TelaHistoricoPedidos> {
  final ScrollController _scrollController = ScrollController();
  int? _pedidoAtualizadoIndex;

  Icon _getStatusIcon(String status) {
    switch (status) {
      case 'Concluído':
        return Icon(Icons.check_circle, color: Colors.green);
      case 'Pendente':
        return Icon(Icons.pending, color: Colors.orange);
      default:
        return Icon(Icons.help_outline, color: Colors.grey);
    }
  }

  void _confirmarEntrega(int pedidoId, int index) async {
    await DatabaseHelper.instance.atualizarStatusPedido(pedidoId, 'Concluído');
    setState(() {
      _pedidoAtualizadoIndex = index; // Salva o índice do pedido atualizado
    });

    // Mostra uma mensagem de confirmação
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Entrega confirmada para o pedido $pedidoId'),
      ),
    );

    // Aguarda a reconstrução da interface e tenta rolar até o item atualizado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pedidoAtualizadoIndex != null && _scrollController.hasClients) {
        _scrollController.animateTo(
          _pedidoAtualizadoIndex! *
              80.0, // Ajuste o valor conforme o tamanho do item
          duration: Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Pedidos'),
        titleTextStyle: TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.obterPedidos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum pedido registrado.'));
          }

          final pedidos = snapshot.data!;

          return ListView.builder(
            controller: _scrollController,
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              final status = pedido['status'];
              final quantidade = pedido['quantidade'];
              final dataSolicitacao = DateFormat('dd/MM/yyyy').format(
                DateTime.parse(pedido['data_solicitacao']),
              );

              return ListTile(
                title: Text('Pedido #$index'),
                subtitle: Text(
                  'Status: $status\nQuantidade: $quantidade\nData de Solicitação: $dataSolicitacao',
                ),
                trailing: _getStatusIcon(status),
                onTap: () {
                  if (status == 'Pendente') {
                    _confirmarEntrega(pedido['id'], index);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _iniciarBancoDeDados();
    return _database!;
  }

  Future<Database> _iniciarBancoDeDados() async {
    return openDatabase(
      'flybank.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pedidos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            quantidade INTEGER,
            status TEXT,
            data_solicitacao TEXT
          )
        ''');
      },
    );
  }

  Future<int> inserirPedido(int quantidade, String status) async {
    final db = await database;
    final dataSolicitacao = DateTime.now().toIso8601String();
    return await db.insert('pedidos', {
      'quantidade': quantidade,
      'status': status,
      'data_solicitacao': dataSolicitacao,
    });
  }

  Future<List<Map<String, dynamic>>> obterPedidos() async {
    final db = await database;
    return await db.query('pedidos');
  }

  Future<void> atualizarStatusPedido(int id, String status) async {
    final db = await database;
    await db.update(
      'pedidos',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
