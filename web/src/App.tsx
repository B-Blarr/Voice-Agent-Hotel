import { useEffect, useState } from 'react';
import { RequestCard } from './components/RequestCard';
import type { BookingRequest, BookingStatus } from './types';
import { getCookie } from './utils/cookies';
import { formatStatus } from './utils/format';

const STATUS_FILTERS: BookingStatus[] = ['offen', 'bestaetigt', 'abgelehnt'];

export function App() {
  const [requests, setRequests] = useState<BookingRequest[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [statusFilter, setStatusFilter] = useState<BookingStatus>('offen');
  const today = new Date().toLocaleDateString('de-DE');

  useEffect(() => {
    async function loadRequests() {
      try {
        const response = await fetch(`/api/booking-requests/?status=${statusFilter}`);
        if (!response.ok) {
          console.error(`Loading the booking requests failed with status ${response.status}`);
          setError('Die Buchungsanfragen konnten nicht geladen werden.');
          return;
        }
        const data: BookingRequest[] = await response.json();
        setRequests(data);
      } finally {
        setIsLoading(false);
      }
    }
    loadRequests();
  }, [statusFilter]);

  async function changeStatus(id: number, status: BookingStatus) {
    const response = await fetch(`/api/booking-requests/${id}/`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRFToken': getCookie('csrftoken') ?? '',
      },
      body: JSON.stringify({ status }),
    });
    if (!response.ok) {
      console.error(
        `Changing the status of booking request ${id} failed with status ${response.status}`,
      );
      setError('Der Status konnte nicht geändert werden.');
      return;
    }
    setRequests((current) => current.filter((request) => request.id !== id));
  }

  return (
    <main>
      <h1>Hotel Elmblick</h1>
      <p>Teambereich</p>
      <p>Heute ist {today}</p>
      <div role="group" aria-label="Status">
        {STATUS_FILTERS.map((status) => (
          <button
            key={status}
            type="button"
            aria-pressed={status === statusFilter}
            onClick={() => setStatusFilter(status)}
          >
            {formatStatus(status)}
          </button>
        ))}
      </div>
      {isLoading && <p role="status">Die Buchungsanfragen werden geladen</p>}
      {error && <p role="alert">{error}</p>}
      {!isLoading && !error && requests.length === 0 && (
        <p role="status">Es gibt keine Buchungsanfragen</p>
      )}
      {requests.map((request) => (
        <RequestCard key={request.id} request={request} onStatusChange={changeStatus} />
      ))}
    </main>
  );
}
