import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { saveAs } from 'file-saver';
import jsPDF from 'jspdf';
import 'jspdf-autotable';

const Transactions = () => {
  const [payments, setPayments] = useState([]);
  const [filtered, setFiltered] = useState([]);
  const [statusFilter, setStatusFilter] = useState('all');
  const [selected, setSelected] = useState([]);
  const [modalData, setModalData] = useState(null);

  useEffect(() => {
    axios.get(`${process.env.REACT_APP_API_URL}/admin/transactions`)
      .then(res => {
        setPayments(res.data);
        setFiltered(res.data);
      });
  }, []);

  useEffect(() => {
    if (statusFilter === 'all') {
      setFiltered(payments);
    } else {
      setFiltered(payments.filter(p => p.payment_status === statusFilter));
    }
    setSelected([]);
  }, [statusFilter, payments]);

  const toggleSelect = (id) => {
    setSelected(prev =>
      prev.includes(id) ? prev.filter(i => i !== id) : [...prev, id]
    );
  };

  const downloadCSV = () => {
    const headers = ['Payment ID', 'Client', 'Amount', 'Date', 'Status', 'Booking ID'];
    const rows = filtered
      .filter(p => selected.includes(p.payment_id))
      .map(p => [p.payment_id, p.client_name, `$${parseFloat(p.amount).toFixed(2)}`, p.payment_date, p.payment_status, p.booking_id]);

    const csv = [headers, ...rows].map(row => row.join(',')).join('\n');
    const blob = new Blob([csv], { type: 'text/csv' });
    saveAs(blob, 'selected-transactions.csv');
  };

  const downloadPDF = () => {
    const doc = new jsPDF();
    const rows = filtered
      .filter(p => selected.includes(p.payment_id))
      .map(p => [p.payment_id, p.client_name, `$${parseFloat(p.amount).toFixed(2)}`, p.payment_date, p.payment_status, p.booking_id]);

    doc.autoTable({
      head: [['Payment ID', 'Client', 'Amount', 'Date', 'Status', 'Booking ID']],
      body: rows
    });
    doc.save('selected-transactions.pdf');
  };

  return (
    <div className="p-6">
      <h2 className="text-2xl font-bold text-gray-800 mb-6">💸 Transactions</h2>

      <div className="mb-4 flex gap-2 flex-wrap">
        {['all', 'paid', 'failed', 'refunded'].map(status => (
          <button
            key={status}
            className={`px-3 py-1 rounded ${
              statusFilter === status ? 'bg-blue-600 text-white' : 'bg-gray-200 text-blue-600'
            }`}
            onClick={() => setStatusFilter(status)}
          >
            {status.charAt(0).toUpperCase() + status.slice(1)}
          </button>
        ))}
        {selected.length > 0 && (
          <>
            <button onClick={downloadCSV} className="px-3 py-1 rounded bg-green-600 text-white">Download CSV</button>
            <button onClick={downloadPDF} className="px-3 py-1 rounded bg-red-600 text-white">Download PDF</button>
          </>
        )}
      </div>

      <div className="overflow-x-auto bg-white rounded-md shadow-md">
        <table className="min-w-full text-sm">
          <thead className="bg-blue-600 text-white">
            <tr>
              <th className="px-4 py-2">
                <input
                  type="checkbox"
                  onChange={e => {
                    if (e.target.checked) {
                      setSelected(filtered.map(p => p.payment_id));
                    } else {
                      setSelected([]);
                    }
                  }}
                  checked={selected.length === filtered.length && filtered.length > 0}
                />
              </th>
              <th className="px-4 py-2 text-left">Payment ID</th>
              <th className="px-4 py-2 text-left">Client</th>
              <th className="px-4 py-2 text-left">Amount</th>
              <th className="px-4 py-2 text-left">Date</th>
              <th className="px-4 py-2 text-left">Status</th>
              <th className="px-4 py-2 text-left">Booking ID</th>
            </tr>
          </thead>
          <tbody>
            {filtered.map((p, i) => (
              <tr
                key={i}
                className={`border-t hover:bg-gray-50 cursor-pointer ${selected.includes(p.payment_id) ? 'bg-blue-50' : ''}`}
                onClick={() => setModalData(p)}
              >
                <td className="px-4 py-2">
                  <input
                    type="checkbox"
                    checked={selected.includes(p.payment_id)}
                    onClick={e => e.stopPropagation()}
                    onChange={() => toggleSelect(p.payment_id)}
                  />
                </td>
                <td className="px-4 py-2">{p.payment_id}</td>
                <td className="px-4 py-2">{p.client_name}</td>
                <td className="px-4 py-2">${parseFloat(p.amount).toFixed(2)}</td>
                <td className="px-4 py-2">{p.payment_date}</td>
                <td className="px-4 py-2">{p.payment_status}</td>
                <td className="px-4 py-2">{p.booking_id}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Modal View */}
      {modalData && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex justify-center items-center z-50">
          <div className="bg-white p-6 rounded-lg shadow-lg w-full max-w-lg">
            <h3 className="text-xl font-bold mb-4 text-blue-700">Transaction Details</h3>
            <div className="space-y-2 text-sm text-gray-700">
              <p><strong>Payment ID:</strong> {modalData.payment_id}</p>
              <p><strong>Client:</strong> {modalData.client_name}</p>
              <p><strong>Amount:</strong> ${parseFloat(modalData.amount).toFixed(2)}</p>
              <p><strong>Status:</strong> {modalData.payment_status}</p>
              <p><strong>Date:</strong> {modalData.payment_date}</p>
              <p><strong>Booking ID:</strong> {modalData.booking_id}</p>
              <p><strong>Client ID:</strong> {modalData.client_id}</p>
            </div>
            <div className="mt-4 flex justify-end">
              <button
                onClick={() => setModalData(null)}
                className="bg-blue-600 text-white px-4 py-2 rounded"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Transactions;
