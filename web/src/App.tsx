import { RequestCard } from './components/RequestCard';
import type { BookingRequest } from './types';

const exampleRequests: BookingRequest[] = [
  {
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
    phone: '+49 000 0000001',
    email: null,
    wishes: 'Waldblick, ruhiges Zimmer',
  },
  {
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
    phone: null,
    email: 'familie.muster@example.com',
    wishes: null,
  },
];

export function App() {
  const today = new Date().toLocaleDateString('de-DE');

  return (
    <main>
      <h1>Hotel Elmblick</h1>
      <p>Teambereich</p>
      <p>Heute ist {today}</p>
      {exampleRequests.map((request) => (
        <RequestCard key={request.id} request={request} />
      ))}
    </main>
  );
}
