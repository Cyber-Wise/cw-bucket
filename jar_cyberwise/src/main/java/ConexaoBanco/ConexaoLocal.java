package ConexaoBanco;

import org.apache.commons.dbcp2.BasicDataSource;
import org.springframework.jdbc.core.JdbcTemplate;

public class ConexaoLocal {
    private JdbcTemplate conexaoDoBanco;

    public ConexaoLocal(){
        BasicDataSource dataSource = new BasicDataSource();

        BasicDataSource dataSource1 = new BasicDataSource();
        dataSource.setDriverClassName("com.mysql.cj.jdbc.Driver");
        dataSource.setUrl("jdbc:mysql://localhost:3306/cyberwise");
//        dataSource.setUsername("root");
        dataSource.setUsername("cyberwise");
        dataSource.setPassword("cyber100");
//        dataSource.setPassword("1513");

        conexaoDoBanco = new JdbcTemplate(dataSource1);
    }

    public JdbcTemplate getConexaoDoBanco() {
        return conexaoDoBanco;
    }
}
