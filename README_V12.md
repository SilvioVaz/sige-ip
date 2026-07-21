# SIGE-IP V12 Enterprise Consolidada

Versão reconstruída sobre a base V10.1/V11.1, preservando módulos, dados, relatórios e melhorias anteriores.

## Principais garantias
- `index.html` contém somente a estrutura HTML da aplicação.
- Código visual em `assets/app.css`.
- Código funcional em `assets/app.js`.
- Arquivos SQL permanecem separados e nunca devem ser renomeados para `index.html`.
- Inicialização local funciona mesmo sem Supabase configurado.
- Mantida a mesma base IndexedDB e a rotina de migração existente.
- Dashboard executivo permanece limpo, com detalhes recolhidos.
- Módulos de governança e relatórios da V10.1 permanecem integrados.

## Publicação no GitHub Pages
Envie o conteúdo desta pasta para a raiz do repositório. Confirme que `index.html` começa com `<!DOCTYPE html>`.
