class Gasto{
    constructor(id, idUsuario, tipo, descricao, valor, data, repeticao, dataInicio, dataFinal, quantidadeDeParcelas, juros, tipoJuros){
        this.idGasto = id; 
        this.idUsuario = idUsuario;
        this.tipo = tipo;               // se é fixo ou variável
        this.descricao = descricao;     // no que foi gasto
        this.valor = valor;
        this.data = data;               // data em que o valor foi gasto 
        this.repeticao = repeticao;     // semanal, mensal, null
        this.dataInicio = dataInicio;   // primeiro dia em que será descontado o valor
        this.dataFinal = dataFinal;     // até quando será repetido o gasto automaticamente
        this.quantidadeDeParcelas = quantidadeDeParcelas;
        this.juros = juros;             // valor do juro, caso este exista
        this.tipoJuros = tipoJuros;     // simples ou composto
    }

}

module.exports = Gasto  // para poder acessar a classe em outros lugares do projeto