package ConexaoBanco;

import org.apache.commons.dbcp2.BasicDataSource;
import org.springframework.jdbc.core.JdbcTemplate;


import javax.sql.DataSource;

public class Conexao {
    private static String ipBanco;
    private static String nome;
    private static String senha;

    private JdbcTemplate conexaoDoBanco;

    public Conexao(){
        BasicDataSource dataSource = new BasicDataSource();
        dataSource.setDriverClassName("com.mysql.cj.jdbc.Driver");
        dataSource.setUrl("jdbc:mysql://"+ipBanco+":3306/cyberwise");
        dataSource.setUsername(nome);
        dataSource.setPassword(senha);

        conexaoDoBanco = new JdbcTemplate(dataSource);
    }

    public JdbcTemplate getConexaoDoBanco() {
        return conexaoDoBanco;
    }

    public static String getIpBanco() {
        return ipBanco;
    }

    public static void setIpBanco(String ipBanco) {
        Conexao.ipBanco = ipBanco;
    }

    public static String getNome() {
        return nome;
    }

    public static void setNome(String nome) {
        Conexao.nome = nome;
    }

    public static String getSenha() {
        return senha;
    }

    public static void setSenha(String senha) {
        Conexao.senha = senha;
    }
}

