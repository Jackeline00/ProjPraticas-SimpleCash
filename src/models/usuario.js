class Usuario {

    constructor(id, nome, senha, email, dataCriacao){
        this.id = id
        this.nome = nome
        this.senha = senha
        this.email = email
        this.dataCriacao = dataCriacao // data em que a conta foi criada
    }

    verificarSenha(senhaDigitada){
        return this.senha === senhaDigitada
    }

    

}

module.exports = Usuario // para poder acessar a classe em outros lugares do projeto