import type { BookingRequest, BookingStatus } from '../types';
import { formatCategory, formatDate, formatGuests, formatStatus } from '../utils/format';
import { useState } from 'react';

type RequestCardProps = {
  request: BookingRequest;
  onStatusChange: (id: number, status: BookingStatus) => void;
};

/** Shows one booking request and lets the team confirm or decline it while it is open. */
export function RequestCard({ request, onStatusChange }: RequestCardProps) {
  const [showDetails, setShowDetails] = useState(false);
  return (
    <article>
      <h2>{formatCategory(request.category)}</h2>
      <p>
        {formatDate(request.arrival)} bis {formatDate(request.departure)}
      </p>
      <p>{request.name}</p>
      <p>Status: {formatStatus(request.status)}</p>
      {request.status === 'offen' && (
        <div>
          <button type="button" onClick={() => onStatusChange(request.id, 'bestaetigt')}>
            Bestätigen
          </button>
          <button type="button" onClick={() => onStatusChange(request.id, 'abgelehnt')}>
            Ablehnen
          </button>
        </div>
      )}
      <p>{formatGuests(request.adults, request.children, request.babies)}</p>
      {request.accessible && <p>Barrierefrei</p>}
      {request.separate_beds && <p>Getrennte Betten</p>}
      <button type="button" onClick={() => setShowDetails(!showDetails)}>
        {showDetails ? 'Details ausblenden' : 'Details anzeigen'}
      </button>
      {showDetails && (
        <div>
          {request.phone && <p>Telefon: {request.phone}</p>}
          {request.email && <p>E-Mail: {request.email}</p>}
          {request.wishes && <p>Wünsche: {request.wishes}</p>}
        </div>
      )}
    </article>
  );
}
