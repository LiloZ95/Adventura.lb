import React, { useState, useEffect } from 'react';

const ActivityModal = ({ isOpen, onClose, onSave, initialData }) => {
  const [formData, setFormData] = useState({});

  useEffect(() => {
    if (initialData) setFormData(initialData);
  }, [initialData]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = () => {
    onSave(formData);
    onClose();
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white p-6 rounded shadow-lg w-[400px]">
        <h2 className="text-xl font-semibold mb-4">Edit Activity</h2>

        <label className="block mb-2">Name:</label>
        <input
          type="text"
          name="name"
          value={formData.name || ''}
          onChange={handleChange}
          className="w-full border px-3 py-2 mb-3 rounded"
        />

        <label className="block mb-2">Location:</label>
        <input
          type="text"
          name="location"
          value={formData.location || ''}
          onChange={handleChange}
          className="w-full border px-3 py-2 mb-3 rounded"
        />

        <label className="block mb-2">Price:</label>
        <input
          type="number"
          name="price"
          value={formData.price || ''}
          onChange={handleChange}
          className="w-full border px-3 py-2 mb-3 rounded"
        />

        <label className="block mb-2">Seats:</label>
        <input
          type="number"
          name="nb_seats"
          value={formData.nb_seats || ''}
          onChange={handleChange}
          className="w-full border px-3 py-2 mb-3 rounded"
        />

        <div className="flex justify-end gap-2 mt-4">
          <button onClick={onClose} className="px-4 py-2 bg-gray-300 rounded">
            Cancel
          </button>
          <button onClick={handleSubmit} className="px-4 py-2 bg-blue-600 text-white rounded">
            Save
          </button>
        </div>
      </div>
    </div>
  );
};

export default ActivityModal;
