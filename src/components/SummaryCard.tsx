import type { SummaryData } from '@/lib/salesTypes';

interface SummaryCardProps {
  summary: SummaryData;
  onFieldChange: (field: keyof SummaryData, value: number) => void;
}

const fmt = (v: number) =>
  v.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });

export function SummaryCard({ summary, onFieldChange }: SummaryCardProps) {
  const editableFields: { key: keyof SummaryData; label: string }[] = [
    { key: 'antecipacao', label: 'ANTECIPAÇÃO' },
    { key: 'publicidade', label: 'PUBLICIDADE' },
    { key: 'simples', label: 'SIMPLES' },
    { key: 'tarifasFull', label: 'TARIFAS FULL' },
    { key: 'pagina', label: 'PÁGINA' },
  ];

  return (
    <div className="bg-card rounded-xl border border-border shadow-sm p-6">
      <h2 className="text-lg font-bold text-foreground mb-4">Resumo Financeiro</h2>
      <div className="space-y-3">
        {/* Fixed rows */}
        <div className="flex justify-between items-center py-2 border-b border-border">
          <span className="font-semibold text-foreground">VENDA LÍQUIDA</span>
          <span className="text-lg font-bold text-success">{fmt(summary.vendaLiquida)}</span>
        </div>
        <div className="flex justify-between items-center py-2 border-b border-border">
          <span className="font-semibold text-foreground">CUSTO PEÇAS</span>
          <span className="text-lg font-bold text-destructive">{fmt(summary.custoPecas)}</span>
        </div>

        {/* Editable rows */}
        {editableFields.map(({ key, label }) => (
          <div key={key} className="flex justify-between items-center py-2 border-b border-border">
            <span className="font-medium text-foreground">{label}</span>
            <input
              type="number"
              step="0.01"
              value={summary[key] || ''}
              onChange={(e) => onFieldChange(key, parseFloat(e.target.value) || 0)}
              placeholder="0,00"
              className="w-36 text-right bg-secondary/50 border border-border rounded-md px-3 py-1.5 text-sm font-medium focus:outline-none focus:ring-2 focus:ring-ring"
            />
          </div>
        ))}

        {/* Total */}
        <div className="flex justify-between items-center pt-3 mt-2 border-t-2 border-primary">
          <span className="text-lg font-bold text-foreground">TOTAL</span>
          <span className={`text-xl font-bold ${summary.total >= 0 ? 'text-success' : 'text-destructive'}`}>
            {fmt(summary.total)}
          </span>
        </div>
      </div>
    </div>
  );
}
