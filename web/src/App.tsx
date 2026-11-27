import { useEffect, useState } from 'react';
import { RequestCard } from './components/RequestCard';
import type { BookingRequest } from './types';

export function App() {
  const [requests, setRequests] = useState<BookingRequest[]>([]);
  const [error, setError] = useState<string | null>(null);
  const today = new Date().toLocaleDateString('de-DE');

  useEffect(() => {
    async function loadRequests() {
      const response = await fetch('/api/booking-requests/');
      if (!response.ok) {
        console.error(`Loading the booking requests failed with status ${response.status}`);
        setError('Die Buchungsanfragen konnten nicht geladen werden.')
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
      {error && <p role="alert">{error}</p>}
      {requests.map((request) => (
        <RequestCard key={request.id} request={request} />
      ))}
    </main>
  );
}
