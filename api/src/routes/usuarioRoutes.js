const express = require('express');
const router = express.Router();
const usuarioController = require('../controllers/usuarioController');

// Criar usuário
router.post('/', usuarioController.criarUsuario);

// Listar todos os usuários
router.get('/', usuarioController.listarUsuarios);

// Buscar usuário por ID
router.get('/:id', usuarioController.buscarUsuario);

// Buscar id do usuário por email
router.get('/id/:email', usuarioController.buscarId);

// Buscar dados do usuário
router.get('/dados/:emailPk', usuarioController.buscarUsuarioPorEmail)

// Buscar nome do usuário por email
router.get('/nome/:email', usuarioController.buscarNome);

// Buscar senha do usuário por email
router.get('/senha/:email', usuarioController.buscarSenha);

// Buscar saldo do usuário por email
router.get('/saldo/:email', usuarioController.buscarSaldo);

// Atualizar usuário 
router.put('/:emailPk', usuarioController.atualizarUsuario);

// Deletar usuário
router.delete('del/:email', usuarioController.deletarUsuario);

// Fazer login
router.post('/login',usuarioController.loginUsuario);

// Atualizar saldo
// router.put('/:id/saldo', usuarioController.atualizarSaldo);

module.exports = router;