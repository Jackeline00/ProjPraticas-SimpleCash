const express = require('express');
const router = express.Router();
const poupancaController = require('../controllers/poupancaController');

// Criar poupança
router.post('/', poupancaController.criarPoupanca);

// Listar todas as poupanças de um usuário
router.get('/:idUsuario', poupancaController.listarPoupancas);

// Buscar poupança por ID
router.get('/detalhe/:id', poupancaController.buscarPoupanca);

// Atualizar poupança
router.put('/:id', poupancaController.atualizarPoupanca);

// Deletar poupança
router.delete('/:id', poupancaController.deletarPoupanca);

module.exports = router;