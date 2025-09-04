const express = require('express');
const router = express.Router();
const historicoController = require('../controllers/historicoController');

// Criar novo dado do histórico
router.post('/', historicoController.criarDado);

// Listar todos os dados de um usuário
router.get('/:idUsuario', historicoController.listarDados);

// Buscar dado por ID
router.get('/detalhe/:id', historicoController.buscarDado);

// Atualizar dado
router.put('/:id', historicoController.atualizarDado);

// Deletar dado
router.delete('/:id', historicoController.deletarDado);

module.exports = router;