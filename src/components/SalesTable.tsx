import type { SaleRow } from '@/lib/salesTypes';

interface SalesTableProps {
  sales: SaleRow[];
  onUpdateRow: (id: string, field: 'custo' | 'observacao', value: string | number) => void;
}

const fmt = (v: number) =>
  v.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });

export function SalesTable({ sales, onUpdateRow }: SalesTableProps) {
  return (
    <div className="bg-card rounded-xl border border-border shadow-sm overflow-hidden">
      <div className="p-4 border-b border-border">
        <h2 className="text-lg font-bold text-foreground">Detalhamento de Vendas</h2>
        <p className="text-sm text-muted-foreground">{sales.length} vendas encontradas</p>
      </div>
      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead>
            <tr className="bg-secondary/50">
              <th className="text-left px-3 py-3 font-semibold text-foreground whitespace-nowrap">N.º Venda</th>
              <th className="text-left px-3 py-3 font-semibold text-foreground whitespace-nowrap">Data</th>
              <th className="text-left px-3 py-3 font-semibold text-foreground whitespace-nowrap">Estado</th>
              <th className="text-right px-3 py-3 font-semibold text-foreground whitespace-nowrap">Unid</th>
              <th className="text-right px-3 py-3 font-semibold text-foreground whitespace-nowrap">Receita</th>
              <th className="text-right px-3 py-3 font-semibold text-foreground whitespace-nowrap">Tarifa</th>
              <th className="text-right px-3 py-3 font-semibold text-foreground whitespace-nowrap">Frete ML</th>
              <th className="text-right px-3 py-3 font-semibold text-foreground whitespace-nowrap">Custo</th>
              <th className="text-right px-3 py-3 font-semibold text-foreground whitespace-nowrap">Total</th>
              <th className="text-left px-3 py-3 font-semibold text-foreground">Título</th>
              <th className="text-left px-3 py-3 font-semibold text-foreground">Observação</th>
            </tr>
          </thead>
          <tbody>
            {sales.map((s, i) => (
              <tr key={s.id} className={i % 2 === 0 ? 'bg-card' : 'bg-secondary/20'}>
                <td className="px-3 py-2 font-mono text-xs text-muted-foreground">{s.numero}</td>
                <td className="px-3 py-2 text-xs whitespace-nowrap">{s.data}</td>
                <td className="px-3 py-2">
                  <span className="inline-block px-2 py-0.5 text-xs rounded-full bg-success/15 text-success font-medium">
                    {s.estado}
                  </span>
                </td>
                <td className="px-3 py-2 text-right">{s.unidade}</td>
                <td className="px-3 py-2 text-right whitespace-nowrap">{fmt(s.receita)}</td>
                <td className="px-3 py-2 text-right text-destructive whitespace-nowrap">{fmt(s.tarifaVenda)}</td>
                <td className="px-3 py-2 text-right text-destructive whitespace-nowrap">{s.freteML ? fmt(s.freteML) : '-'}</td>
                <td className="px-3 py-2">
                  <input
                    type="number"
                    step="0.01"
                    value={s.custo || ''}
                    onChange={(e) => onUpdateRow(s.id, 'custo', parseFloat(e.target.value) || 0)}
                    className="w-24 text-right bg-secondary/50 border border-border rounded px-2 py-1 text-xs focus:outline-none focus:ring-1 focus:ring-ring"
                    placeholder="0,00"
                  />
                </td>
                <td className="px-3 py-2 text-right font-semibold whitespace-nowrap">{fmt(s.totalBRL)}</td>
                <td className="px-3 py-2 text-xs max-w-[200px] truncate" title={s.titulo}>{s.titulo}</td>
                <td className="px-3 py-2">
                  <input
                    type="text"
                    value={s.observacao}
                    onChange={(e) => onUpdateRow(s.id, 'observacao', e.target.value)}
                    className="w-32 bg-secondary/50 border border-border rounded px-2 py-1 text-xs focus:outline-none focus:ring-1 focus:ring-ring"
                    placeholder="Obs..."
                  />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
