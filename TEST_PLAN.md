# Plano de Teste de Uso Contínuo (GO/NO-GO) - rocafe.app

## 1. Objetivo

Este documento descreve o procedimento de teste de uso contínuo de 7 dias para o `rocafe.app`. O objetivo é simular o uso real e intenso do software para validar a estabilidade da aplicação, a integridade dos dados financeiros e a robustez do sistema de backup/restore.

A conclusão bem-sucedida deste plano é o critério final para uma decisão de **GO (aprovado para produção)** ou **NO-GO (lançamento bloqueado)**.

## 2. Pré-requisitos

- O aplicativo deve ser compilado com sucesso na versão de `Release`.
- Todos os testes automatizados (unitários e de integração, incluindo os dos Blocos 1 e 2) devem passar com 100% de sucesso.

## 3. Procedimento: Simulação de 7 Dias de Uso Real

Execute as seguintes ações na ordem especificada. Documente os resultados de cada dia.

---

### **Dia 1: Configuração Inicial do Negócio**

O objetivo é popular o banco de dados com a estrutura inicial de um negócio.

1.  **Fornecedores:** Crie 3 fornecedores diferentes (ex: "Distribuidora de Café", "Fábrica de Embalagens", "Mercado Local").
2.  **Matérias-Primas:** Crie 5 produtos do tipo `Matéria-Prima`.
    - Café em Grãos (Custo: R$ 50,00/kg)
    - Leite (Custo: R$ 4,00/L)
    - Açúcar (Custo: R$ 5,00/kg)
    - Copo de Papel (Custo: R$ 0,30/unidade)
    - Farinha (Custo: R$ 6,00/kg)
3.  **Produtos Fabricados (Simples e Aninhado):**
    - Crie um produto `Fabricado` chamado "Espresso". Crie uma receita para ele usando "Café em Grãos" e "Copo de Papel".
    - Crie um produto `Fabricado` chamado "Massa Base". Crie uma receita para ele usando "Farinha" e "Açúcar".
    - Crie um produto `Fabricado` chamado "Bolo de Fubá". Crie uma receita para ele que utilize a "Massa Base" como um de seus ingredientes (receita aninhada).
4.  **Despesas:** Crie 2 despesas recorrentes (ex: "Aluguel", "Software").

---

### **Dia 2: Operação Normal**

O objetivo é simular um dia de vendas e despesas.

1.  **Vendas:** Registre 15 vendas de produtos variados ("Espresso", "Bolo de Fubá", etc.).
2.  **Despesas:** Registre 2 despesas pontuais (ex: "Compra de guardanapos", "Manutenção da máquina").
3.  **Verificação:** Abra o relatório DRE e observe os valores de receita e despesa. Eles não precisam ser auditados ainda, apenas verifique se os totais refletem as operações do dia.

---

### **Dia 3: Gestão e Análise**

O objetivo é usar funcionalidades de gestão e relatórios.

1.  **Clientes:** Crie 3 novos clientes.
2.  **Vendas a Clientes:** Associe uma das vendas do Dia 2 a um cliente recém-criado. Registre 2 novas vendas diretamente para os outros clientes.
3.  **Análise:** Gere o relatório DRE novamente. Os números devem estar maiores. Anote o **Lucro Líquido** exibido para verificação posterior.

---

### **Dia 4: Modificações e Evolução**

O objetivo é testar a capacidade do sistema de se adaptar a mudanças no negócio.

1.  **Preço:** Altere o preço de venda de um dos produtos (ex: "Bolo de Fubá").
2.  **Receita:** Crie uma **nova versão** da receita do "Espresso", alterando a quantidade de café.
3.  **Novas Vendas:** Registre vendas dos produtos modificados ("Bolo de Fubá" e "Espresso") e verifique se o novo preço e custo (se aplicável) são utilizados.

---

### **Dia 5: Teste de Falha e Recuperação (CRÍTICO)**

