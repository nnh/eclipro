import 'whatwg-fetch'

export default function fetchWithCors(url) {
  return fetch(url, {
    mode: 'cors',
    credentials: 'include'
  }).then((response) => {
    return response.json();
  });
}
