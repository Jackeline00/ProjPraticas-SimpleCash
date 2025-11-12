require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { conectaBD } = require('./api/src/db/db.js'); 

// importar rotas
const usuarioRoutes = require('./api/src/routes/usuarioRoutes');
const ganhosRoutes = require('./api/src/routes/ganhoRoutes');
const gastosRoutes = require('./api/src/routes/gastoRoutes');
const poupancaRoutes = require('./api/src/routes/poupancaRoutes');
const historicoRoutes = require('./api/src/routes/historicoRoutes');

const app = express();

// middlewares
app.use(cors()); // libera acesso externo (Flutter)
app.use(express.json()); // permite receber JSON no req.body

// tenta conectar ao banco ANTES de rodar o servidor
(async () => {
  try {
    await conectaBD();
    console.log('Conectado ao banco com sucesso!');
  } catch (err) {
    console.error('Falha na conexão com o banco:', err);
  }
})();

// rotas
app.use('/usuarios', usuarioRoutes);
app.use('/ganhos', ganhosRoutes);
app.use('/gastos', gastosRoutes);
app.use('/poupanca', poupancaRoutes);
app.use('/historico', historicoRoutes);

// rota inicial de teste
app.get('/', (req, res) => {
  res.send('API de SimpleCash rodando');
});

// porta do servidor
const PORT = process.env.PORTA || 3000;
app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});
