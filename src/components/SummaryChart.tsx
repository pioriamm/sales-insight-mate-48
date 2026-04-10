import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend } from 'recharts';
import type { SummaryData } from '@/lib/salesTypes';

interface SummaryChartProps {
  summary: SummaryData;
}

const fmt = (v: number) =>
  v.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });

export function SummaryChart({ summary }: SummaryChartProps) {
  const data = [
    { name: 'Venda Líquida', valor: summary.vendaLiquida },
    { name: 'Custo Peças', valor: summary.custoPecas },
    { name: 'Antecipação', valor: summary.antecipacao },
    { name: 'Publicidade', valor: summary.publicidade },
    { name: 'Simples', valor: summary.simples },
    { name: 'Tarifas Full', valor: summary.tarifasFull },
    { name: 'Página', valor: summary.pagina },
    { name: 'Total', valor: summary.total },
  ];

  return (
    <div className="bg-card rounded-xl border border-border shadow-sm p-6">
      <h2 className="text-lg font-bold text-foreground mb-4">Gráfico Financeiro</h2>
      <ResponsiveContainer width="100%" height={300}>
        <LineChart data={data} margin={{ top: 5, right: 30, left: 20, bottom: 5 }}>
          <CartesianGrid strokeDasharray="3 3" className="stroke-border" />
          <XAxis dataKey="name" tick={{ fontSize: 12 }} className="fill-muted-foreground" />
          <YAxis tick={{ fontSize: 12 }} className="fill-muted-foreground" tickFormatter={(v) => fmt(v)} />
          <Tooltip formatter={(value: number) => fmt(value)} />
          <Legend />
          <Line
            type="monotone"
            dataKey="valor"
            name="Valor (R$)"
            stroke="hsl(var(--primary))"
            strokeWidth={2}
            dot={{ r: 5, fill: 'hsl(var(--primary))' }}
            activeDot={{ r: 7 }}
          />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}
