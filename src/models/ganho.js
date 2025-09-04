class Ganho{
    constructor(id, idUsuario, valor, data, descricao, tipo, repeticao){
        this.idGanho = id 
        this.idUsuario = idUsuario
        this.valor = valor
        this.data = data               // data em que foi ganho
        this.descricao = descricao     // no que foi gasto
        this.tipo = tipo               // se é fixo ou variável
        this.repeticao = repeticao     // semanal, mensal, null
    }


}

module.exports = Ganho  // para poder acessar a classe em outros lugares do projeto