SIGE IP v8.2 — CORREÇÃO DAS ABAS

Correção aplicada:
- As seções Planejamento Google e Plataforma Executiva agora são criadas na inicialização.
- A função de navegação também cria a seção automaticamente caso ela ainda não exista.
- Cache do aplicativo atualizado.
- Mesmo banco IndexedDB preservado: SIGE_IP_LOCAL_DB.

ATUALIZAÇÃO NO GITHUB
1. Envie o CONTEÚDO desta pasta para a raiz do repositório sige-ip.
2. Confirme que index.html e sw.js ficaram na raiz.
3. Abra https://silviovaz.github.io/sige-ip/?v=82
4. Pressione Ctrl+Shift+R.
5. Caso necessário: DevTools > Application > Service Workers > Unregister; depois recarregue.

Não limpe os dados do site, pois eles contêm o IndexedDB local.
