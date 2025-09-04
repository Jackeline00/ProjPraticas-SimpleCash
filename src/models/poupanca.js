class Poupanca{
    constructor(id, idUsuario, tipo, descricao, valor, data, repeticao, origem){
        this.idPoupanca = id;
        this.idUsuario = idUsuario;
        this.tipo = tipo;
        this.descricao = descricao;  // para que este dinheiro está sendo poupado
        this.valor = valor;
        this.data = data;
        this.repeticao = repeticao;  // de quanto em quanto tempo será quardado dinheiro de forma automática
        this.origem = origem;        // de qual renda saiu
    }

}

module.exports = Poupanca; // para poder acessar a classe em outros lugares do projeto