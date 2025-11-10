const { conectaBD } = require("../db/db"); // cria a conexão com o banco
const sql = require('mssql'); 

// Adicionar no histórico
async function criarDado(req, res) {
  const { idUsuario, tipoAtividade, idReferencia, descricao, valor } = req.body; 

  try {
    const pool = await conectaBD(); // abre uma conexão com o banco

    await pool.request() // prepara uma consulta sql
      .input("idUsuario", sql.Int, idUsuario) 
      .input("tipoAtividade", sql.NVarChar, tipoAtividade)  // "gasto", "ganho" ou "poupanca"
      .input("idReferencia", sql.Int, idReferencia)    // o mesmo da atividade a qual se refere
      .input("descricao", sql.NVarChar, descricao)          // com o que foi gasto, de onde veio ou para que está sendo guardado
      .input("valor", sql.Decimal(18,2), valor)
      .query(`
        INSERT INTO simpleCash.Historico (idUsuario, tipoAtividade, idReferencia, descricao, valor, dataCriacao)
        VALUES (@idUsuario, @tipoAtividade, @idReferencia, @descricao, @valor, GETDATE())
      `);

    res.status(201).json({ message: "Dado adicionado ao historico com sucesso!" });
  } catch (err) {
    console.error("Erro em criarDado:", err);
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
    console.error("Erro em listarDados:", err);
    res.status(500).json({ error: "Erro ao listar os dados." });
  }
}

// Buscar gastos de um usuário
async function buscarGastos(req, res) {
  const { id } = req.params;

  try {
    const pool = await conectaBD();

    const result = await pool.request()
      .input("idUsuario", sql.Int, id)
      .query("SELECT * FROM simpleCash.Historico WHERE idUsuario = @idUsuario AND tipoAtividade = 'gasto'");

    if (!result.recordset || result.recordset.length === 0) {
      return res.status(404).json({ error: "Dados de gastos não encontrados." });
    }

    res.json(result.recordset);
  } catch (err) {
    console.error("Erro em buscarGastos:", err); 
    res.status(500).json({ error: "Erro ao buscar gastos do histórico." });
  }
}


// Buscar ganhos de um usuário
async function buscarGanhos(req, res) {
  const { id } = req.params;

  try {
    const pool = await conectaBD();

    const result = await pool.request()
      .input("idUsuario", sql.Int, id)
      .query("SELECT * FROM simpleCash.Historico WHERE idUsuario = @idUsuario AND tipoAtividade = 'ganho'");

    if (!result.recordset || result.recordset.length === 0) {
      return res.status(404).json({ error: "Dados de ganhos não encontrados." });
    }

    res.json(result.recordset);
  } catch (err) {
    console.error("Erro em buscarGanhos:", err); 
    res.status(500).json({ error: "Erro ao buscar ganhos do histórico." });
  }
}


// Buscar poupanças de um usuário
async function buscarPoupanca(req, res) { // <-- corrigido: receber req e res
  const { id } = req.params;

  try {
    const pool = await conectaBD();

    const result = await pool.request()
      .input("idUsuario", sql.Int, id)
      .query("SELECT * FROM simpleCash.Historico WHERE idUsuario = @idUsuario AND tipoAtividade = 'poupanca'");

    if (!result.recordset || result.recordset.length === 0) {
      return res.status(404).json({ error: "Dados de poupança não encontrados." });
    }

    // Retorna todos os registros encontrados
    res.json(result.recordset);
  } catch (err) {
    console.error("Erro em buscarPoupanca:", err); 
    res.status(500).json({ error: "Erro ao buscar poupanças do histórico." });
  }
}

// Buscar dado do histórico por ID
async function buscarDado(req, res) {
  const { id } = req.params;

  try {
    const pool = await conectaBD();
    const result = await pool.request()
      .input("idHistorico", sql.Int, id)
      .query("SELECT * FROM simpleCash.Historico WHERE idHistorico = @idHistorico");

    if (result.recordset.length === 0) {
      return res.status(404).json({ error: "Dado do histórico não encontrado." });
    }

    res.json(result.recordset[0]);
  } catch (err) {
    console.error("Erro em buscarDado:", err);
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
      .input('idHistorico', sql.Int, id)
      .input("idUsuario", sql.Int, idUsuario) 
      .input("tipoAtividade", sql.NVarChar, tipoAtividade)
      .input("idReferencia", sql.Int, idReferencia)
      .input("descricao", sql.NVarChar, descricao)
      .input("valor", sql.Decimal(18,2), valor)
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
    console.error("Erro em atualizarDado:", err);
    res.status(500).json({ error: "Erro ao atualizar dados do histórico." });
  }
}

// Deletar dado do histórico
async function deletarDado(req, res) {
  const { id } = req.params;

  try {
    const pool = await conectaBD();
    await pool.request()
      .input("idHistorico", sql.Int, id)
      .query("DELETE FROM simpleCash.Historico WHERE idHistorico = @idHistorico");

    res.json({ message: "Dado deletado com sucesso!" });
  } catch (err) {
    console.error("Erro em deletarDado:", err);
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
