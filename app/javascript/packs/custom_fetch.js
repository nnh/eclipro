import 'whatwg-fetch'

const baseOpts = {
  mode: 'cors',
  credentials: 'include'
}

export function fetchWithCors(url) {
  return fetch(url, baseOpts).then((r) => r.json());
}

export function fetchByJSON(url, method, body) {
  const addOpts = {
    method: method,
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(body)
  };
  return fetchWithXCSRF(url, Object.assign({}, baseOpts, addOpts)).then((r) => r.json());
}

export function fetchWithXCSRF(url, opts) {
  const token = document.querySelector('meta[name=csrf-token]').content;
  const newOpts = Object.assign({}, opts, { headers: Object.assign({}, opts.headers, { 'X-CSRF-Token': token }) });
  return fetch(url, newOpts);
}
