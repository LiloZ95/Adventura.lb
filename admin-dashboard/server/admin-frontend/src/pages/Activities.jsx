import React, { useEffect, useState } from 'react';
import axios from 'axios';
import ActivityModal from '../components/ActivityModal';

const Activities = () => {
  const [activities, setActivities] = useState([]);
  const [filteredActivities, setFilteredActivities] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('');
  const [editingActivity, setEditingActivity] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);

  useEffect(() => {
    axios
      .get(`${process.env.REACT_APP_API_URL}/admin/activities`)
      .then((res) => {
        setActivities(res.data);
        setFilteredActivities(res.data);
      })
      .catch((err) => console.error(err));
  }, []);

  useEffect(() => {
    const filtered = activities.filter((activity) => {
      const matchesSearch = activity.name.toLowerCase().includes(searchTerm.toLowerCase());
      const matchesCategory = categoryFilter ? activity.category?.name === categoryFilter : true;
      return matchesSearch && matchesCategory;
    });
    setFilteredActivities(filtered);
  }, [searchTerm, categoryFilter, activities]);

  const handleDelete = async (id) => {
    if (window.confirm('Are you sure you want to delete this activity?')) {
      try {
        await axios.delete(`${process.env.REACT_APP_API_URL}/admin/activities/${id}`);
        setActivities((prev) => prev.filter((act) => act.activity_id !== id));
      } catch (err) {
        alert('Error deleting activity');
      }
    }
  };

  const openEditModal = (activity) => {
    setEditingActivity(activity);
    setIsModalOpen(true);
  };

  const handleSave = async (updated) => {
    try {
      await axios.patch(`${process.env.REACT_APP_API_URL}/admin/activities/${updated.activity_id}`, updated);
      setActivities((prev) =>
        prev.map((act) => (act.activity_id === updated.activity_id ? updated : act))
      );
      setIsModalOpen(false);
    } catch (err) {
      alert('Error updating activity');
    }
  };

  const uniqueCategories = [...new Set(activities.map((a) => a.category?.name).filter(Boolean))];

  return (
    <div className="p-6">
      <h2 className="text-2xl font-bold mb-6 text-gray-800">Activities</h2>

      <div className="flex justify-between items-center mb-4">
        <input
          type="text"
          placeholder="Search by name..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="border p-2 rounded w-1/2"
        />

        <select
          value={categoryFilter}
          onChange={(e) => setCategoryFilter(e.target.value)}
          className="border p-2 rounded"
        >
          <option value="">All Categories</option>
          {uniqueCategories.map((category) => (
            <option key={category} value={category}>{category}</option>
          ))}
        </select>
      </div>

      <table className="min-w-full bg-white shadow-md rounded-md overflow-hidden">
        <thead className="bg-blue-600 text-white">
          <tr>
            <th className="py-3 px-6 text-left">Name</th>
            <th className="py-3 px-6 text-left">Location</th>
            <th className="py-3 px-6 text-left">Price</th>
            <th className="py-3 px-6 text-left">Seats</th>
            <th className="py-3 px-6 text-left">Category</th>
            <th className="py-3 px-6 text-center">Actions</th>
          </tr>
        </thead>
        <tbody>
          {filteredActivities.map((activity) => (
            <tr key={activity.activity_id} className="border-t hover:bg-gray-50">
              <td className="px-6 py-4">{activity.name}</td>
              <td className="px-6 py-4">{activity.location}</td>
              <td className="px-6 py-4">${activity.price}</td>
              <td className="px-6 py-4">{activity.nb_seats}</td>
              <td className="px-6 py-4">{activity.category?.name || 'N/A'}</td>
              <td className="px-6 py-4 text-center space-x-2">
                <button
                  className="bg-blue-500 hover:bg-blue-600 text-white px-4 py-1 rounded-full"
                  onClick={() => openEditModal(activity)}
                >
                  ✏️ Edit
                </button>
                <button
                  className="bg-red-500 hover:bg-red-600 text-white px-4 py-1 rounded-full"
                  onClick={() => handleDelete(activity.activity_id)}
                >
                  🗑️ Delete
                </button>
              </td>
            </tr>
          ))}
          {filteredActivities.length === 0 && (
            <tr>
              <td colSpan="6" className="text-center py-4 text-gray-500 font-medium">
                No activities found.
              </td>
            </tr>
          )}
        </tbody>
      </table>

      {isModalOpen && (
        <ActivityModal
          isOpen={isModalOpen}
          onClose={() => setIsModalOpen(false)}
          onSave={handleSave}
          initialData={editingActivity}
        />
      )}
    </div>
  );
};

export default Activities;
