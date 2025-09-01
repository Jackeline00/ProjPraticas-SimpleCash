class Poupanca{
    constructor(id, idUsuario, tipo, descricao, valor, data, categoria, repeticao, origem){
        this.idPoupanca = id
        this.idUsuario = idUsuario
        this.tipo = tipo
        this.descricao = descricao
        this.valor = valor
        this.data = data
        this.categoria = categoria
        this.repeticao = repeticao  // de quanto em quanto tempo será quardado dinheiro de forma automática
        this.origem = origem        // de qual renda saiu
    }

}

module.exports = Poupanca // para poder acessar a classe em outros lugares do projeto