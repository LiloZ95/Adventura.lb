import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Sidebar from './components/Sidebar';
import Insights from './pages/Insights';
import Activities from './pages/Activities';
import Users from './pages/Users';
import AdvancedInsights from './pages/AdvancedInsights';
import Transactions from './pages/Transactions';
function App() {
  return (
    <Router>
      <div className="flex">
        {/* Sidebar (fixed) */}
        <Sidebar />

        {/* Main content with margin-left to prevent overlap */}
        <div className="ml-64 flex-1 p-6 bg-gray-50 min-h-screen">
          <Routes>
            <Route path="/insights" element={<Insights />} />
            <Route path="/activities" element={<Activities />} />
            <Route path="/users" element={<Users />} />
            <Route path="/advanced-insights" element={<AdvancedInsights />} />
            <Route path="/transactions" element={<Transactions />} />
          </Routes>
        </div>
      </div>
    </Router>
  );
}

export default App;
