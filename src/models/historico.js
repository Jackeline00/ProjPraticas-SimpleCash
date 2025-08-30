class Historico{
    constructor(acao, data, valor){
        this.acao = acao   // registrar gasto, ganho, cadastrar
        this.data = data   // data em que foi feita tal ação
        this.valor = valor // o valor gasto, ganho ou guardado
    }

}

module.exports = Historico // para poder acessar a classe em outros lugares do projeto