package CapturarDados;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import ConexaoBanco.Conexao;
import ConexaoBanco.ConexaoLocal;

import java.util.List;

public class InsertDados {
    public static void inserirBanco(Componentes componentes, Integer id) {
        Conexao conexao = new Conexao();
        ConexaoLocal conexaoLocal = new ConexaoLocal();

        JdbcTemplate con = conexao.getConexaoDoBanco();
        JdbcTemplate con1 = conexaoLocal.getConexaoDoBanco();


        long totalDisco = componentes.getTotalDisco();
        long tamanhoDisponivel = componentes.getTamanhoDisponivel();

        Double totalRam = componentes.getTotalRam();
        Double ramDisponivel = componentes.getRamDisponivel();

        Double cpuEmUso = componentes.getCpuEmUso();

        try {

            while (true) {

                con.execute("INSERT INTO monitoramento (cpuEmUso, ramDisponivel, tamanhoDisponivelDisco, fk_maquina, data_hora) " +
                        "VALUES ("+ cpuEmUso + ", " + ramDisponivel + ", " + tamanhoDisponivel + ", " + id + ", CURRENT_TIMESTAMP)");


                con1.execute("INSERT INTO monitoramento (cpuEmUso, ramDisponivel, tamanhoDisponivelDisco, fk_maquina, data_hora) " +
                        "VALUES ("+ cpuEmUso + ", " + ramDisponivel + ", " + tamanhoDisponivel + ", " + id + ", CURRENT_TIMESTAMP)");
//         lembrar de colocar rede

//         con.execute("INSERT INTO monitoramento (dadosCPU, dadosRAM, dadosDISCO, dadosREDE, fk_maquina, data_hora) " +
//                 "VALUES ("+ cpuEmUso + ", " + ramDisponivel + ", " + tamanhoDisponivel + ", 4.2, 1, CURRENT_TIMESTAMP)");

                System.out.println("Coletando...");

                Thread.sleep(5000);
            }
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }


    }
}
