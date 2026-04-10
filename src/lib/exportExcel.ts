import * as XLSX from 'xlsx';
import type { SaleRow, SummaryData } from './salesTypes';

export function exportToExcel(sales: SaleRow[], summary: SummaryData) {
  const wb = XLSX.utils.book_new();

  // Detail sheet
  const detailData = sales.map((s) => ({
    'N.º de venda': s.numero,
    'Data da venda': s.data,
    'Estado': s.estado,
    'Unid': s.unidade,
    'Receita': s.receita,
    'Tarifa de venda': s.tarifaVenda,
    'Frete ML': s.freteML,
    'Total (BRL)': s.totalBRL,
    'Título do anúncio': s.titulo,
    'Custo': s.custo,
    'Observação': s.observacao,
  }));
  const ws1 = XLSX.utils.json_to_sheet(detailData);
  XLSX.utils.book_append_sheet(wb, ws1, 'Vendas');

  // Summary sheet
  const summaryData = [
    { 'Descrição': 'VENDA LÍQUIDA', 'Valor': summary.vendaLiquida },
    { 'Descrição': 'CUSTO PEÇAS', 'Valor': summary.custoPecas },
    { 'Descrição': 'ANTECIPAÇÃO', 'Valor': summary.antecipacao },
    { 'Descrição': 'PUBLICIDADE', 'Valor': summary.publicidade },
    { 'Descrição': 'SIMPLES', 'Valor': summary.simples },
    { 'Descrição': 'TARIFAS FULL', 'Valor': summary.tarifasFull },
    { 'Descrição': 'PÁGINA', 'Valor': summary.pagina },
    { 'Descrição': 'TOTAL', 'Valor': summary.total },
  ];
  const ws2 = XLSX.utils.json_to_sheet(summaryData);
  XLSX.utils.book_append_sheet(wb, ws2, 'Resumo');

  const now = new Date();
  const mes = now.toLocaleString('pt-BR', { month: 'long' });
  const mesCapitalized = mes.charAt(0).toUpperCase() + mes.slice(1);
  const ano = now.getFullYear();
  XLSX.writeFile(wb, `${mesCapitalized}-${ano}-Contabilidade.xlsx`);
}
