export type BookingRequest = {
  id: number;
  category: string;
  arrival: string;
  departure: string;
  adults: number;
  children: number;
  babies: number;
  separate_beds: boolean;
  accessible: boolean;
  name: string;
  phone: string | null;
  email: string | null;
  wishes: string | null;
};
