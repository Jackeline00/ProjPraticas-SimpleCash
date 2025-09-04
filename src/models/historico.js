class Historico{
    constructor(id, idUsuario, tipoAtividade, idReferencia, descricao, valor, data){
        this.idHistorico = id;
        this.idUsuario = idUsuario;           // o usuário que realizou a ação
        this.tipoAtividade = tipoAtividade;   // registrar gasto, ganho, cadastrar
        this.idReferencia = idReferencia;     // indica o id da atividade em sua tabela (ganho, gasto, ..)
        this.descricao = descricao;
        this.valor = valor;                   // o valor gasto, ganho ou guardado
        this.data = data;                     // data em que foi feita tal ação
    }

}

module.exports = Historico; // para poder acessar a classe em outros lugares do projeto