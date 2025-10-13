const express = require('express');
const router = express.Router();
const gastoController = require('../controllers/gastoController');

// Criar gasto
router.post('/', gastoController.criarGasto);

// Listar todos os gastos de um usuário
router.get('/:idUsuario', gastoController.listarGastos);

// Listar as descrições dos gastos de um usuário
router.get('/descricao/:idUsuario', gastoController.listarDescricoes);

// Buscar gasto por ID
router.get('/detalhe/:id', gastoController.buscarGasto);

// Atualizar gasto
router.put('/:id', gastoController.atualizarGasto);

// Deletar gasto
router.delete('/:id', gastoController.deletarGasto);

module.exports = router;