import React, { useState } from 'react';
import {
  BarChart, Bar,
  LineChart, Line,
  XAxis, YAxis, Tooltip,
  ResponsiveContainer
} from 'recharts';

const COLORS = ['#3b82f6', '#60a5fa', '#93c5fd'];

const TopCitiesByRevenue = ({ data }) => {
  const [view, setView] = useState('table');
  const podium = data.slice(0, 3);

  const podiumStyles = [
    { borderColor: '#FFD700', bgFrom: 'from-yellow-200', bgTo: 'to-yellow-50', text: 'text-yellow-800', emoji: '🥇', height: 'h-48' },
    { borderColor: '#C0C0C0', bgFrom: 'from-gray-200', bgTo: 'to-gray-100', text: 'text-gray-800', emoji: '🥈', height: 'h-40' },
    { borderColor: '#cd7f32', bgFrom: 'from-orange-200', bgTo: 'to-orange-100', text: 'text-orange-800', emoji: '🥉', height: 'h-36' },
  ];

  return (
    <div className="mt-12">
      <div className="bg-blue-600 text-white px-6 py-3 rounded-t-md shadow-md flex justify-between items-center">
        <div>
          <h3 className="text-lg font-semibold">Top Cities by Revenue</h3>
          <p className="text-sm text-blue-100">Top 3 Revenue-Generating Cities 💸</p>
        </div>
        <div className="flex gap-2">
          {['table', 'bar', 'line', 'podium'].map((v) => (
            <button
              key={v}
              onClick={() => setView(v)}
              className={`px-3 py-1 rounded ${view === v ? 'bg-white text-blue-600' : 'bg-blue-500'}`}
            >
              {v.charAt(0).toUpperCase() + v.slice(1)}
            </button>
          ))}
        </div>
      </div>

      <div className="bg-white rounded-b-md shadow-md p-6">
        {view === 'table' && (
          <div className="overflow-x-auto">
            <table className="min-w-full text-sm">
              <thead className="bg-blue-600 text-white">
                <tr>
                  <th className="px-4 py-2 text-left">Rank</th>
                  <th className="px-4 py-2 text-left">City</th>
                  <th className="px-4 py-2 text-left">Revenue</th>
                </tr>
              </thead>
              <tbody>
                {data.map((city, idx) => (
                  <tr key={idx} className="border-t hover:bg-gray-50">
                    <td className="px-4 py-2 font-medium">{idx + 1}</td>
                    <td className="px-4 py-2">{city.city}</td>
                    <td className="px-4 py-2">${parseFloat(city.total_revenue).toFixed(2)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {view === 'bar' && (
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={data}>
              <XAxis dataKey="city" />
              <YAxis />
              <Tooltip formatter={(value) => `$${parseFloat(value).toFixed(2)}`} />
              <Bar dataKey="total_revenue" fill="#3b82f6" />
            </BarChart>
          </ResponsiveContainer>
        )}

        {view === 'line' && (
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={data}>
              <XAxis dataKey="city" />
              <YAxis />
              <Tooltip formatter={(value) => `$${parseFloat(value).toFixed(2)}`} />
              <Line type="monotone" dataKey="total_revenue" stroke="#3b82f6" strokeWidth={3} />
            </LineChart>
          </ResponsiveContainer>
        )}

        {view === 'podium' && (
          <div className="flex justify-center items-end gap-6 mt-6">
            {podium.map((city, index) => (
              <div
                key={index}
                className={`w-32 ${podiumStyles[index].height} rounded-xl flex flex-col justify-end items-center p-4 bg-gradient-to-b ${podiumStyles[index].bgFrom} ${podiumStyles[index].bgTo}`}
                style={{
                  borderWidth: 4,
                  borderStyle: 'solid',
                  borderColor: podiumStyles[index].borderColor
                }}
              >
                <div className="text-2xl">{podiumStyles[index].emoji}</div>
                <div className={`font-semibold ${podiumStyles[index].text}`}>{city.city}</div>
                <div className={`text-sm ${podiumStyles[index].text}`}>${parseFloat(city.total_revenue).toFixed(2)}</div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default TopCitiesByRevenue;
