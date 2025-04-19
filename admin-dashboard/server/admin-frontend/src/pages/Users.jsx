import React, { useEffect, useState } from 'react';
import axios from 'axios';

const Users = () => {
  const [users, setUsers] = useState([]);
  const [filteredUsers, setFilteredUsers] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [roleFilter, setRoleFilter] = useState('');
  const [editingUser, setEditingUser] = useState(null);
  const [confirmDeleteId, setConfirmDeleteId] = useState(null);
  const [confirmEditData, setConfirmEditData] = useState(null);

  const fetchUsers = () => {
    axios.get(`${process.env.REACT_APP_API_URL}/admin/users`)
      .then(res => {
        setUsers(res.data);
        setFilteredUsers(res.data);
      })
      .catch(err => console.error('Error fetching users:', err));
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  useEffect(() => {
    const filtered = users.filter(user => {
      const matchesSearch = `${user.first_name} ${user.last_name}`.toLowerCase().includes(searchTerm.toLowerCase());
      const matchesRole = roleFilter ? user.user_type === roleFilter : true;
      return matchesSearch && matchesRole;
    });
    setFilteredUsers(filtered);
  }, [searchTerm, roleFilter, users]);

  const handleDelete = (id) => {
    setConfirmDeleteId(id);
  };

  const confirmDelete = async () => {
    try {
      await axios.delete(`${process.env.REACT_APP_API_URL}/admin/users/${confirmDeleteId}`);
      setConfirmDeleteId(null);
      fetchUsers();
    } catch (err) {
      console.error('Delete error:', err);
    }
  };

  const handleSaveEdit = (data) => {
    setConfirmEditData(data);
  };

  const confirmSaveEdit = async () => {
    try {
      await axios.patch(`${process.env.REACT_APP_API_URL}/admin/users/${editingUser.user_id}`, confirmEditData);
      setEditingUser(null);
      setConfirmEditData(null);
      fetchUsers();
    } catch (err) {
      console.error('Edit error:', err?.response?.data || err.message);
      alert('Failed to save changes');
    }
  };

  return (
    <div className="p-6">
      <h2 className="text-2xl font-bold mb-6 text-gray-800">Users</h2>

      <div className="flex justify-between items-center mb-4">
        <input
          type="text"
          placeholder="Search by name..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="border p-2 rounded w-1/2"
        />
        <select
          value={roleFilter}
          onChange={(e) => setRoleFilter(e.target.value)}
          className="border p-2 rounded"
        >
          <option value="">All Roles</option>
          <option value="client">Client</option>
          <option value="provider">Provider</option>
          <option value="admin">Admin</option>
        </select>
      </div>

      <table className="min-w-full bg-white shadow-md rounded-md overflow-hidden">
        <thead className="bg-blue-600 text-white">
          <tr>
            <th className="py-3 px-6 text-left">First Name</th>
            <th className="py-3 px-6 text-left">Last Name</th>
            <th className="py-3 px-6 text-left">Email</th>
            <th className="py-3 px-6 text-left">Phone</th>
            <th className="py-3 px-6 text-left">Role</th>
            <th className="py-3 px-6 text-center">Actions</th>
          </tr>
        </thead>
        <tbody>
          {filteredUsers.map(user => (
            <tr key={user.user_id} className="border-t hover:bg-gray-50">
              <td className="px-6 py-4">{user.first_name}</td>
              <td className="px-6 py-4">{user.last_name}</td>
              <td className="px-6 py-4">{user.email}</td>
              <td className="px-6 py-4">{user.phone_number}</td>
              <td className="px-6 py-4 capitalize">{user.user_type}</td>
              <td className="px-6 py-4 text-center space-x-2">
                <button
                  onClick={() => setEditingUser(user)}
                  className="bg-blue-500 text-white px-4 py-1 rounded-full"
                >
                  ✏️ Edit
                </button>
                <button
                  onClick={() => handleDelete(user.user_id)}
                  className="bg-red-500 text-white px-4 py-1 rounded-full"
                >
                  🗑️ Delete
                </button>
              </td>
            </tr>
          ))}
          {filteredUsers.length === 0 && (
            <tr>
              <td colSpan="6" className="text-center py-4 text-gray-500 font-medium">
                No users found.
              </td>
            </tr>
          )}
        </tbody>
      </table>

      {editingUser && (
        <EditUserModal
          user={editingUser}
          onClose={() => setEditingUser(null)}
          onSave={handleSaveEdit}
        />
      )}

      {/* ✅ Delete Confirmation Modal */}
      {confirmDeleteId && (
        <ConfirmModal
          title="Confirm Delete"
          message="Are you sure you want to delete this user?"
          onConfirm={confirmDelete}
          onCancel={() => setConfirmDeleteId(null)}
        />
      )}

      {/* ✅ Edit Confirmation Modal */}
      {confirmEditData && (
        <ConfirmModal
          title="Confirm Save"
          message="Are you sure you want to save these changes?"
          onConfirm={confirmSaveEdit}
          onCancel={() => setConfirmEditData(null)}
        />
      )}
    </div>
  );
};

const EditUserModal = ({ user, onClose, onSave }) => {
  const [form, setForm] = useState({ ...user });

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleSubmit = () => {
    onSave(form);
  };

  return (
    <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-40 z-50">
      <div className="bg-white p-6 rounded-lg w-[400px]">
        <h3 className="text-xl font-semibold mb-4">Edit User</h3>
        <div className="space-y-3">
          <input name="first_name" value={form.first_name} onChange={handleChange} placeholder="First Name" className="w-full px-3 py-2 border rounded" />
          <input name="last_name" value={form.last_name} onChange={handleChange} placeholder="Last Name" className="w-full px-3 py-2 border rounded" />
          <input name="phone_number" value={form.phone_number} onChange={handleChange} placeholder="Phone" className="w-full px-3 py-2 border rounded" />
          <select name="user_type" value={form.user_type} onChange={handleChange} className="w-full px-3 py-2 border rounded">
            <option value="client">Client</option>
            <option value="provider">Provider</option>
            <option value="admin">Admin</option>
          </select>
        </div>
        <div className="flex justify-end mt-4 space-x-2">
          <button onClick={onClose} className="px-4 py-1 bg-gray-200 rounded">Cancel</button>
          <button onClick={handleSubmit} className="px-4 py-1 bg-blue-500 text-white rounded">Save</button>
        </div>
      </div>
    </div>
  );
};

const ConfirmModal = ({ title, message, onConfirm, onCancel }) => {
  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white p-6 rounded-lg w-[350px]">
        <h3 className="text-lg font-semibold mb-4">{title}</h3>
        <p className="text-sm text-gray-700 mb-6">{message}</p>
        <div className="flex justify-end gap-2">
          <button onClick={onCancel} className="bg-gray-200 px-4 py-1 rounded">Cancel</button>
          <button onClick={onConfirm} className="bg-red-600 text-white px-4 py-1 rounded">Confirm</button>
        </div>
      </div>
    </div>
  );
};

export default Users;
