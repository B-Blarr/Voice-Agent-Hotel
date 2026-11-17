import type { BookingRequest } from '../types';

type RequestCardProps = {
  request: BookingRequest;
};

export function RequestCard({ request }: RequestCardProps) {
  return (
    <article>
      <h2>{request.category}</h2>
      <p>
        {request.arrival} bis {request.departure}
      </p>
      <p>{request.name}</p>
      <p>{request.adults} Erwachsene</p>
      {request.accessible && <p>Barrierefrei</p>}
      {request.separate_beds && <p>Getrennte Betten</p>}
    </article>
  );
}
