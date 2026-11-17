import { RequestCard } from './components/RequestCard';
import type { BookingRequest } from './types';

const firstRequest: BookingRequest = {
  id: 1,
  category: 'doppelzimmer',
  arrival: '2027-11-20',
  departure: '2027-11-22',
  adults: 2,
  children: 0,
  babies: 0,
  separate_beds: true,
  accessible: false,
  name: 'Anna Beispiel',
};

const secondRequest: BookingRequest = {
  id: 2,
  category: 'suite',
  arrival: '2027-12-03',
  departure: '2027-12-05',
  adults: 2,
  children: 1,
  babies: 1,
  separate_beds: false,
  accessible: true,
  name: 'Familie Muster',
};

export function App() {
  const today = new Date().toLocaleDateString('de-DE');

  return (
    <main>
      <h1>Hotel Elmblick</h1>
      <p>Teambereich</p>
      <p>Heute ist {today}</p>
      <RequestCard request={firstRequest} />
      <RequestCard request={secondRequest} />
    </main>
  );
}
