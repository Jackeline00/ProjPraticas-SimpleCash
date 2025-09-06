const sql = require('mssql');
require('dotenv').config();

const config = process.env.STRING_CONNECTION; // pega a string de conexão

async function conectaBD() {
  try {
    const pool = await sql.connect(config);
    return pool;
  } catch (err) {
    console.error('Erro ao conectar no banco:', err);
    throw err;
  }
}

module.exports = { conectaBD };
