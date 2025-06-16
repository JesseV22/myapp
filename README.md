# Prato Certo

Bem-vindo ao **Prato Certo**, um aplicativo mobile desenvolvido em Flutter para gerenciar estoques de ingredientes e cardápios de forma prática e eficiente. Ideal para cozinhas, restaurantes ou qualquer pessoa que precise organizar seus suprimentos e receitas!

## Descrição
O Prato Certo permite adicionar, editar e excluir ingredientes com suas quantidades e limites de estoque, além de criar e gerenciar pratos com base nos ingredientes disponíveis. O app inclui notificações para alertar sobre estoques baixos e sincronização com o Firebase para backup em nuvem.

## Funcionalidades
- Adicionar e gerenciar ingredientes com unidades personalizadas (g, kg, unidade, lata, etc.).
- Criar e visualizar pratos com lista de ingredientes.
- Notificações para estoques críticos (ex.: Mussarela abaixo do limite).
- Sincronização com Firebase Firestore.
- Interface amigável com tema ajustável.
## Telas do Aplicativo

O **Prato Certo** é composto por várias telas que trabalham em conjunto para oferecer uma experiência completa de gestão de estoque e cardápio. Abaixo estão as descrições das principais telas:

### 1. `cardapio_screen.dart` (Tela de Cardápio)
- **Propósito**: Gerencia o cardápio, permitindo criar, visualizar, editar e excluir pratos com base nos ingredientes disponíveis.
- **Funcionalidades**:
  - Adicionar novos pratos com uma lista de ingredientes temporários.
  - Selecionar ingredientes do estoque e definir quantidades.
  - Visualizar detalhes dos pratos existentes.
  - Opções para preparar, editar ou excluir pratos.
  - Integração com o `CardapioProvider` para gerenciamento de estado.
- **Fluxo**: Usada para planejar o menu, essencial para cozinheiros ou gerentes de restaurante.

### 2. `estoque_screen.dart` (Tela de Estoque)
- **Propósito**: Controla o estoque de ingredientes, permitindo adicionar, editar e excluir itens, além de monitorar níveis críticos.
- **Funcionalidades**:
  - Adicionar ingredientes com nome, quantidade, unidade (g, kg, unidade, lata) e limite de estoque.
  - Exibir a lista de ingredientes com notificações para itens abaixo do limite (ex.: Mussarela).
  - Excluir ingredientes do estoque.
  - Integração com notificações locais para alertas de estoque baixo.
- **Fluxo**: Fundamental para manter o inventário atualizado e evitar faltas de suprimentos.

### 3. `login_screen.dart` (Tela de Login)
- **Propósito**: Fornece a interface de autenticação, garantindo que apenas usuários autorizados acessem o aplicativo.
- **Funcionalidades**:
  - Campo para entrada de e-mail e senha.
  - Botão de login (com possível suporte a registro ou recuperação de senha).
  - Integração com Firebase Auth para validação de usuários.
- **Fluxo**: Primeira tela acessada, assegurando segurança no uso do app.

### 4. `tela_home.dart` (Tela Inicial)
- **Propósito**: Atua como dashboard, oferecendo uma visão geral e navegação entre as funcionalidades do aplicativo.
- **Funcionalidades**:
  - Exibe saudação e resumos (ex.: ingredientes em falta, pratos recentes).
  - Navegação via bottom navigation bar para `Início`, `Cardápio` e `Estoque`.
  - Integração com `CardapioProvider` para carregar dados.
  - Opção para alternar entre temas claro e escuro.
- **Fluxo**: Ponto central de acesso, onde os usuários iniciam suas tarefas e monitoram o status geral.

### Integração das Telas
- **Navegação**: A `tela_home.dart` conecta `cardapio_screen.dart` e `estoque_screen.dart` via barra de navegação inferior.
- **Autenticação**: O acesso a todas as telas depende da autenticação via `login_screen.dart`.
- **Sincronização**: As telas utilizam o `BancoDados` para operações locais e o Firebase para sincronização em nuvem, mantendo os dados consistentes.
## Tecnologias Utilizadas
- **Flutter**: Framework para desenvolvimento mobile.
- **Dart**: Linguagem de programação.
- **sqflite**: Banco de dados local.
- **Firebase**: Autenticação e Firestore para sincronização em nuvem.
- **flutter_local_notifications**: Notificações locais.
- **provider**: Gerenciamento de estado.
- **sqflite_common_ffi**: Suporte a banco de dados em plataformas desktop.

## Pré-requisitos
- [Flutter SDK](https://flutter.dev/docs/get-started/install) instalado.
- [Dart](https://dart.dev/get-dart) configurado.
- [Android Studio](https://developer.android.com/studio) ou [VS Code](https://code.visualstudio.com/) com suporte a Flutter.
- Configuração do Firebase (incluir `google-services.json` para Android).

## Instalação
1. Clone o repositório:
   ```bash
   git clone https://github.com/seu-usuario/prato-certo.git
   cd prato-certo
