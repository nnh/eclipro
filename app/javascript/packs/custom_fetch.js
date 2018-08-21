import 'whatwg-fetch'

const baseOpts = {
  mode: 'cors',
  credentials: 'include'
}

export function fetchWithCors(url) {
  return fetch(url, baseOpts).then((r) => r.json());
}

export function fetchByJSON(url, method, body) {
  const opts = {
    method: method,
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(body)
  };
  return fetchWithXCSRF(url, opts);
}

export function fetchWithXCSRF(url, opts) {
  const token = document.querySelector('meta[name=csrf-token]').content;
  const newOpts = Object.assign({}, baseOpts, opts, { headers: Object.assign({}, opts.headers, { 'X-CSRF-Token': token }) });
  return fetch(url, newOpts).then((r) => r.json());
}
