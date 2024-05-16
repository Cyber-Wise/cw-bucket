package ConexaoBanco;

import org.apache.commons.dbcp2.BasicDataSource;
import org.springframework.jdbc.core.JdbcTemplate;

public class Conexao {
    private JdbcTemplate conexaoDoBanco;

    public Conexao(){
        BasicDataSource dataSource = new BasicDataSource();
        dataSource.setDriverClassName("com.mysql.cj.jdbc.Driver");
        dataSource.setUrl("jdbc:mysql://34.229.136.76:3306/cyberwise");
//        dataSource.setUsername("root");
        dataSource.setUsername("cyberwise");
        dataSource.setPassword("cyber100");
//        dataSource.setPassword("1513");

        conexaoDoBanco = new JdbcTemplate(dataSource);

    }

    public JdbcTemplate getConexaoDoBanco() {
        return conexaoDoBanco;
    }
}
