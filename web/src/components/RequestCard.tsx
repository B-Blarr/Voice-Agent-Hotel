import type { BookingRequest } from '../types';
import { formatCategory, formatDate, formatGuests } from '../utils/format';

type RequestCardProps = {
  request: BookingRequest;
};

/** Describes who is travelling, like "2 Erwachsene, 1 Kind, 1 Baby". Children and babies only appear if there are any. */
export function RequestCard({ request }: RequestCardProps) {
  return (
    <article>
      <h2>{formatCategory(request.category)}</h2>
      <p>
        {formatDate(request.arrival)} bis {formatDate(request.departure)}
      </p>
      <p>{request.name}</p>
      <p>{formatGuests(request.adults, request.children, request.babies)}</p>
      {request.accessible && <p>Barrierefrei</p>}
      {request.separate_beds && <p>Getrennte Betten</p>}
    </article>
  );
}
