const sql = require('mssql');
require('dotenv').config();

const config = JSON.parse(process.env.STRING_CONNECTION); // converte a string JSON em objeto

async function conectaBD() {
  try {
    const pool = await sql.connect(config);
    //console.log('Conectado ao MSSQL');
    return pool;
  } catch (err) {
    console.error('Erro ao conectar no banco:', err);
    throw err;
  }
}

module.exports = { conectaBD };
