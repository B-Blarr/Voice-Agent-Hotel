import type { BookingStatus } from '../types';

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

const STATUS_LABELS: Record<BookingStatus, string> = {
  offen: 'Offen',
  bestaetigt: 'Bestätigt',
  abgelehnt: 'Abgelehnt',
};

export function formatStatus(status: BookingStatus): string {
  return STATUS_LABELS[status];
}

/** Describes who is travelling, like "2 Erwachsene, 1 Kind, 1 Baby". Children and babies only appear if there are any. */
export function formatGuests(adults: number, children: number, babies: number): string {
  const parts: string[] = [];
  parts.push(`${adults} ${adults === 1 ? 'Erwachsener' : 'Erwachsene'}`);
  if (children > 0) {
    parts.push(`${children} ${children === 1 ? 'Kind' : 'Kinder'}`);
  }
  if (babies > 0) {
    parts.push(`${babies} ${babies === 1 ? 'Baby' : 'Babys'}`);
  }
  return parts.join(', ');
}
