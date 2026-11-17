function App() {
  const heute = new Date().toLocaleDateString('de-DE')

  return (
    <main>
      <h1>Hotel Elmblick</h1>
      <p>Teambereich</p>
      <p>Heute ist {heute}</p>
    </main>
  )
}

export default App