const { conectaBD } = require("../db/db"); // cria a conexão com o banco

// Criar usuário
async function criarUsuario(req, res) {
  const { nome, email, senha } = req.body; // pega os dados digitados pelo usuário (flutter)

  try {
    const pool = await connectDB(); // abre uma conexão com o banco

    await pool.request() // prepara uma consulta sql
      .input("nome", nome) 
      .input("email", email)
      .input("senha", senha)
      .input("saldoTotal", saldoTotal)
      .query(`
        INSERT INTO simpleCash.Usuario (nome, email, senha, dataCriacao, saldoTotal)
        VALUES (@nome, @email, @senha, GETDATE(), @saldoTotal)
      `);

    res.status(201).json({ message: "Conta criada com sucesso!" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Erro ao criar a conta." });
  }
}

// Listar todos os usuários
async function listarUsuarios(req, res) {
  try {
    const pool = await conectaBD(); // nova conexão com o banco
    const result = await pool.request().query("SELECT * FROM simpleCash.Usuario");

    res.json(result.recordset);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Erro ao listar os usuários." });
  }
}

// Buscar usuário por ID
async function buscarUsuario(req, res) {
  const { id } = req.params;

  try {
    const pool = await conectaBD();
    const result = await pool.request()
      .input("idUsuario", id)
      .query("SELECT * FROM simpleCash.Usuario WHERE idUsuario = @idUsuario");

    if (result.recordset.length === 0) {
      return res.status(404).json({ error: "Usuário não encontrado." });
    }

    res.json(result.recordset[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Erro ao buscar usuário." });
  }
}

// Atualizar usuário
async function atualizarUsuario(req, res) {
  const { id } = req.params;
  const { nome, email, senha } = req.body;

  try {
    const pool = await conectaBD();
    await pool.request()
      .input("idUsuario", id)
      .input("nome", nome)
      .input("email", email)
      .input("senha", senha)
      .query(`
        UPDATE simpleCash.Usuario
        SET nome = @nome,
            email = @email,
            senha = @senha
        WHERE idUsuario = @idUsuario
      `);

    res.json({ message: "Dados do usuário atualizados com sucesso!" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Erro ao atualizar dados do usuário." });
  }
}

// Deletar usuário
async function deletarUsuario(req, res) {
  const { id } = req.params;

  try {
    const pool = await conectaBD();
    await pool.request()
      .input("idUsuario", id)
      .query("DELETE FROM simpleCash.Usuario WHERE idUsuario = @idUsuario");

    res.json({ message: "Usuário deletado com sucesso!" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Erro ao deletar usuário." });
  }
}

// Login usuário - validar senha e email
async function loginUsuario(req, res) {
  const { email, senha } = req.body;

  try {
    const pool = await connectDB();

    // Busca usuário pelo email
    const result = await pool.request()
      .input('email', email)
      .query('SELECT * FROM simpleCash.Usuario WHERE email = @email');

    if (result.recordset.length === 0) {
      return res.status(401).json({ error: 'Email ou senha inválidos' });
    }

    const usuario = result.recordset[0];

    // Validar senha
    const senhaValida = await bcrypt.compare(senha, usuario.senha);
    if (!senhaValida) {
      return res.status(401).json({ error: 'Email ou senha inválidos' });
    }

    res.json({ message: 'Login realizado com sucesso!', idUsuario: usuario.idUsuario });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao realizar login.' });
  }
}

/*
async function atualizarSaldo(req, res) {
  const { id } = req.params;
  const { saldoAtual } = req.body;

  try {
    const pool = await conectaBD();
    await pool.request()
      .input("idUsuario", id)
      .input("nome", nome)
      .input("email", email)
      .input("senha", senha)
      .query(`
        UPDATE simpleCash.Usuario
        SET nome = @nome,
            email = @email,
            senha = @senha
        WHERE idUsuario = @idUsuario
      `);

    res.json({ message: "Saldo atualizado com sucesso!" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Erro ao atualizar saldo do usuário." });
  }
}
*/

module.exports = {
  criarUsuario,
  listarUsuarios,
  buscarUsuario,
  atualizarUsuario,
  deletarUsuario,
  loginUsuario
};
