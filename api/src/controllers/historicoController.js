const { conectaBD } = require("../db/db"); // cria a conexão com o banco

// Adicionar no histórico
async function criarDado(req, res) {
  const { idUsuario, tipoAtividade, idReferencia, descricao, valor, data } = req.body; 

  try {
    const pool = await connectDB(); // abre uma conexão com o banco

    await pool.request() // prepara uma consulta sql
      .input("idUsuario", idUsuario) 
      .input("tipoAtividade", tipoAtividade)
      .input("idReferencia", idReferencia)
      .input("descricao", descricao)
      .input("valor", valor)
      .input("data", data)
      .query(`
        INSERT INTO simpleCash.Historico (idUsuario, tipoAtividade, idReferencia, descricao, valor, data)
        VALUES (@idUsuario, @tipoAtividade, @idReferencia, @descricao, @valor, @data)
      `);

    res.status(201).json({ message: "Dado adicionado ao histrico com sucesso!" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Erro ao adicionar dado ao histórico." });
  }
}

// Listar todos os dados do histórico
async function listarDados(req, res) {
  try {
    const pool = await conectaBD(); // nova conexão com o banco
    const result = await pool.request().query("SELECT * FROM simpleCash.Historico");

    res.json(result.recordset);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Erro ao listar os dados." });
  }
}

// Buscar dado do histórico por ID
async function buscarDado(req, res) {
  const { id } = req.params;

  try {
    const pool = await conectaBD();
    const result = await pool.request()
      .input("idHistorico", id)
      .query("SELECT * FROM simpleCash.Historico WHERE idHistorico = @idHistorico");

    if (result.recordset.length === 0) {
      return res.status(404).json({ error: "Dado do histórico não encontrado." });
    }

    res.json(result.recordset[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Erro ao buscar dado do histórico." });
  }
}

// Atualizar dado
async function atualizarDado(req, res) {
  const { id } = req.params;
  const { idUsuario, tipoAtividade, idReferencia, descricao, valor, data } = req.body;

  try {
    const pool = await conectaBD();
    await pool.request()
      .input("idUsuario", idUsuario) 
      .input("tipoAtividade", tipoAtividade)
      .input("idReferencia", idReferencia)
      .input("descricao", descricao)
      .input("valor", valor)
      .input("data", data)
      .query(`
        UPDATE simpleCash.Historico
        SET idUsuario = @idUsuario, 
            tipoAtividade = @tipoAtividade, 
            referencia = @idReferencia, 
            descricao = @descricao, 
            valor = @valor, 
            data = @data
        WHERE idHistorico = @idHistorico
      `);

    res.json({ message: "Dados atualizados com sucesso!" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Erro ao atualizar dados do histórico." });
  }
}

// Deletar dado do histórico
async function deletarDado(req, res) {
  const { id } = req.params;

  try {
    const pool = await conectaBD();
    await pool.request()
      .input("idHistorico", id)
      .query("DELETE FROM simpleCash.Historico WHERE idHistorico = @idHistorico");

    res.json({ message: "Dado deletado com sucesso!" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Erro ao deletar dado do histórico." });
  }
}

module.exports = {
  criarDado,
  listarDados,
  buscarDado,
  atualizarDado,
  deletarDado
};
