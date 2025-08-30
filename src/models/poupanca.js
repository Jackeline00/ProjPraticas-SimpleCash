class Poupanca{
    constructor(id, usuarioId, valor, data, categoria, tipo, repeticao){
        this.id = id
        this.usuarioId = usuarioId
        this.valor = valor
        this.data = data
        this.categoria = categoria
        this.tipo = tipo
        this.repeticao = repeticao
    }

}

module.exports = Poupanca // para poder acessar a classe em outros lugares do projeto