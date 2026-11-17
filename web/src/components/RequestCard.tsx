type RequestCardProps = {
  category: string;
  guestName: string;
  arrival: string;
  departure: string;
};

export function RequestCard({ category, guestName, arrival, departure }: RequestCardProps) {
  return (
    <article>
      <h2>{category}</h2>
      <p>
        {arrival} bis {departure}
      </p>
      <p>{guestName}</p>
    </article>
  );
}
