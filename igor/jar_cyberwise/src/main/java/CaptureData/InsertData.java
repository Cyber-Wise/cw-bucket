package CaptureData;

import AlertManagement.Status;
import AuthenticateMachine.Machine;
import Connection.ConnectionLocal;
import org.springframework.jdbc.core.JdbcTemplate;
import Connection.ConnectionServer;

import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

public class InsertData {
    public static void inserirBanco(Monitoring monitoramento, Integer id, Machine machine, String horaInicio, String horaFim) {
        ConnectionServer connectionServer = new ConnectionServer();
        JdbcTemplate con = connectionServer.getConexaoDoBanco();

        String status = monitoramento.getStatus().getStatusMaquina();

        Long discoEmUso = monitoramento.getDiscoEmUso();
        Double porcentagemRam = monitoramento.getPorcentagemRam();
        Double ramEmUso = monitoramento.getRamEmUso();
        Double porcentagemDisco = monitoramento.getPorcentagemDisco();
        Double cpuEmUso = monitoramento.getCpuEmUso();
        Double gbEnviados = monitoramento.getGbEnviados();
        Double gbRecebidos = monitoramento.getGbRecebidos();
        Long pacotesEnviados = monitoramento.getPacotesEnviados();
        Long pacotesRecebidos = monitoramento.getPacotesRecebidos();

        DateTimeFormatter formato = DateTimeFormatter.ofPattern("HH:mm");
        LocalTime horaInicioTime = LocalTime.parse(horaInicio, formato);
        LocalTime horaFimTime = LocalTime.parse(horaFim, formato);

        try {
            while (true) {
                LocalTime horarioAtual = LocalTime.now();
                String horarioFormatado = horarioAtual.format(formato);

                // Verifica se está no intervalo de monitoramento
                if ((horarioAtual.isAfter(horaInicioTime) || horarioAtual.equals(horaInicioTime)) &&
                        (horarioAtual.isBefore(horaFimTime) || horarioAtual.equals(horaFimTime))) {

                    con.execute("INSERT INTO monitoramento (status_maquina, cpuEmUso, ramEmUso, tamanhoEmUsoDisco," +
                            " gbEnviados, gbRecebidos, pacotesEnviados, pacotesRecebidos, fk_maquina, data_hora) " +
                            "VALUES ('" + status + "', " + cpuEmUso + ", " + porcentagemRam + ", " + porcentagemDisco + ", " + gbEnviados + ", " +
                            gbRecebidos + ", " + pacotesEnviados + ", " + pacotesRecebidos + ", " + id + ", CURRENT_TIMESTAMP)");
                    System.out.println("Monitorando...");
                    CaptureData.pegarDados(id, machine ,horaInicio, horaFim);
                    Thread.sleep(5000);

                } else if (horarioAtual.isAfter(horaFimTime)) {
                    // Finaliza a captura de dados ao alcançar o horário de fim
                    System.out.println("Captura de dados finalizada!");
                    System.exit(0);
                } else {
                    // Fora do horário de monitoramento
                    System.out.println("Esperando o horario de inicio");
                    Thread.sleep(1000); // Intervalo para evitar um loop muito rápido
                }
            }
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
    }

    public static void inserirAlerta(String componente, Status status, Integer idMaquina){
        ConnectionServer connectionServer = new ConnectionServer();
        JdbcTemplate con = connectionServer.getConexaoDoBanco();

        String criticidade = status.getStatusMaquina();

        con.execute("INSERT INTO alertas VALUES " +
                "(NULL, '" + criticidade + "', CURRENT_TIMESTAMP, '" + componente + "', " + idMaquina + ");");
    }

    public static void HistoricoLocal(String componente, Status status, Integer idMaquina){
        ConnectionLocal connectionLocal = new ConnectionLocal();
        JdbcTemplate con = connectionLocal.getConexaoDoBanco();

        String criticiade = status.getStatusMaquina();

        con.execute("INSERT INTO historicoLocal VALUES " +
                "(" + idMaquina +", '" + criticiade +"', CURRENT_TIMESTAMP, '" + componente + "');");

    }
}
