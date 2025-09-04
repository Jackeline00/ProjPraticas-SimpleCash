const express = require('express');
const cors = require('cors');
require('dotenv').config();

// importar rotas
const usuarioRoutes = require('./routes/usuarioRoutes');
const ganhosRoutes = require('./routes/ganhosRoutes');
const gastosRoutes = require('./routes/gastosRoutes');
const poupancaRoutes = require('./routes/poupancaRoutes');
const historicoRoutes = require('./routes/historicoRoutes');

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
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});
