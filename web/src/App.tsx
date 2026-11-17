import {RequestCard} from "./components/RequestCard"

export function App() {
  const today = new Date().toLocaleDateString('de-DE')

  return (
    <main>
      <h1>Hotel Elmblick</h1>
      <p>Teambereich</p>
      <p>Heute ist {today}</p>
      <RequestCard />
      <RequestCard />
    </main>
  )
}
