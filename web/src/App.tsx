import { RequestCard } from './components/RequestCard';

export function App() {
  const today = new Date().toLocaleDateString('de-DE');

  return (
    <main>
      <h1>Hotel Elmblick</h1>
      <p>Teambereich</p>
      <p>Heute ist {today}</p>
      <RequestCard
        category="Doppelzimmer"
        guestName="Anna Beispiel"
        arrival="20.11.2027"
        departure="22.11.2027"
      />
      <RequestCard
        category="Suite"
        guestName="Familie Muster"
        arrival="03.12.2027"
        departure="05.12.2027"
      />
    </main>
  );
}
