# Implantação do SIGE IP v9

## 1. Criar o projeto Supabase
Crie um projeto e copie a Project URL e a Publishable Key. Nunca coloque Secret/Service Role Key no navegador.

## 2. Banco de dados
No SQL Editor, execute `supabase/migrations/001_schema.sql`.

## 3. Google Cloud
1. Crie ou selecione um projeto no Google Cloud.
2. Ative a Google Sheets API.
3. Crie uma conta de serviço e uma chave JSON.
4. Compartilhe a planilha com o e-mail da conta de serviço como Leitor.

## 4. Edge Function
Instale o Supabase CLI e execute:

```bash
supabase login
supabase link --project-ref SEU_PROJECT_REF
supabase secrets set GOOGLE_SERVICE_ACCOUNT_EMAIL="conta@projeto.iam.gserviceaccount.com"
supabase secrets set GOOGLE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
supabase functions deploy sync-google-sheets
```

## 5. Configurar o aplicativo
Copie `config.example.js` para `config.js` e informe:
- `supabaseUrl`
- `supabasePublishableKey`
- `spreadsheetUrl`

## 6. Publicar
Envie todos os arquivos para a raiz do GitHub Pages. Não envie credenciais privadas. `config.js` contém apenas chave publicável.

## 7. Primeiro acesso e migração
Abra o mesmo endereço e navegador onde estão seus dados atuais. Faça login. Se a nuvem estiver vazia, a versão v9 envia automaticamente o banco local existente ao Supabase, preservando os módulos e registros.

## 8. Sincronização
Clique em “Sincronizar planilha”. A Edge Function lê todas as abas via API oficial do Google, grava os itens estratégicos no Postgres e o painel recebe os dados.

## 9. Backups automáticos
A cada salvamento o estado principal é atualizado. O botão “Backup nuvem” cria uma cópia versionada. Para automatizar, habilite pg_cron e agende uma cópia diária da tabela `app_states` para `app_backups`, ou use o backup gerenciado do plano Supabase contratado.
