class Gasto{
    constructor(id, usuarioId, valor, data, categoria, tipo, repeticao, juros, tipoJuros){
        this.id = id 
        this.usuarioId = usuarioId
        this.valor = valor
        this.data = data        // data em que o valor foi gasto 
        this.categoria = categoria     // no que foi gasto
        this.tipo = tipo               // se é fixo ou variável
        this.repeticao = repeticao     // semanal, mensal, null
        this.juros = juros             // valor do juro, caso este exista
        this.tipoJuros = tipoJuros     // simples ou composto
    }

    calcularJuros(){

    }




}

module.exports = Gasto  // para poder acessar a classe em outros lugares do projeto