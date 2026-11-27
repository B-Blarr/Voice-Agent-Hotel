/** Reads a cookie by name, or returns null if the browser has no such cookie. */
export function getCookie(name: string): string | null {
  const prefix = `${name}=`;
  const cookie = document.cookie.split('; ').find((entry) => entry.startsWith(prefix));
  return cookie ? decodeURIComponent(cookie.slice(prefix.length)) : null;
}
