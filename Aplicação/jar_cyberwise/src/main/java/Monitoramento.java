import CapturarDados.CapturarDados;
import ConexaoBanco.Conexao;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import java.util.Scanner;

public class Monitoramento {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);

        // Estabelecer a conexão com o banco
        JdbcTemplate con = criarConexao();

          if (con != null) {
            // Realizar o login do usuário e obter o ID da empresa do funcionário logado
            Integer idEmpresa = fazerLogin(con, scanner);

            // Se o login foi bem-sucedido, continuar com o programa
            if (idEmpresa != null) {
                System.out.println("Insira o número de série da máquina:");
                Integer numeroSerie = scanner.nextInt();

                // Consultar a máquina com base no número de série e no ID da empresa do funcionário logado
                List<Maquina> lista = con.query(
                        "SELECT maquina.id, maquina.modelo " +
                                "FROM maquina " +
                                "INNER JOIN funcionario ON maquina.fk_empresa = funcionario.fk_empresa " +
                                "WHERE maquina.numSerie = ? AND funcionario.fk_empresa = ?",
                        new Object[]{numeroSerie, idEmpresa},
                        new BeanPropertyRowMapper<>(Maquina.class));

                if (lista.isEmpty()) {
                    System.out.println("Código de acesso inválido!");
                } else {
                    System.out.println("Logado com sucesso");
                    System.out.println("Dados sendo coletados");

                    CapturarDados.pegarDados(lista.get(0).getId());
                }
            } else {
                // Se o login falhar, encerrar o programa
                System.out.println("Falha ao fazer login. Encerrando o programa.");
            }
        } else {
            // Se a conexão falhar, encerrar o programa
            System.out.println("Falha ao conectar ao banco de dados. Encerrando o programa.");
        }
    }

    // Método para criar a conexão com o banco
// Método para criar a conexão com o banco
    private static JdbcTemplate criarConexao() {
        Scanner scanner = new Scanner(System.in);

        System.out.println("Jar iniciando...");
        System.out.println("Insira o IP do banco de dados:");
        String ipBanco = scanner.nextLine();
        System.out.println("Insira o usuário do banco:");
        String nomeUsuario = scanner.nextLine();
        System.out.println("Insira a senha do usuário:");
        String senhaUsuario = scanner.nextLine();

        Conexao conexao = new Conexao();
        conexao.setIpBanco(ipBanco);
        conexao.setNome(nomeUsuario);
        conexao.setSenha(senhaUsuario);

        JdbcTemplate con = conexao.getConexaoDoBanco();

        // Testar a conexão
        try {
            con.getDataSource().getConnection().close();
            System.out.println("Conexão bem-sucedida!");
        } catch (SQLException e) {
            System.out.println("Falha ao conectar ao banco de dados: " + e.getMessage());
            con = null;
        }

        return con;
    }

    // Método para fazer o login do usuário e retornar o ID da empresa
    private static Integer fazerLogin(JdbcTemplate con, Scanner scanner) {
        boolean logado = false;
        Integer idEmpresa = null;

        // Loop para solicitar email e senha do usuário
        while (!logado) {
            System.out.println("Insira seu email:");
            String email = scanner.nextLine();
            System.out.println("Insira sua senha:");
            String senha = scanner.nextLine();

            // Verificar se o usuário existe na tabela "funcionario"
            List<Map<String, Object>> funcionarios = con.queryForList(
                    "SELECT * FROM funcionario WHERE email = ? AND senha = ?",
                    email, senha);

            if (funcionarios.isEmpty()) {
                System.out.println("Email ou senha incorretos. Tente novamente.");
            } else {
                // Se chegou até aqui, o login foi bem-sucedido
                System.out.println("Login bem-sucedido");
                logado = true;
                idEmpresa = (Integer) funcionarios.get(0).get("fk_empresa");
            }
        }

        return idEmpresa;
    }
}
