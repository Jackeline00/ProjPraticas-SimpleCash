class Gasto{
    constructor(id, idUsuario, valor, data, categoria, tipo, repeticao, dataFinal, juros, tipoJuros){
        this.idGasto = id 
        this.idUsuario = idUsuario
        this.valor = valor
        this.data = data               // data em que o valor foi gasto 
        this.categoria = categoria     // no que foi gasto
        this.tipo = tipo               // se é fixo ou variável
        this.repeticao = repeticao     // semanal, mensal, null
        this.dataFinal = dataFinal     // até quando será repetido o gasto automaticamente
        this.juros = juros             // valor do juro, caso este exista
        this.tipoJuros = tipoJuros     // simples ou composto
    }

}

module.exports = Gasto  // para poder acessar a classe em outros lugares do projeto