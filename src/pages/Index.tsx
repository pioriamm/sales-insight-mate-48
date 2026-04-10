import { useState, useMemo, useCallback } from 'react';
import { FileUpload } from '@/components/FileUpload';
import { SummaryCard } from '@/components/SummaryCard';
import { SalesTable } from '@/components/SalesTable';
import { parseExcelFile } from '@/lib/parseExcel';
import { exportToExcel } from '@/lib/exportExcel';
import type { SaleRow, SummaryData } from '@/lib/salesTypes';
import { Download, RotateCcw } from 'lucide-react';

const Index = () => {
  const [sales, setSales] = useState<SaleRow[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [manualFields, setManualFields] = useState({
    antecipacao: 0,
    publicidade: 0,
    simples: 0,
    tarifasFull: 0,
    pagina: 0,
  });

  const handleFileSelect = useCallback(async (file: File) => {
    setIsLoading(true);
    try {
      const parsed = await parseExcelFile(file);
      setSales(parsed);
    } catch (err) {
      console.error('Erro ao processar arquivo:', err);
    } finally {
      setIsLoading(false);
    }
  }, []);

  const handleUpdateRow = useCallback((id: string, field: 'custo' | 'observacao', value: string | number) => {
    setSales((prev) =>
      prev.map((s) => (s.id === id ? { ...s, [field]: value } : s))
    );
  }, []);

  const summary: SummaryData = useMemo(() => {
    const vendaLiquida = sales.reduce((acc, s) => acc + s.totalBRL, 0);
    const custoPecas = sales.reduce((acc, s) => acc + s.custo, 0);
    const total =
      vendaLiquida -
      custoPecas -
      manualFields.antecipacao -
      manualFields.publicidade -
      manualFields.simples -
      manualFields.tarifasFull -
      manualFields.pagina;

    return {
      vendaLiquida,
      custoPecas,
      ...manualFields,
      total,
    };
  }, [sales, manualFields]);

  const handleFieldChange = useCallback((field: keyof SummaryData, value: number) => {
    if (field in manualFields) {
      setManualFields((prev) => ({ ...prev, [field]: value }));
    }
  }, [manualFields]);

  const handleExport = useCallback(() => {
    exportToExcel(sales, summary);
  }, [sales, summary]);

  const handleReset = useCallback(() => {
    setSales([]);
    setManualFields({ antecipacao: 0, publicidade: 0, simples: 0, tarifasFull: 0, pagina: 0 });
  }, []);

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="bg-card border-b border-border px-6 py-4">
        <div className="max-w-7xl mx-auto flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-foreground">Gestão de Vendas</h1>
            <p className="text-sm text-muted-foreground">Importe sua planilha e analise seus resultados</p>
          </div>
          {sales.length > 0 && (
            <div className="flex gap-2">
              <button
                onClick={handleReset}
                className="flex items-center gap-2 px-4 py-2 text-sm font-medium rounded-lg border border-border text-foreground hover:bg-secondary transition-colors"
              >
                <RotateCcw className="h-4 w-4" />
                Nova Planilha
              </button>
              <button
                onClick={handleExport}
                className="flex items-center gap-2 px-4 py-2 text-sm font-medium rounded-lg bg-primary text-primary-foreground hover:bg-primary/90 transition-colors"
              >
                <Download className="h-4 w-4" />
                Exportar Excel
              </button>
            </div>
          )}
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-6 py-8 space-y-6">
        {sales.length === 0 ? (
          <FileUpload onFileSelect={handleFileSelect} isLoading={isLoading} />
        ) : (
          <>
            <SummaryCard summary={summary} onFieldChange={handleFieldChange} />
            <SalesTable sales={sales} onUpdateRow={handleUpdateRow} />
          </>
        )}
      </main>
    </div>
  );
};

export default Index;
