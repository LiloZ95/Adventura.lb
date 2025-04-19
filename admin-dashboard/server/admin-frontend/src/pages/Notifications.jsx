import React, { useState } from 'react';
import UniversalNotifications from '../components/UniversalNotifications';
import PersonalNotifications from '../components/PersonalNotifications';

const Notifications = () => {
  const [activeTab, setActiveTab] = useState('universal');

  return (
    <div className="p-6">
      <h2 className="text-2xl font-bold mb-4 text-gray-800">Notifications</h2>

      <div className="flex space-x-4 mb-6">
        <button
          onClick={() => setActiveTab('universal')}
          className={`px-4 py-2 rounded ${activeTab === 'universal' ? 'bg-blue-600 text-white' : 'bg-gray-200'}`}
        >
          🌐 Universal
        </button>
        <button
          onClick={() => setActiveTab('personal')}
          className={`px-4 py-2 rounded ${activeTab === 'personal' ? 'bg-blue-600 text-white' : 'bg-gray-200'}`}
        >
          👤 Personal
        </button>
      </div>

      {activeTab === 'universal' ? (
        <UniversalNotifications />
      ) : (
        <PersonalNotifications />
      )}
    </div>
  );
};

export default Notifications;
