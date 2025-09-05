const { conectaBD } = require('../db/db');

// Criar ganho
async function criarGanho(req, res) {
  const { idUsuario, valor, descricao, dataCriacao, tipo, repeticao } = req.body;

  try {
    const pool = await conectaBD();

    // 1. Inserir ganho
    await pool.request()
      .input('idUsuario', idUsuario)
      .input('valor', valor)
      .input('descricao', descricao)
      .input('dataCriacao', dataCriacao)
      .input('tipo', tipo)
      .input('repeticao', repeticao)

      .query(`
        INSERT INTO simpleCash.Ganho (idUsuario, valor, descricao, dataCriacao, tipo, repeticao)
        VALUES (@idUsuario, @valor, @descricao, @dataCriacao, @tipo, @repeticao)
      `);

    // 2. Atualizar saldo do usuário
    await pool.request()
      .input('idUsuario', idUsuario)
      .input('valor', valor)
      .query(`
        UPDATE simpleCash.Usuario
        SET saldoTotal = saldoTotal + @valor
        WHERE idUsuario = @idUsuario
      `);

    res.status(201).json({ message: 'Ganho registrado com sucesso!' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao adicionar ganho.' });
  }
}

// Listar todos os ganhos de um usuário
async function listarGanhos(req, res) {
  const { idUsuario } = req.params;

  try {
    const pool = await conectaBD();
    const result = await pool.request()
      .input('idUsuario', idUsuario)
      .query('SELECT * FROM simpleCash.Ganho WHERE idUsuario = @idUsuario');

    res.json(result.recordset);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao buscar ganhos.' });
  }
}

// Buscar ganho por ID
async function buscarGanho(req, res) {
  const { id } = req.params;

  try {
    const pool = await conectaBD();
    const result = await pool.request()
      .input('idGanho', id)
      .query('SELECT * FROM simpleCash.Ganho WHERE idGanho = @idGanho');

    if (result.recordset.length === 0) {
      return res.status(404).json({ error: 'Ganho não encontrado.' });
    }

    res.json(result.recordset[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao buscar ganho.' });
  }
}

// Atualizar ganho
async function atualizarGanho(req, res) {
  const { id } = req.params;
  const { valor, descricao, data } = req.body;

  try {
    const pool = await conectaBD();

    // Primeiro, buscar o valor antigo para ajustar saldo
    const result = await pool.request()
      .input('idGanho', id)
      .query('SELECT * FROM simpleCash.Ganho WHERE idGanho = @idGanho');

    if (result.recordset.length === 0) {
      return res.status(404).json({ error: 'Ganho não encontrado.' });
    }

    const ganhoAntigo = result.recordset[0];
    const diferenca = valor - ganhoAntigo.valor;

    // Atualizar ganho
    await pool.request()
      .input('idGanho', id)
      .input('valor', valor)
      .input('descricao', descricao)
      .input('data', data)
      .input('tipo', tipo)
      .input('repeticao', repeticao)
      .query(`
        UPDATE simpleCash.Ganho
        SET valor = @valor, descricao = @descricao, data = @data, tipo = @tipo, repeticao = @repeticao
        WHERE idGanho = @idGanho
      `);

    // Ajustar saldo do usuário
    await pool.request()
      .input('idUsuario', ganhoAntigo.idUsuario)
      .input('diferenca', diferenca)
      .query(`
        UPDATE simpleCash.Usuario
        SET saldoTotal = saldoTotal + @diferenca
        WHERE idUsuario = @idUsuario
      `);

    res.json({ message: 'Ganho atualizado com sucesso!' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao atualizar ganho.' });
  }
}

// Deletar ganho
async function deletarGanho(req, res) {
  const { id } = req.params;

  try {
    const pool = await conectaBD();

    // Buscar valor do ganho para ajustar saldo
    const result = await pool.request()
      .input('idGanho', id)
      .query('SELECT * FROM simpleCash.Ganho WHERE idGanho = @idGanho');

    if (result.recordset.length === 0) {
      return res.status(404).json({ error: 'Ganho não encontrado.' });
    }

    const ganho = result.recordset[0];

    // Deletar ganho
    await pool.request()
      .input('idGanho', id)
      .query('DELETE FROM simpleCash.Ganho WHERE idGanho = @idGanho');

    // Atualizar saldo do usuário
    await pool.request()
      .input('idUsuario', ganho.idUsuario)
      .input('valor', ganho.valor)
      .query(`
        UPDATE simpleCash.Usuario
        SET saldoTotal = saldoTotal - @valor
        WHERE idUsuario = @idUsuario
      `);

    res.json({ message: 'Ganho deletado com sucesso!' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao deletar ganho.' });
  }
}

module.exports = {
  criarGanho,
  listarGanhos,
  buscarGanho,
  atualizarGanho,
  deletarGanho
};
