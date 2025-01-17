import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Inicializa o banco de dados
  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'historico_pedidos.db');

    return await openDatabase(
      path,
      version: 2, // Versão do banco de dados
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Criação das tabelas no banco de dados
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pedidos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quantidade INTEGER NOT NULL,
        status TEXT NOT NULL,
        data_solicitacao TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  //  todos os pedidos
  Future<List<Map<String, dynamic>>> getPedidos() async {
    final db = await database;
    return await db.query('pedidos');
  }

  // obter o último pedido
  Future<Map<String, dynamic>?> obterUltimoPedido() async {
    final db = await database;
    final resultado = await db.query(
      'pedidos',
      orderBy: 'data_solicitacao DESC',
      limit: 1,
    );

    return resultado.isNotEmpty ? resultado.first : null;
  }

  // Método para inserir um novo pedido
  Future<int> inserirPedido(int quantidade, String status) async {
    final db = await database;
    final dataAtual = DateTime.now().toIso8601String(); // Data atual
    return await db.insert(
      'pedidos',
      {
        'quantidade': quantidade,
        'status': status,
        'data_solicitacao': dataAtual,
      },
    );
  }

  // verificar se existe um último pedido
  Future<int> obterUltimoPedidoId() async {
    final db = await database;
    final resultado = await db.query(
      'pedidos',
      orderBy: 'data_solicitacao DESC',
      limit: 1,
    );

    if (resultado.isNotEmpty) {
      return resultado.first['id'] as int; // Retorna o ID do último pedido
    }
    return 0; // Caso não haja pedidos, retorna 0
  }

  // verificar se é possível solicitar novamente (20 dias de espera)
  Future<bool> podeSolicitarNovamente() async {
    final ultimoPedido = await obterUltimoPedido();
    if (ultimoPedido != null) {
      final dataUltimaSolicitacao =
          DateTime.parse(ultimoPedido['data_solicitacao']);
      final dataAtual = DateTime.now();
      final diasDeDiferenca =
          dataAtual.difference(dataUltimaSolicitacao).inDays;

      return diasDeDiferenca >= 20; // Verifica se passaram 20 dias
    }
    return true; // Se não houver pedido anterior, pode solicitar
  }
}
