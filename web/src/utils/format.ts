/** Turns an ISO date like 2027-11-20 into the German format 20.11.2027. */
export function formatDate(isoDate: string): string {
  const [year, month, day] = isoDate.split('-');
  return `${day}.${month}.${year}`;
}

const CATEGORY_LABELS: Record<string, string> = {
  einzelzimmer: 'Einzelzimmer',
  doppelzimmer: 'Doppelzimmer',
  suite: 'Suite',
};

/** Turns a room category code like doppelzimmer into its name, or keeps the code if it is unknown. */
export function formatCategory(category: string): string {
  return CATEGORY_LABELS[category] ?? category;
}
