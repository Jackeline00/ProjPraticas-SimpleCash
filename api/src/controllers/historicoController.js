const { conectaBD } = require("../db/db"); // cria a conexão com o banco

// Adicionar no histórico
async function criarDado(req, res) {
  const { idUsuario, tipoAtividade, idReferencia, descricao, valor } = req.body; 

  try {
    const pool = await conectaBD(); // abre uma conexão com o banco

    await pool.request() // prepara uma consulta sql
      .input("idUsuario", idUsuario) 
      .input("tipoAtividade", tipoAtividade)  // "gasto", "ganho" ou "poupanca"
      .input("idReferencia", idReferencia)    // o mesmo da atividade a qual se refere
      .input("descricao", descricao)          // com o que foi gasto, de onde veio ou para que está sendo guardado
      .input("valor", valor)
      .query(`
        INSERT INTO simpleCash.Historico (idUsuario, tipoAtividade, idReferencia, descricao, valor, dataCriacao)
        VALUES (@idUsuario, @tipoAtividade, @idReferencia, @descricao, @valor, GETDATE())
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

// Buscar gastos de um usuário
async function buscarGastos(req, res) {
  const { id } = req.params;

  try {
    const pool = await conectaBD();

    const result = await pool.request()
      .input("idUsuario", id)
      .query("SELECT * FROM simpleCash.Historico WHERE idUsuario = @idUsuario AND tipoAtividade = 'gasto'");

    if (!result.recordset || result.recordset.length === 0) {
      return res.status(404).json({ error: "Dado do histórico não encontrado." });
    }

    // Retorna todos os registros encontrados
    res.json(result.recordset);
  } catch (err) {
    console.error("Erro ao buscar gastos:", err); 
    res.status(500).json({ error: "Erro ao buscar dado do histórico." });
  }
}


// Buscar ganhos de um usuário
async function buscarGanhos(req, res) {
  const { id } = req.params;

  try {
    const pool = await conectaBD();

    const result = await pool.request()
      .input("idUsuario", id)
      .query("SELECT * FROM simpleCash.Historico WHERE idUsuario = @idUsuario AND tipoAtividade = 'ganho'");

    if (!result.recordset || result.recordset.length === 0) {
      return res.status(404).json({ error: "Dado do histórico não encontrado." });
    }

    // Retorna todos os registros encontrados
    res.json(result.recordset);
  } catch (err) {
    console.error("Erro ao buscar gastos:", err); 
    res.status(500).json({ error: "Erro ao buscar dado do histórico." });
  }
}


// Buscar poupanças de um usuário
async function buscarPoupanca(){
  const { id } = req.params;

  try {
    const pool = await conectaBD();

    const result = await pool.request()
      .input("idUsuario", id)
      .query("SELECT * FROM simpleCash.Historico WHERE idUsuario = @idUsuario AND tipoAtividade = 'poupanca'");

    if (!result.recordset || result.recordset.length === 0) {
      return res.status(404).json({ error: "Dado do histórico não encontrado." });
    }

    // Retorna todos os registros encontrados
    res.json(result.recordset);
  } catch (err) {
    console.error("Erro ao buscar gastos:", err); 
    res.status(500).json({ error: "Erro ao buscar dado do histórico." });
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
  const { idUsuario, tipoAtividade, idReferencia, descricao, valor } = req.body;

  try {
    const pool = await conectaBD();
    await pool.request()
      .input('idHistorico', id)
      .input("idUsuario", idUsuario) 
      .input("tipoAtividade", tipoAtividade)
      .input("idReferencia", idReferencia)
      .input("descricao", descricao)
      .input("valor", valor)
      .query(`
        UPDATE simpleCash.Historico
        SET idUsuario = @idUsuario, 
            tipoAtividade = @tipoAtividade, 
            idReferencia = @idReferencia, 
            descricao = @descricao, 
            valor = @valor
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
  buscarGastos,
  buscarGanhos,
  buscarPoupanca,
  buscarDado,
  atualizarDado,
  deletarDado
};
