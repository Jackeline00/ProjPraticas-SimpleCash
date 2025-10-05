const express = require('express');
const router = express.Router();
const usuarioController = require('../controllers/usuarioController');

// Criar usuário
router.post('/', usuarioController.criarUsuario);

// Listar todos os usuários
router.get('/', usuarioController.listarUsuarios);

// Buscar usuário por ID
router.get('/:id', usuarioController.buscarUsuario);

//Buscar usuário por email
router.get('/:email', usuarioController.buscarPorEmail);

//Buscar nome do usuário por email
router.get('/nome/:email', usuarioController.buscarNome);

// Atualizar usuário
router.put('/:id', usuarioController.atualizarUsuario);

// Deletar usuário
router.delete('del/:email', usuarioController.deletarUsuario);

// Fazer login
router.post('/login',usuarioController.loginUsuario);

// Atualizar saldo
// router.put('/:id/saldo', usuarioController.atualizarSaldo);

module.exports = router;