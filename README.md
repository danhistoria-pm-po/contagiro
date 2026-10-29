# 🚗 ContaGiro: Controle Inteligente de Gastos Automotivos

## 🎯 1. Visão Geral e Objetivo do Produto
O **ContaGiro** é uma aplicação multiplataforma (Web e Mobile) desenvolvida para motoristas gerenciarem com precisão o custo operacional de seus veículos. O sistema oferece uma experiência fluida para registro de despesas (Abastecimentos, Manutenções e Outros), cálculo automatizado de eficiência em **KM/L** e garantia de isolamento total de dados na nuvem.

### 🚀 Diferenciais de Mercado & Portfólio
- **Identidade Visual Consistente:** Cabeçalho unificado com logotipo estilizado e navegação rápida integrada (*Visão Geral*, *Lançamentos* e *Histórico*).
- **Inteligência de Consumo:** Cálculo automático de eficiência de combustível com base na quilometragem rodada e litros abastecidos.
- **Segurança Robusta (Multi-usuário):** Arquitetura segura protegida por autenticação em nuvem e regras de isolamento via *Row-Level Security (RLS)* no Supabase.

---

## 🧠 2. Arquitetura e Tecnologias Utilizadas
- **Front-end:** Flutter & Dart (desenvolvimento multiplataforma otimizado para Web e Mobile).
- **Back-end & Banco de Dados:** Supabase (PostgreSQL relacional).
- **Padrão de Projeto:** Clean Architecture simplificada estruturada em módulos por features (`auth`, `dashboard`, `expenses`).

---

## 🏗️ 3. Organização de Módulos (`lib/modules/`)
- `lib/core/` -> Componentes globais, temas e widgets reutilizáveis (ex: `AppHeader`).
- `lib/modules/auth/` -> Gerenciamento de sessão, login e autenticação de usuários.
- `lib/modules/dashboard/` -> Painel central com indicadores financeiros consolidados e métricas de consumo.
- `lib/modules/expenses/` -> Módulo de lançamentos dinâmicos, formulários, observações detalhadas e listagem de histórico.

---

## 🗄️ 4. Modelagem do Banco de Dados (`vehicle_expenses`)

Estrutura relacional na nuvem integrada ao Supabase Auth:

- `id` (uuid, Primary Key)
- `user_id` (uuid, Foreign Key -> `auth.users`) -> Vincula o registro ao motorista autenticado.
- `date` (text) -> Data em que a despesa foi realizada.
- `expense_type` (text) -> Categoria ('Abastecimento', 'Manutenção' ou 'Outros').
- `odometer` (int) -> Quilometragem atual do veículo (KM).
- `value` (numeric) -> Valor monetário total da despesa (R$).
- `liters` (numeric, opcional) -> Quantidade de litros (exclusivo para abastecimentos).
- `observation` (text, opcional) -> Anotações complementares sobre o serviço ou gasto.
- `created_at` (timestamp) -> Registro temporal de criação do dado.

---

## 🏁 5. Mapa de Sprints & Evolução do Projeto

### 🟦 Sprint 1: Estrutura Base e Formulário de Lançamento (Status: CONCLUÍDO)
- [x] Configuração inicial do Flutter e formulário base de despesas.
- [x] Implementação de campos dinâmicos condicionais (Litros e Observações).

### 🟦 Sprint 2: Histórico e Persistência em Nuvem (Status: CONCLUÍDO)
- [x] Criação da tabela relacional no Supabase e integração via SDK.
- [x] Desenvolvimento da tela de listagem (`HistoryPage`) com suporte a exclusão em tempo real.

### 🟦 Sprint 3: Dashboard e Indicadores de Desempenho (Status: CONCLUÍDO)
- [x] Construção da tela principal de indicadores financeiros (`DashboardPage`).
- [x] Algoritmo de cálculo de eficiência de combustível em **KM/L**.

### 🟦 Sprint 4: Autenticação, Multi-usuário e Identidade Visual (Status: CONCLUÍDO)
- [x] Implementação do fluxo de Login/Cadastro com Supabase Auth.
- [x] Ativação de segurança avançada com *Row-Level Security (RLS)*.
- [x] Criação e padronização do logotipo exclusivo **ContaGiro** e menu de navegação rápido no cabeçalho.