import * as XLSX from 'xlsx';
import type { CostItem } from './costTypes';

function parseNumber(val: any): number {
  if (val == null || val === '') return 0;
  if (typeof val === 'number') return val;
  const str = String(val).replace(/\s/g, '').replace('.', '').replace(',', '.');
  const n = parseFloat(str);
  return isNaN(n) ? 0 : n;
}

export function parseCostFile(file: File): Promise<CostItem[]> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = (e) => {
      try {
        const data = new Uint8Array(e.target?.result as ArrayBuffer);
        const wb = XLSX.read(data, { type: 'array' });
        const ws = wb.Sheets[wb.SheetNames[0]];
        const rows: any[] = XLSX.utils.sheet_to_json(ws, { defval: '' });

        const items: CostItem[] = rows.map((r) => ({
          sku: String(r['SKU'] ?? ''),
          descricao: String(r['Descrição'] ?? r['Descricao'] ?? ''),
          custo: parseNumber(r['Custo']),
        }));

        resolve(items);
      } catch (err) {
        reject(err);
      }
    };
    reader.onerror = reject;
    reader.readAsArrayBuffer(file);
  });
}

function normalize(str: string): string {
  return str
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9\s]/g, '')
    .trim();
}

function getKeywords(str: string): string[] {
  return normalize(str).split(/\s+/).filter((w) => w.length > 2);
}

export function findCostForTitle(titulo: string, costItems: CostItem[]): number {
  if (!titulo || costItems.length === 0) return 0;

  const titleKeywords = getKeywords(titulo);
  if (titleKeywords.length === 0) return 0;

  let bestMatch: CostItem | null = null;
  let bestScore = 0;

  for (const item of costItems) {
    const descKeywords = getKeywords(item.descricao);
    if (descKeywords.length === 0) continue;

    let matches = 0;
    for (const kw of titleKeywords) {
      if (descKeywords.some((dk) => dk.includes(kw) || kw.includes(dk))) {
        matches++;
      }
    }

    const score = matches / Math.max(titleKeywords.length, descKeywords.length);

    if (score > bestScore && matches >= 3) {
      bestScore = score;
      bestMatch = item;
    }
  }

  return bestMatch ? Math.abs(bestMatch.custo) : 0;
}
