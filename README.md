# 🎯 Radar de Concursos - Alertas com IA

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Telegram API](https://img.shields.io/badge/Telegram-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-007ACC?style=for-the-badge&logo=typescript&logoColor=white)

Um sistema automatizado e inteligente projetado para monitorizar editais de concursos públicos e notificar os candidatos diretamente via Telegram, de acordo com as suas preferências de área, estado e escolaridade.

---

## 📖 Sobre o Projeto

O **Radar de Concursos** nasceu para resolver o problema da perda de prazos em inscrições para vagas no setor público. Em vez de obrigar o utilizador a aceder a dezenas de sites de bancas organizadoras diariamente, o sistema inverte o fluxo: a plataforma monitoriza os dados e entrega alertas cirúrgicos e personalizados diretamente no telemóvel do candidato.

A arquitetura foi desenhada para ser altamente escalável, de baixo custo (Serverless) e totalmente imune a bloqueios de spam, optando pelo Telegram como canal oficial de entrega devido à flexibilidade da sua API e ausência de custos por mensagem.

---

## ⚙️ Arquitetura e Fluxo de Funcionamento

Para garantir uma experiência de utilizador (UX) fluida e manter a segurança e integridade do banco de dados, o sistema utiliza uma abordagem inovadora de **Payload em Base64 via Deep Link**:

1. **Frontend (Flutter Web):** O utilizador seleciona os filtros (Área de Interesse, Estado, Escolaridade) numa interface moderna e responsiva.
2. **Deep Link Base64:** O Flutter compacta as escolhas do utilizador num payload convertido para `Base64 URL-Safe` e anexa esse código ao link de redirecionamento do Telegram (ex: `t.me/RadarConcursosBot?start=PAYLOAD_AQUI`).
3. **Ativação (Telegram):** O utilizador é redirecionado para a aplicação do Telegram e clica em "Começar" (`/start`).
4. **Backend (Supabase Edge Functions):** O Telegram dispara um Webhook para uma Edge Function em TypeScript hospedada no Supabase.
5. **Processamento e Upsert:** A função descodifica o Base64, extrai os filtros, captura o `telegram_id` e o `nome` real do utilizador, realiza um *Upsert* (inserção/atualização) no PostgreSQL e devolve uma mensagem formatada em HTML confirmando o registo.

---

## 🛠️ Tecnologias Utilizadas

*   **Frontend:** Flutter (Dart), `dropdown_button2` (v3.0), `url_launcher`.
*   **Backend & Banco de Dados:** Supabase (PostgreSQL, Edge Functions em Deno/TypeScript).
*   **Integração de Mensageria:** Telegram Bot API (Webhooks).
*   **APIs Externas:** IBGE API (para listagem dinâmica de Estados/UFs).

---

## 🗄️ Estrutura do Banco de Dados

O PostgreSQL no Supabase foi modelado com políticas rígidas de **Row Level Security (RLS)**. As inserções são geridas inteiramente pelo Backend (via *Service Role Key*), impedindo manipulações diretas pelo lado do cliente.

### Tabela `usuarios`
| Coluna | Tipo | Descrição |
| :--- | :--- | :--- |
| `id` | `UUID` | Chave primária (Gerada automaticamente) |
| `telegram_id` | `BIGINT` | ID único do utilizador no Telegram (UNIQUE) |
| `nome` | `VARCHAR(255)`| Primeiro nome capturado pelo Telegram |
| `area_interesse` | `VARCHAR(50)` | Ex: Tecnologia da Informação, Fiscal, Saúde |
| `estado_uf` | `VARCHAR(10)` | Sigla do Estado escolhido |
| `escolaridade` | `VARCHAR(50)` | Ex: Nível Superior, Médio |
| `opt_in` | `BOOLEAN` | Confirmação de consentimento para alertas |
| `ativo` | `BOOLEAN` | Status da subscrição |

*(Futuras tabelas como `concursos` e `envios_notificacoes` atuarão no controlo de não-duplicação de envio de editais para a IA).*

---

## 🚀 Como Executar o Projeto Localmente

### Pré-requisitos
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) configurado (Versão 3.10+).
*   Conta ativa no [Supabase](https://supabase.com/).
*   Um Bot criado no Telegram via [@BotFather](https://t.me/botfather).

### Passos para Instalação

1. Clone este repositório:
   ```bash
   git clone [https://github.com/seu-usuario/radar-concursos.git](https://github.com/seu-usuario/radar-concursos.git)
   cd radar-concursos