Este é o dia mais importante. O objetivo é simular um desastre e testar a recuperação.

1.  **Backup:** Use a funcionalidade de "Backup Manual" para criar um arquivo de backup seguro em um local conhecido (ex: Mesa do computador).
2.  **Simulação de Desastre:**
    - Feche completamente o `rocafe.app`.
    - Navegue até a pasta de suporte do aplicativo (`~/Library/Application Support/rocafe/`).
    - **Delete ou renomeie o arquivo `rocafe.sqlite`**. Isso simula uma corrupção total do banco de dados.
3.  **Verificação da Falha:**
    - Tente abrir o `rocafe.app`.
    - **Comportamento esperado:** O aplicativo não deve "crashar" silenciosamente. Ele deve abrir e mostrar um estado de erro claro, informando que os dados não puderam ser carregados, ou apresentar uma tela vazia.
4.  **Restauração:**
    - Use a funcionalidade de "Restaurar Backup".
    - Selecione o arquivo de backup criado na etapa 1.
    - Siga as instruções. O aplicativo provavelmente pedirá para ser reiniciado.
5.  **Validação Pós-Restauração:**
    - Reinicie o aplicativo.
    - **Verificação CRÍTICA:** Verifique se **TODOS** os dados dos Dias 1 a 4 estão perfeitamente intactos. Clientes, produtos, receitas, vendas, despesas, etc. Compare o Lucro Líquido do DRE com o valor anotado no Dia 3.

---

### **Dia 6: Continuidade Pós-Restauração**

O objetivo é garantir que o banco de dados restaurado é 100% funcional.

1.  **Operação Normal:** Continue as operações do negócio: registre mais 10 vendas e 1 nova despesa.
2.  **Verificação:** Certifique-se de que o aplicativo se comporta normalmente, sem lentidão ou erros inesperados.

---

### **Dia 7: Auditoria Final**

O objetivo é realizar uma verificação financeira completa.

1.  **Exportar Relatórios:** Gere o relatório DRE final para todo o período de 7 dias.
2.  **Auditoria Manual:** Em uma planilha separada, some manualmente todas as receitas de vendas registradas e todas as despesas (pontuais e recorrentes aplicadas ao período).
3.  **Comparação:** Compare o resultado da sua planilha com o relatório DRE gerado pelo aplicativo. Os valores de **Receita Bruta, Despesas Totais e Lucro Líquido** devem ser **idênticos**.

## 4. Critérios de GO / NO-GO

### **Condições para GO (Aprovado para Produção)**

- [ ] Todas as ações dos 7 dias foram concluídas sem nenhum crash da aplicação.
- [ ] A restauração do backup no Dia 5 foi concluída com sucesso, e **100% dos dados** foram restaurados com integridade.
- [ ] O aplicativo lidou de forma graciosa com o arquivo de banco de dados ausente no Dia 5, exibindo um estado de erro ou vazio, sem crashar.
- [ ] A auditoria financeira do Dia 7 mostrou que os relatórios do aplicativo são **100% precisos**.
- [ ] Nenhum erro inesperado (telas travadas, estados de UI inconsistentes) foi observado.

### **Condições para NO-GO (Lançamento Bloqueado) - *Qualquer uma destas condições resulta em NO-GO***

- [ ] **Qualquer** perda de dados ou corrupção de dados após a restauração do backup.
- [ ] **Qualquer** discrepância, mesmo que de centavos, na auditoria financeira final.
- [ ] **Um único** crash inexplicado ou uma falha que exija intervenção manual nos arquivos do sistema para ser corrigida.
- [ ] Falha no processo de restauração que deixe o aplicativo em um estado inutilizável.
- [ ] A aplicação não lidou de forma clara com a ausência do banco de dados no Dia 5.

---

Se as condições de **GO** forem atendidas, o software é considerado **Pronto para Uso**. Caso contrário, os problemas identificados devem ser corrigidos e este plano de teste deve ser executado novamente na íntegra.
