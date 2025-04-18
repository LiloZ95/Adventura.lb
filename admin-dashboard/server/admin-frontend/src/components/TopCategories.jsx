import React, { useState } from 'react';
import {
  BarChart, Bar,
  LineChart, Line,
  XAxis, YAxis, Tooltip, Legend,
  ResponsiveContainer
} from 'recharts';

const COLORS = ['#3b82f6', '#60a5fa', '#93c5fd', '#bfdbfe', '#dbeafe'];

const TopCategories = ({ data }) => {
  const [view, setView] = useState('table'); // 'table', 'bar', 'line', 'pie', 'podium'
  if (!data || data.length === 0) return null;

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
          <h3 className="text-lg font-semibold">Top Categories by Activity Count</h3>
          <p className="text-sm text-blue-100">Most popular activity categories</p>
        </div>
        <div className="flex gap-2 flex-wrap">
          {['table', 'bar', 'line', 'podium'].map(v => (
            <button
              key={v}
              className={`px-3 py-1 rounded ${view === v ? 'bg-white text-blue-600' : 'bg-blue-500'}`}
              onClick={() => setView(v)}
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
                  <th className="px-4 py-2 text-left">Category</th>
                  <th className="px-4 py-2 text-left">Activity Count</th>
                </tr>
              </thead>
              <tbody>
                {data.map((cat, idx) => (
                  <tr key={idx} className="border-t hover:bg-gray-50">
                    <td className="px-4 py-2 font-medium">{idx + 1}</td>
                    <td className="px-4 py-2">{cat.category_name}</td>
                    <td className="px-4 py-2">{cat.activity_count}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {view === 'bar' && (
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={data}>
              <XAxis dataKey="category_name" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="activity_count" fill="#3b82f6" />
            </BarChart>
          </ResponsiveContainer>
        )}

        {view === 'line' && (
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={data}>
              <XAxis dataKey="category_name" />
              <YAxis />
              <Tooltip />
              <Line type="monotone" dataKey="activity_count" stroke="#3b82f6" strokeWidth={3} dot={{ r: 5 }} />
            </LineChart>
          </ResponsiveContainer>
        )}


        {view === 'podium' && (
          <div className="flex justify-center items-end gap-6 mt-6">
            {podium.map((cat, index) => (
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
                <div className={`font-semibold ${podiumStyles[index].text}`}>{cat?.category_name}</div>
                <div className={`text-sm ${podiumStyles[index].text}`}>{cat?.activity_count} activities</div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default TopCategories;
