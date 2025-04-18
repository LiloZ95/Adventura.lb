import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { PieChart, Pie, Cell, Tooltip, Legend } from 'recharts';
import TopProviders from '../components/TopProviders';
import TopClients from '../components/TopClients';
import TopCategories from '../components/TopCategories';
import TopCategoriesByRevenue from '../components/TopCategoriesByRevenue';

const COLORS = ['#3b82f6', '#60a5fa', '#93c5fd', '#bfdbfe', '#dbeafe'];

const AdvancedInsights = () => {
  const [cities, setCities] = useState([]);
  const [citiesByRevenue, setCitiesByRevenue] = useState([]);
  const [topProviders, setTopProviders] = useState([]);
  const [topClients, setTopClients] = useState([]);
  const [topCategories, setTopCategories] = useState([]);
  const [topCategoriesByRevenue, setTopCategoriesByRevenue] = useState([]);
  const [categoryView, setCategoryView] = useState('booking');
  const [cityView, setCityView] = useState('count'); // 👈 city toggle

  useEffect(() => {
    axios.get(`${process.env.REACT_APP_API_URL}/admin/top-cities`).then(res => setCities(res.data));
    axios.get(`${process.env.REACT_APP_API_URL}/admin/top-cities-revenue`).then(res => setCitiesByRevenue(res.data));
    axios.get(`${process.env.REACT_APP_API_URL}/admin/top-providers`).then(res => setTopProviders(res.data));
    axios.get(`${process.env.REACT_APP_API_URL}/admin/top-clients`).then(res => setTopClients(res.data));
    axios.get(`${process.env.REACT_APP_API_URL}/admin/top-categories`).then(res => setTopCategories(res.data));
    axios.get(`${process.env.REACT_APP_API_URL}/admin/top-categories-revenue`).then(res => setTopCategoriesByRevenue(res.data));
  }, []);

  const pieData =
    cityView === 'count'
      ? cities.map(city => ({ name: city.city, value: parseInt(city.count) }))
      : citiesByRevenue.map(city => ({ name: city.city, value: parseFloat(city.total_revenue) }));

  return (
    <div className="p-6">
      {/* 📍 Top Cities */}
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-2xl font-bold text-gray-800">Top Cities</h2>
        <div className="flex gap-2">
          <button
            className={`px-4 py-1 rounded ${cityView === 'count' ? 'bg-blue-600 text-white' : 'bg-gray-100 text-blue-600'}`}
            onClick={() => setCityView('count')}
          >
            By Activity Count
          </button>
          <button
            className={`px-4 py-1 rounded ${cityView === 'revenue' ? 'bg-blue-600 text-white' : 'bg-gray-100 text-blue-600'}`}
            onClick={() => setCityView('revenue')}
          >
            By Revenue
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-12">
        {/* Table */}
        <div className="bg-white shadow-md rounded-md overflow-hidden">
          <table className="min-w-full text-sm">
            <thead className="bg-blue-600 text-white">
              <tr>
                <th className="px-4 py-2 text-left">City</th>
                <th className="px-4 py-2 text-left">{cityView === 'count' ? 'Activity Count' : 'Total Revenue ($)'}</th>
              </tr>
            </thead>
            <tbody>
              {(cityView === 'count' ? cities : citiesByRevenue).map((city, idx) => (
                <tr key={idx} className="border-t hover:bg-gray-50">
                  <td className="px-4 py-2 font-medium text-gray-800">{city.city}</td>
                  <td className="px-4 py-2">
                    {cityView === 'count' ? city.count : parseFloat(city.total_revenue).toFixed(2)}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Pie Chart */}
        <div className="bg-white shadow-md rounded-md p-4 flex justify-center items-center">
          <PieChart width={300} height={300}>
            <Pie
              data={pieData}
              cx="50%"
              cy="50%"
              outerRadius={100}
              label
              dataKey="value"
            >
              {pieData.map((_, index) => (
                <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
              ))}
            </Pie>
            <Tooltip />
            <Legend />
          </PieChart>
        </div>
      </div>

      {/* 🏆 Top Performers */}
      <h2 className="text-2xl font-bold text-gray-800 mb-4">Top Performers</h2>
      <div className="flex flex-col gap-10 mb-12">
        <TopProviders data={topProviders} />
        <TopClients data={topClients} />
      </div>

      {/* 🧩 Top Categories (Toggle) */}
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-2xl font-bold text-gray-800">Top Categories</h2>
        <div className="flex gap-2">
          <button
            className={`px-4 py-1 rounded ${categoryView === 'booking' ? 'bg-blue-600 text-white' : 'bg-gray-100 text-blue-600'}`}
            onClick={() => setCategoryView('booking')}
          >
            By Booking
          </button>
          <button
            className={`px-4 py-1 rounded ${categoryView === 'revenue' ? 'bg-blue-600 text-white' : 'bg-gray-100 text-blue-600'}`}
            onClick={() => setCategoryView('revenue')}
          >
            By Revenue
          </button>
        </div>
      </div>

      {categoryView === 'booking' && <TopCategories data={topCategories} />}
      {categoryView === 'revenue' && <TopCategoriesByRevenue data={topCategoriesByRevenue} />}
    </div>
  );
};

export default AdvancedInsights;
