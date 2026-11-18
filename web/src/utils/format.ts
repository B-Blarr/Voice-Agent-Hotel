/** Turns an ISO date like 2027-11-20 into the German format 20.11.2027. */
export function formatDate(isoDate: string): string {
  const [year, month, day] = isoDate.split('-');
  return `${day}.${month}.${year}`;
}
