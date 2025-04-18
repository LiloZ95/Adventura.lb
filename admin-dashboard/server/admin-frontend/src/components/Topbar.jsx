import React from 'react';

const Topbar = () => {
  return (
    <header className="bg-white shadow px-6 py-4 flex justify-between items-center">
      <h2 className="text-xl font-semibold text-gray-800">Admin Dashboard</h2>
      <div className="text-sm text-gray-500">Welcome, Admin</div>
    </header>
  );
};

export default Topbar;
