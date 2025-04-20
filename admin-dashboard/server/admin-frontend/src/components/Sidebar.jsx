import React from 'react';
import { Link, useLocation } from 'react-router-dom';

const Sidebar = () => {
  const location = useLocation();
  const isActive = (path) => location.pathname === path;

  return (
    <aside className="fixed top-0 left-0 w-64 h-screen bg-[#1e293b] text-white flex flex-col p-4 shadow-md z-50">
      <h1 className="text-2xl font-bold text-center mb-10 tracking-wide text-blue-400">
        Adventura 🧭
      </h1>

      <nav className="space-y-4">
        <Link
          to="/insights"
          className={`block px-4 py-2 rounded ${isActive('/insights') ? 'bg-blue-600' : 'hover:bg-blue-700'}`}
        >
          Insights
        </Link>

        <Link
          to="/users"
          className={`block px-4 py-2 rounded ${isActive('/users') ? 'bg-blue-600' : 'hover:bg-blue-700'}`}
        >
          Users
        </Link>

        <Link
          to="/activities"
          className={`block px-4 py-2 rounded ${isActive('/activities') ? 'bg-blue-600' : 'hover:bg-blue-700'}`}
        >
          Activities
        </Link>

        <Link
          to="/advanced-insights"
          className={`block px-4 py-2 rounded ${isActive('/advanced-insights') ? 'bg-blue-600' : 'hover:bg-blue-700'}`}
        >
          Advanced Insights
        </Link>

        <Link
          to="/transactions"
          className={`block px-4 py-2 rounded ${isActive('/transactions') ? 'bg-blue-600' : 'hover:bg-blue-700'}`}
        >
          Transactions
        </Link>

        {/* ✅ Notifications tab added */}
        <Link
          to="/notifications"
          className={`block px-4 py-2 rounded ${isActive('/notifications') ? 'bg-blue-600' : 'hover:bg-blue-700'}`}
        >
          Notifications
        </Link>
        <Link
  to="/provider-requests"
  className={`block px-4 py-2 rounded ${isActive('/provider-requests') ? 'bg-blue-600' : 'hover:bg-blue-700'}`}
>
  Provider Requests
</Link>


      </nav>
    </aside>
  );
};

export default Sidebar;
