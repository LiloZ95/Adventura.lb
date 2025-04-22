import React, { useEffect, useState } from 'react';
import axios from 'axios';

const TABS = ['pending', 'approved', 'rejected'];

const ProviderRequests = () => {
  const [requests, setRequests] = useState([]);
  const [selectedStatus, setSelectedStatus] = useState('pending');
  const [selectedRequest, setSelectedRequest] = useState(null);
  const [previewImage, setPreviewImage] = useState(null); // 🆕 Full-size preview image state

  useEffect(() => {
    axios.get(`${process.env.REACT_APP_API_URL}/admin/provider-requests`)
      .then(res => setRequests(res.data))
      .catch(err => console.error(err));
  }, []);

  const filtered = requests
    .filter(req => req.status === selectedStatus)
    .sort((a, b) => new Date(a.submitted_at) - new Date(b.submitted_at));

    const handleStatusChange = async (id, status) => {
      try {
        // 1. Update status in backend
        await axios.patch(`${process.env.REACT_APP_API_URL}/admin/provider-requests/${id}/${status}`);
    
        // 2. Fetch the updated list from backend
        const res = await axios.get(`${process.env.REACT_APP_API_URL}/admin/provider-requests`);
        setRequests(res.data);
    
        // 3. Exit detail view
        setSelectedRequest(null);
      } catch (err) {
        console.error(err);
      }
    };
    
    

  const renderRequestCard = (req) => (
    <div
      key={req.request_id}
      className="bg-white shadow rounded p-4 mb-2 hover:bg-gray-100 cursor-pointer"
      onClick={() => setSelectedRequest(req)}
    >
      <p className="text-gray-800 font-semibold">User #{req.user_id}</p>
      <p className="text-sm text-gray-500">Submitted: {req.submitted_at.split('T')[0]}</p>
    </div>
  );

  const renderDetails = () => {
    if (!selectedRequest) return null;

    return (
      <div className="bg-white shadow rounded p-6 mt-6">
        <h3 className="text-xl font-semibold mb-4">Request from User #{selectedRequest.user_id}</h3>
        <p><strong>Birth Date:</strong> {selectedRequest.birth_date}</p>
        <p><strong>City:</strong> {selectedRequest.city}</p>
        <p><strong>Address:</strong> {selectedRequest.address}</p>

        <div className="flex gap-4 my-4">
  <div>
    <img
      src={`http://localhost:3000/uploads/provider_docs/${selectedRequest.user_id}/${selectedRequest.selfie_url.split('\\').pop()}`}
      alt="Selfie"
      className="w-40 h-auto rounded border cursor-pointer"
      onClick={() =>
        setPreviewImage(
          `http://localhost:3000/uploads/provider_docs/${selectedRequest.user_id}/${selectedRequest.selfie_url.split('\\').pop()}`
        )
      }
    />
    <p className="text-sm text-center text-gray-600 mt-2">Selfie</p>
  </div>
  <div>
    <img
      src={`http://localhost:3000/uploads/provider_docs/${selectedRequest.user_id}/${selectedRequest.gov_id_url.split('\\').pop()}`}
      alt="Gov ID"
      className="w-40 h-auto rounded border cursor-pointer"
      onClick={() =>
        setPreviewImage(
          `http://localhost:3000/uploads/provider_docs/${selectedRequest.user_id}/${selectedRequest.gov_id_url.split('\\').pop()}`
        )
      }
    />
    <p className="text-sm text-center text-gray-600 mt-2">Gov ID</p>
  </div>
</div>

        <p><strong>Certificate:</strong> {selectedRequest.certificate_url}</p>

        <div className="mt-4 flex gap-2">
          {selectedRequest.status === 'pending' && (
            <>
              <button
                onClick={() => handleStatusChange(selectedRequest.request_id, 'approve')}
                className="bg-green-600 text-white px-4 py-1 rounded"
              >
                Accept
              </button>
              <button
                onClick={() => handleStatusChange(selectedRequest.request_id, 'reject')}
                className="bg-red-600 text-white px-4 py-1 rounded"
              >
                Reject
              </button>
            </>
          )}
          <button
            onClick={() => setSelectedRequest(null)}
            className="bg-gray-300 text-black px-4 py-1 rounded ml-auto"
          >
            Back to List
          </button>
        </div>
      </div>
    );
  };

  return (
    <div>
      <h2 className="text-2xl font-bold mb-6 text-gray-800">Provider Requests</h2>

      {/* Tabs */}
      <div className="flex gap-2 mb-4">
        {TABS.map(tab => (
          <button
            key={tab}
            className={`px-4 py-1 rounded ${
              selectedStatus === tab ? 'bg-blue-600 text-white' : 'bg-gray-200 text-blue-600'
            }`}
            onClick={() => {
              setSelectedStatus(tab);
              setSelectedRequest(null);
            }}
          >
            {tab.charAt(0).toUpperCase() + tab.slice(1)} Requests
          </button>
        ))}
      </div>

      {/* List or Details */}
      {selectedRequest ? renderDetails() : (
        <div className="grid gap-2">
          {filtered.length === 0 ? (
            <p className="text-gray-500">No {selectedStatus} requests.</p>
          ) : (
            filtered.map(renderRequestCard)
          )}
        </div>
      )}

      {/* 🔍 Image Preview Modal */}
      {previewImage && (
        <div
          className="fixed inset-0 bg-black bg-opacity-70 flex items-center justify-center z-50"
          onClick={() => setPreviewImage(null)}
        >
          <img
            src={previewImage}
            alt="Full Preview"
            className="max-w-3xl max-h-[90vh] rounded shadow-lg"
          />
        </div>
      )}
    </div>
  );
};

export default ProviderRequests;
