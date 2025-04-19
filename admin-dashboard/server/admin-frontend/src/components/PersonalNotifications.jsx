import React, { useEffect, useState } from 'react';
import axios from 'axios';

const PersonalNotifications = () => {
  const [users, setUsers] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedUser, setSelectedUser] = useState(null);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [icon, setIcon] = useState('');
  const [history, setHistory] = useState([]);
  const [showConfirm, setShowConfirm] = useState(false);

  useEffect(() => {
    axios.get(`${process.env.REACT_APP_API_URL}/admin/users`).then(res => setUsers(res.data));
  }, []);

  const handleSelectUser = (user) => {
    setSelectedUser(user);
    fetchHistory(user.user_id);
  };

  const fetchHistory = async (id) => {
    try {
      const res = await axios.get(`${process.env.REACT_APP_API_URL}/admin/personal-notifications/${id}`);
      setHistory(res.data);
    } catch (err) {
      console.error("Error fetching history:", err);
    }
  };

  const handleSend = async () => {
    try {
      await axios.post(`${process.env.REACT_APP_API_URL}/admin/notifications`, {
        user_id: selectedUser.user_id,
        title,
        description,
        icon
      });
      setTitle('');
      setDescription('');
      setIcon('');
      setShowConfirm(false);
      fetchHistory(selectedUser.user_id);
    } catch (err) {
      console.error('Error sending notification:', err);
    }
  };

  const filteredUsers = users.filter(user =>
    user.first_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.last_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.user_id.toString() === searchTerm
  );

  return (
    <div className="space-y-6">
      {!selectedUser ? (
        <div className="bg-white p-6 rounded shadow">
          <h2 className="text-xl font-semibold mb-4">Search User</h2>
          <input
            type="text"
            placeholder="Search by ID or Name..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full px-4 py-2 border border-gray-300 rounded"
          />
          <ul className="mt-4 space-y-2">
            {filteredUsers.map((user) => (
              <li
                key={user.user_id}
                className="p-2 hover:bg-gray-100 cursor-pointer rounded"
                onClick={() => handleSelectUser(user)}
              >
                {user.first_name} {user.last_name} (ID: {user.user_id})
              </li>
            ))}
          </ul>
        </div>
      ) : (
        <div className="bg-white p-6 rounded shadow">
          <h2 className="text-xl font-semibold mb-6">
            Send Notification to {selectedUser.first_name} {selectedUser.last_name}
          </h2>

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
              <label className="block text-gray-700 font-medium mb-1">Icon (e.g. ✅)</label>
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

          <div className="flex gap-4 mt-4">
            <button
              className="bg-blue-600 hover:bg-blue-700 text-white px-5 py-2 rounded shadow"
              onClick={() => setShowConfirm(true)}
            >
              🚀 Send Notification
            </button>
            <button
              onClick={() => setSelectedUser(null)}
              className="bg-gray-300 hover:bg-gray-400 px-5 py-2 rounded shadow"
            >
              Back to Users
            </button>
          </div>

          {/* Confirmation Modal */}
          {showConfirm && (
            <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
              <div className="bg-white p-6 rounded shadow w-96">
                <h2 className="text-lg font-semibold mb-3">Confirm Personal Notification</h2>
                <p className="text-sm mb-1"><strong>To:</strong> {selectedUser.first_name} {selectedUser.last_name}</p>
                <p className="text-sm mb-1"><strong>Title:</strong> {title}</p>
                <p className="text-sm mb-1"><strong>Icon:</strong> {icon}</p>
                <p className="text-sm mb-4"><strong>Description:</strong> {description}</p>

                <div className="flex justify-end gap-3">
                  <button
                    onClick={() => setShowConfirm(false)}
                    className="px-3 py-1 bg-gray-200 hover:bg-gray-300 rounded"
                  >
                    Cancel
                  </button>
                  <button
                    onClick={handleSend}
                    className="px-3 py-1 bg-green-600 hover:bg-green-700 text-white rounded"
                  >
                    Confirm
                  </button>
                </div>
              </div>
            </div>
          )}

          <div className="mt-6">
            <h3 className="text-lg font-semibold mb-2">Previous Notifications</h3>
            {history.length === 0 ? (
              <p className="text-gray-500">No previous notifications.</p>
            ) : (
              <ul className="list-disc list-inside space-y-1">
                {history.map((notif) => (
                  <li key={notif.notification_id}>
                    <strong>{notif.icon} {notif.title}:</strong> {notif.description}
                  </li>
                ))}
              </ul>
            )}
          </div>
        </div>
      )}
    </div>
  );
};

export default PersonalNotifications;
