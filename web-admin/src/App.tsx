import { useState } from 'react';
import { 
  ShieldAlert, 
  Users, 
  Video, 
  Settings, 
  Bell, 
  Search,
  Activity,
  CheckCircle2,
  Clock
} from 'lucide-react';
import './App.css'; // Let's leave app.css if Vite uses it, but index is injecting tailwind

function App() {
  const [activeTab, setActiveTab] = useState('overview');

  return (
    <div className="min-h-screen bg-slate-950 text-slate-200 font-sans selection:bg-red-500/30">
      
      {/* Sidebar */}
      <aside className="fixed top-0 left-0 h-screen w-64 bg-slate-900 border-r border-slate-800 flex flex-col z-20">
        <div className="px-6 py-8 flex items-center gap-3 border-b border-slate-800">
          <div className="w-10 h-10 rounded-full bg-red-500/10 flex items-center justify-center">
            <ShieldAlert className="text-red-500 w-6 h-6" />
          </div>
          <div>
            <h1 className="font-bold text-xl text-white tracking-tight">MilOjos Admin</h1>
            <p className="text-xs text-slate-500">Intsitucional B2B</p>
          </div>
        </div>
        
        <nav className="flex-1 px-4 py-6 space-y-2">
          <button 
            onClick={() => setActiveTab('overview')}
            className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl transition-all ${
              activeTab === 'overview' 
                ? 'bg-red-500 text-white shadow-[0_0_20px_rgba(239,68,68,0.2)]' 
                : 'text-slate-400 hover:text-white hover:bg-slate-800/50'
            }`}
          >
            <Activity className="w-5 h-5" />
            <span className="font-medium">Panel de Monitoreo</span>
          </button>
          
          <button 
            onClick={() => setActiveTab('students')}
            className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl transition-all ${
              activeTab === 'students' 
                ? 'bg-red-500 text-white shadow-[0_0_20px_rgba(239,68,68,0.2)]' 
                : 'text-slate-400 hover:text-white hover:bg-slate-800/50'
            }`}
          >
            <Users className="w-5 h-5" />
            <span className="font-medium">Estudiantes & QR</span>
          </button>

          <button 
            onClick={() => setActiveTab('cameras')}
            className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl transition-all ${
              activeTab === 'cameras' 
                ? 'bg-red-500 text-white shadow-[0_0_20px_rgba(239,68,68,0.2)]' 
                : 'text-slate-400 hover:text-white hover:bg-slate-800/50'
            }`}
          >
            <Video className="w-5 h-5" />
            <span className="font-medium">Red de Cámaras VP8</span>
          </button>
        </nav>

        <div className="p-4 mt-auto">
          <button className="w-full flex items-center gap-3 px-4 py-3 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800 transition-all">
            <Settings className="w-5 h-5" />
            <span className="font-medium">Configuración</span>
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <main className="pl-64 flex flex-col min-h-screen">
        
        {/* Header */}
        <header className="h-20 border-b border-slate-800 bg-slate-900/50 backdrop-blur-md sticky top-0 z-10 flex items-center justify-between px-8">
          <div className="relative w-96">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-500" />
            <input 
              type="text" 
              placeholder="Buscar estudiante, alerta o ID de cámara..." 
              className="w-full bg-slate-950 border border-slate-800 text-sm rounded-full py-2.5 pl-10 pr-4 text-slate-300 focus:outline-none focus:border-red-500/50 focus:ring-1 focus:ring-red-500/50 transition-all"
            />
          </div>
          
          <div className="flex items-center gap-6">
            <button className="relative p-2 text-slate-400 hover:text-white transition-colors">
              <Bell className="w-6 h-6" />
              <span className="absolute top-1 right-2 w-2.5 h-2.5 bg-red-500 rounded-full border-2 border-slate-900"></span>
            </button>
            <div className="flex items-center gap-3 pl-6 border-l border-slate-800">
              <div className="text-right">
                <p className="text-sm font-semibold text-white">Rectoría San José</p>
                <p className="text-xs text-sky-400">Institución Enterprise</p>
              </div>
              <div className="w-10 h-10 rounded-full bg-gradient-to-tr from-slate-700 to-slate-600 border border-slate-700"></div>
            </div>
          </div>
        </header>

        {/* Dashboard Content */}
        <div className="p-8 flex-1">
          <div className="mb-8 flex items-end justify-between">
            <div>
              <h2 className="text-3xl font-bold text-white mb-2 tracking-tight">Vigilancia Activa</h2>
              <p className="text-slate-400 text-sm">Monitoreo en tiempo real del área de protección de 500m.</p>
            </div>
            <div className="flex items-center gap-2 px-3 py-1.5 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-sm font-medium">
              <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
              Sistema en Línea
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
            <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 relative overflow-hidden group hover:border-slate-700 transition-all">
              <div className="absolute top-0 right-0 p-6 opacity-20 group-hover:opacity-40 transition-opacity group-hover:scale-110 duration-500">
                <ShieldAlert className="w-24 h-24 text-red-500" />
              </div>
              <p className="text-slate-400 text-sm font-medium mb-1 relative z-10">Alertas Activas (Hoy)</p>
              <h3 className="text-4xl font-black text-white mb-4 relative z-10">0</h3>
              <div className="flex items-center gap-2 text-emerald-400 text-xs font-medium relative z-10">
                <CheckCircle2 className="w-4 h-4" />
                <span>Radio escolar seguro</span>
              </div>
            </div>

            <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 relative overflow-hidden group hover:border-slate-700 transition-all">
              <div className="absolute top-0 right-0 p-6 opacity-20 group-hover:opacity-40 transition-opacity group-hover:scale-110 duration-500">
                <Users className="w-24 h-24 text-sky-500" />
              </div>
              <p className="text-slate-400 text-sm font-medium mb-1 relative z-10">Estudiantes Protegidos</p>
              <h3 className="text-4xl font-black text-white mb-4 relative z-10">1,204</h3>
              <div className="flex items-center gap-2 text-sky-400 text-xs font-medium relative z-10">
                <span>+42 carnets emitidos esta semana</span>
              </div>
            </div>

            <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 relative overflow-hidden group hover:border-slate-700 transition-all">
              <div className="absolute top-0 right-0 p-6 opacity-10 group-hover:opacity-30 transition-opacity group-hover:scale-110 duration-500">
                <Video className="w-24 h-24 text-white" />
              </div>
              <p className="text-slate-400 text-sm font-medium mb-1 relative z-10">Cámaras Desplegadas</p>
              <h3 className="text-4xl font-black text-white mb-4 relative z-10">14</h3>
              <div className="flex items-center gap-2 text-emerald-400 text-xs font-medium relative z-10">
                <span className="w-2 h-2 rounded-full bg-emerald-500"></span>
                <span>Todas transmitiendo vía MediaSoup</span>
              </div>
            </div>
          </div>

          <div className="grid grid-cols-3 gap-6">
            <div className="col-span-2 bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden flex flex-col">
              <div className="px-6 py-5 border-b border-slate-800 flex items-center justify-between bg-slate-900/50">
                <h3 className="font-semibold text-white">Mapa de Cobertura PostGIS</h3>
                <button className="text-xs font-medium text-red-400 hover:text-red-300">Ver Pantalla Completa</button>
              </div>
              <div className="flex-1 bg-slate-950 p-6 flex flex-col items-center justify-center relative min-h-[400px]">
                {/* Simulated Map Container with glassmorphism */}
                <div className="absolute inset-0 bg-[url('https://maps.wikimedia.org/osm-intl/16/18659/33132.png')] bg-cover opacity-20 grayscale sepia-[0.3] hue-rotate-180"></div>
                <div className="relative z-10 bg-slate-900/60 backdrop-blur-xl border border-slate-700/50 rounded-2xl p-8 text-center max-w-sm shadow-2xl">
                  <div className="w-16 h-16 bg-red-500/20 rounded-full flex items-center justify-center mx-auto mb-4 border border-red-500/30">
                    <Video className="text-red-400 w-8 h-8" />
                  </div>
                  <h4 className="text-white font-semibold mb-2">Simulación Maps GPS</h4>
                  <p className="text-slate-400 text-sm leading-relaxed mb-6">
                    El mapa interactivo renderizará las zonas de protección radiales de cada cámara conectada por los Vecinos Pro.
                  </p>
                  <button className="px-6 py-2 bg-red-500 hover:bg-red-600 text-white font-medium text-sm rounded-lg transition-colors shadow-lg shadow-red-500/20">
                    Sincronizar Coordenadas
                  </button>
                </div>
              </div>
            </div>

            <div className="col-span-1 bg-slate-900 border border-slate-800 rounded-2xl flex flex-col">
              <div className="px-6 py-5 border-b border-slate-800 bg-slate-900/50">
                <h3 className="font-semibold text-white">Log de Incidentes</h3>
              </div>
              <div className="p-6 flex-1 flex flex-col gap-4">
                {/* No events placeholder */}
                <div className="flex-1 flex flex-col items-center justify-center text-center p-6 border border-dashed border-slate-800 rounded-xl">
                  <div className="w-12 h-12 bg-emerald-500/10 rounded-full flex items-center justify-center mb-4">
                    <CheckCircle2 className="text-emerald-500 w-6 h-6" />
                  </div>
                  <h4 className="text-white font-medium text-sm mb-1">Sin Altercados</h4>
                  <p className="text-slate-500 text-xs">Aún no se ha detectado el botón de pánico hoy.</p>
                </div>
                
                {/* Simulated old event */}
                <div className="bg-slate-950 border border-slate-800 rounded-xl p-4 flex gap-4 opacity-70">
                  <div className="mt-0.5">
                    <div className="w-2 h-2 rounded-full bg-slate-600"></div>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-slate-300">Test de Humo (MediaSoup)</p>
                    <p className="text-xs text-slate-500 mt-1 flex items-center gap-1">
                      <Clock className="w-3 h-3" /> Hace 12 horas • SuperAdmin
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}

export default App;
