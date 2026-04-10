import * as XLSX from 'xlsx';
import type { SaleRow } from './salesTypes';

const MONTHS: Record<string, string> = {
  'janeiro': '01', 'fevereiro': '02', 'março': '03', 'abril': '04',
  'maio': '05', 'junho': '06', 'julho': '07', 'agosto': '08',
  'setembro': '09', 'outubro': '10', 'novembro': '11', 'dezembro': '12',
};

function formatDate(val: any): string {
  if (val == null || val === '') return '';
  if (val instanceof Date) {
    const d = val;
    const dd = String(d.getDate()).padStart(2, '0');
    const mm = String(d.getMonth() + 1).padStart(2, '0');
    const yyyy = d.getFullYear();
    const hh = String(d.getHours()).padStart(2, '0');
    const min = String(d.getMinutes()).padStart(2, '0');
    return `${dd}/${mm}/${yyyy} ${hh}:${min}`;
  }
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
  // Parse "5 de abril de 2026 21:05 hs." format
  const str = String(val);
  const match = str.match(/(\d{1,2})\s+de\s+(\w+)\s+de\s+(\d{4})\s+(\d{1,2}):(\d{2})/i);
  if (match) {
    const dd = match[1].padStart(2, '0');
    const monthName = match[2].toLowerCase();
    const mm = MONTHS[monthName] || '01';
    const yyyy = match[3];
    const hh = match[4].padStart(2, '0');
    const min = match[5];
    return `${dd}/${mm}/${yyyy} ${hh}:${min}`;
  }
  return str;
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
        const wb = XLSX.read(data, { type: 'array' });
        const ws = wb.Sheets[wb.SheetNames[0]];
        const rows: any[] = XLSX.utils.sheet_to_json(ws, { defval: '' });

        const sales: SaleRow[] = rows.map((r, i) => ({
          id: String(i),
          numero: String(r['N.º de venda'] ?? r['Nº de venda'] ?? r['N° de venda'] ?? ''),
          data: formatDate(r['Data da venda']),
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
