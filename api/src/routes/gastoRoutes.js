const express = require('express');
const router = express.Router();
const gastoController = require('../controllers/gastoController');

// Buscar gasto por ID
router.get('/detalhe/:id', gastoController.buscarGasto);

// Listar todos os gastos 
router.get('/todos', gastoController.listarGastos);

// Listar todos os gastos de um usuário
router.get('/:idUsuario', gastoController.listarTodos);

// Criar gasto
router.post('/', gastoController.criarGasto);

// Atualizar gasto
router.put('/:id', gastoController.atualizarGasto);

// Deletar gasto
router.delete('/:id', gastoController.deletarGasto);

module.exports = router;