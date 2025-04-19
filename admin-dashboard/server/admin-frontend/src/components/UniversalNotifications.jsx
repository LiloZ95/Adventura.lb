import React, { useEffect, useState } from 'react';
import axios from 'axios';

const UniversalNotifications = () => {
  const [notifications, setNotifications] = useState([]);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [icon, setIcon] = useState('');
  const [showConfirm, setShowConfirm] = useState(false);

  const fetchUniversalNotifications = async () => {
    try {
      const res = await axios.get(`${process.env.REACT_APP_API_URL}/admin/universal-notifications`);
      setNotifications(res.data);
    } catch (err) {
      console.error('Error fetching universal notifications:', err);
    }
  };

  useEffect(() => {
    fetchUniversalNotifications();
  }, []);

  const handleSend = async () => {
    try {
      await axios.post(`${process.env.REACT_APP_API_URL}/admin/universal-notifications`, {
        title,
        description,
        icon,
      });
      setTitle('');
      setDescription('');
      setIcon('');
      setShowConfirm(false);
      fetchUniversalNotifications();
    } catch (err) {
      console.error('Error sending notification:', err);
    }
  };

  return (
    <div className="space-y-6">
      <div className="bg-white p-6 rounded shadow">
        <h2 className="text-xl font-semibold mb-6">Send Universal Notification</h2>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
          <div>
            <label className="block text-gray-700 font-medium mb-1">Title</label>
            <input
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="Enter title"
              className="w-full px-4 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-400"
            />
          </div>

          <div>
            <label className="block text-gray-700 font-medium mb-1">Icon (e.g. 🔔)</label>
            <input
              type="text"
              value={icon}
              onChange={(e) => setIcon(e.target.value)}
              placeholder="Emoji"
              className="w-full px-4 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-400"
            />
          </div>

          <div>
            <label className="block text-gray-700 font-medium mb-1">Description</label>
            <textarea
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Type your message..."
              className="w-full px-4 py-2 h-24 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-400"
            />
          </div>
        </div>

        <button
          onClick={() => setShowConfirm(true)}
          className="bg-blue-600 hover:bg-blue-700 text-white px-5 py-2 rounded shadow"
        >
          🚀 Send Notification
        </button>
      </div>

      {/* Modal Confirmation */}
      {showConfirm && (
        <div className="fixed inset-0 bg-black bg-opacity-40 flex items-center justify-center z-50">
          <div className="bg-white p-6 rounded shadow-lg w-96">
            <h2 className="text-lg font-semibold mb-4">Confirm Notification</h2>
            <p className="text-sm mb-2"><strong>Title:</strong> {title}</p>
            <p className="text-sm mb-2"><strong>Icon:</strong> {icon}</p>
            <p className="text-sm mb-4"><strong>Description:</strong> {description}</p>

            <div className="flex justify-end gap-4">
              <button
                onClick={() => setShowConfirm(false)}
                className="px-4 py-2 bg-gray-300 hover:bg-gray-400 rounded"
              >
                Cancel
              </button>
              <button
                onClick={handleSend}
                className="px-4 py-2 bg-green-600 text-white hover:bg-green-700 rounded"
              >
                Confirm
              </button>
            </div>
          </div>
        </div>
      )}

      <div className="bg-white p-6 rounded shadow">
        <h2 className="text-xl font-semibold mb-4">Past Universal Notifications</h2>
        {notifications.length === 0 ? (
          <p className="text-gray-500">No notifications sent yet.</p>
        ) : (
          <ul className="list-disc list-inside space-y-2">
            {notifications.map((notif) => (
              <li key={notif.id}>
                <span className="font-semibold">{notif.icon} {notif.title}:</span> {notif.description}
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
};

export default UniversalNotifications;
