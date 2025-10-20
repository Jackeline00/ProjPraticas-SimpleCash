const express = require('express');
const router = express.Router();
const historicoController = require('../controllers/historicoController');

// Criar novo dado do histórico
router.post('/', historicoController.criarDado);

// Listar todos os dados de um usuário
router.get('/:idUsuario', historicoController.listarDados);

// Buscar dado por ID
router.get('/detalhe/:id', historicoController.buscarDado);

// Buscar gastos de um usuário
router.get('/gastos/:id', historicoController.buscarGastos);

// Buscar ganhos de um usuário
router.get('/ganhos/:id', historicoController.buscarGanhos);

// Buscar poupanças de um usuário
router.get('/poupancas/:id', historicoController.buscarPoupanca);

// Atualizar dado
router.put('/:id', historicoController.atualizarDado);

// Deletar dado
router.delete('/:id', historicoController.deletarDado);

module.exports = router;