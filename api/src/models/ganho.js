class Ganho{
    constructor(id, idUsuario, valor, data, descricao, tipo, repeticao){
        this.idGanho = id; 
        this.idUsuario = idUsuario;
        this.tipo = tipo;               // se é fixo ou variável
        this.descricao = descricao;     // de onde veio o ganho
        this.valor = valor;             // quanto foi ganho
        this.data = data;               // data em que foi ganho
        this.repeticao = repeticao;     // semanal, mensal, null
    }


}

module.exports = Ganho;  // para poder acessar a classe em outros lugares do projeto