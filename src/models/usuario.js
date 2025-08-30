class Usuario {

    constructor(id, nome, senha, email, dataCriacao, saldoDaConta){
        this.id = id
        this.nome = nome
        this.senha = senha
        this.email = email
        this.dataCriacao = dataCriacao   // data em que a conta foi criada
        this.saldoDaConta = saldoDaConta // valor que existe na conta, sem contar a poupança
    }

    verificarSenha(senhaDigitada){
        return this.senha === senhaDigitada
    }

    atualizarSenha(senhaAntiga, novaSenha) {
        if(this.senha === senhaAntiga)
            this.senha = novaSenha; 
    }

}

module.exports = Usuario // para poder acessar a classe em outros lugares do projeto