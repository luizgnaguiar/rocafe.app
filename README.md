# rocafe.app - PDV Enxuto para macOS

Este é o código-fonte para o projeto `rocafe.app`, um sistema de Ponto de Venda (PDV) simplificado para macOS, gerado com base em uma arquitetura detalhada.

## Visão Geral

O projeto utiliza uma arquitetura MVVM (Model-View-ViewModel) com SwiftUI para a interface de usuário. A persistência de dados é feita com o banco de dados SQLite, gerenciado pela biblioteca [GRDB.swift](https://github.com/groue/GRDB.swift).

A estrutura do projeto é modular, com cada funcionalidade principal (Produtos, Receitas, Clientes, etc.) organizada em sua própria pasta dentro de `rocafe/Features`.

## Estrutura de Pastas

```
rocafe.app/
├── rocafe/
│   ├── App/          (Ponto de entrada da aplicação e navegação principal)
│   ├── Core/         (Modelos de dados, banco de dados e lógica de negócio)
│   │   ├── Models/
│   │   ├── Database/
│   │   └── Services/
│   ├── Features/     (Módulos da aplicação: Produtos, Clientes, etc.)
│   └── Shared/       (Componentes de UI, extensões e utilitários reutilizáveis)
└── rocafe.xcodeproj  (Arquivo do projeto Xcode - a ser criado)
```

## Como Compilar e Executar

Este repositório contém apenas os arquivos de código-fonte (`.swift`). Para compilar e executar o projeto, você precisará do Xcode e deverá seguir os seguintes passos:

### 1. Criar o Projeto no Xcode

1.  Abra o Xcode.
2.  Selecione **File > New > Project...**.
3.  Escolha o template **macOS > App**.
4.  Nomeie o projeto como `rocafe` (ou `rocafe.app`).
5.  Certifique-se de que a **Interface** esteja definida como **SwiftUI** e a **Life Cycle** como **SwiftUI App**.
6.  Salve o projeto no diretório raiz onde a pasta `rocafe` foi criada. O Xcode criará a pasta `rocafe.xcodeproj`.

### 2. Adicionar os Arquivos ao Projeto

1.  No Navegador de Projetos do Xcode (a barra lateral esquerda), clique com o botão direito na pasta azul `rocafe` e selecione **Add Files to "rocafe"...**.
2.  Navegue até a pasta `rocafe` gerada que contém as subpastas `App`, `Core`, `Features`, etc.
3.  Selecione **todas as subpastas** (`App`, `Core`, `Features`, `Shared`).
4.  Certifique-se de que a opção **"Copy items if needed"** esteja **desmarcada** (para que os arquivos permaneçam no lugar) e que **"Create groups"** esteja selecionado.
5.  Clique em **Add**.

O Xcode agora deve exibir a estrutura de pastas e arquivos que foi gerada.

### 3. Adicionar a Dependência (GRDB.swift)

O projeto depende da biblioteca `GRDB.swift`. A maneira mais fácil de adicioná-la é usando o Swift Package Manager, que é integrado ao Xcode.

1.  No Xcode, selecione **File > Add Packages...**.
2.  Na barra de busca no canto superior direito, cole a URL do repositório do GRDB: `https://github.com/groue/GRDB.swift`.
3.  O Xcode irá encontrar o pacote. Deixe as regras de dependência como estão (provavelmente "Up to Next Major Version").
4.  Clique em **Add Package**.
5.  Selecione o produto `GRDB` para ser adicionado ao seu target `rocafe` e clique em **Add Package** novamente.

### 4. Compilar e Executar

Agora o projeto está configurado.

1.  Pressione **Cmd + R** ou clique no botão de "Play" (▶) no topo da janela do Xcode.
2.  O Xcode irá compilar todos os arquivos e executar o aplicativo `rocafe.app`.

A janela principal da aplicação deverá aparecer, mostrando a barra lateral de navegação.

## Próximos Passos

O código gerado é um esqueleto funcional. Muitos detalhes de implementação, especialmente a lógica de negócio mais complexa dentro dos `Services` e a navegação entre as telas (marcada com `// TODO:` nos arquivos de View), precisam ser finalizados.
