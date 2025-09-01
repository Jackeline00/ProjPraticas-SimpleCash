class Usuario {

    constructor(idUsuario, nome, senha, email, dataCriacao, saldoDaConta){
        this.id = idUsuario
        this.nome = nome
        this.senha = senha
        this.email = email
        this.dataCriacao = dataCriacao   // data em que a conta foi criada
        this.saldoTotal = saldoDaConta // valor que existe na conta, sem contar a poupança
    }

    verificarSenha(senhaDigitada){
        return this.senha === senhaDigitada
    }

    atualizarSenha(senhaAntiga, novaSenha) {
        if(this.senha === senhaAntiga)
            this.senha = novaSenha; 
    }

    editarDados(){

    }

    excluirConta(){

    }


}

module.exports = Usuario // para poder acessar a classe em outros lugares do projeto