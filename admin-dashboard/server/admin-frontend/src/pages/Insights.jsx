import React, { useEffect, useState } from 'react';
import axios from 'axios';
import {
  LineChart, Line, XAxis, YAxis, Tooltip,
  CartesianGrid, ResponsiveContainer
} from 'recharts';

const Insights = () => {
  const [summary, setSummary] = useState({});
  const [bestActivity, setBestActivity] = useState(null);
  const [revenueData, setRevenueData] = useState([]);
  const [revenueView, setRevenueView] = useState('monthly');

  useEffect(() => {
    axios.get(`${process.env.REACT_APP_API_URL}/admin/summary`).then(res => setSummary(res.data));
    axios.get(`${process.env.REACT_APP_API_URL}/admin/best-activity`).then(res => setBestActivity(res.data));
  }, []);

  useEffect(() => {
    axios
      .get(`${process.env.REACT_APP_API_URL}/admin/revenue?type=${revenueView}`)
      .then(res => {
        // Add a label key based on selected view (for X-axis)
        const labelKey = {
          daily: 'day',
          weekly: 'week',
          monthly: 'month',
          yearly: 'year'
        }[revenueView];

        const mappedData = res.data.map(item => ({
          label: item[labelKey],
          revenue: parseFloat(item.revenue)
        }));

        setRevenueData(mappedData);
      })
      .catch(err => console.error(err));
  }, [revenueView]);

  return (
    <div className="p-6 space-y-8">
      <h2 className="text-2xl font-bold text-gray-800">Admin Dashboard</h2>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6 mb-8">
        <div className="bg-white rounded-2xl shadow p-6 border border-blue-100 flex items-center gap-4">
          <div className="text-4xl text-blue-600">👤</div>
          <div>
            <p className="text-sm text-gray-500">Total Users</p>
            <h3 className="text-3xl font-bold text-blue-600 mt-1">{summary.totalUsers}</h3>
          </div>
        </div>
        <div className="bg-white rounded-2xl shadow p-6 border border-blue-100 flex items-center gap-4">
          <div className="text-4xl text-blue-600">🎯</div>
          <div>
            <p className="text-sm text-gray-500">Total Activities</p>
            <h3 className="text-3xl font-bold text-blue-600 mt-1">{summary.totalActivities}</h3>
          </div>
        </div>
        <div className="bg-white rounded-2xl shadow p-6 border border-blue-100 flex items-center gap-4">
          <div className="text-4xl text-blue-600">💰</div>
          <div>
            <p className="text-sm text-gray-500">Total Revenue</p>
            <h3 className="text-3xl font-bold text-blue-600 mt-1">${summary.totalRevenue}</h3>
          </div>
        </div>
      </div>

      {/* Best Activity */}
      <div className="bg-gradient-to-r from-blue-100 to-blue-200 border-l-4 border-blue-500 p-5 rounded-xl shadow-md">
        <div className="flex items-center gap-3">
          <span className="text-3xl">🏆</span>
          <div>
            <h3 className="text-lg font-semibold text-blue-800">Best Activity</h3>
            <p className="text-xl font-bold text-blue-600">{bestActivity?.name}</p>
            <span className="inline-block bg-blue-200 text-blue-800 text-sm font-medium px-3 py-1 rounded-full mt-1">
              {bestActivity?.bookings_count} Bookings
            </span>
          </div>
        </div>
      </div>

      {/* Revenue Chart */}
      <div className="bg-white p-4 rounded shadow">
        <div className="flex justify-between items-center mb-4">
          <p className="text-gray-600 font-medium">Revenue Overview</p>
          <div className="flex gap-2">
            {['daily', 'weekly', 'monthly', 'yearly'].map(view => (
              <button
                key={view}
                className={`px-3 py-1 rounded text-sm ${
                  revenueView === view
                    ? 'bg-blue-600 text-white'
                    : 'bg-gray-100 text-blue-600 hover:bg-gray-200'
                }`}
                onClick={() => setRevenueView(view)}
              >
                {view.charAt(0).toUpperCase() + view.slice(1)}
              </button>
            ))}
          </div>
        </div>

        <ResponsiveContainer width="100%" height={300}>
          <LineChart data={revenueData} margin={{ top: 10, right: 30, left: 0, bottom: 0 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
            <XAxis dataKey="label" stroke="#334155" />
            <YAxis stroke="#334155" tickFormatter={(value) => `$${value}`} />
            <Tooltip
              formatter={(value) => `$${value}`}
              contentStyle={{ backgroundColor: "#f9fafb", borderRadius: "0.5rem", borderColor: "#cbd5e1" }}
              labelStyle={{ color: "#1e293b" }}
            />
            <Line
              type="monotone"
              dataKey="revenue"
              stroke="#3b82f6"
              strokeWidth={3}
              dot={{ r: 5, stroke: "#1e3a8a", strokeWidth: 2 }}
              activeDot={{ r: 7 }}
            />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
};

export default Insights;
