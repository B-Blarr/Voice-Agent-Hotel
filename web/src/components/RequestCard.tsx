import type { BookingRequest } from '../types';
import { formatCategory, formatDate } from '../utils/format';

type RequestCardProps = {
  request: BookingRequest;
};

export function RequestCard({ request }: RequestCardProps) {
  return (
    <article>
      <h2>{formatCategory(request.category)}</h2>
      <p>
        {formatDate(request.arrival)} bis {formatDate(request.departure)}
      </p>
      <p>{request.name}</p>
      <p>{request.adults} Erwachsene</p>
      {request.accessible && <p>Barrierefrei</p>}
      {request.separate_beds && <p>Getrennte Betten</p>}
    </article>
  );
}
