export interface SaleRow {
  id: string;
  numero: string;
  data: string;
  estado: string;
  unidade: number;
  receita: number;
  tarifaVenda: number;
  freteML: number;
  totalBRL: number;
  titulo: string;
  custo: number;
  observacao: string;
}

export interface SummaryData {
  vendaLiquida: number;
  custoPecas: number;
  antecipacao: number;
  publicidade: number;
  simples: number;
  tarifasFull: number;
  pagina: number;
  total: number;
}
