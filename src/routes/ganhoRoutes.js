const express = require('express');
const router = express.Router();
const ganhoController = require('../controllers/ganhoController');

// Criar ganho
router.post('/', ganhoController.criarGanho);

// Listar todos os ganhos de um usuário
router.get('/:idUsuario', ganhoController.listarGanhos);

// Buscar ganho por ID
router.get('/detalhe/:id', ganhoController.buscarGanho);

// Atualizar ganho
router.put('/:id', ganhoController.atualizarGanho);

// Deletar ganho
router.delete('/:id', ganhoController.deletarGanho);

module.exports = router;