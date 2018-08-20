import fetchWithXCSRF from './fetch_with_x_csrf'

export default function fetchByJSON(url, method, body) {
  const opts = {
    mode: 'cors',
    credentials: 'include',
    method: method,
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(body)
  };
  return fetchWithXCSRF(url, opts).then((r) => r.json());
}
