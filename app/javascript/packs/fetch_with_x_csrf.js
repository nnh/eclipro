export default function fetchWithXCSRF(url, opts) {
  const token = document.querySelector('meta[name=csrf-token]').content;
  const newOpts = Object.assign({}, opts, { headers: Object.assign({}, opts.headers, { 'X-CSRF-Token': token }) });
  return fetch(url, newOpts);
}
