const { conectaBD } = require('../db/db');

// Criar poupanca
async function criarPoupanca(req, res) {
  const { idUsuario, tipo, descricao, valor, data, repeticao, origem } = req.body;

  try {
    const pool = await conectaBD();

    // 1. Inserir poupanca
    await pool.request()
      .input('idUsuario', idUsuario)
      .input('tipo', tipo)
      .input('descricao', descricao)
      .input('valor', valor)
      .input('data', data)
      .input('repeticao', repeticao)
      .input('origem', origem)
      .query(`
        INSERT INTO simpleCash.Poupanca (idUsuario, tipo, descricao, valor, data, repeticao, origem)
        VALUES (@idUsuario, @tipo, @descricao, @valor, @data, @repeticao, @origem)
      `);

    // 2. Atualizar saldo do usuário
    await pool.request()
      .input('idUsuario', idUsuario)
      .input('valor', valor)
      .query(`
        UPDATE simpleCash.Usuario
        SET saldoTotal = saldoTotal - @valor
        WHERE idUsuario = @idUsuario
      `);

    res.status(201).json({ message: 'Nova poupança registrada com sucesso!' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao adicionar poupança.' });
  }
}

// Listar todos as poupanças de um usuário
async function listarPoupancas(req, res) {
  const { idUsuario } = req.params;

  try {
    const pool = await conectaBD();
    const result = await pool.request()
      .input('idUsuario', idUsuario)
      .query('SELECT * FROM simpleCash.Poupanca WHERE idUsuario = @idUsuario');

    res.json(result.recordset);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao buscar poupanças.' });
  }
}

// Buscar poupança por ID
async function buscarPoupanca(req, res) {
  const { id } = req.params;

  try {
    const pool = await conectaBD();
    const result = await pool.request()
      .input('idPoupanca', id)
      .query('SELECT * FROM simpleCash.Poupanca WHERE idPoupanca = @idPoupanca');

    if (result.recordset.length === 0) {
      return res.status(404).json({ error: 'Poupança não encontrada.' });
    }

    res.json(result.recordset[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao buscar poupança.' });
  }
}

// Atualizar poupança
async function atualizarPoupanca(req, res) {
  const { id } = req.params;
  const { idUsuario, tipo, descricao, valor, data, repeticao, origem } = req.body;

  try {
    const pool = await conectaBD();

    // Primeiro, buscar o valor antigo para ajustar saldo
    const result = await pool.request()
      .input('idPoupanca', id)
      .query('SELECT * FROM simpleCash.Poupanca WHERE idPoupanca = @idPoupanca');

    if (result.recordset.length === 0) {
      return res.status(404).json({ error: 'Poupança não encontrada.' });
    }

    const poupancaAntiga = result.recordset[0];
    const diferenca = poupancaAntiga.valor - valor; // valor sendo a nova poupanca

    // Atualizar poupanca
    await pool.request()
      .input('idUsuario', idUsuario)
      .input('tipo', tipo)
      .input('descricao', descricao)
      .input('valor', valor)
      .input('data', data)
      .input('repeticao', repeticao)
      .input('origem', origem)
      .query(`
        UPDATE simpleCash.Poupanca
        SET idUsuario = @idUsuario, 
            tipo = @tipo, 
            descricao = @descricao, 
            valor = @valor, 
            data = @data, 
            repeticao = @repeticao, 
            origem = @origem
        WHERE idPoupanca = @idPoupanca
      `);

    // Ajustar saldo do usuário
    await pool.request()
      .input('idUsuario', poupancaAntiga.idUsuario)
      .input('diferenca', diferenca)
      .query(`
        UPDATE simpleCash.Usuario
        SET saldoTotal = saldoTotal + @diferenca
        WHERE idUsuario = @idUsuario
      `);

    res.json({ message: 'Poupança atualizada com sucesso!' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao atualizar poupança.' });
  }
}

// Deletar poupança
async function deletarPoupanca(req, res) {
  const { id } = req.params;

  try {
    const pool = await conectaBD();

    // Buscar valor da poupança para ajustar saldo
    const result = await pool.request()
      .input('idPoupanca', id)
      .query('SELECT * FROM simpleCash.Poupanca WHERE idPoupanca = @idPoupanca');

    if (result.recordset.length === 0) {
      return res.status(404).json({ error: 'Poupanca não encontrada.' });
    }

    const poupanca = result.recordset[0];

    // Deletar poupanca
    await pool.request()
      .input('idPoupanca', id)
      .query('DELETE FROM simpleCash.Poupanca WHERE idPoupanca = @idPoupanca');

    // Atualizar saldo do usuário
    await pool.request()
      .input('idUsuario', poupanca.idUsuario)
      .input('valor', poupanca.valor)
      .query(`
        UPDATE simpleCash.Usuario
        SET saldoTotal = saldoTotal + @valor
        WHERE idUsuario = @idUsuario
      `);

    res.json({ message: 'Poupança deletada com sucesso!' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao deletar poupança.' });
  }
}

module.exports = {
  criarPoupanca,
  listarPoupancas,
  buscarPoupanca,
  atualizarPoupanca,
  deletarPoupanca
};
