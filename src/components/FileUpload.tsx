import { Upload } from 'lucide-react';
import { useRef } from 'react';

interface FileUploadProps {
  onFileSelect: (file: File) => void;
  isLoading: boolean;
}

export function FileUpload({ onFileSelect, isLoading }: FileUploadProps) {
  const inputRef = useRef<HTMLInputElement>(null);

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    const file = e.dataTransfer.files[0];
    if (file) onFileSelect(file);
  };

  return (
    <div
      onDrop={handleDrop}
      onDragOver={(e) => e.preventDefault()}
      onClick={() => inputRef.current?.click()}
      className="border-2 border-dashed border-primary/30 rounded-xl p-12 text-center cursor-pointer hover:border-primary/60 hover:bg-primary/5 transition-all duration-200"
    >
      <Upload className="mx-auto h-12 w-12 text-primary/50 mb-4" />
      <p className="text-lg font-medium text-foreground">
        {isLoading ? 'Processando...' : 'Arraste sua planilha Excel aqui'}
      </p>
      <p className="text-sm text-muted-foreground mt-1">ou clique para selecionar</p>
      <input
        ref={inputRef}
        type="file"
        accept=".xlsx,.xls"
        className="hidden"
        onChange={(e) => {
          const file = e.target.files?.[0];
          if (file) onFileSelect(file);
        }}
      />
    </div>
  );
}
