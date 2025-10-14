const express = require('express');
const cors = require('cors');
require('dotenv').config();

// importar rotas
const usuarioRoutes = require('./api/src/routes/usuarioRoutes');
const ganhosRoutes = require('./api/src/routes/ganhoRoutes');
const gastosRoutes = require('./api/src/routes/gastoRoutes');
const poupancaRoutes = require('./api/src/routes/poupancaRoutes');
const historicoRoutes = require('./api/src/routes/historicoRoutes');

const app = express();

// middlewares
app.use(cors()); // libera acesso externo (front-end em Flutter)
app.use(express.json()); // permite receber JSON no req.body

// rotas
app.use('/usuarios', usuarioRoutes);
app.use('/ganhos', ganhosRoutes);
app.use('/gastos', gastosRoutes);
app.use('/poupanca', poupancaRoutes);
app.use('/historico', historicoRoutes);

// rota inicial só para teste
app.get('/', (req, res) => {
  res.send('API de SimpleCash rodando');
});

// porta do servidor (pode vir do .env ou default 3000)
const PORT = process.env.PORTA || 3000;
app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});
