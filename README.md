# Sales Insight Mate (Flutter Web)

Este projeto foi migrado de React para **Flutter Web**.

## Funcionalidades

- Importação de planilha de custos (.xlsx/.xls) para preencher custo automaticamente.
- Importação de planilha de vendas (.xlsx/.xls).
- Resumo financeiro com campos editáveis (antecipação, publicidade, etc.).
- Tabela de vendas com edição de custo e observação.
- Exportação para Excel com abas `Vendas` e `Resumo`.

## Firebase (obrigatório para Web)

A inicialização do Firebase usa `--dart-define` no runtime. Defina pelo menos:

- `FIREBASE_API_KEY`
- `FIREBASE_APP_ID`
- `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_PROJECT_ID`

Exemplo:

```bash
flutter run -d chrome \
  --dart-define=FIREBASE_API_KEY=... \
  --dart-define=FIREBASE_APP_ID=... \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=... \
  --dart-define=FIREBASE_PROJECT_ID=... \
  --dart-define=FIREBASE_AUTH_DOMAIN=... \
  --dart-define=FIREBASE_DATABASE_URL=...
```

## Rodando localmente

```bash
flutter pub get
flutter run -d chrome
```

## Build Web

```bash
flutter build web
```
