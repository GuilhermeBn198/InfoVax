# InfoVax
Aplicação flutter para recebimento e rastreamento de informações advindas de dispositivos Iot de controle de segurança de refrigeradores de vacinas de hospitais

## Problema Abordado

A gestão eficaz do armazenamento de vacinas depende de informações confiáveis e acessíveis sobre as condições dos refrigeradores. Muitos sistemas hospitalares carecem de uma interface prática que permita visualizar em tempo real a temperatura e o acesso aos refrigeradores, dificultando a tomada de decisões rápidas em casos de irregularidades. Isso pode comprometer a qualidade das vacinas e a saúde pública.

## Solução Proposta

InfoVax é um sistema de monitoramento que atua como um dashboard para exibir, de forma clara e intuitiva, as informações enviadas pelo SafeVax. Por meio de um broker MQTT, como o HiveMQ, o InfoVax permite que dados sobre a temperatura e o status de abertura das portas dos refrigeradores sejam apresentados em tempo real. Dessa forma, profissionais da área de saúde podem identificar rapidamente anomalias e agir para proteger o estoque de vacinas.

## Ferramentas Utilizadas

- HiveMQ: Broker MQTT para intermediação das mensagens entre SafeVax e InfoVax.

- Flutter: Framework para o desenvolvimento do dashboard multiplataforma (Android, iOS e web).

## Implementações Futuras

- Alertas em tempo real: Notificações push no app ou via SMS para informação imediata em caso de irregularidades.

- Firebase ou SQLite: Armazenamento local ou na nuvem dos dados para consultas e históricos.

- Relatórios detalhados: Exibição de gráficos e análises históricas do desempenho dos refrigeradores.

- Integração com sistemas hospitalares: Sincronização dos dados com plataformas de gestão de saúde, como ERP hospitalar.

- Personalização de parâmetros: Configuração de limites personalizados para temperatura e tempo de abertura das portas.

O InfoVax, ao complementar o SafeVax, oferece uma solução abrangente para o monitoramento e a gestão do armazenamento de vacinas, garantindo segurança e eficiência em ambientes hospitalares.
