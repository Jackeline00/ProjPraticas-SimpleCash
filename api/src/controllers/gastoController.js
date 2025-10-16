const { conectaBD } = require('../db/db');
const sql = require('mssql');

// Criar gasto
async function criarGasto(req, res) {
  const { idUsuario, tipo, descricao, valor, repeticao, intervaloDias, dataInicio, dataFinal, quantidadeDeParcelas, juros, tipoJuros } = req.body;

  try {
    const pool = await conectaBD();

    // 1. Inserir ganho
    await pool.request()
      .input('idUsuario', idUsuario)                // int
      .input('tipo', tipo)                          // fixo, variavel, nenhuma
      .input('descricao', descricao)                // string
      .input('valor', valor)                        // decimal
      //.input('dataCriacao', dataCriacao)  // não é recebido, o próprio sistema coloca
      .input('repeticao', repeticao)                // nenhuma, mensal, semanal, anual
      .input('intervaloDias', intervaloDias)        // int -> null
      .input('dataInicio', dataInicio)              // yyyy-mm-dd -> null
      .input('dataFinal', dataFinal)                // yyyy-mm-dd -> null
      .input('quantidadeDeParcelas', quantidadeDeParcelas) // int -> null
      .input('juros', juros)                        // decimal -> null
      .input('tipoJuros', tipoJuros)                // nenhum, simples, composto
      .query(`
        INSERT INTO simpleCash.Gasto (idUsuario, tipo, descricao, valor, dataCriacao, repeticao, intervaloDias, dataInicio, dataFinal, quantidadeDeParcelas, juros, tipoJuros)
        VALUES (@idUsuario, @tipo, @descricao, @valor, GETDATE(), @repeticao, @intervaloDias, @dataInicio, @dataFinal, @quantidadeDeParcelas, @juros, @tipoJuros)
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

// Listar todos os gastos
async function listarGastos(req, res) {
  try {
    const pool = await conectaBD();
    const result = await pool.request().query("SELECT * FROM simpleCash.Gasto");

    res.json(result.recordset);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Erro ao listar os gastos." });
  }
}

// Listar todos os gastos de um usuário
async function listarTodos(req, res) {
  const { idUsuario } = req.params;

  try {
    const pool = await conectaBD();
    const result = await pool.request()
      .input('idUsuario', idUsuario)
      .query('SELECT * FROM simpleCash.Gasto');

    res.json(result.recordset);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao buscar gastos.' });
  }
}

// Listar as descrições dos gastos de um usuário
async function listarDescricoes(req, res) {
  const { idUsuario } = req.params;

  try {
    const pool = await conectaBD();
    const result = await pool.request()
      .input('idUsuario', idUsuario)
      .query('SELECT descricao FROM simpleCash.Gasto WHERE idUsuario = @idUsuario');

    res.json(result.recordset);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao buscar descrições dos gastos.' });
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
  const idGasto = parseInt(req.params.id, 10);
  const {
    idUsuario, // opcional: se quiser permitir alterar dono, trate com cuidado
    tipo,
    descricao,
    valor, // espere número (ou parseFloat)
    repeticao,
    intervaloDias,
    dataInicio,
    dataFinal,
    quantidadeDeParcelas,
    juros,
    tipoJuros
  } = req.body;

  if (Number.isNaN(idGasto)) {
    return res.status(400).json({ error: 'idGasto inválido.' });
  }

  try {
    const pool = await conectaBD();

    // inicia transação para garantir atomicidade
    const transaction = new sql.Transaction(pool);
    await transaction.begin();

    try {
      const request = new sql.Request(transaction);

      // Buscar gasto antigo
      const selectRes = await request
        .input('idGasto', sql.Int, idGasto)
        .query('SELECT * FROM simpleCash.Gasto WHERE idGasto = @idGasto');

      if (!selectRes.recordset || selectRes.recordset.length === 0) {
        await transaction.rollback();
        return res.status(404).json({ error: 'Gasto não encontrado.' });
      }

      const gastoAntigo = selectRes.recordset[0];

      // converte valores numéricos se vierem como string
      const novoValor = typeof valor === 'string' ? parseFloat(valor) : valor;
      if (novoValor == null || Number.isNaN(novoValor)) {
        await transaction.rollback();
        return res.status(400).json({ error: 'Valor inválido.' });
      }

      const diferenca = novoValor - (gastoAntigo.valor ?? 0);

      // Atualizar gasto (usa parâmetros corretos; passa também idGasto)
      const updateReq = new sql.Request(transaction);
      updateReq
        .input('idGasto', sql.Int, idGasto)
        .input('idUsuario', sql.Int, idUsuario ?? gastoAntigo.idUsuario) // se não veio, mantém antigo
        .input('tipo', sql.VarChar(100), tipo ?? gastoAntigo.tipo)
        .input('descricao', sql.VarChar(500), descricao ?? gastoAntigo.descricao)
        .input('valor', sql.Decimal(18,2), novoValor)
        .input('dataInicio', sql.Date, dataInicio ?? gastoAntigo.dataInicio)
        .input('dataFinal', sql.Date, dataFinal ?? gastoAntigo.dataFinal)
        .input('repeticao', sql.VarChar(50), repeticao ?? gastoAntigo.repeticao)
        .input('intervaloDias', sql.Int, intervaloDias ?? gastoAntigo.intervaloDias)
        .input('quantidadeDeParcelas', sql.Int, quantidadeDeParcelas ?? gastoAntigo.quantidadeDeParcelas)
        .input('juros', sql.Decimal(18,2), juros ?? gastoAntigo.juros)
        .input('tipoJuros', sql.VarChar(50), tipoJuros ?? gastoAntigo.tipoJuros);

      await updateReq.query(`
        UPDATE simpleCash.Gasto
        SET idUsuario = @idUsuario,
            tipo = @tipo,
            descricao = @descricao,
            valor = @valor,
            dataInicio = @dataInicio,
            dataFinal = @dataFinal,
            repeticao = @repeticao,
            intervaloDias = @intervaloDias,
            quantidadeDeParcelas = @quantidadeDeParcelas,
            juros = @juros,
            tipoJuros = @tipoJuros
        WHERE idGasto = @idGasto
      `);

      // Ajustar saldo do usuário (usamos o idUsuario final do gasto)
      const idUsuarioParaAjuste = idUsuario ?? gastoAntigo.idUsuario;
      const adjustReq = new sql.Request(transaction);
      adjustReq
        .input('idUsuario', sql.Int, idUsuarioParaAjuste)
        .input('diferenca', sql.Decimal(18,2), diferenca);

      await adjustReq.query(`
        UPDATE simpleCash.Usuario
        SET saldoTotal = saldoTotal + @diferenca
        WHERE idUsuario = @idUsuario
      `);

      await transaction.commit();
      return res.json({ message: 'Gasto atualizado com sucesso!' });
    } catch (innerErr) {
      await transaction.rollback();
      console.error('Erro na transação atualizarGasto:', innerErr);
      return res.status(500).json({ error: 'Erro ao atualizar gasto.' });
    }
  } catch (err) {
    console.error('Erro conectar/atualizar gasto:', err);
    return res.status(500).json({ error: 'Erro ao atualizar gasto.' });
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
      .input('idGasto', id)
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
  listarTodos,
  listarGastos,
  listarDescricoes,
  buscarGasto,
  atualizarGasto,
  deletarGasto
};
