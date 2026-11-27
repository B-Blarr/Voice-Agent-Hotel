import type { BookingRequest } from '../types';
import { formatCategory, formatDate, formatGuests, formatStatus } from '../utils/format';
import { useState } from 'react';

type RequestCardProps = {
  request: BookingRequest;
};

/** Describes who is travelling, like "2 Erwachsene, 1 Kind, 1 Baby". Children and babies only appear if there are any. */
export function RequestCard({ request }: RequestCardProps) {
  const [showDetails, setShowDetails] = useState(false);
  return (
    <article>
      <h2>{formatCategory(request.category)}</h2>
      <p>
        {formatDate(request.arrival)} bis {formatDate(request.departure)}
      </p>
      <p>{request.name}</p>
      <p>Status: {formatStatus(request.status)}</p>
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
