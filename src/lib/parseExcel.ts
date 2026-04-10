import * as XLSX from 'xlsx';
import type { SaleRow } from './salesTypes';

function parseNumber(val: any): number {
  if (val == null || val === '') return 0;
  if (typeof val === 'number') return val;
  const str = String(val).replace(/\s/g, '').replace('.', '').replace(',', '.');
  const n = parseFloat(str);
  return isNaN(n) ? 0 : n;
}

export function parseExcelFile(file: File): Promise<SaleRow[]> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = (e) => {
      try {
        const data = new Uint8Array(e.target?.result as ArrayBuffer);
        const wb = XLSX.read(data, { type: 'array' });
        const ws = wb.Sheets[wb.SheetNames[0]];
        const rows: any[] = XLSX.utils.sheet_to_json(ws, { defval: '' });

        const sales: SaleRow[] = rows.map((r, i) => ({
          id: String(i),
          numero: String(r['N.º de venda'] ?? r['Nº de venda'] ?? r['N° de venda'] ?? ''),
          data: String(r['Data da venda'] ?? ''),
          estado: String(r['Estado'] ?? ''),
          unidade: parseNumber(r['Unid'] ?? r['Unidade'] ?? 0),
          receita: parseNumber(r['Receita']),
          tarifaVenda: parseNumber(r['Tarifa de venda']),
          freteML: parseNumber(r['Frete ML']),
          totalBRL: parseNumber(r['Total (BRL)']),
          titulo: String(r['Título do anúncio'] ?? r['Titulo do anúncio'] ?? ''),
          custo: 0,
          observacao: '',
        }));

        resolve(sales);
      } catch (err) {
        reject(err);
      }
    };
    reader.onerror = reject;
    reader.readAsArrayBuffer(file);
  });
}
