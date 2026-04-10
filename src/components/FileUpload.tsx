import { Upload, FileSpreadsheet } from 'lucide-react';
import { useRef } from 'react';

interface FileUploadProps {
  onFileSelect: (file: File) => void;
  onCostFileSelect: (file: File) => void;
  isLoading: boolean;
  costLoaded: boolean;
}

export function FileUpload({ onFileSelect, onCostFileSelect, isLoading, costLoaded }: FileUploadProps) {
  const salesInputRef = useRef<HTMLInputElement>(null);
  const costInputRef = useRef<HTMLInputElement>(null);

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    const file = e.dataTransfer.files[0];
    if (file) onFileSelect(file);
  };

  return (
    <div className="space-y-4">
      {/* Cost file upload */}
      <div
        onClick={() => costInputRef.current?.click()}
        className={`border-2 border-dashed rounded-xl p-6 text-center cursor-pointer transition-all duration-200 ${
          costLoaded
            ? 'border-success/50 bg-success/5'
            : 'border-muted-foreground/30 hover:border-primary/60 hover:bg-primary/5'
        }`}
      >
        <FileSpreadsheet className={`mx-auto h-8 w-8 mb-2 ${costLoaded ? 'text-success' : 'text-muted-foreground/50'}`} />
        <p className="text-sm font-medium text-foreground">
          {costLoaded ? '✓ Planilha de custos carregada' : '1. Importe a planilha de custos (SKU / Descrição / Custo)'}
        </p>
        <p className="text-xs text-muted-foreground mt-1">Opcional — usada para preencher o custo automaticamente</p>
        <input
          ref={costInputRef}
          type="file"
          accept=".xlsx,.xls"
          className="hidden"
          onChange={(e) => {
            const file = e.target.files?.[0];
            if (file) onCostFileSelect(file);
          }}
        />
      </div>

      {/* Sales file upload */}
      <div
        onDrop={handleDrop}
        onDragOver={(e) => e.preventDefault()}
        onClick={() => salesInputRef.current?.click()}
        className="border-2 border-dashed border-primary/30 rounded-xl p-12 text-center cursor-pointer hover:border-primary/60 hover:bg-primary/5 transition-all duration-200"
      >
        <Upload className="mx-auto h-12 w-12 text-primary/50 mb-4" />
        <p className="text-lg font-medium text-foreground">
          {isLoading ? 'Processando...' : '2. Arraste sua planilha de vendas aqui'}
        </p>
        <p className="text-sm text-muted-foreground mt-1">ou clique para selecionar</p>
        <input
          ref={salesInputRef}
          type="file"
          accept=".xlsx,.xls"
          className="hidden"
          onChange={(e) => {
            const file = e.target.files?.[0];
            if (file) onFileSelect(file);
          }}
        />
      </div>
    </div>
  );
}
