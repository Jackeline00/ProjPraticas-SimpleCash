const { conectaBD } = require('../db/db');

// Criar gasto
async function criarGasto(req, res) {
  const { idUsuario, tipo, descricao, valor, data, repeticao, dataInicio, dataFinal, quantidadeDeParcelas, juros, tipoJuros } = req.body;

  try {
    const pool = await conectaBD();

    // 1. Inserir ganho
    await pool.request()
      .input('idUsuario', idUsuario)
      .input('tipo', tipo)
      .input('descricao', descricao)
      .input('valor', valor)
      .input('data', data)
      .input('repeticao', repeticao)
      .input('dataInicio', dataInicio)
      .input('dataFinal', dataFinal)
      .input('quantidadeDeParcelas', quantidadeDeParcelas)
      .input('juros', juros)
      .input('tipoJuros', tipoJuros)
      .query(`
        INSERT INTO simpleCash.Gasto (idUsuario, tipo, descricao, valor, data, repeticao, dataInicio, dataFinal, quantidadeDeParcelas, juros, tipoJuros)
        VALUES (@idUsuario, @tipo, @descricao, @valor, @data, @repeticao, @dataInicio, @dataFinal, @quantidadeDeParcelas, @juros, @tipoJuros)
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

    res.status(201).json({ message: 'Gasto registrado com sucesso!' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao adicionar gasto.' });
  }
}

// Listar todos os gastos de um usuário
async function listarGastos(req, res) {
  const { idUsuario } = req.params;

  try {
    const pool = await conectaBD();
    const result = await pool.request()
      .input('idUsuario', idUsuario)
      .query('SELECT * FROM simpleCash.Gasto WHERE idUsuario = @idUsuario');

    res.json(result.recordset);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao buscar gastos.' });
  }
}

// Buscar gasto por ID
async function buscarGasto(req, res) {
  const { id } = req.params;

  try {
    const pool = await conectaBD();
    const result = await pool.request()
      .input('idGasto', id)
      .query('SELECT * FROM simpleCash.Gasto WHERE idGasto = @idGasto');

    if (result.recordset.length === 0) {
      return res.status(404).json({ error: 'Gasto não encontrado.' });
    }

    res.json(result.recordset[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao buscar gasto.' });
  }
}

// Atualizar gasto
async function atualizarGasto(req, res) {
  const { id } = req.params;
  const { valor, descricao, data } = req.body;

  try {
    const pool = await conectaBD();

    // Primeiro, buscar o valor antigo para ajustar saldo
    const result = await pool.request()
      .input('idGasto', id)
      .query('SELECT * FROM simpleCash.Gasto WHERE idGasto = @idGasto');

    if (result.recordset.length === 0) {
      return res.status(404).json({ error: 'Gasto não encontrado.' });
    }

    const gastoAntigo = result.recordset[0];
    const diferenca = valor - gastoAntigo.valor;

    // Atualizar gasto
    await pool.request()
      .input('idUsuario', idUsuario)
      .input('tipo', tipo)
      .input('descricao', descricao)
      .input('valor', valor)
      .input('data', data)
      .input('repeticao', repeticao)
      .input('dataInicio', dataInicio)
      .input('dataFinal', dataFinal)
      .input('quantidadeDeParcelas', quantidadeDeParcelas)
      .input('juros', juros)
      .input('tipoJuros', tipoJuros)
      .query(`
        UPDATE simpleCash.Gasto
        SET tipo = @tipo, descricao = @descricao, valor = @valor, data = @data, 
        repeticao = @repeticao, dataInicio = @dataIncio, dataFinal = @dataFinal, 
        quantidadeDeParcelas = @quantidadeDeParcelas, juros = @juros, tipoJuros = @tipoJuros
        WHERE idGasto = @idGasto
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

    res.json({ message: 'Gasto atualizado com sucesso!' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao atualizar gasto.' });
  }
}

// Deletar gasto
async function deletarGasto(req, res) {
  const { id } = req.params;

  try {
    const pool = await conectaBD();

    // Buscar valor do gasto para ajustar saldo
    const result = await pool.request()
      .input('idGasto', id)
      .query('SELECT * FROM simpleCash.Gasto WHERE idGasto = @idGasto');

    if (result.recordset.length === 0) {
      return res.status(404).json({ error: 'Gasto não encontrado.' });
    }

    const gasto = result.recordset[0];

    // Deletar gasto
    await pool.request()
      .input('idGanho', id)
      .query('DELETE FROM simpleCash.Gasto WHERE idGasto = @idGasto');

    // Atualizar saldo do usuário
    await pool.request()
      .input('idUsuario', gasto.idUsuario)
      .input('valor', gasto.valor)
      .query(`
        UPDATE simpleCash.Usuario
        SET saldoTotal = saldoTotal + @valor
        WHERE idUsuario = @idUsuario
      `);

    res.json({ message: 'Gasto deletado com sucesso!' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao deletar gasto.' });
  }
}

module.exports = {
  criarGasto,
  listarGastos,
  buscarGasto,
  atualizarGasto,
  deletarGasto
};
