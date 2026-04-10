import * as XLSX from 'xlsx';
import type { SaleRow } from './salesTypes';

function formatDate(val: any): string {
  if (val == null || val === '') return '';
  // If XLSX parsed it as a JS Date
  if (val instanceof Date) {
    const d = val;
    const dd = String(d.getDate()).padStart(2, '0');
    const mm = String(d.getMonth() + 1).padStart(2, '0');
    const yyyy = d.getFullYear();
    const hh = String(d.getHours()).padStart(2, '0');
    const min = String(d.getMinutes()).padStart(2, '0');
    return `${dd}/${mm}/${yyyy} ${hh}:${min}`;
  }
  // If it's an Excel serial number
  if (typeof val === 'number' && val > 25000) {
    const d = XLSX.SSF.parse_date_code(val);
    if (d) {
      const dd = String(d.d).padStart(2, '0');
      const mm = String(d.m).padStart(2, '0');
      const yyyy = d.y;
      const hh = String(d.H).padStart(2, '0');
      const min = String(d.M).padStart(2, '0');
      return `${dd}/${mm}/${yyyy} ${hh}:${min}`;
    }
  }
  return String(val);
}

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
        const wb = XLSX.read(data, { type: 'array', cellDates: true });
        const ws = wb.Sheets[wb.SheetNames[0]];
        const rows: any[] = XLSX.utils.sheet_to_json(ws, { defval: '', raw: true });

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
