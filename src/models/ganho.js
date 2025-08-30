class Ganho{
    constructor(id, usuarioId, valor, data, categoria, tipo, repeticao){
        this.id = id 
        this.usuarioId = usuarioId
        this.valor = valor
        this.data = data        // data em que foi ganho
        this.categoria = categoria     // no que foi gasto
        this.tipo = tipo               // se é fixo ou variável
        this.repeticao = repeticao     // semanal, mensal, null
    }


}

module.exports = Ganho  // para poder acessar a classe em outros lugares do projeto