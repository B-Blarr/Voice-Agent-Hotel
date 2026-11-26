import { useEffect, useState } from 'react';
import { RequestCard } from './components/RequestCard';
import type { BookingRequest } from './types';

export function App() {
  const [requests, setRequests] = useState<BookingRequest[]>([]);
  const today = new Date().toLocaleDateString('de-DE');

  useEffect(() => {
    async function loadRequests() {
      const response = await fetch('/api/booking-requests/');
      if (!response.ok) {
        console.error(`Loading the booking requests failed with status ${response.status}`);
        return;
      }
      const data: BookingRequest[] = await response.json();
      setRequests(data);
    }

    loadRequests();
  }, []);

  return (
    <main>
      <h1>Hotel Elmblick</h1>
      <p>Teambereich</p>
      <p>Heute ist {today}</p>
      {requests.map((request) => (
        <RequestCard key={request.id} request={request} />
      ))}
    </main>
  );
}
